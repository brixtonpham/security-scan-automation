#!/bin/bash

function analyze_results() {
    echo "[INFO] Starting analysis of scan results..."
    mkdir -p reports

    # Process Snyk results
    local snyk_output="reports/snyk-high-critical-vulnerabilities.log"
    > "$snyk_output"
    for file in reports/snyk-results-*.json; do
        if [ -s "$file" ]; then
            echo "[INFO] Processing Snyk results from $file..."
            jq -r '.vulnerabilities[]? | select(.severity=="high" or .severity=="critical") | .title + " | Severity: " + .severity + " | Package: " + .package + " | Version: " + (.version // "N/A") + " | Fix: " + (.fixedIn[0] // "N/A")' \
                "$file" >> "$snyk_output"
        fi
    done

    # Process Trivy results
    local trivy_output="reports/trivy-high-critical-vulnerabilities.log"
    > "$trivy_output"
    for file in reports/trivy-results-*.json; do
        if [ -s "$file" ]; then
            echo "[INFO] Processing Trivy results from $file..."
            jq -r '.Results[]?.Vulnerabilities[]? | select(.Severity=="HIGH" or .Severity=="CRITICAL") | .Title + " | Severity: " + .Severity + " | Package: " + .PkgName + " | Installed Version: " + (.InstalledVersion // "N/A") + " | Fix Version: " + (.FixedVersion // "N/A")' \
                "$file" >> "$trivy_output"
        fi
    done

    # Combine and print all high/critical vulnerabilities
    echo "[INFO] High/Critical Vulnerabilities Found:"
    cat "$snyk_output" "$trivy_output"

    return 0
}
