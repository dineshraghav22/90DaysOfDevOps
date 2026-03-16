# Day 19 – Shell Scripting Project: Log Rotation, Backup & Crontab

## Scripts Created

1. `log_rotate.sh` – compresses old logs, deletes old archives
2. `backup.sh` – timestamped tar.gz backups with auto-purge
3. `maintenance.sh` – combines both with timestamped logging

---

## Task 1: log_rotate.sh

```bash
./log_rotate.sh /var/log/myapp
```

What it does:
1. Validates the directory exists (exits with error if not)
2. Finds `.log` files older than 7 days → compresses with `gzip`
3. Finds `.gz` files older than 30 days → deletes them
4. Reports how many files were compressed and deleted

**Key commands:**
```bash
# Find and compress logs older than 7 days
find "$LOG_DIR" -name "*.log" -mtime +7 -print0 | while read -r -d '' file; do
    gzip "$file"
done

# Find and delete compressed logs older than 30 days
find "$LOG_DIR" -name "*.gz" -mtime +30 -delete
```

---

## Task 2: backup.sh

```bash
./backup.sh /etc /backup
```

**Sample output:**
```
[2026-03-05 11:22:34] Creating backup of '/tmp/test-logs'...
[2026-03-05 11:22:34] Archive created: backup-2026-03-05_11-22-34.tar.gz (Size: 4.0K)
[2026-03-05 11:22:34] Done. Purged 0 old backups.
```

What it does:
1. Validates source directory exists
2. Creates timestamped archive: `backup-YYYY-MM-DD_HH-MM-SS.tar.gz`
3. Verifies archive was created with `[ -f "$ARCHIVE_PATH" ]`
4. Reports archive name and size
5. Purges backups older than 14 days from destination

**Key command:**
```bash
TIMESTAMP=$(date +%Y-%m-%d_%H-%M-%S)
tar -czf "${DEST}/backup-${TIMESTAMP}.tar.gz" -C "$(dirname "$SOURCE")" "$(basename "$SOURCE")"
```

---

## Task 3: Crontab Entries

```bash
crontab -l    # view current cron jobs
crontab -e    # edit cron jobs
```

**Cron syntax:**
```
* * * * *  command
│ │ │ │ └── Day of week (0=Sun, 7=Sun)
│ │ │ └──── Month (1-12)
│ │ └────── Day of month (1-31)
│ └──────── Hour (0-23)
└────────── Minute (0-59)
```

**Cron entries written:**
```bash
# Run log rotation every day at 2 AM
0 2 * * * /opt/scripts/log_rotate.sh /var/log/myapp >> /var/log/cron-log-rotate.log 2>&1

# Run backup every Sunday at 3 AM
0 3 * * 0 /opt/scripts/backup.sh /etc /backup >> /var/log/cron-backup.log 2>&1

# Run health check every 5 minutes
*/5 * * * * /opt/scripts/health_check.sh >> /var/log/health-check.log 2>&1

# Run full maintenance daily at 1 AM
0 1 * * * /opt/scripts/maintenance.sh >> /var/log/maintenance.log 2>&1
```

---

## Task 4: maintenance.sh

Combines log rotation and backup, logs everything with timestamps to `/var/log/maintenance.log`:

```
[2026-03-05 11:30:00] === Maintenance started ===
[2026-03-05 11:30:00] --- Log Rotation ---
[2026-03-05 11:30:01] [2026-03-05] Starting log rotation...
[2026-03-05 11:30:01] --- Backup ---
[2026-03-05 11:30:02] Archive created: backup-2026-03-05_11-30-02.tar.gz (Size: 45M)
[2026-03-05 11:30:02] === Maintenance completed ===
```

---

## What I Learned

1. **`find -print0` + `read -r -d ''`** is the correct way to handle filenames with spaces in loops — the null delimiter (`\0`) prevents word-splitting bugs.
2. **Timestamped archives never collide** — `date +%Y-%m-%d_%H-%M-%S` ensures each backup gets a unique filename, even if run multiple times per day.
3. **Cron output should always be logged** — appending `>> logfile 2>&1` to cron jobs captures both stdout and stderr. Without it, failures are completely invisible.
