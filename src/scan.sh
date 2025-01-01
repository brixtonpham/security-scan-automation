# src/scan.sh
#!/bin/bash

function run_security_scans() {
    mkdir -p reports

    if [ "$SNYK_ENABLED" = "true" ]; then
        if [ -z "$SNYK_TOKEN" ]; then
            echo "[ERROR] SNYK_TOKEN not set"
            return 0
        fi
        echo "[INFO] Running Snyk scan..."
        snyk test --json --severity-threshold="$SNYK_SEVERITY" > reports/snyk-results.json || true
    fi

    if [ "$TRIVY_ENABLED" = "true" ]; then
        local severity_flag="HIGH,CRITICAL"
        if [[ "$TRIVY_SEVERITY" =~ ^(LOW|MEDIUM|HIGH|CRITICAL)$ ]]; then
            severity_flag="$TRIVY_SEVERITY"
        fi

        echo "[INFO] Running Trivy scan on $IMAGE_NAME..."
        trivy image --format json \
            --severity "$severity_flag" \
            --ignore-unfixed="${TRIVY_IGNORE_UNFIXED:-false}" \
            --output reports/trivy-results.json \
            "$IMAGE_NAME" || true
    fi

    return 0
}
