
# **Security Pipeline Scanner**

An **automated security scanning tool** for CI/CD pipelines, integrating **Snyk** and **Trivy** for comprehensive vulnerability detection.

---

## **Table of Contents**
- [Features](#features)
- [Project Structure](#project-structure)
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Configuration](#configuration)
- [Usage](#usage)
- [CI/CD Integration](#cicd-integration)
- [Reports](#reports)

---

## **Features**
- 🔒 **Automated vulnerability scanning** for dependencies using Snyk.
- 🐳 **Container image scanning** with Trivy.
- 🎛️ **Configurable severity thresholds** and ignore rules.
- 📊 **HTML report generation** for clear insights.
- 🔧 **GitHub Actions integration** for CI/CD pipelines.
- 🌐 **Environment-based configuration** for flexible setups.

---

## **Project Structure**
```plaintext
security-scan-automation/
├── .github/
│   └── workflows/
│       └── security-scan.yml    # GitHub Actions workflow
├── src/
│   ├── config.sh                # Configuration management  
│   ├── tools.sh                 # Tool installation & checks
│   ├── scan.sh                  # Security scanning implementation
│   ├── analyze.sh               # Results analysis 
│   ├── report.sh                # Report generation
│   └── load_env.sh              # Environment loader
├── config/
│   └── default.yaml             # Default configuration
├── reports/                     # Generated scan results
├── .env                         # Environment variables
├── .gitignore
├── README.md
└── security-scan.sh             # Main executable script
```

---

## **Prerequisites**
- **Node.js** ≥14
- **Docker Desktop**
- **jq** for JSON processing
- **yq** for YAML processing
- **Git** (optional, for version control)

---

## **Installation**

### **Clone the Repository**
```bash
git clone https://github.com/brixtonpham/security-scan-automation.git
cd security-scan-automation
```

### **Install Dependencies**
```bash
# Install Node dependencies
npm install -g snyk

# Install system dependencies
sudo apt-get update
sudo apt-get install -y jq curl
sudo wget https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 -O /usr/local/bin/yq
sudo chmod +x /usr/local/bin/yq
```

### **Setup Environment**
```bash
# Create environment file
cp .env.example .env

# Edit .env with your configuration
nano .env
```

---

## **Configuration**

### **Environment Variables (.env)**
```bash
# Security Tokens
SNYK_TOKEN=xxx                # Required for Snyk scans
# Tool Settings
SNYK_ENABLED=true
SNYK_SEVERITY=high
TRIVY_ENABLED=true
TRIVY_SEVERITY=HIGH
TRIVY_IGNORE_UNFIXED=false

# Container Settings
IMAGE_NAME=ubuntu:latest
```

### **Default Configuration (config/default.yaml)**
```yaml
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
```

---

## **Usage**

### **Basic Usage**
```bash
# Make scripts executable
chmod +x security-scan.sh
chmod +x src/*.sh

# Run security scan
./security-scan.sh
```

### **Custom Configuration**
```bash
# Scan specific image
IMAGE_NAME=node:16 ./security-scan.sh

# Custom severity
SNYK_SEVERITY=medium TRIVY_SEVERITY=HIGH ./security-scan.sh
```

---

## **CI/CD Integration**

### **GitHub Actions**
The included workflow runs scans on:
- Push to the `main` branch.
- Pull requests.
- Scheduled runs daily at 00:00 UTC.

**Example workflow:**
```yaml
jobs:
  security-scan:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Run Security Scan
        env:
          SNYK_TOKEN: ${{ secrets.SNYK_TOKEN }}
        run: |
          chmod +x security-scan.sh
          ./security-scan.sh
```

### **Jenkins Pipeline**
```groovy
pipeline {
    agent any
    environment {
        SNYK_TOKEN = credentials('snyk-token')
    }
    stages {
        stage('Security Scan') {
            steps {
                sh 'chmod +x security-scan.sh'
                sh './security-scan.sh'
            }
        }
    }
}
```

---

## **Reports**

### **Report Locations**
- **HTML Report**: `reports/report.html` (Main summary).
- **High-Severity Issues**: `reports/high-severity.json`.
- **Raw Snyk Results**: `reports/snyk-results.json`.
- **Raw Trivy Results**: `reports/trivy-results.json`.

### **Report Format**
The **HTML report** includes:
1. **Executive Summary**
2. **Vulnerability Counts by Severity**
3. **Detailed Findings**
4. **Remediation Recommendations**
5. **Scan Metadata**
---

## **Acknowledgments**
- **Snyk** - Dependency scanning.
- **Trivy** - Container scanning.
- **GitHub Actions** - CI/CD automation.
