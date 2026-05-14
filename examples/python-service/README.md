# Example Python Service

Reference FastAPI service derived from the python template.

## Run locally
```bash
python -m venv .venv
source .venv/bin/activate
pip install -r requirements-dev.txt
uvicorn app.main:app --reload --port 8080
```

## API docs
- Swagger UI: `http://localhost:8080/docs`
- ReDoc: `http://localhost:8080/redoc`
- OpenAPI JSON: `http://localhost:8080/openapi.json`

## Quality checks
```bash
ruff check .
ruff format --check .
pytest
```
