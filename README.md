# Security Scan Automation

Automated security scanning tool that integrates with DevOps pipelines to detect vulnerabilities in dependencies and containers.

## Features

- Automated tool installation (Snyk, Trivy)
- Dependency and container scanning
- Configurable severity thresholds
- HTML report generation
- Slack notifications
- GitHub Actions integration

## Requirements

- Linux/WSL environment 
- Node.js 16+
- Docker
- jq, curl

## Installation

```bash
# Clone repository
git clone https://github.com/brixtonpham/security-scan-automation.git
cd security-scan-automation

# Install dependencies
sudo apt-get update && sudo apt-get install -y jq curl
sudo wget https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 -O /usr/local/bin/yq
sudo chmod +x /usr/local/bin/yq

# Configure environment variables
export SNYK_TOKEN="your-snyk-token"
export SLACK_WEBHOOK="your-slack-webhook-url" 
export IMAGE_NAME="image-to-scan:tag"
```

## Usage

```bash
./security-scan.sh
```

Results will be in the `reports` directory:
- report.html: Detailed HTML report
- high-severity.json: JSON list of critical findings

## Configuration

Edit `config/default.yaml` or create `config/custom.yaml` to customize:

```yaml
tools:
  snyk:
    enabled: true
    severity: high
  trivy:
    enabled: true
    severity: critical
    ignore_unfixed: true

notifications:
  slack:
    enabled: false
    webhook: ${SLACK_WEBHOOK}
```

## GitHub Actions

The project includes GitHub Actions workflow that:
- Runs on push/PR to main branch
- Executes daily security scans
- Uploads scan results as artifacts

Required secrets:
- SNYK_TOKEN
- SLACK_WEBHOOK

## Project Structure

```
security-scan-automation/
├── src/
│   ├── tools.sh       # Tool management
│   ├── scan.sh        # Security scanning
│   ├── analyze.sh     # Result analysis
│   └── report.sh      # Report generation
├── config/
│   └── default.yaml   # Default configuration
├── .github/
│   └── workflows/     # GitHub Actions
└── reports/           # Scan results
```

## License

MIT
