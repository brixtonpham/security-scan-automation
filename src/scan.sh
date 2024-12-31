# src/scan.sh
#!/bin/bash

function run_security_scans() {
    local scan_failed=0
    mkdir -p reports

    if [ "$SNYK_ENABLED" = "true" ]; then
        if [ -z "$SNYK_TOKEN" ]; then
            echo "[ERROR] SNYK_TOKEN not set. Please set the SNYK_TOKEN environment variable"
            echo "You can get a token from https://app.snyk.io/account"
            scan_failed=1
        else
            echo "[INFO] Running Snyk scan..."
            if ! snyk test --json --severity-threshold="$SNYK_SEVERITY" > reports/snyk-results.json; then
                echo "[WARN] Snyk scan found issues"
                scan_failed=1
            fi
        fi
    fi

    if [ "$TRIVY_ENABLED" = "true" ]; then
        local severity_flag
        case "$TRIVY_SEVERITY" in
            "LOW"|"MEDIUM"|"HIGH"|"CRITICAL")
                severity_flag="$TRIVY_SEVERITY"
                ;;
            *)
                severity_flag="HIGH,CRITICAL"  # Default to HIGH,CRITICAL if invalid
                ;;
        esac

        IMAGE_NAME="${IMAGE_NAME:-ubuntu:latest}"
        echo "[INFO] Running Trivy scan on $IMAGE_NAME..."
        if ! trivy image --format json \
            --severity "$severity_flag" \
            --ignore-unfixed="${TRIVY_IGNORE_UNFIXED:-false}" \
            --output reports/trivy-results.json \
            "$IMAGE_NAME"; then
            echo "[WARN] Trivy scan found issues"
            scan_failed=1
        fi
    fi

    return $scan_failed
}
