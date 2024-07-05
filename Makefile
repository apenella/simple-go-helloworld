# MAKEFILE for simple-go-helloworld

NAME=simple-go-helloworld

# os name and arch
OS_NAME=$(shell go env GOOS)
OS_ARCH=$(shell go env GOARCH)

BIN_ROOT=$(PWD)/.bin
export PATH:=$(PATH):$(BIN_ROOT)

BINARY_NATIVE=$(NAME)_$(OS_NAME)_$(OS_ARCH)
ifeq ($(OS_NAME),windows)
	BINARY_NATIVE=$(NAME)_$(OS_NAME)_$(OS_ARCH).exe
endif
BINARY_NATIVE_WHICH=$(shell command -v $(BINARY_NATIVE))

BINARY_DOCKER=$(NAME)_linux_amd64
BINARY_DOCKER_WHICH=$(shell command -v $(BINARY_DOCKER))

VERSION=`cat version`
COMMIT=`git rev-parse --short HEAD || echo "unknown"`

LDFLAGS=-ldflags "-X simple-go-helloworld/release.Version=${VERSION} -X simple-go-helloworld/release.Commit=${COMMIT}"

print:
	@echo ""
	@echo "NAME:                   $(NAME)"
	@echo ""
	@echo "OS_NAME:                $(OS_NAME)"
	@echo "OS_ARCH:                $(OS_ARCH)"
	@echo ""
	@echo "BIN_ROOT:               $(BIN_ROOT)"
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

.DEFAULT_GOAL: print

# define phony targets
.PHONY: clean install build-native build-linux docker-container docker-container-clear docker-image test dep

# build the binary and deploy a container with it
all: build-native build-linux docker

dep:
	go get -u github.com/stretchr/testify/assert

# build a clean image an container
docker: docker-image-clean docker-image docker-container

bin-init:
	mkdir -p $(BIN_ROOT)
bin-del:
	rm -rf $(BIN_ROOT)


build-all: bin-init build-native build-docker
build-native: bin-init dep
	# for devs
	CGO_ENABLED=0 GOOS=$(OS_NAME) GOARCH=$(OS_ARCH) go build ${LDFLAGS} -a -o $(BIN_ROOT)/${BINARY_NATIVE} .
build-docker: bin-init dep
	# for docker
	CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build ${LDFLAGS} -a -o $(BIN_ROOT)/${BINARY_DOCKER} .

run-native:
	$(BINARY_NATIVE)

# execute all tests
test: dep
	go test ./...

# create a docker image to run the binary
docker-image:
	docker buildx build --tag ${NAME} --tag ${NAME}:${VERSION} .
# create a container to run the binary.
docker-container:
	docker run -d --name ${NAME} -p 80:80 ${NAME}
# clean the containers
docker-container-clean:
	docker ps -a | grep ${NAME} | tr -s ' ' | cut -d " " -f1 | while read c; do docker stop $$c; docker rm -v $$c; done
# clear docker images
docker-image-clean: docker-container-clean
	docker images | grep $(NAME) | tr -s ' ' | cut -d " " -f2 | while read t; do docker rmi ${NAME}:$$t; done
