# Security Scan Automation

Automated security scanning script that integrates Snyk and Trivy for comprehensive security analysis of dependencies and containers.

## Features

- Automated installation of security tools (Snyk, Trivy)
- Dependency scanning with Snyk
- Container image scanning with Trivy
- HTML report generation
- Configurable severity thresholds
- Notification support (Slack/Email)

## Prerequisites

- Linux/WSL environment
- Node.js (for Snyk)
- Docker (for container scanning)
- curl, jq

## Installation

```bash
# Clone repository
git clone https://github.com/brixtonpham/security-scan-automation.git
cd security-scan-automation

# Install dependencies
sudo apt-get update
sudo apt-get install -y jq curl

# Set up environment variables
export SNYK_TOKEN="your-snyk-token"
export IMAGE_NAME="image-to-scan:tag"
```

## Usage

```bash
./security-scan.sh
```

Results will be available in the `reports` directory.

## Configuration

Edit `config/default.yaml` to customize:
- Tool settings
- Severity thresholds
- Notification preferences
- Report format

