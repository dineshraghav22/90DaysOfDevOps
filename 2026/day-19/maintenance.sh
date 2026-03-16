#!/bin/bash
set -euo pipefail

LOGFILE="/var/log/maintenance.log"
LOG_DIR="${1:-/var/log/myapp}"
BACKUP_SRC="${2:-/etc}"
BACKUP_DEST="${3:-/backup}"

SCRIPT_DIR="$(dirname "$0")"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOGFILE"
}

log "=== Maintenance started ==="

log "--- Log Rotation ---"
bash "${SCRIPT_DIR}/log_rotate.sh" "$LOG_DIR" 2>&1 | while read -r line; do
    log "$line"
done || log "Warning: log rotation encountered issues"

log "--- Backup ---"
bash "${SCRIPT_DIR}/backup.sh" "$BACKUP_SRC" "$BACKUP_DEST" 2>&1 | while read -r line; do
    log "$line"
done || log "Warning: backup encountered issues"

log "=== Maintenance completed ==="
