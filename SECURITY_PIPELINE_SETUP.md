# Secure CI/CD Pipeline Setup

This repository contains a complete GitHub Actions-driven security pipeline aligned to the phases in `plan.md`.

## Phase 1: Local pre-commit and CI scans

- `.pre-commit-config.yaml` installs local hooks for Gitleaks, TruffleHog, Semgrep, and Trivy.
- `.gitleaks.toml` and `.trufflehog.yaml` define secret scanning rules.
- `.semgrep.yml` and `.trivy.yaml` configure static analysis and dependency scanning.
- `.github/workflows/phase1-secret-sast-sca.yml` runs the same checks in CI on PRs and pushes.

### Verification

```bash
pre-commit install
pre-commit run --all-files
semgrep --config auto .
trivy fs --security-checks vuln,config --severity CRITICAL,HIGH --exit-code 1 .
```

## Phase 2: Docker security

- `Dockerfile` is a hardened secure example.
- `.github/workflows/phase2-docker-security.yml` runs Hadolint, Trivy, Syft, and Cosign.
- The workflow enforces CVE blocking before image promotion.

### Verification

```bash
docker build -t app:local .
hadolint Dockerfile
trivy image --severity HIGH,CRITICAL --exit-code 1 app:local
syft app:local -o spdx-json=sbom.spdx.json
cosign generate-key-pair
cosign sign --key cosign.key app:local
cosign verify --key cosign.pub app:local
```

## Phase 3: Terraform and AWS OIDC

- `infra/terraform/` contains secure baseline Terraform templates.
- `.github/workflows/phase3-terraform-aws.yml` checks IaC with Checkov, authenticates via OIDC, and runs Terraform.
- AWS Secrets Manager retrieval is configured in the workflow.

### Verification

```bash
terraform -chdir=infra/terraform init
terraform -chdir=infra/terraform validate
terraform -chdir=infra/terraform plan
checkov -d infra/terraform --framework terraform --output cli
```

## Phase 4: OPA/Conftest policy gates

- `policy/signed-image-required.rego`
- `policy/no-critical-cves.rego`
- `policy/non-root-user.rego`
- `policy/approved-image.json`
- `policy/rejected-image.json`

### Verification

```bash
conftest test --policy policy/ policy/approved-image.json
conftest test --policy policy/ policy/rejected-image.json
```

The rejected example should fail because it is not signed, runs as root, and has critical CVEs.

## Phase 5: Demo fail-test suite

The `demo/` folder includes intentionally insecure artifacts:

- `demo/secrets/.env` includes a hardcoded AWS key.
- `demo/sast/ssrf.py` demonstrates SSRF patterns.
- `demo/sast/sql_injection.py` demonstrates SQLi patterns.
- `demo/iac/main.tf` creates a public S3 bucket.
- `demo/container/Dockerfile` uses `USER root`.

### Failure verification

```bash
./scripts/validate-demo.sh
```

The script intentionally calls scanners against insecure demo artifacts and expects them to fail.

## Required GitHub settings

1. Go to Settings > Branches
2. Add a rule for `main`
3. Require PRs before merge
4. Require status checks:
   - `gitleaks`
   - `trufflehog`
   - `semgrep`
   - `trivy`
   - `phase2-docker-security`
   - `phase3-terraform-aws`
   - `phase4-policy-gates`
