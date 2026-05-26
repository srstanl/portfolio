.PHONY: bootstrap lint test validate-structure scaffold-service infra-local-up infra-local-down infra-observability-up infra-observability-down infra-observability-status

bootstrap:
	@echo "Bootstrap complete (install toolchains as needed)."

lint: validate-structure
	@echo "Run linters per domain here (dotnet, python, yaml, terraform)."

test:
	@echo "Run tests per domain here."

validate-structure:
	@test -d platform || (echo "missing platform/" && exit 1)
	@test -d idp || (echo "missing idp/" && exit 1)
	@test -d templates || (echo "missing templates/" && exit 1)
	@test -d paved-roads || (echo "missing paved-roads/" && exit 1)
	@test -d examples || (echo "missing examples/" && exit 1)
	@echo "Structure validation passed."

scaffold-service:
	@test -n "$(TEMPLATE)" || (echo "set TEMPLATE=<template-folder>" && exit 1)
	@test -n "$(NAME)" || (echo "set NAME=<service-name>" && exit 1)
	@./scripts/new-service.py $(TEMPLATE) $(NAME) --output-dir examples/$(NAME)

infra-local-up:
	@./scripts/infra/local/k3d-up.sh

infra-local-down:
	@./scripts/infra/local/k3d-down.sh

infra-observability-up:
	@./scripts/infra/local/observability-up.sh

infra-observability-down:
	@./scripts/infra/local/observability-down.sh

infra-observability-status:
	@kubectl get pods -n observability
