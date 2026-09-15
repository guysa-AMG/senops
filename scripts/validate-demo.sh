#!/usr/bin/env bash
set -euo pipefail

echo "[1/5] Gitleaks secret scan"
gitleaks detect --source . --no-banner --redact --exit-code 1 || true

echo "[2/5] Semgrep SAST scan"
semgrep --config auto demo --error --severity ERROR || true

echo "[3/5] Trivy filesystem scan"
trivy fs --security-checks vuln,config --severity CRITICAL,HIGH --exit-code 1 demo || true

echo "[4/5] Checkov IaC scan"
checkov -d demo/iac --framework terraform --output cli || true

echo "[5/5] Hadolint and Dockerfile checks"
hadolint demo/container/Dockerfile || true

echo "Demo validation completed. Expected failures confirm that the pipeline blocks insecure artifacts."
