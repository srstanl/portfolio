# Example Angular Web UI

Reference Angular UI that links to local API health and OpenAPI endpoints.

## Run locally
```bash
npm ci
npm start
```

## Quality checks
```bash
npm test
npm run build
npm run test:e2e
npm audit --omit=dev --audit-level=high
```

## Local UI URL
- `http://localhost:4200`

## Run with Docker
```bash
docker build -t web-angular:local .
docker run --rm -p 8080:8080 web-angular:local
```

Container UI URL:
- `http://localhost:8080`
