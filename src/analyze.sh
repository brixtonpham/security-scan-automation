#!/bin/bash

function analyze_results() {
  echo "[INFO] Analyzing results..."
  HIGH_COUNT=0
  
  if [ -f "../reports/trivy-results.json" ]; then
    HIGH_COUNT=$(jq '.vulnerabilities | length' ../reports/trivy-results.json 2>/dev/null || echo "0")
  fi
  
  echo "[INFO] Found $HIGH_COUNT potential vulnerabilities"
  return $HIGH_COUNT
}
