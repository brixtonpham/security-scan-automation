#!/bin/bash

set -e
trap 'echo "[ERROR] Script failed at line $LINENO"' ERR

# Source all components
source src/config.sh
source src/tools.sh
source src/scan.sh
source src/analyze.sh
source src/report.sh

echo "[INFO] Starting security scan automation..."

# Load configuration
load_config

# Check and install tools
check_tools || exit 1

# Run scans
run_security_scans
scan_status=$?

# Analyze results and generate report
analyze_results
vuln_count=$?
generate_report $vuln_count

# Exit with status
if [ $scan_status -ne 0 ] || [ $vuln_count -gt 0 ]; then
    echo "[WARN] Security issues found"
    exit 1
fi

echo "[INFO] Security scan completed successfully"
