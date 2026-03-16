# Day 18 – Shell Scripting: Functions & Intermediate Concepts

## Scripts Created

1. `functions.sh` – basic functions with arguments
2. `disk_check.sh` – functions for disk and memory checks
3. `strict_demo.sh` – demonstrates `set -euo pipefail`
4. `local_demo.sh` – shows local vs global variable scoping
5. `system_info.sh` – full system reporter using functions

---

## Task 1: Basic Functions – functions.sh

```bash
greet() {
    echo "Hello, $1!"
}

add() {
    local RESULT=$(( $1 + $2 ))
    echo "Sum of $1 + $2 = $RESULT"
}

greet "Dinesh"
add 10 25
```
```
Hello, Dinesh!
Hello, DevOps World!
Sum of 10 + 25 = 35
Sum of 100 + 200 = 300
```

---

## Task 2: Functions with Return Values – disk_check.sh

```bash
check_disk() {
    echo "=== Disk Usage ==="
    df -h /
}

check_memory() {
    echo "=== Memory Usage ==="
    free -h
}
```

Output shows `/` at 83% used (76G total, 63G used) — time to monitor this.

---

## Task 3: Strict Mode – strict_demo.sh

```bash
set -euo pipefail
```

| Flag | What it does |
|------|--------------|
| `set -e` | Exit immediately if any command returns non-zero exit code |
| `set -u` | Treat undefined variables as errors (exit instead of expanding to empty string) |
| `set -o pipefail` | If any command in a pipeline fails, the whole pipeline fails (default: only last command matters) |

**Why it matters:**
Without `set -u`:
```bash
echo $UNDEFINED_VAR   # Silently prints empty string
```
With `set -u`:
```bash
echo $UNDEFINED_VAR   # Error: UNDEFINED_VAR: unbound variable — script exits
```
This catches typos in variable names before they cause silent failures.

---

## Task 4: Local Variables – local_demo.sh

```bash
with_local() {
    local MY_VAR="I am local to with_local()"
    echo "Inside: MY_VAR = $MY_VAR"
}

without_local() {
    MY_VAR="I leaked from without_local()"
}
```

**Output:**
```
Inside with_local: MY_VAR = I am local to with_local()
After with_local: MY_VAR = 'not set'       ← local variable gone

Inside without_local: MY_VAR = I leaked from without_local()
After without_local: MY_VAR = 'I leaked...' ← global variable persists!
GLOBAL_VAR = I am global
```

**Rule:** Always use `local` for function variables. Without it, you're modifying global state which causes unexpected bugs in larger scripts.

---

## Task 5: System Info Reporter – system_info.sh

```
System Info Report — Thu Mar  5 11:20:40 IST 2026

============================================
  HOSTNAME & OS INFO
============================================
Hostname : database_vip
OS       : Oracle Linux Server 8.10
Kernel   : 5.4.17-2136.344.4.3.el8uek.x86_64

============================================
  UPTIME
============================================
up 2 weeks, 3 days, 18 hours, 29 minutes

============================================
  TOP 5 DISK USAGE
============================================
/dev/mapper/ol-root   76G  63G  13G  83%  /

============================================
  MEMORY USAGE
============================================
Mem:  7.5Gi total | 1.7Gi used | 3.8Gi free

============================================
  TOP 5 CPU-CONSUMING PROCESSES
============================================
root   1031410  10.8   claude
systemd+ 2468   0.7    mariadbd
```

---

## What I Learned

1. **`local` is not optional in real scripts** — without it, every function can accidentally overwrite global variables. Always declare local variables with `local MY_VAR=...` inside functions.
2. **`set -euo pipefail` as the first line** (after shebang) is production-grade practice — it turns on three independent safety nets. Use it in every script that runs in automated environments (cron, CI/CD).
3. **A `main()` function improves readability** — defining all logic in functions and calling `main` at the end makes scripts easy to read top-to-bottom and easy to test individual functions in isolation.
