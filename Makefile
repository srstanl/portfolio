.PHONY: bootstrap lint test validate-structure

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
