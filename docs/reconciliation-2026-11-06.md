# Portfolio Reconciliation — November 6, 2026

## Baseline

The local checkout was clean but seven commits behind GitHub. After fetching, local `main` was fast-forwarded from `85c4e2b` (July 17) to `4d7879b` (September 16, PR #38). The earlier July-only workspace recap was incomplete because it used the stale remote-tracking reference.

This record reconciles committed files, GitHub issues and PRs, and recorded CI results. It does not claim a fresh application, dependency, container, local-cluster, or Azure validation.

## Completed Work

| Outcome | Tracking / evidence |
|---|---|
| Angular Playwright smoke and CI lane | Tasks [#3](https://github.com/srstanl/portfolio/issues/3) and [#4](https://github.com/srstanl/portfolio/issues/4) closed; files and CI steps tracked |
| Backstage kept as a platform-owned module | Decision [#5](https://github.com/srstanl/portfolio/issues/5) closed; portal files tracked |
| Manual deployment contract, preview/promote, reusable workflow | Tasks #7–#9 closed; wrapper expansion merged in [PR #18](https://github.com/srstanl/portfolio/pull/18) |
| Delivery standards and portable requirements | Tasks #10 and #13 closed; Floci/GitOps toolchain documented |
| Floci AKS lifecycle | Task [#27](https://github.com/srstanl/portfolio/issues/27) closed through [PR #28](https://github.com/srstanl/portfolio/pull/28) |
| Argo CD bootstrap | Task [#29](https://github.com/srstanl/portfolio/issues/29) closed through [PR #30](https://github.com/srstanl/portfolio/pull/30) |
| Python GitOps reference proof | Task [#32](https://github.com/srstanl/portfolio/issues/32) closed through [PR #34](https://github.com/srstanl/portfolio/pull/34) |
| .NET GitOps reference proof | Task [#35](https://github.com/srstanl/portfolio/issues/35) closed through [PR #36](https://github.com/srstanl/portfolio/pull/36); first-CD epic #12 closed |
| Logical platform asset charter | Task [#37](https://github.com/srstanl/portfolio/issues/37) closed through [PR #38](https://github.com/srstanl/portfolio/pull/38); no physical migration |

## Open Work

| Item | Verified state | Remaining action |
|---|---|---|
| [#39](https://github.com/srstanl/portfolio/issues/39): registry-backed local promotion | Open; linked [PR #40](https://github.com/srstanl/portfolio/pull/40) is open, non-draft, mergeable, and reports a clean merge state | Review and decide merge disposition; do not describe its ACR implementation as merged |
| [#22](https://github.com/srstanl/portfolio/issues/22): problem recommender onboarding | Open, deferred in current context | Resume when explicitly selected and consumer readiness is established |
| [#21](https://github.com/srstanl/portfolio/issues/21): physical platform migration | Open; contingent on onboarding | Define migration scope when needed; retain current logical boundary meanwhile |
| [#11](https://github.com/srstanl/portfolio/issues/11): provider-drift risk | Open; body is a placeholder lacking mitigation owner, target date, and plan | Triage the risk and decide whether the historical manual lanes still justify it |

PR #40 is the only open PR returned for this repository. Its head is `39bb42d` on `feat/floci-acr-promotion`. It reports successful local Python and .NET proof commands in its validation section. Those are author-recorded results, not reruns from this reconciliation.

## Current Delivery Boundary

Merged `main` builds a reference-service image tagged with its committed service Git tree ID, imports it directly into the Floci-backed k3s node, and lets Argo CD reconcile Git-tracked overlays. The overlays use `imagePullPolicy: Never`; rollout and in-cluster health checks block completion.

PR #40 proposes Floci ACR lifecycle, a workstation registry push, and a fresh node pull with `imagePullPolicy: Always`. This validates a local registry boundary; real Azure identity, authorization, networking, and governance evidence remain future work. Cross-stage GitOps promotion is not established merely by the local reference proof.

The older Python/Node/.NET manual GitHub Actions wrappers remain committed and use imperative Kubernetes deployment. Their runbooks are retained as historical lanes. Legacy k3d and observability scripts also remain; observability backend selection is deferred and OTEL compatibility remains the telemetry requirement.

The local sibling `playground/problem_recommender` already has a FastAPI health/recommendation surface and shared recommendation/corpus services. Its adoption plan now acknowledges that partial extraction. Its remote state and runtime were not revalidated, and no sibling repository was modified.

## Recorded CI Evidence

These are historical results retrieved from GitHub on November 6; they are not current dependency or runtime guarantees.

| Workflow / scope | Latest result observed |
|---|---|
| `platform-ci` on main | Success, August 25, at `865bd57`: [run](https://github.com/srstanl/portfolio/actions/runs/32863618104) |
| PR #40 platform structure check | Success, September 16, at `39bb42d`: [run](https://github.com/srstanl/portfolio/actions/runs/35120656888) |
| `python-cd` on main | Success, May 27: [run](https://github.com/srstanl/portfolio/actions/runs/26516317189) |
| `idp-ci` on main | Success, May 26: [run](https://github.com/srstanl/portfolio/actions/runs/26471123333); dependency audit remains advisory |
| `web-angular-ci` on main | Success, May 22: [run](https://github.com/srstanl/portfolio/actions/runs/26295891837) |
| Python/.NET/Node example CI on main | Latest returned runs succeeded May 18; no fresh runs were dispatched |

The September 16 main commit changes documentation, so path filtering did not produce a new platform run for it. Root `make lint` and `make test` are placeholders apart from structure validation and must not be presented as full application checks. Some actions in the historical reusable CD workflow remain version-tagged rather than SHA-pinned.

## Verification and Access Gaps

- `gh project list --owner srstanl --format json` failed because the current token lacks `read:project`. Browser fallback also failed before the project page could be read. No project custom fields were verified or changed. For subsequent board reconciliation, PR #40 / task #39 should be checked for `Workflow=Review`; merged/closed items should be checked against the documented Done rules.
- The open risk #11 still needs an owner, mitigation date, and plan. No owner or deadline was invented during cleanup.
- No cluster, container, cloud resource, dependency scan, or application suite was started. Existing runtime health and current advisory status remain unverified.
- PR #40 remains open; no implementation work was merged or discarded during this documentation cleanup.

## Cleanup Validation

- `make validate-structure`: passed.
- `bash scripts/ci/check-repo-hygiene.sh`: passed.
- `git diff --check`: passed.
- Local Markdown links in the changed documentation: checked for existing targets.
- Python and .NET Floci overlay image tags: match the committed service Git tree IDs.

## Handoff

Use `PROJECT_CONTEXT.md` as the starting point. The user's specific task for today has not yet been provided. Deferred onboarding, physical migration, observability, and real-Azure work should remain deferred until selected.
