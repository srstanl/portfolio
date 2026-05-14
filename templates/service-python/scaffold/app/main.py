from fastapi import FastAPI

app = FastAPI(
    title="{{ service_name }}",
    description="Template FastAPI service with OpenAPI/Swagger docs enabled.",
    version="1.0.0",
)


@app.get("/health")
def health() -> dict[str, str]:
    return {"status": "ok"}
