#!/bin/bash

LOG_UPTIME="../logs/uptime.log"
LOG_RESPONSE_TIME="../logs/response_times.log"
REPORT_FILE="../logs/report_$(date '+%Y-%m-%d').txt"

{
    echo "=== Uptime Summary ==="
    grep "UP" "$LOG_UPTIME" | wc -l | awk '{print "Total UP times:", $1}'
    grep "DOWN" "$LOG_UPTIME" | wc -l | awk '{print "Total DOWN times:", $1}'
    
    echo -e "\n=== Response Times (Last 10 Checks) ==="
    tail -n 10 "$LOG_RESPONSE_TIME"
} > "$REPORT_FILE"

echo "Report generated: $REPORT_FILE"