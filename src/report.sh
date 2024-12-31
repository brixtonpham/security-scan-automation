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
    
    echo "[INFO] Generating HTML report..."

    cat > reports/report.html << 'EOFHTML'
<!DOCTYPE html>
<html>
<head>
    <title>Security Scan Report</title>
    <style>
        body { font-family: Arial, sans-serif; line-height: 1.6; margin: 0; padding: 20px; }
        .container { max-width: 1200px; margin: 0 auto; }
        .high { color: #dc3545; }
        .critical { color: #721c24; font-weight: bold; }
        .summary { background: #f8f9fa; padding: 15px; border-radius: 4px; margin: 20px 0; }
        table { width: 100%; border-collapse: collapse; margin: 20px 0; }
        th, td { padding: 12px; border: 1px solid #dee2e6; text-align: left; }
        th { background: #f8f9fa; }
    </style>
</head>
<body>
    <div class="container">
        <h1>Security Scan Report</h1>
        
        <div class="summary">
            <h2>Summary</h2>
            <p>Scan Time: $start_time</p>
            <p>Total High/Critical Vulnerabilities: <span class="high">$vuln_count</span></p>
            <p>Scanned Image: ${IMAGE_NAME:-N/A}</p>
        </div>

        <h2>Vulnerability Details</h2>
        <table>
            <thead>
                <tr>
                    <th>Title</th>
                    <th>Severity</th>
                    <th>Package</th>
                    <th>Version</th>
                    <th>Fix Version</th>
                </tr>
            </thead>
            <tbody>
EOFHTML

    if [ -f "reports/high-severity.json" ]; then
        while IFS= read -r vuln; do
            title=$(echo "$vuln" | jq -r '.Title // .title // "N/A"')
            severity=$(echo "$vuln" | jq -r '.Severity // .severity // "N/A"')
            package=$(echo "$vuln" | jq -r '.PkgName // .package // "N/A"')
            version=$(echo "$vuln" | jq -r '.InstalledVersion // .version // "N/A"')
            fix=$(echo "$vuln" | jq -r '.FixedVersion // .fixedIn[0] // "N/A"')

            cat >> reports/report.html << EOFROW
                <tr>
                    <td>$title</td>
                    <td class="${severity,,}">$severity</td>
                    <td>$package</td>
                    <td>$version</td>
                    <td>$fix</td>
                </tr>
EOFROW
        done < <(jq -c '.[]' reports/high-severity.json)
    fi

    cat >> reports/report.html << 'EOFHTML'
            </tbody>
        </table>
    </div>
</body>
</html>
EOFHTML

    if [ "$vuln_count" -gt 0 ]; then
        send_notification "⚠️ Security Scan found $vuln_count high/critical vulnerabilities!"
    fi

    echo "[INFO] Report generated: reports/report.html"
}
