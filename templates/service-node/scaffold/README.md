# {{ service_name }}

Fastify service scaffolded from `templates/service-node`.

## Run locally
```bash
npm ci
npm run dev
```

## Quality checks
```bash
npm run lint
npm test
npm audit --omit=dev --audit-level=high
```

## API docs
- Swagger UI: `http://localhost:8080/docs`
- OpenAPI JSON: `http://localhost:8080/docs/json`
