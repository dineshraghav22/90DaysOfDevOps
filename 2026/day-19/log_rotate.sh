#!/bin/bash
set -euo pipefail

LOG_DIR="${1:-}"

if [ -z "$LOG_DIR" ]; then
    echo "Usage: $0 <log-directory>"
    exit 1
fi

if [ ! -d "$LOG_DIR" ]; then
    echo "Error: Directory '$LOG_DIR' does not exist."
    exit 1
fi

echo "[$(date)] Starting log rotation for: $LOG_DIR"

# Compress .log files older than 7 days
COMPRESSED=0
while IFS= read -r -d '' file; do
    gzip "$file" && echo "  Compressed: $file" && COMPRESSED=$((COMPRESSED + 1))
done < <(find "$LOG_DIR" -name "*.log" -mtime +7 -print0 2>/dev/null)

# Delete .gz files older than 30 days
DELETED=0
while IFS= read -r -d '' file; do
    rm -f "$file" && echo "  Deleted: $file" && DELETED=$((DELETED + 1))
done < <(find "$LOG_DIR" -name "*.gz" -mtime +30 -print0 2>/dev/null)

echo "[$(date)] Done. Compressed: $COMPRESSED files, Deleted: $DELETED files."
