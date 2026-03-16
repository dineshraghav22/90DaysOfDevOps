# Day 20 – Bash Scripting Challenge: Log Analyzer

## Script: log_analyzer.sh

Usage:
```bash
./log_analyzer.sh <path-to-log-file>
```

---

## How It Works

### Task 1: Input Validation
```bash
if [ "$#" -eq 0 ]; then
    echo "Usage: $0 <log-file-path>"
    exit 1
fi

if [ ! -f "$LOG_FILE" ]; then
    echo "Error: Log file '$LOG_FILE' does not exist."
    exit 1
fi
```
- Exits with clear message if no argument provided
- Exits if the file doesn't exist at the given path

### Task 2: Error Count
```bash
ERROR_COUNT=$(grep -c -E "ERROR|Failed" "$LOG_FILE" 2>/dev/null || echo 0)
echo "Total errors (ERROR/Failed): $ERROR_COUNT"
```
`grep -c` counts matching lines. `-E` enables extended regex for OR matching.

**Output on sample log (300 lines):**
```
Total errors (ERROR/Failed): 67
```

### Task 3: Critical Events with Line Numbers
```bash
grep -n "CRITICAL" "$LOG_FILE" | while IFS= read -r line; do
    LINENUM=$(echo "$line" | cut -d: -f1)
    CONTENT=$(echo "$line" | cut -d: -f2-)
    echo "Line $LINENUM:$CONTENT"
done
```
**Sample output:**
```
--- Critical Events ---
Line 9: 2026-03-05 11:28:21 [CRITICAL]  - 25547
Line 12: 2026-03-05 11:28:21 [CRITICAL]  - 27058
Line 16: 2026-03-05 11:28:21 [CRITICAL]  - 19265
...52 critical events total
```

### Task 4: Top 5 Error Messages
```bash
grep "ERROR" "$LOG_FILE" | sed 's/^[0-9-]* [0-9:]* \[ERROR\] //' | sort | uniq -c | sort -rn | head -5
```
Pipeline breakdown:
- `grep "ERROR"` — extract error lines
- `sed` — strip timestamp and log level prefix
- `sort` — group identical messages together
- `uniq -c` — count occurrences
- `sort -rn` — sort by count descending
- `head -5` — keep top 5

**Output:**
```
--- Top 5 Error Messages ---
 15 Failed to connect - <random>
 14 Segmentation fault - <random>
 13 Out of memory - <random>
 12 Disk full - <random>
 11 Invalid input - <random>
```

### Task 5: Summary Report
Generated to `log_report_2026-03-05.txt`:
```
================================================
  LOG ANALYSIS REPORT
================================================
Date of Analysis : 2026-03-05
Log File         : /tmp/sample_log.log
Total Lines      : 300
Total Errors     : 67

--- Top 5 Error Messages ---
...

--- Critical Events ---
Line 9: 2026-03-05 11:28:21 [CRITICAL]  - 25547
...

Report generated at: Thu Mar  5 11:28:22 IST 2026
```

### Task 6: Archive
```bash
mkdir -p archive
mv "$LOG_FILE" archive/
echo "Archived log to: archive/$(basename "$LOG_FILE")"
```
Moves processed log to `archive/` directory.

---

## Commands & Tools Used

| Tool | Purpose |
|------|---------|
| `grep -c` | Count matching lines |
| `grep -n` | Print line numbers with matches |
| `sed` | Strip prefixes from log lines |
| `sort` | Sort lines for uniq to work correctly |
| `uniq -c` | Count consecutive duplicate lines |
| `sort -rn` | Reverse numeric sort (highest count first) |
| `head -5` | Limit to top 5 results |
| `wc -l` | Count total lines |
| `cut -d: -f1` | Extract field before colon |

---

## What I Learned

1. **Pipes are powerful for log analysis** — chaining `grep | sed | sort | uniq -c | sort -rn | head` is a single-line log analyzer that works on any log file without writing to temp files.
2. **`grep -c` vs `grep | wc -l`** — both count matches, but `grep -c` is more efficient (counts internally). Use `grep -c` when you only need the count.
3. **Log analysis is the core of SRE work** — understanding how to extract signal from noisy logs (count errors, find criticals, identify top failures) is a daily skill for any DevOps or SRE engineer.
