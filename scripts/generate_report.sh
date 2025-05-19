#!/bin/bash

BASE_DIR="/d/Operating System Lab/website-status-checker"
LOG_UPTIME="$BASE_DIR/logs/uptime.log"
LOG_RESPONSE_TIME="$BASE_DIR/logs/response_times.log"
LOG_SSL="$BASE_DIR/logs/ssl_checks.log"
REPORT_FILE="$BASE_DIR/logs/report_$(date '+%Y-%m-%d').txt"

{
    echo "=== Uptime Summary ==="
    grep "UP" "$LOG_UPTIME" | wc -l | awk '{print "Total UP times:", $1}'
    grep "DOWN" "$LOG_UPTIME" | wc -l | awk '{print "Total DOWN times:", $1}'

    echo -e "\n=== Response Times (Last 10 Checks) ==="
    tail -n 10 "$LOG_RESPONSE_TIME"

    echo -e "\n=== SSL Expiry Summary (Latest Check Per Domain) ==="
    tac "$LOG_SSL" | awk -F'|' '!seen[$2]++ {print $1 " |" $2 " |" $3}' | tac
} > "$REPORT_FILE"

echo "Report generated: $REPORT_FILE"