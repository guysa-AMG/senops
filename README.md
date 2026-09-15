# Secure CI/CD Pipeline

This repository provides a security-focused GitHub Actions pipeline for a
placeholder application. It is designed to identify secrets, insecure code,
vulnerable dependencies, unsafe infrastructure, and untrusted container
artifacts before deployment.

The repository contains pipeline configuration, infrastructure templates,
policy-as-code rules, and intentionally vulnerable demo fixtures. It does not
contain application business logic.

## Security objectives

- Prevent secrets from being committed or exposed in CI.
- Detect common OWASP application security patterns.
- Block high and critical dependency or image vulnerabilities.
- Enforce secure Terraform and container configuration.
- Generate software bills of materials for built images.
- Require cryptographic image signatures before promotion.
- Use GitHub Actions OIDC instead of long-lived AWS credentials.
- Validate security controls with deterministic failing examples.

## Repository structure

| Path | Purpose |
| --- | --- |
| `.github/workflows/` | GitHub Actions workflows for each security phase |
| `infra/terraform/` | Terraform baseline and AWS deployment templates |
| `policy/` | Conftest and OPA policies plus test fixtures |
| `demo/` | Intentionally insecure artifacts for gate validation |
| `scripts/` | Local bootstrap and demo validation scripts |
| `.pre-commit-config.yaml` | Local secret, SAST, and filesystem scan hooks |
| `SECURITY_PIPELINE_SETUP.md` | Detailed setup and verification procedures |

## Pipeline phases

1. Secret scanning, SAST, and filesystem dependency scanning
2. Dockerfile linting, image scanning, SBOM generation, and signing
3. Terraform validation, Checkov, AWS OIDC, and deployment
4. OPA/Conftest policy enforcement
5. Deliberately vulnerable fixture validation

## Getting started

Run these commands from the repository root.

### Install local tools

On Linux or macOS, use the bootstrap script:

```bash
bash scripts/bootstrap-security-tools.sh
```

On Windows, install the equivalent tools using your preferred package manager
or run them in WSL. The required tools are:

- Git
- Docker
- pre-commit
- Gitleaks
- TruffleHog
- Semgrep
- Trivy
- Hadolint
- Syft
- Cosign
- Checkov
- Terraform
- Conftest

Verify the installation:

```bash
gitleaks version
trivy --version
semgrep --version
hadolint --version
syft version
cosign version
checkov --version
terraform version
conftest --version
pre-commit --version
```

### Enable pre-commit hooks

```bash
pre-commit install
pre-commit run --all-files
```

The hooks are intentionally strict. A real secret, a high-severity finding,
or an applicable SAST match should stop the local commit.

## GitHub Actions workflows

The workflows are separated by responsibility:

| Workflow | Trigger | Controls |
| --- | --- | --- |
| `phase1-secret-sast-sca.yml` | Pull requests and pushes to `main` | Gitleaks, TruffleHog, Semgrep, and Trivy filesystem scanning |
| `phase2-docker-security.yml` | Docker-related changes | Hadolint, image vulnerability scanning, Syft, and Cosign |
| `phase3-terraform-aws.yml` | Terraform changes on `main` or manual dispatch | Checkov, Terraform validation and plan, AWS OIDC, and Secrets Manager access |
| `phase4-policy-gates.yml` | Pull requests and pushes to `main` | Conftest policy checks |
| `phase5-demo-validation.yml` | Pull requests and pushes to `main` | Presence checks for the validation fixtures |

Before enabling deployment, replace the placeholder AWS role ARN and repository
subject in `phase3-terraform-aws.yml`. The IAM role must trust only the
intended GitHub organization, repository, branch, and OIDC audience.

## Branch protection

Protect the `main` branch in the repository settings:

1. Require pull requests before merging.
2. Require status checks before merging.
3. Require the security workflows to pass.
4. Require approval from at least one reviewer.
5. Prevent force pushes and branch deletion.

Use the exact check names shown by the completed workflow runs when configuring
required status checks.

## Container supply chain

The root `Dockerfile` demonstrates a non-root runtime user and a minimized
runtime package set. The image workflow:

1. Lints the Dockerfile.
2. Builds the image.
3. Blocks high and critical vulnerabilities.
4. Generates an SPDX SBOM.
5. Signs the image with keyless Cosign signing.
6. Verifies the signature against the GitHub Actions OIDC issuer.

Do not deploy an image unless its digest is scanned, signed, and verified.
