# MAKEFILE for simple-go-helloworld

.DEFAULT_GOAL: help

# These are the onyl variables to change in the Makefile. 
# Everything else is generic
APP_NAME=simple-go-helloworld
MODULE_NAME=github.com/apenella/$(APP_NAME)
LISTEN_ADDRESS=8080

# os name and arch
OS_NAME=$(shell go env GOOS)
OS_ARCH=$(shell go env GOARCH)

BIN_DIR=$(PWD)/.bin
export PATH:=$(PATH):$(BIN_DIR):DEP_DIR

BINARY_NAME=$(APP_NAME)_$(OS_NAME)_$(OS_ARCH)
ifeq ($(OS_NAME),windows)
	BINARY_NAME=$(APP_NAME)_$(OS_NAME)_$(OS_ARCH).exe
endif

APP_VERSION=$(shell git describe --tags --abbrev=0 || cat version)
COMMIT_SHA=$(shell git rev-parse --short HEAD || echo "unknown")

LDFLAGS=-ldflags "-X $(MODULE_NAME)/release.Version=$(APP_VERSION) -X $(MODULE_NAME)/release.Commit=$(COMMIT_SHA)"

help: ## Lists available targets
	@echo
	@echo "Makefile usage:"
	@grep -E '^[a-zA-Z1-9_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[1;32m%-20s\033[0m %s\n", $$1, $$2}' | sort
	@echo

init: ## Initialize the project
	go mod init $(MODULE_NAME) || true
	mkdir -p $(BIN_DIR)

update: ## Update dependencies
	go get -u ./...

modules: ## Handle module dependencies
	go mod tidy
	go mod verify	

clean: ## Clean the project
	rm -rf $(BIN_DIR)

test: modules ## Execute tests
	go test ./... -count=1 -v

build-binary: test clean modules ## Build application binary
	CGO_ENABLED=0 GOOS=$(OS_NAME) GOARCH=$(OS_ARCH) go build ${LDFLAGS} -a -o $(BIN_DIR)/${BINARY_NAME} .

build-docker: build-binary ## Create a docker image to run the binary
	docker build --build-arg listen_port=$(LISTEN_ADDRESS) --tag $(APP_NAME):$(APP_VERSION) .

run: ## Run the application in a container
	docker run --rm --name $(APP_NAME) -p 80:$(LISTEN_ADDRESS) $(APP_NAME):$(APP_VERSION) --listen-port ":$(LISTEN_ADDRESS)"

build-run: build-docker run ## Build and run the application

stop: ## Stop the application
	docker stop $(APP_NAME)
