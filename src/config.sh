# src/config.sh
#!/bin/bash

function load_config() {
    local default_config="config/default.yaml"
    local custom_config="config/custom.yaml"
    local output="config/merged.yaml"

    if [ ! -f "$default_config" ]; then
        echo "[ERROR] Default config not found: $default_config"
        exit 1
    }

    cp "$default_config" "$output"

    if [ -f "$custom_config" ]; then
        yq eval-all 'select(fileIndex == 0) * select(fileIndex == 1)' "$output" "$custom_config" > "${output}.tmp"
        mv "${output}.tmp" "$output"
    }

    # Export config values
    export SNYK_ENABLED=$(yq e '.tools.snyk.enabled' "$output")
    export SNYK_SEVERITY=$(yq e '.tools.snyk.severity' "$output")
    export TRIVY_ENABLED=$(yq e '.tools.trivy.enabled' "$output")
    export TRIVY_SEVERITY=$(yq e '.tools.trivy.severity' "$output")
    export TRIVY_IGNORE_UNFIXED=$(yq e '.tools.trivy.ignore_unfixed' "$output")
    export SLACK_ENABLED=$(yq e '.notifications.slack.enabled' "$output")
    export SLACK_WEBHOOK=$(yq e '.notifications.slack.webhook' "$output")
}

# config/default.yaml
tools:
  snyk:
    enabled: true
    severity: high
    ignore_dev_dependencies: true
  trivy:
    enabled: true
    severity: critical
    ignore_unfixed: true

notifications:
  slack:
    enabled: false
    webhook: ${SLACK_WEBHOOK}

report:
  format: html
  output_dir: reports
