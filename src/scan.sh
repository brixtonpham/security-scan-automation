function run_security_scans() {
    local target_dir=$1
    local image_name=$2

    mkdir -p reports

    # Run Snyk scan
    if [ "$SNYK_ENABLED" = "true" ]; then
        echo "[INFO] Running Snyk scan on $target_dir..."
        snyk test --file="$target_dir/package.json" --json --severity-threshold="$SNYK_SEVERITY" > "reports/snyk-results-${image_name}.json" || true
    fi

    # Run Trivy scan
    if [ "$TRIVY_ENABLED" = "true" ]; then
        if [ -f "$target_dir/Dockerfile" ]; then
            echo "[INFO] Running Trivy scan on $target_dir..."
            docker build -t "${image_name}" "$target_dir" || true
            trivy image --format json \
                --severity "$TRIVY_SEVERITY" \
                --ignore-unfixed="${TRIVY_IGNORE_UNFIXED:-false}" \
                --output "reports/trivy-results-${image_name}.json" \
                "${image_name}" || true
        else
            echo "[WARN] Skipping Trivy scan for $target_dir: No Dockerfile found"
        fi
    fi
}
