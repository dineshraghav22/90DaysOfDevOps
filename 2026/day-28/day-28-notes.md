# Day 28 – Revision Day: Everything from Day 1 to Day 27

## Task 1: Self-Assessment Checklist

### Linux

| Skill | Status |
|-------|--------|
| Navigate the file system, create/move/delete files | Can do confidently |
| Manage processes — list, kill, background/foreground | Can do confidently |
| Work with systemd — start, stop, enable, check status | Can do confidently |
| Read and edit text files using vi/vim or nano | Can do confidently |
| Troubleshoot CPU, memory, disk issues (top, free, df, du) | Can do confidently |
| Explain Linux file system hierarchy | Can do confidently |
| Create users and groups, manage passwords | Can do confidently |
| Set file permissions using chmod | Can do confidently |
| Change ownership with chown and chgrp | Can do confidently |
| Create and manage LVM volumes | Comfortable (need more practice) |
| Network connectivity — ping, curl, netstat, ss, dig | Can do confidently |
| Explain DNS, IP addressing, subnets, and common ports | Can do confidently |

### Shell Scripting

| Skill | Status |
|-------|--------|
| Write scripts with variables, arguments, user input | Can do confidently |
| Use if/elif/else and case statements | Can do confidently |
| Write for, while, and until loops | Can do confidently |
| Define and call functions with arguments and return values | Can do confidently |
| Use grep, awk, sed, sort, uniq for text processing | Comfortable |
| Handle errors with set -e, set -u, set -o pipefail, trap | Can do confidently |
| Schedule scripts with crontab | Can do confidently |

### Git & GitHub

| Skill | Status |
|-------|--------|
| Initialize repo, stage, commit, and view history | Can do confidently |
| Create and switch branches | Can do confidently |
| Push to and pull from GitHub | Can do confidently |
| Explain clone vs fork | Can do confidently |
| Merge branches — fast-forward vs merge commit | Can do confidently |
| Rebase a branch | Comfortable |
| Use git stash and git stash pop | Can do confidently |
| Cherry-pick a commit | Can do confidently |
| Explain squash merge vs regular merge | Can do confidently |
| Use git reset (soft, mixed, hard) and git revert | Can do confidently |
| Explain GitFlow, GitHub Flow, Trunk-Based Dev | Can do confidently |
| Use GitHub CLI | Comfortable |

---

## Task 2: Revisited Weak Spots

### 1. `grep`, `awk`, `sed` — Re-practiced

```bash
# grep: find ERROR lines in log
grep "ERROR" /var/log/messages | head -5

# awk: print specific columns
ps aux | awk '{print $1, $2, $3, $11}'

# sed: replace a string in file
sed 's/old-value/new-value/g' config.txt

# Combined: top error messages
grep "ERROR" app.log | awk '{$1=$2=$3=""; print}' | sort | uniq -c | sort -rn | head -5
```

### 2. LVM — Re-ran key commands
```bash
pvs && vgs && lvs  # confirm devops-vg still exists
df -h /mnt/app-data  # 668M available, 14K used
```

---

## Task 3: Quick-Fire Questions

**1. What does `chmod 755 script.sh` do?**
Sets permissions: owner = rwx (7), group = r-x (5), others = r-x (5). Owner can read/write/execute. Everyone else can read and execute but not modify.

**2. Difference between a process and a service?**
A process is any running program (has a PID). A service is a background process managed by systemd, designed to run persistently and restart automatically.

**3. How do you find which process is using port 8080?**
```bash
ss -tulpn | grep 8080
# OR
lsof -i :8080
```

**4. What does `set -euo pipefail` do?**
- `-e`: exit on any error
- `-u`: exit if undefined variable used
- `-o pipefail`: exit if any command in a pipeline fails

**5. Difference between `git reset --hard` and `git revert`?**
`git reset --hard` destroys the commit and changes from history (dangerous on shared branches). `git revert` creates a new commit that undoes changes while keeping the original commit in history (safe for shared branches).

**6. Branching strategy for a team of 5 developers shipping weekly?**
GitHub Flow — simple, single main branch with feature branches. Fast enough for weekly releases, simple enough for a small team.

**7. What does `git stash` do and when would you use it?**
Saves uncommitted changes to a temporary stack so you can switch branches with a clean working directory. Use it when you're interrupted mid-task and need to switch context immediately.

**8. How to schedule a script to run every day at 3 AM?**
```bash
crontab -e
# Add:
0 3 * * * /path/to/script.sh >> /var/log/script.log 2>&1
```

**9. Difference between `git fetch` and `git pull`?**
`git fetch` downloads remote changes without merging. `git pull` = `git fetch` + `git merge`. Use fetch when you want to inspect changes before integrating.

**10. What is LVM and why use it instead of regular partitions?**
LVM (Logical Volume Manager) adds abstraction over disks. Unlike regular partitions, LVM allows: resizing volumes online (no downtime), spanning a single volume across multiple disks, snapshots. Used when you need flexible storage management on production servers.

---

## Task 4: All Submissions Verified

- Days 01–11: Committed and pushed ✓
- Days 12–20: Committed and pushed ✓
- Days 21–22: Previously done ✓
- Days 23–27: Committed and pushed ✓
- `git-commands.md` updated with all commands through Day 26 ✓
- Shell scripting cheat sheet (Day 21) complete ✓
- GitHub profile updated (Day 27) ✓

---

## Task 5: Teach It Back — File Permissions

**Explaining Linux file permissions to someone new:**

Every file in Linux has three permission groups: **owner**, **group**, and **others**. Each group can have three permissions: **read (r)**, **write (w)**, and **execute (x)**.

When you run `ls -l`, you see something like `-rwxr-xr-x`. Break it down:
- The first character (`-`) = it's a regular file (`d` = directory)
- `rwx` = owner can read, write, and execute
- `r-x` = group members can read and execute (not write)
- `r-x` = everyone else can read and execute

To change permissions: `chmod 755 script.sh`
- `7` = owner: 4+2+1 = rwx
- `5` = group: 4+1 = r-x
- `5` = others: 4+1 = r-x

Real-world example: a web server (nginx, running as `www-data`) needs read access to your HTML files but should not be able to write to them. Set to `644`: owner can edit, web server can only read.
