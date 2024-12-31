#!/bin/bash

# Set up error handling
set -e
trap 'echo "[ERROR] Script failed at line $LINENO"' ERR

# Source all components
source src/load_env.sh
source src/tools.sh
source src/scan.sh
source src/analyze.sh
source src/report.sh

# Load environment variables
load_env

# Main execution
echo "[INFO] Starting security scan automation..."

# Create reports directory
mkdir -p reports

# Run tools and scans
check_tools || true
run_security_scans || true
analyze_results || true
VULN_COUNT=$?
generate_report $VULN_COUNT

echo "[INFO] Security scan completed."
exit 0
