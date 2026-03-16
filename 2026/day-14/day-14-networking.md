# Day 14 – Networking Fundamentals & Hands-on Checks

## Quick Concepts

### OSI vs TCP/IP Models

| OSI Layer | Name         | TCP/IP Layer  | Examples                   |
|-----------|--------------|---------------|---------------------------|
| 7         | Application  | Application   | HTTP, HTTPS, DNS, SSH, FTP |
| 6         | Presentation | Application   | TLS/SSL, encoding          |
| 5         | Session      | Application   | Sessions, cookies          |
| 4         | Transport    | Transport     | TCP, UDP                   |
| 3         | Network      | Internet      | IP, ICMP, routing          |
| 2         | Data Link    | Link          | Ethernet, MAC addresses    |
| 1         | Physical     | Link          | Cables, WiFi signals       |

**Where key protocols sit:**
- **IP** → Network/Internet layer (L3) — handles addressing and routing
- **TCP/UDP** → Transport layer (L4) — handles delivery reliability and ports
- **HTTP/HTTPS** → Application layer (L7) — the actual web request/response
- **DNS** → Application layer (L7), but resolves to L3 (IP addresses)

**Real example:** `curl https://example.com`
= Application layer (HTTP) over Transport (TCP) over Network (IP) over Link (Ethernet/WiFi)

---

## Hands-on Checklist

### Identity: My IP Addresses
```bash
hostname -I
# 172.16.115.78 172.18.0.1 172.17.0.1

ip addr show | grep "inet "
# inet 127.0.0.1/8       scope host lo
# inet 172.16.115.78/23  scope global noprefixroute ens192
# inet 172.18.0.1/16     scope global br-115a47f6ce80
# inet 172.17.0.1/16     scope global docker0
```
- `172.16.115.78` = main server IP (private range)
- `172.17.0.1` and `172.18.0.1` = Docker bridge networks

---

### Reachability: Ping
```bash
ping -c 4 google.com
```
**Output:**
```
4 packets transmitted, 4 received, 0% packet loss, time 3005ms
rtt min/avg/max/mdev = 2.784/2.852/2.896/0.042 ms
```
- 0% packet loss → connectivity is healthy
- 2.85ms avg latency → very fast (same data center region)

---

### Path: Tracepath to google.com
```bash
tracepath google.com
```
**Output:**
```
1?: [LOCALHOST]                      pmtu 1500
1:  _gateway                          1.5ms
1:  _gateway                          0.7ms
2-6: no reply (intermediate routers not responding)
```
- First hop: our gateway at ~1ms (local network)
- Subsequent hops: `no reply` means routers block ICMP — normal corporate behavior
- MTU: 1500 bytes (standard Ethernet)

---

### Ports: Listening Services
```bash
ss -tulpn
```
**Output (key services):**
```
tcp  LISTEN  0.0.0.0:22    sshd          → SSH
tcp  LISTEN  0.0.0.0:8080  docker-proxy  → Web app (Nginx via Docker)
tcp  LISTEN  0.0.0.0:3306  docker-proxy  → MySQL via Docker
tcp  LISTEN  0.0.0.0:10051 docker-proxy  → Zabbix server
tcp  LISTEN  *:9001        java          → Java app
tcp  LISTEN  *:9002        java          → Java app (second port)
udp  UNCONN  127.0.0.1:323 chronyd       → NTP time sync
```

---

### Name Resolution: DNS
```bash
dig google.com A +short
# 142.250.70.110
```
- google.com resolves to `142.250.70.110` (public IP)
- TTL varies (typically 300s for google.com)

---

### HTTP Check
```bash
curl -I https://google.com
```
**Output:**
```
HTTP/2 301
location: https://www.google.com/
```
- **301 Moved Permanently** — google.com redirects to www.google.com
- Protocol: HTTP/2 (modern, multiplexed)

---

### Connections Snapshot
```bash
netstat -an | grep -E "ESTABLISHED|LISTEN" | wc -l
# 72 total connections (ESTABLISHED + LISTEN)
```

---

## Mini Task: Port Probe & Interpret

**Port 22 (SSH):**
```bash
nc -zv localhost 22
# Ncat: Connected to 127.0.0.1:22.
```
Reachable — SSH daemon is accepting connections.

**Port 8080 (web app via Docker):**
```bash
nc -zv localhost 8080
# Ncat: Connected to 127.0.0.1:8080.
```
Reachable — Docker-proxied web service is up.

---

## Reflection

**Which command gives the fastest signal when something is broken?**
`curl -I http://service:port` — immediately tells you if you can reach a service and what it responds with. Faster than ping for application-level issues.

**If DNS fails, what layer do I inspect?**
Application layer (L7) for DNS config, but the resolution itself is L3 (IP). First check: `dig @8.8.8.8 hostname` to test with a known resolver — if that works, it's your local DNS config.

**If HTTP 500 shows up?**
L7 issue — the server received the request but the application failed. Next checks:
1. `journalctl -u appservice -n 50` (application logs)
2. `systemctl status appservice` (service health)

**Two follow-up checks in a real incident:**
1. `ss -tulpn | grep <port>` — confirm the service is actually listening
2. `curl -v http://localhost:<port>/health` — test the application endpoint directly from the server
