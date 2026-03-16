# Day 08 – Cloud Server Setup: Docker, Nginx & Web Deployment

## Commands Used

### Launch & Connect (AWS EC2)
```bash
# SSH into instance
ssh -i my-key.pem ubuntu@<instance-ip>

# Update system
sudo apt update && sudo apt upgrade -y
```

### Install Nginx
```bash
sudo apt install -y nginx
sudo systemctl start nginx
sudo systemctl enable nginx
sudo systemctl status nginx
```

### Verify Nginx Running
```bash
curl -I http://localhost
# HTTP/1.1 200 OK
# Server: nginx/1.24.0 (Ubuntu)
```

### Security Group Configuration
On AWS Console:
- Added inbound rule: Type = HTTP, Port = 80, Source = 0.0.0.0/0
- Added inbound rule: Type = HTTPS, Port = 443, Source = 0.0.0.0/0
- SSH (22) was already configured

Access in browser: `http://<instance-ip>` → Nginx welcome page!

### Extract & Save Nginx Logs
```bash
# View access logs
sudo cat /var/log/nginx/access.log

# View error logs
sudo cat /var/log/nginx/error.log

# Save to file
sudo cat /var/log/nginx/access.log > ~/nginx-logs.txt
sudo cat /var/log/nginx/error.log >> ~/nginx-logs.txt

# Check file
ls -lh ~/nginx-logs.txt
```

### Download Logs to Local Machine
```bash
# Run from local machine:
scp -i my-key.pem ubuntu@<instance-ip>:~/nginx-logs.txt .
```

---

## Challenges Faced

1. **Security group not configured** — Nginx installed and running, but browser showed timeout. Solution: Added port 80 inbound rule in AWS console.
2. **Permission denied reading logs** — `/var/log/nginx/` requires sudo. Solution: `sudo cat /var/log/nginx/access.log`

---

## What I Learned

- Cloud instances are just Linux servers — all previous knowledge applies directly
- Security groups act as stateful firewalls at the AWS network layer — a service can run locally but be unreachable if the security group doesn't allow the port
- Nginx serves from `/var/www/html/` by default — `index.nginx-debian.html` is the welcome page
- systemd manages Nginx just like any other service — `systemctl status nginx`, `journalctl -u nginx`
- Log files live in `/var/log/nginx/` — `access.log` for requests, `error.log` for problems

---

## Architecture Diagram

```
Internet
    ↓
AWS Security Group (allows 22, 80, 443)
    ↓
EC2 Instance (Ubuntu)
    ↓
Nginx (port 80)
    ↓
/var/www/html/index.html (welcome page)
```
