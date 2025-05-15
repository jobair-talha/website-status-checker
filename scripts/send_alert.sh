#!/bin/bash

MESSAGE="$1"
BASE_DIR="/d/Operating System Lab/website-status-checker"
CONFIG_FILE="$BASE_DIR/config/alert_settings.conf"
LOG_FILE="$BASE_DIR/logs/alerts.log"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

# Load email and Slack config
EMAIL=$(grep "^EMAIL=" "$CONFIG_FILE" | cut -d= -f2)
SLACK_WEBHOOK=$(grep "^SLACK_WEBHOOK=" "$CONFIG_FILE" | cut -d= -f2)

# Try to send email (not available on Windows, fallback to logging)
if command -v mail >/dev/null 2>&1; then
    echo "$MESSAGE" | mail -s "Website Alert" "$EMAIL"
else
    echo "$TIMESTAMP | ALERT (EMAIL NOT SENT): $MESSAGE" >> "$LOG_FILE"
fi

# Send Slack alert if webhook is set
if [ -n "$SLACK_WEBHOOK" ]; then
    curl -X POST -H "Content-type: application/json" --data "{\"text\":\"$MESSAGE\"}" "$SLACK_WEBHOOK"
else
    echo "$TIMESTAMP | ALERT (NO SLACK WEBHOOK): $MESSAGE" >> "$LOG_FILE"
fi
