# MAKEFILE for simple-go-helloworld

.DEFAULT_GOAL: print

# These are the onyl variables to change in the Makefile. 
# Everything else is generic
APP_NAME=simple-go-helloworld
MODULE_NAME=github.com/apenella/simple-go-helloworld
LISTEN_ADDRESS=8080

# os name and arch
OS_NAME=$(shell go env GOOS)
OS_ARCH=$(shell go env GOARCH)

BIN_ROOT=$(PWD)/.bin
DEP_ROOT=$(PWD)/.dep
export PATH:=$(PATH):$(BIN_ROOT):DEP_ROOT

BINARY_NATIVE=$(APP_NAME)_$(OS_NAME)_$(OS_ARCH)
ifeq ($(OS_NAME),windows)
	BINARY_NATIVE=$(APP_NAME)_$(OS_NAME)_$(OS_ARCH).exe
endif
BINARY_NATIVE_WHICH=$(shell command -v $(BINARY_NATIVE))

BINARY_DOCKER=$(APP_NAME)_linux_amd64
BINARY_DOCKER_WHICH=$(shell command -v $(BINARY_DOCKER))

VERSION_SEMVAR=version_semver
VERSION_COMMIT=version_commit

VERSION=$(shell cat $(VERSION_SEMVAR))
COMMIT=$(shell git rev-parse --short HEAD || echo "unknown")

LDFLAGS=-ldflags "-X $(MODULE_NAME)/release.Version=${VERSION} -X $(MODULE_NAME)/release.Commit=${COMMIT}"

print:
	@echo ""
	@echo "APP_NAME:              $(APP_NAME)"
	@echo "MODULE_NAME:           $(MODULE_NAME)"
	@echo "LISTEN_ADDRESS:        $(LISTEN_ADDRESS)"
	@echo ""
	@echo "OS_NAME:                $(OS_NAME)"
	@echo "OS_ARCH:                $(OS_ARCH)"
	@echo ""
	@echo "BIN_ROOT:               $(BIN_ROOT)"
	@echo "DEP_ROOT:               $(DEP_ROOT)"
	@echo ""
	@echo "BINARY_NATIVE:          $(BINARY_NATIVE)"
	@echo "BINARY_NATIVE_WHICH:    $(BINARY_NATIVE_WHICH)"
	@echo ""
	@echo "BINARY_DOCKER:          $(BINARY_DOCKER)"
	@echo "BINARY_DOCKER_WHICH:    $(BINARY_DOCKER_WHICH)"
	@echo ""
	@echo "VERSION:                $(VERSION)"
	@echo "COMMIT:                 $(COMMIT)"
	@echo "LDFLAGS:                $(LDFLAGS)"
	@echo ""

# build the binary and deploy a container with it
all: dep bin-all docker-all

# build a clean image an container
docker-all: docker-image-clean docker-image docker-container

dep: dep-bin
	go get -u github.com/stretchr/testify/assert
dep-init:
	mkdir -p $(DEP_ROOT)
dep-del:
	rm -rf $(DEP_ROOT)
dep-bin: dep-init
	# bins that we need 
	# https://github.com/google/gops
	# https://github.com/google/gops/releases/tag/v0.3.28
	go install github.com/google/gops@v0.3.28
	cp $(GOPATH)/bin/gops $(DEP_ROOT)/gops
	#rm -f $(GOPATH)/bin/gops


mod-tidy:
	go mod tidy
mod-up:
	go mod tidy
	go run github.com/oligot/go-mod-upgrade@latest
	go mod tidy


bin-all: bin-clean bin-init bin-native bin-docker
bin-init:
	mkdir -p $(BIN_ROOT)
bin-clean:
	rm -rf $(BIN_ROOT)
bin-version:
	# calculate it
	rm -f $(VERSION_COMMIT)
	@echo $(COMMIT) >> version_commit
bin-native: bin-init dep bin-version
	# for devs
	cp version_commit $(BIN_ROOT)/${BINARY_NATIVE}_version_commit
	cp version_semver $(BIN_ROOT)/${BINARY_NATIVE}_version_semver

	CGO_ENABLED=0 GOOS=$(OS_NAME) GOARCH=$(OS_ARCH) go build ${LDFLAGS} -a -o $(BIN_ROOT)/${BINARY_NATIVE} .
bin-docker: bin-init dep bin-version
	# for docker
	cp version_commit $(BIN_ROOT)/${BINARY_DOCKER}_version_commit
	cp version_semver $(BIN_ROOT)/${BINARY_DOCKER}_version_semver
	CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build ${LDFLAGS} -a -o $(BIN_ROOT)/${BINARY_DOCKER} .

run-native:
	@echo "http://localhost:$(LISTEN_ADDRESS)"
	
	$(BINARY_NATIVE)
run-docker:

run-gops:
	gops

curl:
	curl http://localhost:8080/

# execute all tests
test: dep
	go test ./...

# create a docker image to run the binary
docker-image:
	docker buildx build --tag ${APP_NAME} --tag ${APP_NAME}:${VERSION} .
# create a container to run the binary.
docker-container:
	docker run --rm --detach --name ${APP_NAME} -p 80:$(LISTEN_ADDRESS) ${APP_NAME}
# clean the containers
docker-container-clean:
	docker ps -a | grep ${APP_NAME} | tr -s ' ' | cut -d " " -f1 | while read c; do docker stop $$c; docker rm -v $$c; done
# clear docker images
docker-image-clean: docker-container-clean
	docker images | grep $(APP_NAME) | tr -s ' ' | cut -d " " -f2 | while read t; do docker rmi ${APP_NAME}:$$t; done
