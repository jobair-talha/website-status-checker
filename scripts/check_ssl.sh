#!/bin/bash

WEBSITES_FILE="../config/websites.list"
LOG_SSL="../logs/ssl_checks.log"

while read -r website; do
    domain=$(echo "$website" | awk -F/ '{print $3}')
    expiry_date=$(openssl s_client -connect "$domain:443" -servername "$domain" 2>/dev/null | openssl x509 -noout -dates | grep "notAfter" | cut -d= -f2)
    
    echo "$(date '+%Y-%m-%d %H:%M:%S') | $domain | SSL Expires: $expiry_date" >> "$LOG_SSL"
    
    # Check if SSL expires in < 7 days
    expiry_epoch=$(date -d "$expiry_date" +%s)
    current_epoch=$(date +%s)
    days_left=$(( (expiry_epoch - current_epoch) / 86400 ))
    
    if [ "$days_left" -lt 7 ]; then
        ../scripts/send_alert.sh "⚠️ SSL for $domain expires in $days_left days!"  
    fi
done < "$WEBSITES_FILE"