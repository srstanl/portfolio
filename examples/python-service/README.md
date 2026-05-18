# python-service

FastAPI service scaffolded from `templates/service-python`.

## Run locally
```bash
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements-dev.txt
uvicorn app.main:app --reload --port 8080
```

## Quality checks
```bash
ruff check .
ruff format --check .
PYTHONPATH=. pytest
pip-audit -r requirements.txt
```

## API docs
- Swagger UI: `http://localhost:8080/docs`
- OpenAPI JSON: `http://localhost:8080/openapi.json`
