# Developer Guide

## Purpose
Local development commands for the example services and CI-aligned checks.

## Prerequisites
- .NET SDK 10
- Python 3.12+
- Node.js 22+
- Docker
- Trivy (optional, for local container scanning)

## .NET Example Service
Directory: `examples/dotnet-service`

Run quality checks:
```bash
cd examples/dotnet-service
dotnet restore dotnet-service.sln
dotnet format --verify-no-changes dotnet-service.sln
dotnet build dotnet-service.sln -warnaserror
dotnet test dotnet-service.sln --no-build
dotnet list dotnet-service.sln package --vulnerable --include-transitive
```

Run service:
```bash
dotnet run --project src/dotnet-service.csproj
```

Swagger/OpenAPI:
- `http://localhost:5000/swagger`
- `http://localhost:5000/swagger/v1/swagger.json`

Container build + scan:
```bash
cd ../..
docker build -t dotnet-service:ci examples/dotnet-service
trivy image --severity CRITICAL --ignore-unfixed dotnet-service:ci
```

## Python Example Service
Directory: `examples/python-service`

Environment + quality checks:
```bash
cd examples/python-service
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements-dev.txt
ruff check .
ruff format --check .
PYTHONPATH=. pytest
pip-audit -r requirements.txt
```

Run service:
```bash
uvicorn app.main:app --reload --port 8080
```

Swagger/OpenAPI:
- `http://localhost:8080/docs`
- `http://localhost:8080/redoc`
- `http://localhost:8080/openapi.json`

Container build + scan:
```bash
cd ../..
docker build -t python-service:ci examples/python-service
trivy image --severity CRITICAL --ignore-unfixed python-service:ci
```

## Node Example Service
Directory: `examples/node-service`

Install + quality checks:
```bash
cd examples/node-service
npm ci
npm run lint
npm test
npm audit --omit=dev --audit-level=high
```

Run service:
```bash
npm run dev
```

Swagger/OpenAPI:
- `http://localhost:8080/docs`
- `http://localhost:8080/docs/json`

Container build + scan:
```bash
cd ../..
docker build -t node-service:ci examples/node-service
trivy image --severity CRITICAL --ignore-unfixed node-service:ci
```

## Angular Example UI
Directory: `examples/web-angular`

Install + quality checks:
```bash
cd examples/web-angular
npm ci
npm run test:headless
npm run build
npm audit --omit=dev --audit-level=high
```

Run UI:
```bash
npm start
```

UI URL:
- `http://localhost:4200`

## Notes
- CI path filters are scoped per service domain. Changes outside a service path will not trigger that service workflow.
- On macOS, if `dotnet` commands fail in sandboxed terminals due to IPC permissions, run in a normal shell session.
