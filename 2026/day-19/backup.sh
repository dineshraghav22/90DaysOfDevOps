#!/bin/bash
set -euo pipefail

SOURCE="${1:-}"
DEST="${2:-}"

if [ -z "$SOURCE" ] || [ -z "$DEST" ]; then
    echo "Usage: $0 <source-dir> <backup-dest-dir>"
    exit 1
fi

if [ ! -d "$SOURCE" ]; then
    echo "Error: Source directory '$SOURCE' does not exist."
    exit 1
fi

mkdir -p "$DEST"

TIMESTAMP=$(date +%Y-%m-%d_%H-%M-%S)
ARCHIVE_NAME="backup-${TIMESTAMP}.tar.gz"
ARCHIVE_PATH="${DEST}/${ARCHIVE_NAME}"

echo "[$(date)] Creating backup of '$SOURCE'..."
tar -czf "$ARCHIVE_PATH" -C "$(dirname "$SOURCE")" "$(basename "$SOURCE")"

if [ -f "$ARCHIVE_PATH" ]; then
    SIZE=$(du -sh "$ARCHIVE_PATH" | cut -f1)
    echo "[$(date)] Archive created: $ARCHIVE_NAME (Size: $SIZE)"
else
    echo "Error: Archive creation failed."
    exit 1
fi

# Delete backups older than 14 days
PURGED=0
while IFS= read -r -d '' file; do
    rm -f "$file" && echo "  Purged old backup: $file" && PURGED=$((PURGED + 1))
done < <(find "$DEST" -name "backup-*.tar.gz" -mtime +14 -print0 2>/dev/null)

echo "[$(date)] Done. Purged $PURGED old backups."
