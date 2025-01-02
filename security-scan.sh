#!/bin/bash

# Enable error handling
set -e
trap 'echo "[ERROR] Script failed at line $LINENO"' ERR

# Load dependencies
source src/load_env.sh
source src/config.sh
source src/tools.sh
source src/scan.sh
source src/analyze.sh
source src/report.sh

# Load env and set defaults
load_env

export SNYK_ENABLED="${SNYK_ENABLED:-true}"
export SNYK_SEVERITY="${SNYK_SEVERITY:-high}"
export TRIVY_ENABLED="${TRIVY_ENABLED:-true}"
export TRIVY_SEVERITY="${TRIVY_SEVERITY:-HIGH}"
export TRIVY_IGNORE_UNFIXED="${TRIVY_IGNORE_UNFIXED:-false}"

# Initialize
echo "[INFO] Starting security scan automation..."
mkdir -p reports

# Validate env vars
if [ "$SNYK_ENABLED" = "true" ] && [ -z "$SNYK_TOKEN" ]; then
   echo "[ERROR] SNYK_TOKEN required when Snyk is enabled"
   exit 1
fi

# Loop through all subdirectories and run scans
for dir in */; do
    # Normalize directory name for Docker image and output
    normalized_dir=$(basename "$dir" | sed 's/[^a-zA-Z0-9]/_/g')

    echo "[INFO] Scanning directory: $dir"
    run_security_scans "$dir" "$normalized_dir"
done

# Analyze results
analyze_results
vuln_count=$?
generate_report $vuln_count

# Exit based on findings
if [ $vuln_count -gt 0 ]; then
   echo "[WARN] Found $vuln_count vulnerabilities"
   exit 0
fi

echo "[INFO] Security scan completed successfully"
exit 0
