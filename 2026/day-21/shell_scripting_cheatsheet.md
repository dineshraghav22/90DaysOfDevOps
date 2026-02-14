# Shell Scripting Cheat Sheet

## Quick Reference Table

| Topic | Key Syntax | Example |
|-------|-----------|---------|
| Variable | `VAR="value"` | `NAME="DevOps"` |
| Argument | `$1, $2` | `./script.sh arg1` |
| If | `if [ condition ]; then` | `if [ -f file ]; then` |
| For loop | `for i in list; do` | `for i in 1 2 3; do` |
| Function | `name() { ... }` | `greet() { echo "Hi"; }` |
| Grep | `grep pattern file` | `grep -i "error" log.txt` |
| Awk | `awk '{print $1}' file` | `awk -F: '{print $1}' /etc/passwd` |
| Sed | `sed 's/old/new/g' file` | `sed -i 's/foo/bar/g' config.txt` |

---

## Task 1: Basics

### Shebang

The shebang tells the OS which interpreter to use to run the script.

```bash
#!/bin/bash
echo "This runs with bash"
```

Without it, the script may be interpreted by the wrong shell.

### Running a Script

```bash
# Make it executable and run directly
chmod +x script.sh
./script.sh

# Or run with bash explicitly (no chmod needed)
bash script.sh
```

### Comments

```bash
# This is a single-line comment

echo "Hello" # This is an inline comment
```

### Variables

```bash
# Declaring and using variables
NAME="DevOps"
echo $NAME          # Basic usage
echo "$NAME"        # Double quotes — variable is expanded
echo '$NAME'        # Single quotes — literal string, no expansion
echo "${NAME}_team" # Braces to separate variable from surrounding text
```

### Reading User Input

```bash
#!/bin/bash
read -p "Enter your name: " USERNAME
echo "Hello, $USERNAME!"
```

### Command-Line Arguments

```bash
#!/bin/bash
echo "Script name: $0"
echo "First arg:   $1"
echo "Second arg:  $2"
echo "All args:    $@"
echo "Arg count:   $#"
echo "Last exit:   $?"
```

```bash
./script.sh hello world
# Script name: ./script.sh
# First arg:   hello
# Second arg:  world
# All args:    hello world
# Arg count:   2
# Last exit:   0
```

---

## Task 2: Operators and Conditionals

### String Comparisons

```bash
STR="hello"

[ "$STR" = "hello" ]   # Equal
[ "$STR" != "world" ]  # Not equal
[ -z "$STR" ]           # True if string is empty
[ -n "$STR" ]           # True if string is not empty
```

### Integer Comparisons

```bash
A=5; B=10

[ "$A" -eq "$B" ]  # Equal
[ "$A" -ne "$B" ]  # Not equal
[ "$A" -lt "$B" ]  # Less than
[ "$A" -gt "$B" ]  # Greater than
[ "$A" -le "$B" ]  # Less than or equal
[ "$A" -ge "$B" ]  # Greater than or equal
```

### File Test Operators

```bash
[ -f "file.txt" ]  # True if file exists and is a regular file
[ -d "/tmp" ]       # True if directory exists
[ -e "path" ]       # True if path exists (file or directory)
[ -r "file.txt" ]  # True if file is readable
[ -w "file.txt" ]  # True if file is writable
[ -x "script.sh" ] # True if file is executable
[ -s "file.txt" ]  # True if file is not empty (size > 0)
```

### if / elif / else

```bash
#!/bin/bash
read -p "Enter a number: " NUM

if [ "$NUM" -gt 100 ]; then
    echo "Greater than 100"
elif [ "$NUM" -gt 50 ]; then
    echo "Greater than 50"
else
    echo "50 or less"
fi
```

### Logical Operators

```bash
# AND — both conditions must be true
[ -f "file.txt" ] && [ -r "file.txt" ] && echo "File exists and is readable"

# OR — at least one condition must be true
[ -f "a.txt" ] || [ -f "b.txt" ] && echo "At least one file exists"

# NOT — negates the condition
if [ ! -d "/tmp/mydir" ]; then
    echo "Directory does not exist"
fi
```

### Case Statements

```bash
#!/bin/bash
read -p "Enter environment (dev/staging/prod): " ENV

case "$ENV" in
    dev)
        echo "Deploying to development"
        ;;
    staging)
        echo "Deploying to staging"
        ;;
    prod)
        echo "Deploying to production"
        ;;
    *)
        echo "Unknown environment: $ENV"
        ;;
esac
```

---

## Task 3: Loops

### For Loop — List-Based

```bash
for COLOR in red green blue; do
    echo "Color: $COLOR"
done
```

### For Loop — C-Style

```bash
for ((i = 1; i <= 5; i++)); do
    echo "Number: $i"
done
```

### While Loop

```bash
COUNT=1
while [ "$COUNT" -le 5 ]; do
    echo "Count: $COUNT"
    COUNT=$((COUNT + 1))
done
```

### Until Loop

Runs until the condition becomes true (opposite of `while`).

```bash
NUM=1
until [ "$NUM" -gt 5 ]; do
    echo "Num: $NUM"
    NUM=$((NUM + 1))
done
```

### Loop Control — break and continue

```bash
for i in 1 2 3 4 5; do
    [ "$i" -eq 3 ] && continue   # Skip 3
    [ "$i" -eq 5 ] && break      # Stop at 5
    echo "i = $i"
done
# Output: i = 1, i = 2, i = 4
```

### Looping Over Files

```bash
for file in /var/log/*.log; do
    echo "Processing: $file"
done
```

### Looping Over Command Output

```bash
# Read a file line by line
while IFS= read -r line; do
    echo "Line: $line"
done < /etc/hosts

# Read from command output
ps aux | while read -r line; do
    echo "$line"
done
```

---

## Task 4: Functions

### Defining a Function

```bash
greet() {
    echo "Hello, welcome to shell scripting!"
}
```

### Calling a Function

```bash
greet    # Just use the function name
```

### Passing Arguments to Functions

Arguments inside a function are accessed with `$1`, `$2`, etc.

```bash
greet_user() {
    echo "Hello, $1! You are $2 years old."
}

greet_user "Alice" 30
# Output: Hello, Alice! You are 30 years old.
```

### Return Values — return vs echo

`return` sets an exit code (0–255). Use `echo` to output a usable value.

```bash
# Using return (exit code only)
is_even() {
    [ $(($1 % 2)) -eq 0 ] && return 0 || return 1
}
is_even 4 && echo "Even"

# Using echo (capture output)
add() {
    echo $(($1 + $2))
}
RESULT=$(add 3 7)
echo "Sum: $RESULT"   # Sum: 10
```

### Local Variables

`local` limits the variable scope to the function.

```bash
my_func() {
    local SECRET="hidden"
    echo "Inside: $SECRET"
}
my_func
echo "Outside: $SECRET"   # Empty — variable not accessible outside
```

---

## Task 5: Text Processing Commands

### grep — Search Patterns

```bash
grep "error" /var/log/syslog       # Search for "error"
grep -i "error" /var/log/syslog    # Case-insensitive search
grep -r "TODO" ./src/              # Recursive search in directory
grep -c "error" log.txt            # Count matching lines
grep -n "error" log.txt            # Show line numbers
grep -v "debug" log.txt            # Invert — show non-matching lines
grep -E "error|warn" log.txt      # Extended regex (OR pattern)
```

### awk — Column Processing

```bash
# Print first column
awk '{print $1}' file.txt

# Custom field separator
awk -F: '{print $1, $3}' /etc/passwd

# Pattern matching
awk '/error/ {print $0}' log.txt

# BEGIN/END blocks
awk 'BEGIN {print "Start"} {print $1} END {print "Done"}' file.txt

# Sum a column
awk '{sum += $2} END {print "Total:", sum}' data.txt
```

### sed — Stream Editor

```bash
# Substitute first occurrence per line
sed 's/old/new/' file.txt

# Substitute all occurrences
sed 's/old/new/g' file.txt

# In-place edit
sed -i 's/old/new/g' file.txt

# Delete lines matching a pattern
sed '/^#/d' config.txt

# Delete a specific line number
sed '5d' file.txt
```

### cut — Extract Columns

```bash
# Cut by delimiter (e.g., colon), extract field 1
cut -d: -f1 /etc/passwd

# Extract characters 1-10
cut -c1-10 file.txt

# CSV: extract columns 1 and 3
cut -d, -f1,3 data.csv
```

### sort

```bash
sort file.txt              # Alphabetical sort
sort -n file.txt           # Numerical sort
sort -r file.txt           # Reverse sort
sort -u file.txt           # Sort and remove duplicates
sort -t: -k3 -n /etc/passwd  # Sort by 3rd field (numeric), colon-delimited
```

### uniq

```bash
sort file.txt | uniq       # Remove adjacent duplicates (sort first!)
sort file.txt | uniq -c    # Count occurrences
sort file.txt | uniq -d    # Show only duplicate lines
```

### tr — Translate/Delete Characters

```bash
echo "hello" | tr 'a-z' 'A-Z'     # Convert to uppercase
echo "hello world" | tr -d ' '     # Delete spaces -> helloworld
echo "aabbcc" | tr -s 'a-z'        # Squeeze repeated characters -> abc
cat file.txt | tr '\t' ','          # Replace tabs with commas
```

### wc — Word/Line/Character Count

```bash
wc -l file.txt    # Count lines
wc -w file.txt    # Count words
wc -c file.txt    # Count bytes
wc -m file.txt    # Count characters
```

### head / tail

```bash
head -n 20 file.txt       # First 20 lines
tail -n 20 file.txt       # Last 20 lines
tail -f /var/log/syslog   # Follow mode — watch file in real time
tail -n +5 file.txt       # Print from line 5 onward
```

---

## Task 6: Useful Patterns and One-Liners

### Find and delete files older than 30 days

```bash
find /tmp -type f -mtime +30 -delete
```

### Count lines in all .log files

```bash
wc -l /var/log/*.log
```

### Replace a string across multiple files

```bash
sed -i 's/oldstring/newstring/g' *.conf
```

### Check if a service is running

```bash
systemctl is-active --quiet nginx && echo "Running" || echo "Stopped"
```

### Monitor disk usage with alert

```bash
USAGE=$(df / | awk 'NR==2 {print $5}' | tr -d '%')
[ "$USAGE" -gt 80 ] && echo "WARNING: Disk usage is at ${USAGE}%"
```

### Parse JSON from command line

```bash
echo '{"name":"Alice","age":30}' | python3 -c "import sys,json; d=json.load(sys.stdin); print(d['name'])"
# Or with jq:
echo '{"name":"Alice","age":30}' | jq '.name'
```

### Tail a log and filter for errors in real time

```bash
tail -f /var/log/syslog | grep --line-buffered -i "error"
```

---

## Task 7: Error Handling and Debugging

### Exit Codes

Every command returns an exit code: `0` = success, non-zero = failure.

```bash
ls /nonexistent 2>/dev/null
echo "Exit code: $?"   # Exit code: 2

# Use exit to set your script's return code
exit 0   # Success
exit 1   # General error
```

### set -e — Exit on Error

Script stops immediately if any command fails.

```bash
#!/bin/bash
set -e
cp important.conf /backup/       # Script exits here if cp fails
echo "This won't run if cp fails"
```

### set -u — Treat Unset Variables as Error

Prevents silent bugs from typos in variable names.

```bash
#!/bin/bash
set -u
echo "$UNDEFINED_VAR"   # Script exits with error: unbound variable
```

### set -o pipefail — Catch Errors in Pipes

By default, a pipeline returns the exit code of the last command. `pipefail` catches failures in any part.

```bash
#!/bin/bash
set -o pipefail
cat nonexistent.txt | grep "something"   # Fails because cat fails
echo "Exit code: $?"                     # Non-zero
```

### set -x — Debug Mode (Trace Execution)

Prints each command before executing it.

```bash
#!/bin/bash
set -x
NAME="DevOps"
echo "Hello, $NAME"
# Output:
# + NAME=DevOps
# + echo 'Hello, DevOps'
# Hello, DevOps
```

### Combining Strict Mode (Recommended)

```bash
#!/bin/bash
set -euo pipefail
```

### Trap — Run Cleanup on Exit

`trap` executes a command when a signal is received.

```bash
#!/bin/bash
TMPFILE=$(mktemp)

cleanup() {
    rm -f "$TMPFILE"
    echo "Cleaned up temp file"
}
trap cleanup EXIT

echo "Working with $TMPFILE..."
# Temp file is removed automatically when script exits (even on error)
```

---
