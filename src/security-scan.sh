#!/bin/bash

# Root script orchestrating the security scanning process

# Set up error handling
set -e
trap 'echo "[ERROR] Script failed at line $LINENO"' ERR

# Source all components
source src/tools.sh
source src/scan.sh
source src/analyze.sh
source src/report.sh

# Main execution
echo "[INFO] Starting security scan automation..."

check_tools
run_security_scans
analyze_results
VULN_COUNT=$?
generate_report $VULN_COUNT

echo "[INFO] Security scan completed."
