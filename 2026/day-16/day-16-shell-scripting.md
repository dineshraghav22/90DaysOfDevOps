# Day 16 – Shell Scripting Basics

## Scripts Created

1. `hello.sh` – prints "Hello, DevOps!"
2. `variables.sh` – demonstrates variables and quote types
3. `greet.sh` – takes user input with `read`
4. `check_number.sh` – if/elif/else for positive/negative/zero
5. `file_check.sh` – checks if a file exists
6. `server_check.sh` – checks service status based on user input

---

## Task 1: First Script – hello.sh

```bash
#!/bin/bash
echo "Hello, DevOps!"
```

```bash
chmod +x hello.sh
./hello.sh
# Output: Hello, DevOps!
```

**What happens if you remove the shebang?**
Without `#!/bin/bash`, the OS runs the script with the current shell (usually `/bin/sh`). For simple scripts it works fine, but bash-specific features (`[[ ]]`, `local`, arrays, etc.) will break because `/bin/sh` may not support them.

---

## Task 2: Variables – variables.sh

```bash
#!/bin/bash
NAME="Dinesh"
ROLE="DevOps Engineer"
echo "Hello, I am $NAME and I am a $ROLE"
echo 'Single quotes: $NAME is not expanded here'
echo "Double quotes: $NAME is expanded here"
```

**Output:**
```
Hello, I am Dinesh and I am a DevOps Engineer
Single quotes: $NAME is not expanded here
Double quotes: Dinesh is expanded here
```

**Single vs Double Quotes:**
- Single quotes `'...'` — everything is literal, no variable expansion
- Double quotes `"..."` — variables and `$()` are expanded
- No quotes — word splitting happens (dangerous with spaces in values)

---

## Task 3: User Input – greet.sh

```bash
#!/bin/bash
read -p "Enter your name: " NAME
read -p "Enter your favourite tool: " TOOL
echo "Hello $NAME, your favourite tool is $TOOL"
```

**Sample run:**
```
Enter your name: Dinesh
Enter your favourite tool: Docker
Hello Dinesh, your favourite tool is Docker
```

---

## Task 4: If-Else – check_number.sh & file_check.sh

**check_number.sh:**
```bash
#!/bin/bash
read -p "Enter a number: " NUM
if [ "$NUM" -gt 0 ]; then
    echo "$NUM is positive"
elif [ "$NUM" -lt 0 ]; then
    echo "$NUM is negative"
else
    echo "The number is zero"
fi
```

```
Input: 5  → Output: 5 is positive
Input: -3 → Output: -3 is negative
Input: 0  → Output: The number is zero
```

**file_check.sh:**
```bash
if [ -f "$FILENAME" ]; then
    echo "File '$FILENAME' exists."
fi
```
`-f` checks for a regular file. Other useful flags: `-d` (directory), `-e` (exists), `-r` (readable), `-w` (writable), `-x` (executable).

---

## Task 5: Combine – server_check.sh

```bash
#!/bin/bash
SERVICE="sshd"
read -p "Do you want to check the status of '$SERVICE'? (y/n): " ANSWER
if [ "$ANSWER" = "y" ] || [ "$ANSWER" = "Y" ]; then
    STATUS=$(systemctl is-active "$SERVICE" 2>/dev/null)
    if [ "$STATUS" = "active" ]; then
        echo "$SERVICE is active and running."
    else
        echo "$SERVICE is NOT running (status: $STATUS)."
    fi
else
    echo "Skipped."
fi
```

**Sample run:**
```
Do you want to check the status of 'sshd'? (y/n): y
sshd is active and running.
```

---

## What I Learned

1. **Shebang is not optional in production** — `#!/bin/bash` ensures your script uses bash even when `/bin/sh` is something else (dash, ash). Always include it.
2. **Quote your variables** — always use `"$VAR"` not `$VAR` in conditions and echo. Without quotes, a variable with spaces splits into multiple arguments and breaks everything.
3. **`$()` for command substitution** — `STATUS=$(systemctl is-active sshd)` captures command output into a variable. This is the modern way (backticks are legacy and harder to nest).
