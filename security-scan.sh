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
LOG_FILE="reports/security-scan.log"
exec > >(tee -a "$LOG_FILE") 2>&1

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

# Analyze results and generate logs
analyze_results

# Combine and print all vulnerabilities from logs
snyk_log="reports/snyk-high-critical-vulnerabilities.log"
trivy_log="reports/trivy-high-critical-vulnerabilities.log"
echo "[INFO] High/Critical Vulnerabilities Found:" | tee -a "$LOG_FILE"
if [ -s "$snyk_log" ]; then
    cat "$snyk_log" | tee -a "$LOG_FILE"
fi
if [ -s "$trivy_log" ]; then
    cat "$trivy_log" | tee -a "$LOG_FILE"
fi

# Count vulnerabilities from logs
vuln_count=$( (cat "$snyk_log" "$trivy_log" | wc -l) 2>/dev/null || echo 0)

echo "[INFO] Total High/Critical Vulnerabilities: $vuln_count"

# Generate the report
generate_report "$vuln_count"

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
