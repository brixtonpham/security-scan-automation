#!/bin/bash

# Enable error handling
set -e
trap 'echo "[ERROR] Script failed at line $LINENO"' ERR

# Load environment variables and dependencies
source src/load_env.sh
load_env

source src/config.sh
source src/tools.sh
source src/scan.sh
source src/analyze.sh
source src/report.sh

# Set default configuration values if not set in .env
export SNYK_ENABLED="${SNYK_ENABLED:-true}"
export SNYK_SEVERITY="${SNYK_SEVERITY:-high}" 
export TRIVY_ENABLED="${TRIVY_ENABLED:-true}"
export TRIVY_SEVERITY="${TRIVY_SEVERITY:-HIGH}"
export TRIVY_IGNORE_UNFIXED="${TRIVY_IGNORE_UNFIXED:-false}"
export IMAGE_NAME="${IMAGE_NAME:-ubuntu:latest}"

# Initialize logging
echo "[INFO] Starting security scan automation..."
mkdir -p reports

# Validate required environment variables
if [ "$SNYK_ENABLED" = "true" ] && [ -z "$SNYK_TOKEN" ]; then
   echo "[ERROR] SNYK_TOKEN environment variable must be set when Snyk is enabled"
   exit 1
fi

# Main execution flow
load_config || exit 1
check_tools || exit 1

# Run security scans
run_security_scans
scan_status=$?

# Analyze results and generate report
analyze_results
vuln_count=$?
generate_report $vuln_count

# Check for issues and exit accordingly
if [ $scan_status -ne 0 ] || [ $vuln_count -gt 0 ]; then
   echo "[WARN] Security issues found"
   exit 1
fi

echo "[INFO] Security scan completed successfully"
exit 0
