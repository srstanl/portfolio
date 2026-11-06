# In-home compute host

## Operating model

The office Mac mini runs GitHub Actions jobs, Docker builds, Floci Azure emulation, its AKS/k3s runtime, ACR, and Argo CD. The development laptop edits code, uses SSH, and dispatches jobs. Docker Desktop on the laptop remains stopped.

The host is an Intel Mac mini with 32 GiB RAM. Docker Desktop currently allocates six CPUs and approximately 8 GiB RAM. Existing tools include Floci, kubectl, Helm, Python, Node, .NET, and the Azure CLI. Real Azure deployment is outside this setup; the current Azure infrastructure target is Floci.

## Private Actions execution

The runner is registered only to [portfolio-home-control](https://github.com/srstanl/portfolio-home-control), a private repository. It is named `office-mac-mini` and has labels `self-hosted`, `macOS`, `X64`, and `portfolio-home`.

That repository's manually dispatched `Home compute` workflow checks out a trusted portfolio revision and performs one operation:

| Operation | Behavior |
|---|---|
| `inspect` | Verify host/storage identity, Docker, Kubernetes, and Argo CD |
| `infra-up` | Run Floci AKS, ACR, and Argo CD bootstraps on the Mini |
| `validate` | Bootstrap infrastructure, build/push Python and .NET, reconcile through Argo CD, replace reference pods, verify new UIDs/digests, rollout, and health |

Only the repository owner can run the workflow from its `main`. Operations are serialized so two jobs cannot mutate the shared environment simultaneously. The public portfolio's PR workflows remain GitHub-hosted and have no runner registered in this repository. Existing historical CD wrappers still reference the former `k3d-local` runner; this new GitOps control workflow is the supported home-host entry point.

macOS jobs can invoke the local Docker CLI for Linux image builds. GitHub job containers and Docker container actions require a Linux runner; this setup does not silently route existing Linux-only CI workflows to macOS.

From the laptop:

```bash
make home-inspect
make home-infra-up
make home-validate
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

The existing power settings are unchanged. The user deferred energy measurement and has not chosen permanent always-awake operation. Each requested controller operation uses a scoped `caffeinate` assertion while it runs; the idle runner does not keep the Mini awake indefinitely.

## Verified execution evidence

- [Host inspection run](https://github.com/srstanl/portfolio-home-control/actions/runs/42266790526): succeeded on the external-storage `office-mac-mini` runner.
- [Full remote validation run](https://github.com/srstanl/portfolio-home-control/actions/runs/42267004639): succeeded; both Python and .NET were built, pushed, reconciled, recreated, digest-checked, and health-checked on the Mini. This first full run used the original PR #40 head `39bb42d`; its control-layer verification closes the stale-pod evidence gap for that run.
- Seven local control-code verification tests passed; the public dispatch wrapper passes shell syntax, structure, and repository hygiene checks.

See [issue #42](https://github.com/srstanl/portfolio/issues/42) for current acceptance criteria and follow-up evidence.
