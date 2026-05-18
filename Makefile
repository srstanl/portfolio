.PHONY: bootstrap lint test validate-structure scaffold-service

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
