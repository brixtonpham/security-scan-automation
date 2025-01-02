#!/bin/bash

function create_reports_directory() {
    if [ ! -d "reports" ]; then
        echo "[INFO] Creating reports directory..."
        mkdir -p reports
    fi
}

function count_vulnerabilities_from_logs() {
    local trivy_file="reports/trivy-high-critical-vulnerabilities.log"
    local snyk_file="reports/snyk-high-critical-vulnerabilities.log"

    # Check if files exist and are not empty
    local trivy_count=0
    local snyk_count=0

    if [ -f "$trivy_file" ]; then
        trivy_count=$(wc -l < "$trivy_file")
    fi

    if [ -f "$snyk_file" ]; then
        snyk_count=$(wc -l < "$snyk_file")
    fi

    # Calculate total count
    local total_count=$((trivy_count + snyk_count))

    # Return the count (do not echo here for silent execution)
    echo "$total_count"
}


function generate_report() {
    local vuln_count=$1
    local start_time=$(date -u +"%Y-%m-%d %H:%M:%S UTC")

    create_reports_directory

    echo "[INFO] Generating consolidated HTML report with $vuln_count vulnerabilities..."

    cat > reports/report.html << EOFHTML
<html>
<head>
    <title>Security Scan Report</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; line-height: 1.6; }
        .container { max-width: 800px; margin: 0 auto; background-color: #f9f9f9; padding: 20px; border-radius: 8px; box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1); }
        h1, h2, h3 { text-align: center; color: #333; }
        .summary, .details { margin-bottom: 20px; }
        .summary { padding: 15px; border: 1px solid #ddd; background-color: #fff; }
        .summary p { margin: 0; padding: 5px 0; }
        table { width: 100%; border-collapse: collapse; margin-top: 20px; }
        th, td { padding: 10px; border: 1px solid #ddd; text-align: left; }
        th { background-color: #f2f2f2; }
        .critical { color: red; font-weight: bold; }
        .high { color: #dc3545; font-weight: bold; }
    </style>
</head>
<body>
    <div class="container">
        <h1>Security Scan Report</h1>
        <div class="summary">
            <h2>Summary</h2>
            <p><strong>Scan Time:</strong> ${start_time}</p>
            <p><strong>Total High/Critical Vulnerabilities:</strong> <span class="critical">${vuln_count}</span></p>
        </div>
        <div class="details">
            <h2>Vulnerability Details</h2>
            <h3>Trivy Results</h3>
            <table>
                <thead>
                    <tr>
                        <th>Title</th>
                        <th>Severity</th>
                        <th>Package</th>
                        <th>Installed Version</th>
                        <th>Fix Version</th>
                    </tr>
                </thead>
                <tbody>
EOFHTML

    # Process Trivy log for detailed table
    local trivy_file="reports/trivy-high-critical-vulnerabilities.log"
    if [ -f "$trivy_file" ] && [ -s "$trivy_file" ]; then
        while IFS='|' read -r title severity package installed fix; do
            cat >> reports/report.html << EOFROW
                <tr>
                    <td>${title}</td>
                    <td class="high">${severity}</td>
                    <td>${package}</td>
                    <td>${installed}</td>
                    <td>${fix}</td>
                </tr>
EOFROW
        done < "$trivy_file"
    else
        cat >> reports/report.html << EOFEMPTY
                <tr><td colspan="5">No vulnerabilities found in Trivy results.</td></tr>
EOFEMPTY
    fi

    cat >> reports/report.html << EOFTABLEEND
                </tbody>
            </table>
            <h3>Snyk Results</h3>
            <table>
                <thead>
                    <tr>
                        <th>Title</th>
                        <th>Severity</th>
                        <th>Package</th>
                        <th>Installed Version</th>
                        <th>Fix Version</th>
                    </tr>
                </thead>
                <tbody>
EOFTABLEEND

    # Process Snyk log for detailed table
    local snyk_file="reports/snyk-high-critical-vulnerabilities.log"
    if [ -f "$snyk_file" ] && [ -s "$snyk_file" ]; then
        while IFS='|' read -r title severity package installed fix; do
            cat >> reports/report.html << EOFROW
                <tr>
                    <td>${title}</td>
                    <td class="high">${severity}</td>
                    <td>${package}</td>
                    <td>${installed}</td>
                    <td>${fix}</td>
                </tr>
EOFROW
        done < "$snyk_file"
    else
        cat >> reports/report.html << EOFEMPTY
                <tr><td colspan="5">No vulnerabilities found in Snyk results.</td></tr>
EOFEMPTY
    fi

    cat >> reports/report.html << EOFEND
                </tbody>
            </table>
        </div>
    </div>
</body>
</html>
EOFEND

    echo "[INFO] Report generated: reports/report.html"
}

# # Main execution flow
# vuln_count=$(count_vulnerabilities_from_logs)
# generate_report "$vuln_count"
