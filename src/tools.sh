#!/bin/bash

function check_tools() {
  if ! command -v snyk &>/dev/null; then
    echo "[INFO] Installing Snyk..."
    npm install -g snyk
  fi
  
  if ! command -v trivy &>/dev/null; then
    echo "[INFO] Installing Trivy..."
    curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sh -s -- -b /usr/local/bin
  fi
}
