# src/scan.sh
#!/bin/bash

function run_security_scans() {
    local scan_failed=0
    mkdir -p reports

    if [ "$SNYK_ENABLED" = "true" ]; then
        echo "[INFO] Running Snyk scan..."
        if [ -z "$SNYK_TOKEN" ]; then
            echo "[ERROR] SNYK_TOKEN not set"
            scan_failed=1
        else
            if ! snyk test --json --severity-threshold="$SNYK_SEVERITY" > reports/snyk-results.json; then
                echo "[WARN] Snyk found vulnerabilities"
            fi
        fi
    fi

    if [ "$TRIVY_ENABLED" = "true" ]; then
        echo "[INFO] Running Trivy scan..."
        IMAGE_NAME="${IMAGE_NAME:-ubuntu:latest}"
        if ! trivy image --format json --severity "$TRIVY_SEVERITY" \
            --ignore-unfixed="$TRIVY_IGNORE_UNFIXED" \
            --output reports/trivy-results.json "$IMAGE_NAME"; then
            echo "[WARN] Trivy found vulnerabilities"
        fi
    fi

    return $scan_failed
}
