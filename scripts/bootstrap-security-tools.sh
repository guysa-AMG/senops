#!/usr/bin/env bash
set -euo pipefail

if [[ "$OSTYPE" == "darwin"* ]]; then
  if ! command -v brew >/dev/null 2>&1; then
    echo "Homebrew not found. Install it first: https://brew.sh/"
    exit 1
  fi
  brew install gitleaks trivy hadolint semgrep cosign syft conftest checkov pre-commit || true
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
  if command -v apt-get >/dev/null 2>&1; then
    sudo apt-get update
    sudo apt-get install -y curl python3-pip git
    curl -sSfL https://raw.githubusercontent.com/gitleaks/gitleaks/master/install.sh | sh -s -- -b /usr/local/bin
    curl -sSfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sh -s -- -b /usr/local/bin
    curl -sSfL https://github.com/hadolint/hadolint/releases/latest/download/hadolint-Linux-x86_64 -o /usr/local/bin/hadolint
    chmod +x /usr/local/bin/hadolint
    python3 -m pip install --user semgrep checkov pre-commit
    curl -sSfL https://github.com/open-policy-agent/conftest/releases/latest/download/conftest_$(uname -s)_$(uname -m).tar.gz -o /tmp/conftest.tar.gz
    tar -xzf /tmp/conftest.tar.gz -C /tmp
    sudo mv /tmp/conftest /usr/local/bin/conftest
    curl -sSfL https://raw.githubusercontent.com/anchore/syft/main/install.sh | sh -s -- -b /usr/local/bin
    curl -sSfL https://github.com/sigstore/cosign/releases/latest/download/cosign-linux-amd64 -o /usr/local/bin/cosign
    chmod +x /usr/local/bin/cosign
  else
    echo "Unsupported Linux package manager. Install tools manually."
    exit 1
  fi
else
  echo "Unsupported OS: $OSTYPE"
  exit 1
fi

echo "Tool bootstrap complete. Validate with:"
echo "  gitleaks version"
echo "  trivy --version"
echo "  semgrep --version"
echo "  conftest --version"
echo "  checkov --version"
echo "  hadolint --version"
echo "  cosign version"
echo "  syft version"
