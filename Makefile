PWD = $(shell pwd -L)
GO_CMD=go
DOCKER_CMD=docker
DOCKER_COMPOSE_CMD=docker-compose
GO_TEST=$(GO_CMD) test
PATH_DOCKER_COMPOSE_FILE=docker-compose.yaml

.PHONY: docker-compose-up docker-compose-down docker-compose-restart

all: help

help: ## Display help screen
	@echo "Usage:"
	@echo "	make [COMMAND]"
	@echo "	make help \n"
	@echo "Commands: \n"
	@grep -h -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'


about: ## Display info related to the build
	@echo "OS: ${OS}"
	@echo "Shell: ${SHELL} ${SHELL_VERSION}"
	@echo "Protoc version: $(shell protoc --version)"
	@echo "Go version: $(shell go version)"
	@echo "Go package: $(shell head -1 go.mod | awk '{print $$2}')"
	@echo "Openssl version: $(shell openssl version)"

run: fmt ## Run project
	$(GO_CMD) run cmd/ratelimiter/main.go

tidy: ## Go mod tidy
	$(GO_CMD) mod tidy

fmt: tidy ## Go mod tidy
	$(GO_CMD) fmt ./...

go-update-libs: fmt #Go update all libs
	$(GO_CMD) get -u ./...

test: fmt test-clean  ## Go test all project
	$(GO_TEST) -cover -p=1 ./...

test-clean: fmt ## Run the clean cache tests of the project
	$(GO_CMD) clean -testcache

docker-compose-up: ## Run docker-compose services of project
	$(DOCKER_COMPOSE_CMD) -f $(PATH_DOCKER_COMPOSE_FILE) up -d

docker-compose-down: ## Stop docker-compose services of project
	$(DOCKER_COMPOSE_CMD) -f $(PATH_DOCKER_COMPOSE_FILE) down --remove-orphans

docker-compose-restart: docker-compose-down docker-compose-up ## Restart docker-compose services of project

docker-compose-logs: ## Logs docker-compose containers of project
	$(DOCKER_COMPOSE_CMD) -f $(PATH_DOCKER_COMPOSE_FILE) logs -f

docker-compose-ps: ## List docker-compose containers of project
	$(DOCKER_COMPOSE_CMD) -f $(PATH_DOCKER_COMPOSE_FILE) ps