## Process checks

### 1. List running processes

ps aux | head
Output:
USER       PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
root         1  0.0  0.1 169084  1200 ?        Ss   09:10   0:01 /sbin/init
root       542  0.0  0.3  72288  3400 ?        Ss   09:10   0:00 /usr/sbin/sshd

### Find SSH-related processes
pgrep -a ssh
Output:

542 /usr/sbin/sshd -D
678 sshd: user@pts/0

### Service checks
Check SSH service status
systemctl status ssh
Output:

● ssh.service - OpenBSD Secure Shell server
     Loaded: loaded (/lib/systemd/system/ssh.service; enabled)
     Active: active (running) since Mon 2026-02-07 09:10:12 UTC
   Main PID: 542 (sshd)

### List running services
systemctl list-units --type=service --state=running
Output:

ssh.service      loaded active running OpenBSD Secure Shell server
cron.service     loaded active running Regular background program processing daemon
systemd-journald loaded active running Journal Service
Log checks
### View SSH logs with journalctl
journalctl -u ssh --no-pager | tail -n 5
Output:

Feb 07 09:20:01 server sshd[678]: Accepted password for user from 10.0.0.25
Feb 07 09:20:01 server sshd[678]: pam_unix(sshd:session): session opened
6. Check authentication log
tail -n 20 /var/log/auth.log
Output:

Feb 07 09:20:01 server sshd[678]: Accepted password for user from 10.0.0.25
Feb 07 09:20:01 server sshd[678]: session opened for user user
### Mini troubleshooting steps (SSH)
Start SSH if not running:

systemctl start ssh
Debug SSH startup issues:

systemctl status ssh
journalctl -u ssh -xe
Check if SSH is listening:

ss -tlnp | grep ssh
Investigate login failures:

Review /var/log/auth.log

Check /etc/ssh/sshd_config

Verify user credentials and permissions

