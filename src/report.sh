#!/bin/bash

function generate_report() {
  local vuln_count=$1
  echo "[INFO] Generating report..."
  
  cat << END > ../reports/report.html
<!DOCTYPE html>
<html>
<head>
  <title>Security Scan Report</title>
  <style>
    .high { color: red; }
  </style>
</head>
<body>
  <h1>Security Scan Results</h1>
  <p>Vulnerabilities Found: <span class="high">$vuln_count</span></p>
</body>
</html>
END
}
