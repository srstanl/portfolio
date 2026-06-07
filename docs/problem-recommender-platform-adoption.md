# Problem Recommender Platform Adoption Plan

## Purpose
Define how `playground/problem_recommender` can become the first realistic consumer of the platform paved road.

This is not meant to turn the recommender into a production system immediately. The goal is to make it a credible test dummy that exercises:
- service packaging
- CI quality/security lanes
- container build and scan
- CD preview/promote flow
- platform runtime expectations
- observability and operational defaults

## Why This Project Is a Good Candidate
`problem_recommender` is useful as a platform canary because it is more realistic than a toy sample:
- it has real application logic
- it has external model/API configuration
- it reads and writes local state
- it owns a curated content corpus
- it mixes interactive and automation-oriented behavior

That means it can expose gaps in the paved road that simple reference services may not reveal.

## Why It Is Not Ready Yet
In its current form, `problem_recommender` is primarily a local Python tool with:
- CLI-first interaction
- filesystem-coupled state
- no stable HTTP service interface
- no platform-aligned container/runtime contract
- no repo-local CI/CD behavior matching the portfolio examples

Using it as the platform dummy requires turning it into a deployable service boundary.

## Target End State
The target shape is a Python service that preserves the current recommendation and generation logic, but exposes it through a platform-aligned application boundary.

### Service Boundary
`problem_recommender` should become one deployable service with:
- one runtime process
- one Docker image
- one health endpoint
- one environment-driven configuration surface
- one CI lane
- one CD lane

### Recommended Structure
Suggested internal shape:

```text
problem_recommender/
├── app/                       # HTTP API / service entrypoint
├── domain/                    # recommender, generation, testing logic
├── java/                      # curated Java corpus
├── generated_problems/        # generated content (local/dev or mounted storage)
├── data/                      # local state for dev mode only
├── tests/                     # unit/integration/API tests
├── Dockerfile
├── requirements.txt
├── README.md
└── LICENSE
```

This does not require rewriting the core logic immediately. The first move is separating transport/runtime concerns from domain behavior.

## Platform Contract It Should Satisfy

### Runtime
- containerized Python service
- binds to `0.0.0.0`
- configurable port via environment variable
- `GET /health` endpoint
- optional `GET /ready` endpoint if startup becomes stateful

### API Surface
Minimum useful endpoints:
- `POST /recommend`
- `POST /generate`
- `POST /test`
- `GET /health`
- `GET /openapi.json`

FastAPI is the simplest fit because it aligns with the existing Python example and gives OpenAPI/Swagger with minimal overhead.

### Configuration
All runtime configuration should be environment-driven:
- model provider settings
- API tokens
- storage locations
- feature flags for generation/testing behavior

No runtime dependency should require an interactive shell prompt.

### State Model
The current local state needs explicit classification:

- immutable application content:
  - `java/`
- local/dev mutable state:
  - `data/`
  - `generated_problems/`
- secrets/config:
  - environment variables

For platform testing, the simplest first rule is:
- treat `java/` as baked-in read-only content
- treat `data/` and `generated_problems/` as ephemeral writable paths

Later, this can evolve to mounted volumes or object storage if needed.

## CI Expectations
To act as a platform dummy, it should pass the same classes of checks as the portfolio examples:
- dependency install
- lint/format validation
- unit/integration tests
- dependency vulnerability scan
- Dockerfile lint
- container build
- Trivy image scan

Recommended first alignment:
- `ruff check`
- `ruff format --check`
- `pytest`
- `pip-audit`
- `docker build`
- `trivy image`

## CD Expectations
The service should adopt the same delivery semantics as the existing Python example:
- preview deployment
- promote deployment using the same artifact
- GitHub environment gates
- rollout verification
- health verification

That implies:
- a dedicated wrapper workflow such as `problem-recommender-cd`
- Kubernetes manifests under `platform/cd/problem-recommender/`
- stage mapping for `dev`, `staging`, `prod`

## Observability Baseline
To be a useful platform test dummy, the service should include:
- structured logs
- request logging
- health/readiness endpoints
- a place to add OpenTelemetry hooks later

Do not overbuild this initially. Logging + health + basic request tracing hooks are enough for the first pass.

## Recommended Migration Phases

### Phase 1: Service Extraction
Goal: make the recommender behave like a service.

Work:
- add FastAPI entrypoint
- wrap current core logic behind API handlers
- move reusable logic into importable modules
- keep CLI only as an optional local tool
- add health endpoint and OpenAPI

Exit criteria:
- service runs locally via one command
- API can recommend/generate/test without interactive prompts

### Phase 2: Packaging and Local Runtime
Goal: make the service platform-runnable.

Work:
- add Dockerfile
- define env-based config
- document local run path
- confirm writable directories for local state

Exit criteria:
- container builds locally
- service runs in Docker
- health endpoint responds

### Phase 3: CI Alignment
Goal: make it consume the same quality/security lane shape as the platform examples.

Work:
- add tests suitable for service boundary
- add lint/test/security/build workflow
- add dependency and image scanning

Exit criteria:
- CI lane is green
- checks are comparable to existing example services

### Phase 4: CD Alignment
Goal: make it a real paved-road deployment consumer.

Work:
- add Kubernetes manifests
- add wrapper workflow using the reusable CD contract
- enable preview/promote behavior
- verify rollout and health

Exit criteria:
- deployable through the same contract as other services
- promotion reuses built artifacts

### Phase 5: Paved-Road Feedback
Goal: use the project to improve the platform itself.

Work:
- identify where the paved road assumes too-simple services
- capture storage/config/secrets lessons
- update paved-roads docs and templates based on findings

Exit criteria:
- platform improvements are documented and reusable

## Deliberate Non-Goals for First Adoption
- multi-tenant architecture
- durable production data design
- autoscaling policy sophistication
- deep authn/authz model
- production-grade SLOs

Those can come later if the project proves worth hardening.

## Recommended First Implementation Slice
The smallest high-value slice is:

1. add a FastAPI wrapper around recommendation and health
2. keep generation/testing behind API routes
3. package it with Docker
4. run it through the Python-style CI lane

That is enough to start using it as the first serious consumer of the paved road without committing to a full production rebuild.

## Decision
Use `problem_recommender` as a platform canary only after it is converted into a Python service boundary.

Do not treat the current CLI-first shape as the final target. The value of this project as a test dummy comes from forcing the platform to support a realistic service, not from forcing a local tool into deployment unchanged.
