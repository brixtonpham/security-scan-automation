```markdown
# Security Pipeline Scanner

Automated security scanning tool for CI/CD pipelines integrating Snyk and Trivy.

## Features
- Automated vulnerability scanning for dependencies and containers
- Configurable severity thresholds and ignore rules
- HTML report generation
- Integration with GitHub Actions

## Project Structure
```
security-scan-automation/
├── .github/
│   └── workflows/
│       └── security-scan.yml    # GitHub Actions workflow
├── src/
│   ├── config.sh               # Configuration management
│   ├── tools.sh                # Tool installation & checks  
│   ├── scan.sh                 # Security scanning
│   ├── analyze.sh              # Results analysis
│   ├── report.sh               # Report generation
│   └── load_env.sh             # Environment loader
├── config/
│   └── default.yaml            # Default configuration
├── reports/                    # Scan results output
├── .env                        # Environment variables
├── .env.example               # Environment template
├── .gitignore
├── README.md
└── security-scan.sh           # Main script
```

## Prerequisites
- Node.js ≥14
- Docker
- jq
- yq

## Installation
```bash
# Clone repository
git clone https://github.com/brixtonpham/security-scan-automation.git
cd security-scan-automation

# Install dependencies
npm install -g snyk

# Set environment variables
cp .env.example .env
# Edit .env with your tokens and settings
```

## Usage
```bash
# Make scripts executable
chmod +x security-scan.sh
chmod +x src/*.sh

# Run scan
./security-scan.sh
```

## Configuration
Configure scan settings in `.env`:
```bash
SNYK_TOKEN=xxx              # Required for Snyk scans
SNYK_ENABLED=true          
SNYK_SEVERITY=high

TRIVY_ENABLED=true
TRIVY_SEVERITY=HIGH
TRIVY_IGNORE_UNFIXED=false

IMAGE_NAME=ubuntu:latest    # Container to scan
```

## GitHub Actions Integration
The scanner runs automatically on:
- Push to main branch
- Pull requests
- Daily schedule

## Report Examples
Reports are generated in `reports/`:
- `report.html`: Summary and details
- `high-severity.json`: Critical/high vulnerabilities
