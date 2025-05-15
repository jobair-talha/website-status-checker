#!/bin/bash

# Define paths
BASE_DIR="/d/Operating System Lab/website-status-checker"
WEBSITES_FILE="$BASE_DIR/config/websites.list"
ALERT_CONFIG="$BASE_DIR/config/alert_settings.conf"
LOG_UPTIME="$BASE_DIR/logs/uptime.log"
LOG_RESPONSE_TIME="$BASE_DIR/logs/response_times.log"
ALERT_SCRIPT="$BASE_DIR/scripts/send_alert.sh"

# Read alert threshold from config
THRESHOLD=$(grep ALERT_THRESHOLD_MS "$ALERT_CONFIG" | cut -d= -f2)

# Validate threshold
if ! [[ "$THRESHOLD" =~ ^[0-9]+$ ]]; then
    echo "Error: ALERT_THRESHOLD_MS is not set correctly in $ALERT_CONFIG"
    exit 1
fi

# Monitor each website
while read -r website; do
    # Skip empty or invalid lines
    [[ -z "$website" || ! "$website" =~ ^https?:// ]] && continue

    timestamp=$(date '+%Y-%m-%d %H:%M:%S')

    # Get response time in ms
    response_time=$(curl -o /dev/null -s -w "%{time_total}\n" "$website" | awk '{printf "%.0f", $1 * 1000}')
    echo "$timestamp | $website | Response: ${response_time}ms" >> "$LOG_RESPONSE_TIME"

    # Check website status
    if curl -s -I "$website" | head -n 1 | grep -q "200"; then
        echo "$timestamp | $website | UP" >> "$LOG_UPTIME"
    else
        echo "$timestamp | $website | DOWN" >> "$LOG_UPTIME"
        "$ALERT_SCRIPT" "$website is DOWN!"
    fi

    # Check for slow response
    if [ "$response_time" -gt "$THRESHOLD" ]; then
        "$ALERT_SCRIPT" "$website is SLOW (${response_time}ms)!"
    fi
done < "$WEBSITES_FILE"

