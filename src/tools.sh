# src/tools.sh
#!/bin/bash

function check_tools() {
    local failed=0

    # Check and install Snyk
    if ! command -v snyk &>/dev/null; then
        echo "[INFO] Installing Snyk..."
        if ! npm install -g snyk; then
            echo "[ERROR] Failed to install Snyk"
            failed=1
        fi
    else
        echo "[INFO] Snyk $(snyk --version) is installed"
    fi

    # Check and install Trivy
    if ! command -v trivy &>/dev/null; then
        echo "[INFO] Installing Trivy..."
        if ! curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sh -s -- -b /usr/local/bin; then
            echo "[ERROR] Failed to install Trivy"
            failed=1
        fi
    else
        echo "[INFO] Trivy $(trivy --version) is installed"
    fi

    return $failed
}
