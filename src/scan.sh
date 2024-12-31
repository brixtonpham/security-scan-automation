#!/bin/bash

function run_security_scans() {
  mkdir -p ../reports
  echo "[INFO] Starting security scans..."
  
  # Scan with Trivy
  IMAGE_NAME="${IMAGE_NAME:-ubuntu:latest}"
  trivy image --format json --output ../reports/trivy-results.json "$IMAGE_NAME"
}
