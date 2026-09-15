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
