#!/bin/bash

function analyze_results() {
    echo "[INFO] Analyzing scan results..."
    mkdir -p reports
    touch reports/high-severity.json

    if [ -f "reports/snyk-results.json" ]; then
        jq -r '.vulnerabilities[] | select(.severity=="high" or .severity=="critical")' \
            reports/snyk-results.json > reports/high-severity.json 2>/dev/null || true
    fi

    if [ -f "reports/trivy-results.json" ]; then
        jq -r '.Results[].Vulnerabilities[] | select(.Severity=="HIGH" or .Severity=="CRITICAL")' \
            reports/trivy-results.json >> reports/high-severity.json 2>/dev/null || true
    fi

    local count=$(jq 'length' reports/high-severity.json 2>/dev/null || echo "0")
    echo "[INFO] Found $count high/critical vulnerabilities"
    return 0
}
