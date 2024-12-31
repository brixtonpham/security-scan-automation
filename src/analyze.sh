# src/analyze.sh
#!/bin/bash

function analyze_results() {
    echo "[INFO] Analyzing scan results..."
    local high_count=0

    # Process Snyk results
    if [ -f "reports/snyk-results.json" ]; then
        jq -r '.vulnerabilities[] | select(.severity=="high" or .severity=="critical")' \
            reports/snyk-results.json > reports/high-severity.json 2>/dev/null
        high_count=$((high_count + $(jq '. | length' reports/high-severity.json 2>/dev/null || echo "0")))
    fi

    # Process Trivy results
    if [ -f "reports/trivy-results.json" ]; then
        jq -r '.Results[].Vulnerabilities[] | select(.Severity=="HIGH" or .Severity=="CRITICAL")' \
            reports/trivy-results.json >> reports/high-severity.json 2>/dev/null
        high_count=$((high_count + $(jq '. | length' reports/high-severity.json 2>/dev/null || echo "0")))
    fi

    echo "[INFO] Found $high_count high/critical vulnerabilities"
    return $high_count
}
