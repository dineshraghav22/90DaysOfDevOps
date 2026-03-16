#!/bin/bash
set -euo pipefail

# Task 1: Input and Validation
if [ "$#" -eq 0 ]; then
    echo "Usage: $0 <log-file-path>"
    exit 1
fi

LOG_FILE="$1"

if [ ! -f "$LOG_FILE" ]; then
    echo "Error: Log file '$LOG_FILE' does not exist."
    exit 1
fi

DATE=$(date +%Y-%m-%d)
REPORT_FILE="log_report_${DATE}.txt"
TOTAL_LINES=$(wc -l < "$LOG_FILE")

# Task 2: Error Count
ERROR_COUNT=$(grep -c -E "ERROR|Failed" "$LOG_FILE" 2>/dev/null || echo 0)
echo "Total errors (ERROR/Failed): $ERROR_COUNT"

# Task 3: Critical Events
echo ""
echo "--- Critical Events ---"
grep -n "CRITICAL" "$LOG_FILE" | while IFS= read -r line; do
    LINENUM=$(echo "$line" | cut -d: -f1)
    CONTENT=$(echo "$line" | cut -d: -f2-)
    echo "Line $LINENUM:$CONTENT"
done

# Task 4: Top 5 Error Messages
echo ""
echo "--- Top 5 Error Messages ---"
grep "ERROR" "$LOG_FILE" | sed 's/^[0-9-]* [0-9:]* \[ERROR\] //' | sort | uniq -c | sort -rn | head -5

# Task 5: Generate Summary Report
{
    echo "================================================"
    echo "  LOG ANALYSIS REPORT"
    echo "================================================"
    echo "Date of Analysis : $DATE"
    echo "Log File         : $LOG_FILE"
    echo "Total Lines      : $TOTAL_LINES"
    echo "Total Errors     : $ERROR_COUNT"
    echo ""
    echo "--- Top 5 Error Messages ---"
    grep "ERROR" "$LOG_FILE" | sed 's/^[0-9-]* [0-9:]* \[ERROR\] //' | sort | uniq -c | sort -rn | head -5
    echo ""
    echo "--- Critical Events ---"
    grep -n "CRITICAL" "$LOG_FILE" | while IFS= read -r line; do
        LINENUM=$(echo "$line" | cut -d: -f1)
        CONTENT=$(echo "$line" | cut -d: -f2-)
        echo "Line $LINENUM:$CONTENT"
    done
    echo ""
    echo "================================================"
    echo "Report generated at: $(date)"
} > "$REPORT_FILE"

echo ""
echo "Report saved to: $REPORT_FILE"

# Task 6 (Optional): Archive processed log
mkdir -p archive
mv "$LOG_FILE" archive/
echo "Archived log to: archive/$(basename "$LOG_FILE")"
