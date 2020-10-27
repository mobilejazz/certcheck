#!/bin/bash
MARGIN_DAYS=${MARGIN_DAYS:-6} # 6 days margin by default
MARGIN_SECONDS=$(($MARGIN_DAYS * 86400))

DOMAINS_FILE="${DOMAINS_FILE:-$1}"
if [ -n "$DOMAINS_FILE" ]; then
    DOMAINS=$(cat $DOMAINS_FILE)
fi
if [ -z "$DOMAINS" ]; then
    cat >&2 <<EOF
Usage:
    $0 filename_with_domains.txt
    or DOMAINS_FILE="filename_with_domains.txt" $0
    or DOMAINS="example.com anotherdomain.com" $0
EOF
    exit 1
fi

for DOMAIN in $DOMAINS; do
    EXPIRY=$(openssl s_client -servername "$DOMAIN" -connect "$DOMAIN:443" </dev/null 2>&1 | openssl x509 -noout -text 2>/dev/null | grep "Not After :" | sed 's/.*: //')
    if [ -z "$EXPIRY" ]; then
        echo $DOMAIN does not support SSL
        ERRORS=${ERRORS}"$DOMAIN does not support SSL\n"
    else
        EXPIRY_TIMESTAMP=$(date --version >/dev/null 2>&1 && date '+%s' -d "$EXPIRY" || date -jf '%b %d %H:%M:%S %Y %Z' "$EXPIRY" '+%s')
        NOW_TIMESTAMP=$(date '+%s')
        TIMESTAMP_DIFF=$(($EXPIRY_TIMESTAMP - $NOW_TIMESTAMP))
        if (( $TIMESTAMP_DIFF < $MARGIN_SECONDS )); then
            echo $DOMAIN expires in $EXPIRY, $EXPIRY_TIMESTAMP - $NOW_TIMESTAMP
            ERRORS=${ERRORS}"$DOMAIN expires in $EXPIRY, $EXPIRY_TIMESTAMP - $NOW_TIMESTAMP\n"
        fi
    fi
done

if [ -n "$MAIL_TO" ] && [ -n "$ERRORS" ]; then
  echo -e "To: $MAIL_TO\nSubject: Certificate check failed\n\n$ERRORS" | sendmail "$MAIL_TO"
fi
