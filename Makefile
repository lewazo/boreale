# Build configuration
# -------------------

APP_NAME = `grep -Eo 'app: :\w*' mix.exs | cut -d ':' -f 3`
APP_VERSION = `grep -Eo 'version: "[0-9\.]*"' mix.exs | cut -d '"' -f 2`
GIT_REVISION = `git rev-parse HEAD`
DOCKER_IMAGE_TAG ?= 'latest'
DOCKER_NAMESPACE ?= 'lewazo'

# Introspection targets
# ---------------------

.PHONY: help
help: header targets

.PHONY: header
header:
	@echo "\033[34mEnvironment\033[0m"
	@echo "\033[34m---------------------------------------------------------------\033[0m"
	@printf "\033[33m%-23s\033[0m" "APP_NAME"
	@printf "\033[35m%s\033[0m" $(APP_NAME)
	@echo ""
	@printf "\033[33m%-23s\033[0m" "APP_VERSION"
	@printf "\033[35m%s\033[0m" $(APP_VERSION)
	@echo ""
	@printf "\033[33m%-23s\033[0m" "GIT_REVISION"
	@printf "\033[35m%s\033[0m" $(GIT_REVISION)
	@echo ""
	@printf "\033[33m%-23s\033[0m" "DOCKER_IMAGE_TAG"
	@printf "\033[35m%s\033[0m" $(DOCKER_IMAGE_TAG)
	@echo ""
	@printf "\033[33m%-23s\033[0m" "DOCKER_NAMESPACE"
	@printf "\033[35m%s\033[0m" $(DOCKER_NAMESPACE)
	@echo "\n"

.PHONY: targets
targets:
	@echo "\033[34mTargets\033[0m"
	@echo "\033[34m---------------------------------------------------------------\033[0m"
	@perl -nle'print $& if m{^[a-zA-Z_-]+:.*?## .*$$}' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-22s\033[0m %s\n", $$1, $$2}'

# Build targets
# -------------

.PHONY: prepare
prepare: ## Install dependencies
	mix deps.get

.PHONY: build
build: ## Build the Docker image for the OTP release
	docker build --build-arg APP_NAME=$(APP_NAME) --build-arg APP_VERSION=$(APP_VERSION) --rm --tag $(DOCKER_NAMESPACE)/$(APP_NAME):$(DOCKER_IMAGE_TAG) .

.PHONY: push
push: ## Push the Docker image
	docker push $(DOCKER_NAMESPACE)/$(APP_NAME):$(DOCKER_IMAGE_TAG)

# Development targets
# -------------------

.PHONY: run
run: ## Run the server inside an IEx shell
	iex -S mix phx.server

.PHONY: dependencies
dependencies: ## Install dependencies required by the application
	mix deps.get --force

.PHONY: clean
clean: ## Clean dependencies
	mix deps.clean --unused --unlock

.PHONY: test
test: ## Run the test suite
	mix test

# Check, lint and format targets
# ------------------------------

.PHONY: check
check: check-format check-unused-dependencies check-code-security

.PHONY: check-code-security
check-code-security:
	mix sobelow --config .sobelow-conf

.PHONY: check-format
check-format:
	mix format --dry-run --check-formatted

.PHONY: check-unused-dependencies
check-unused-dependencies:
	mix deps.unlock --check-unused

.PHONY: format
format: ## Format project files
	mix format

.PHONY: lint
lint: lint-elixir

.PHONY: lint-elixir
lint-elixir:
	mix compile --warnings-as-errors --force
	mix credo --strict
