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

# Load environment variables and set defaults
load_env

export SNYK_ENABLED="${SNYK_ENABLED:-true}"
export SNYK_SEVERITY="${SNYK_SEVERITY:-high}"
export TRIVY_ENABLED="${TRIVY_ENABLED:-true}"
export TRIVY_SEVERITY="${TRIVY_SEVERITY:-HIGH}"
export TRIVY_IGNORE_UNFIXED="${TRIVY_IGNORE_UNFIXED:-false}"

# Initialize
echo "[INFO] Starting security scan automation..."
mkdir -p reports

# Validate environment variables
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
    echo "[INFO] Finished scanning $dir"
done
# Analyze results and capture vulnerability count
vuln_count=$(count_vulnerabilities_from_logs)

# Print the total for debugging or user information (if necessary)
echo "[INFO] Total High/Critical Vulnerabilities: $vuln_count"

# Generate the report
generate_report "$vuln_count"


# Validate that vuln_count is a number
if ! [[ "$vuln_count" =~ ^[0-9]+$ ]]; then
    echo "[ERROR] analyze_results returned invalid output: $vuln_count" >&2
    exit 1
fi

# Check vulnerability count
if [[ $vuln_count -gt 0 ]]; then
    echo "[WARN] Found $vuln_count vulnerabilities."
    exit 1
else
    echo "[INFO] No high/critical vulnerabilities found."
fi

# Completion message
echo "[INFO] Security scan completed successfully"
exit 0
