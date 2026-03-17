#!/bin/bash
set -euo pipefail

LOG_FILE="/var/log/application.log"
BACKUP_DIR="/var/log/archive"
RETENTION_DAYS=5
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

if [[ $EUID -ne 0 ]]; then
    echo "Error: This script must be run as root (sudo)."
    exit 1
fi

if [ ! -f "$LOG_FILE" ]; then
    echo "$LOG_FILE not found. Nothing to rotate."
    exit 0
fi

mkdir -p "$BACKUP_DIR"

cp "$LOG_FILE" "$BACKUP_DIR/application.log.$TIMESTAMP"
truncate -s 0 "$LOG_FILE"

gzip "$BACKUP_DIR/application.log.$TIMESTAMP"

find "$BACKUP_DIR" -name "application.log.*.gz" -mtime +$RETENTION_DAYS -delete