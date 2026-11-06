# In-home compute host

## Operating model

The office Mac mini runs GitHub Actions jobs, Docker builds, Floci Azure emulation, its AKS/k3s runtime, ACR, and Argo CD. The development laptop edits code, uses SSH, and dispatches jobs. Docker Desktop on the laptop remains stopped.

The host is an Intel Mac mini with 32 GiB RAM. Docker Desktop currently allocates six CPUs and approximately 8 GiB RAM. Existing tools include Floci, kubectl, Helm, Python, Node, .NET, and the Azure CLI. Real Azure deployment is outside this setup; the current Azure infrastructure target is Floci.

## Private Actions execution

Both runners are registered only to [portfolio-home-control](https://github.com/srstanl/portfolio-home-control), a private repository. The native runner is named `office-mac-mini` with labels `self-hosted`, `macOS`, `X64`, and `portfolio-home`. A Docker-based Linux runner on the same Mini is named `office-mac-mini-linux` with labels `self-hosted`, `Linux`, `X64`, and `portfolio-home-linux`.

That repository's manually dispatched `Home compute` workflow checks out a trusted portfolio revision and performs one operation:

| Operation | Behavior |
|---|---|
| `inspect` | Verify host/storage identity, Docker, Kubernetes, and Argo CD |
| `infra-up` | Run Floci AKS, ACR, and Argo CD bootstraps on the Mini |
| `validate` | Bootstrap infrastructure, build/push Python and .NET, reconcile through Argo CD, replace reference pods, verify new UIDs/digests, rollout, and health |

Only the repository owner can run the workflow from its `main`. Operations are serialized so two jobs cannot mutate the shared environment simultaneously. The public portfolio's PR workflows remain GitHub-hosted and have no runner registered in this repository. Existing historical CD wrappers still reference the former `k3d-local` runner; this new GitOps control workflow is the supported home-host entry point.

macOS jobs control the host infrastructure. The Linux runner supports Docker container actions through the same Mini Docker daemon; its workspace uses the same external path inside and outside the runner container. The private `Linux runner capability` workflow verifies Docker access, the Floci AKS ARM API, and a real container action writing back to that workspace. Existing public PR workflows retain their current routing; trusted equivalents can use the private Linux runner.

From the laptop:

```bash
make home-inspect
make home-infra-up
make home-validate
make home-linux-check
```

These targets only dispatch GitHub Actions; they never start a laptop Docker daemon. They default to the PR #40 branch while its ACR targets are unmerged. Select a reviewed revision explicitly when needed:

```bash
HOME_COMPUTE_PORTFOLIO_REF=<reviewed-branch-or-sha> make home-validate
gh run list --repo srstanl/portfolio-home-control --workflow home-compute.yml
```

## External runner storage

The external `SSRed2TB` drive uses ExFAT. The runner uses an expandable APFS image stored on it for normal permissions and symlinks; the original drive was not reformatted.

| Path | Purpose |
|---|---|
| `/Volumes/SSRed2TB/portfolio-home/runner-storage.sparsebundle` | APFS backing image; grows on demand to a 200 GiB logical maximum |
| `/Volumes/PortfolioRunners/runner` | Runner binaries, credentials, diagnostics, logs, and `_work` checkouts |
| `/Volumes/PortfolioRunners/linux-runner` | Linux runner payload, credentials, diagnostics, logs, and `_work` |
| `/Volumes/PortfolioRunners/cache` | Job package/tool caches |
| `/Volumes/PortfolioRunners/tmp` | Job temporary files |
| `/Volumes/PortfolioRunners/state` | Kubeconfig, Azure CLI configuration, PID, and validation evidence |
| `/Volumes/SSRed2TB/portfolio-home/control` | Small runner bootstrap/control code |

Before a run, the controller verifies the Mini hostname, physical volume UUID, APFS volume UUID, and backing-image identity. It fails if the configured storage is absent rather than creating runner directories on the internal disk. Runner kubeconfig state is outside ephemeral Actions checkouts and is explicitly supplied to all infrastructure commands.

Docker Desktop's VM disk, images, and build-layer cache remain in their existing location. Moving Docker's storage was not part of the request to place runners externally.

## On-demand runner lifecycle

The tested startup path is SSH. A login-service attempt failed because macOS denied the service access to an external log file; that service was removed. No privacy settings were weakened.

From a checkout of the private control repository:

```bash
python3 scripts/manage-runner.py start
python3 scripts/manage-runner.py status
python3 scripts/manage-runner.py stop
python3 scripts/manage-linux-runner.py start
python3 scripts/manage-linux-runner.py status
python3 scripts/manage-linux-runner.py stop
```

The runner detaches from SSH and keeps logs/PID on external storage. Stop it before unmounting the APFS image or disconnecting the drive. Provisioning and storage identity configuration are versioned in the private repository. Registration tokens are short-lived, passed through stdin, and omitted from logs.

After a login/reboot, mount the external runner image before starting the runner:

```bash
ssh -i ~/.ssh/id_ed25519_macmini srstanl@Sians-Mac-mini.local \
  'hdiutil attach /Volumes/SSRed2TB/portfolio-home/runner-storage.sparsebundle -nobrowse -mountpoint /Volumes/PortfolioRunners'
```

Use that mount command only when the image is not already mounted. Docker Desktop must be running on the Mini. A future login service requires a separate explicit macOS permissions decision; unattended cold-boot recovery has not been demonstrated.

## Addressing and state

Infrastructure scripts execute on the Mini, so `localhost:4577` is its Floci API and `localhost:5000` is its host registry endpoint. k3s pulls through `host.docker.internal:5000/portfolioacr`. These addresses do not identify the laptop.

The source checkout for a job, its Docker build, the generated kubeconfig, and kubectl/Helm commands all execute on the Mini. The same Kubernetes API therefore needs no laptop-facing endpoint rewrite. Laptop dashboard access can be added through scoped SSH tunnels.

The observed Floci container used in-memory metadata and the containers had no restart policy. Persistent emulator metadata, container restart behavior, and a reboot recovery test remain explicit follow-up work. An available host is a prerequisite for jobs; sleeping or offline runners leave jobs queued.

## Power and electricity policy

The existing power settings are unchanged. The user deferred energy measurement and has not chosen permanent always-awake operation. Each requested native controller operation uses a scoped `caffeinate` assertion while it runs; neither idle runner keeps the Mini awake indefinitely. Jobs require the host to remain awake under the existing power policy.

## Verified execution evidence

- [Host inspection run](https://github.com/srstanl/portfolio-home-control/actions/runs/42266790526): succeeded on the external-storage `office-mac-mini` runner.
- [Full remote validation run](https://github.com/srstanl/portfolio-home-control/actions/runs/42267004639): succeeded; both Python and .NET were built, pushed, reconciled, recreated, digest-checked, and health-checked on the Mini. This first full run used the original PR #40 head `39bb42d`; its control-layer verification closes the stale-pod evidence gap for that run.
- [Corrected exact-head proof](https://github.com/srstanl/portfolio-home-control/actions/runs/42272459936): succeeded against PR #40 head `83e5784`, with both services verified through new pods and the pushed digest in the runtime image record.
- [Linux capability run](https://github.com/srstanl/portfolio-home-control/actions/runs/42274486618): succeeded on `office-mac-mini-linux`, including Floci ARM API access and Docker container-action workspace mapping.
- Eight local control-code verification tests passed; the public dispatch wrapper passes shell syntax, structure, and repository hygiene checks.

See [issue #42](https://github.com/srstanl/portfolio/issues/42) for current acceptance criteria and follow-up evidence.
