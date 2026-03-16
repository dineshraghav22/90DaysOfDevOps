# Day 17 – Shell Scripting: Loops, Arguments & Error Handling

## Scripts Created

1. `for_loop.sh` – loops through 5 fruits
2. `count.sh` – prints 1 to 10 with for loop
3. `countdown.sh` – while loop countdown from user input
4. `greet.sh` – accepts name as $1, shows usage if missing
5. `args_demo.sh` – demonstrates $0, $#, $@
6. `install_packages.sh` – installs packages if missing, root check
7. `safe_script.sh` – error handling with set -e and ||

---

## Task 1: For Loop

**for_loop.sh:**
```bash
for fruit in apple banana cherry mango pineapple; do
    echo "Fruit: $fruit"
done
```
```
Fruit: apple
Fruit: banana
Fruit: cherry
Fruit: mango
Fruit: pineapple
```

**count.sh:**
```bash
for i in $(seq 1 10); do
    echo "$i"
done
```
```
1
2
3
...
10
```

---

## Task 2: While Loop

**countdown.sh:**
```bash
read -p "Enter a number to count down from: " NUM
while [ "$NUM" -ge 0 ]; do
    echo "$NUM"
    NUM=$((NUM - 1))
done
echo "Done!"
```
```
Input: 5
5
4
3
2
1
0
Done!
```

---

## Task 3: Command-Line Arguments

**greet.sh:**
```bash
if [ "$#" -eq 0 ]; then
    echo "Usage: ./greet.sh <name>"
    exit 1
fi
echo "Hello, $1!"
```
```
./greet.sh           → Usage: ./greet.sh <name>
./greet.sh Dinesh    → Hello, Dinesh!
```

**args_demo.sh:**
```bash
echo "Script name: $0"
echo "Total arguments: $#"
echo "All arguments: $@"
```
```
./args_demo.sh linux docker git
Script name: ./args_demo.sh
Total arguments: 3
All arguments: linux docker git
  linux
  docker
  git
```

---

## Task 4: Install Packages via Script

**install_packages.sh** (runs as root):
```bash
if [ "$EUID" -ne 0 ]; then
    echo "Error: This script must be run as root."
    exit 1
fi

PACKAGES=("nginx" "curl" "wget")
for pkg in "${PACKAGES[@]}"; do
    if rpm -q "$pkg" &>/dev/null; then
        echo "[SKIP] $pkg is already installed"
    else
        echo "[INSTALL] Installing $pkg..."
        yum install -y "$pkg" && echo "[OK]" || echo "[FAIL]"
    fi
done
```
```
[INSTALL] Installing nginx...   (nginx not in configured repo)
[SKIP] curl is already installed
[SKIP] wget is already installed
```

---

## Task 5: Error Handling

**safe_script.sh with `set -e`:**
```bash
#!/bin/bash
set -e

mkdir "$TESTDIR" || echo "Directory already exists"
cd "$TESTDIR"
touch testfile.txt
echo "All steps completed successfully."
```
```
Created testfile.txt in /tmp/devops-test
All steps completed successfully.
```

The `||` operator acts as a fallback — if `mkdir` fails (dir exists), it prints a message instead of exiting.

---

## What I Learned

1. **`$#`, `$@`, `$1`** are essential for reusable scripts — always check `$#` at the start of scripts that require arguments and print usage if empty.
2. **`while` loops need explicit counter updates** — `NUM=$((NUM - 1))` uses bash arithmetic. Forgetting this creates an infinite loop.
3. **`set -e` is your safety net but `||` gives you control** — `set -e` exits on any error, but `|| echo "fallback"` lets you handle expected failures (like "directory already exists") gracefully.
