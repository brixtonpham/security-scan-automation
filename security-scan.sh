
# security-scan.sh updates
#!/bin/bash

set -e
trap 'echo "[ERROR] Script failed at line $LINENO"' ERR

# Load helper functions
source src/config.sh
source src/tools.sh
source src/scan.sh
source src/analyze.sh
source src/report.sh

# Set default config values
export SNYK_ENABLED="${SNYK_ENABLED:-true}"
export SNYK_SEVERITY="${SNYK_SEVERITY:-high}"
export TRIVY_ENABLED="${TRIVY_ENABLED:-true}"
export TRIVY_SEVERITY="${TRIVY_SEVERITY:-HIGH}"
export TRIVY_IGNORE_UNFIXED="${TRIVY_IGNORE_UNFIXED:-false}"

echo "[INFO] Starting security scan automation..."

# Ensure SNYK_TOKEN is set if Snyk is enabled
if [ "$SNYK_ENABLED" = "true" ] && [ -z "$SNYK_TOKEN" ]; then
    echo "[ERROR] SNYK_TOKEN environment variable must be set when Snyk is enabled"
    exit 1
fi

# Load config and run scans
load_config || exit 1
check_tools || exit 1
run_security_scans
scan_status=$?

analyze_results
vuln_count=$?
generate_report $vuln_count

if [ $scan_status -ne 0 ] || [ $vuln_count -gt 0 ]; then
    echo "[WARN] Security issues found"
    exit 1
fi

echo "[INFO] Security scan completed successfully"
