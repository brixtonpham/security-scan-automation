#!/bin/bash

function send_notification() {
    local message="$1"

    if [ "$SLACK_ENABLED" = "true" ] && [ -n "$SLACK_WEBHOOK" ]; then
        echo "[INFO] Sending Slack notification..."
        curl -X POST -H 'Content-type: application/json' \
             --data "{\"text\":\"$message\"}" "$SLACK_WEBHOOK"
    fi
}

function generate_report() {
    local vuln_count=$1
    local start_time=$(date -u +"%Y-%m-%d %H:%M:%S UTC")

    echo "[INFO] Generating consolidated HTML report..."

    # Tạo file HTML
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
        .medium { color: #ff8800; }
        .low { color: #28a745; }
        .info { color: #17a2b8; }
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
            <h2>Vulnerability Distribution</h2>
            <p>Below is the detailed distribution of vulnerabilities found during the scan:</p>
EOFHTML

    # Duyệt qua các file Snyk và Trivy JSON
    for json_file in reports/snyk-results-*.json reports/trivy-results-*.json; do
        if [ -s "$json_file" ]; then
            report_name=$(basename "$json_file" | sed 's/\.[^.]*$//')
            cat >> reports/report.html << EOFTABLE
            <h3>Results from: ${report_name}</h3>
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
EOFTABLE

            if grep -q '"Results"' "$json_file"; then
                jq -c '.Results[] | select(.Vulnerabilities != null) | .Vulnerabilities[]' "$json_file" | while read -r vuln; do
                    title=$(echo "$vuln" | jq -r '.Title // "N/A"')
                    severity=$(echo "$vuln" | jq -r '.Severity // "N/A"')
                    package=$(echo "$vuln" | jq -r '.PkgName // "N/A"')
                    installed=$(echo "$vuln" | jq -r '.InstalledVersion // "N/A"')
                    fixed=$(echo "$vuln" | jq -r '.FixedVersion // "N/A"')

                    cat >> reports/report.html << EOFROW
                    <tr>
                        <td>${title}</td>
                        <td class="${severity,,}">${severity}</td>
                        <td>${package}</td>
                        <td>${installed}</td>
                        <td>${fixed}</td>
                    </tr>
EOFROW
                done
            else
                jq -c '.vulnerabilities[]' "$json_file" | while read -r vuln; do
                    title=$(echo "$vuln" | jq -r '.title // "N/A"')
                    severity=$(echo "$vuln" | jq -r '.severity // "N/A"')
                    package=$(echo "$vuln" | jq -r '.package // "N/A"')
                    version=$(echo "$vuln" | jq -r '.version // "N/A"')
                    fix=$(echo "$vuln" | jq -r '.fixedIn[0] // "N/A"')

                    cat >> reports/report.html << EOFROW
                    <tr>
                        <td>${title}</td>
                        <td class="${severity,,}">${severity}</td>
                        <td>${package}</td>
                        <td>${version}</td>
                        <td>${fix}</td>
                    </tr>
EOFROW
                done
            fi

            cat >> reports/report.html << EOFEND
                </tbody>
            </table>
EOFEND
        else
            echo "[WARN] Skipping empty or missing JSON file: ${json_file}" >> reports/log.txt
        fi
    done

    cat >> reports/report.html << EOFHTML
        </div>
    </div>
</body>
</html>
EOFHTML

    echo "[INFO] Report generated: reports/report.html"
}


