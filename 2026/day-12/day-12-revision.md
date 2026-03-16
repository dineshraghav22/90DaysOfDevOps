# Day 12 – Revision & Consolidation (Days 01–11)

## Today's Approach
Paused new concepts to reinforce what was covered in Days 01–11. Re-ran commands, answered self-check questions, and identified areas to keep practicing.

---

## Re-Run Commands (Hands-On Revision)

### Process Check (Day 04/05)
```bash
ps aux --sort=-%cpu | head -5
```
**Output observed:**
```
USER       PID  %CPU %MEM    VSZ   RSS TTY  STAT  COMMAND
root   1031410   8.4  6.3  74G   494M  pts  Sl+   claude
alepo  1038860   3.0  0.6  636M   51M  ?    Ssl   PM2 v5.2.0 God Daemon
systemd+  2468   0.7  4.4  2.5G  350M  ?    Ssl   mariadbd
```
**Observation:** claude process (this session) is the top CPU consumer, MariaDB (database) is a long-running background service.

### Service Check (Day 04)
```bash
systemctl status sshd --no-pager
```
**Output:**
```
● sshd.service - OpenSSH server daemon
   Active: active (running) since Sun 2026-02-15 22:01:30 IST; 2 weeks ago
   Main PID: 1125 (sshd)
```
SSH has been running for 2+ weeks — healthy, enabled, no restarts needed.

### Disk & Memory Check (Day 05)
```bash
df -h /
# Filesystem: /dev/mapper/ol-root | Size: 76G | Used: 62G | Avail: 14G | Use%: 83%

free -h
# Mem: 7.5Gi total | 1.6Gi used | 4.6Gi free | 1.2Gi buff/cache
```
**Observation:** Disk is at 83% — worth monitoring. Memory is healthy with 4.6Gi free.

### File Permission Re-Practice (Days 06–10)
```bash
touch revision-test.txt
ls -l revision-test.txt      # -rw-r--r-- (644)
chmod 750 revision-test.txt
ls -l revision-test.txt      # -rwxr-x--- (750)
chown tokyo revision-test.txt
ls -l revision-test.txt      # tokyo owns it
```

### User/Group Sanity Check (Day 09/11)
```bash
id tokyo
# uid=1002(tokyo) gid=1002(tokyo) groups=1002(tokyo),1006(developers),1008(project-team)

id berlin
# uid=1003(berlin) gid=1003(berlin) groups=1003(berlin),1006(developers),1007(admins)
```
Users and group assignments from Day 09 are still intact.

---

## Mini Self-Check Answers

### 1. Which 3 commands save me the most time right now, and why?

1. **`systemctl status <service>`** — single command that tells me if a service is running, its PID, memory, and last log lines. Replaces 3–4 separate checks.
2. **`ps aux --sort=-%cpu | head -10`** — instantly identifies which process is consuming CPU. No need for interactive `top` in scripts.
3. **`journalctl -u <service> -n 50`** — the fastest way to get service logs without knowing where log files are on disk.

### 2. How do you check if a service is healthy?

```bash
# Step 1: Check status
systemctl status nginx

# Step 2: If unclear, check recent logs
journalctl -u nginx -n 50

# Step 3: Verify it's enabled to restart on boot
systemctl is-enabled nginx
```
Expected healthy output: `Active: active (running)` and `enabled`.

### 3. How do you safely change ownership and permissions without breaking access?

```bash
# Check current permissions first
ls -l /opt/dev-project/

# Change ownership (be specific, not -R unless needed)
sudo chown www-data:www-data /opt/dev-project/app.conf

# Set appropriate permissions (not 777!)
sudo chmod 644 /opt/dev-project/app.conf

# Verify
ls -l /opt/dev-project/app.conf
```
Rule: always `ls -l` before and after. Never use `chmod 777` — it's a security hole.

### 4. What will I focus on in the next 3 days?

- **Day 13:** LVM storage management — new concept, needs hands-on practice
- **Day 14:** Networking commands — `ss`, `dig`, `traceroute` need more repetition
- **Day 15:** DNS and subnets — conceptual but critical for cloud work

---

## Days 01–11 Checklist Review

| Topic | Status |
|-------|--------|
| Linux architecture (kernel, shell, user space) | Confident |
| Navigate filesystem, create/move/delete files | Confident |
| Manage processes (ps, kill, top, bg/fg) | Confident |
| systemd services (start/stop/enable/status) | Confident |
| journalctl log viewing | Comfortable |
| File system hierarchy (/, /etc, /var, /home, /tmp) | Confident |
| Users and groups (useradd, groupadd, usermod) | Confident |
| File permissions (chmod numeric + symbolic) | Confident |
| File ownership (chown, chgrp, recursive -R) | Confident |
| Text processing (grep, awk, sort, uniq) | Need more practice |
| LVM storage management | Not done yet (Day 13) |

---

## Key Takeaways from Days 01–11

1. **Everything is a file in Linux** — configs, logs, devices, sockets. Understanding the filesystem hierarchy (`/etc`, `/var/log`, `/proc`) is what makes you fast in incidents.
2. **Troubleshooting has a pattern** — status → logs → config → permissions. Stop guessing, follow the flow.
3. **Ownership and permissions together** — changing one without the other often doesn't fix the problem. A file with right permissions but wrong owner still denies access.
