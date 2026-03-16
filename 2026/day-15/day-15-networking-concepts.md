# Day 15 – Networking Concepts: DNS, IP, Subnets & Ports

## Task 1: DNS – How Names Become IPs

### What happens when you type `google.com` in a browser?

1. Browser checks its **local DNS cache** — if found, uses it
2. If not cached, asks the **OS resolver** (checks `/etc/hosts` first, then `/etc/resolv.conf`)
3. OS resolver queries the **recursive resolver** (usually your router or ISP's DNS server)
4. Recursive resolver asks a **root nameserver** (13 root servers globally) → "who handles .com?"
5. Root says "ask the **.com TLD nameserver**"
6. TLD says "ask google.com's **authoritative nameserver**"
7. Authoritative nameserver returns the **A record** (IP address)
8. IP travels back through the chain → browser connects to that IP

### DNS Record Types

| Record | Purpose | Example |
|--------|---------|---------|
| `A`    | Maps hostname to IPv4 address | `google.com → 142.250.70.110` |
| `AAAA` | Maps hostname to IPv6 address | `google.com → 2404:6800:4007::200e` |
| `CNAME`| Alias — points one name to another | `www.google.com → google.com` |
| `MX`   | Mail exchanger — where email goes | `google.com MX → aspmx.l.google.com` |
| `NS`   | Nameserver — who handles DNS for this domain | `google.com NS → ns1.google.com` |

### `dig google.com` Output

```bash
dig google.com
```
```
;; QUESTION SECTION:
;google.com.    IN  A

;; ANSWER SECTION:
google.com.   300  IN  A  142.250.70.110

;; SERVER: 172.16.100.1#53
;; Query time: 8 msec
```

- **A record:** `142.250.70.110` (google's IP)
- **TTL:** 300 seconds (5 minutes — after this, resolver re-fetches)
- **DNS Server used:** `172.16.100.1` (our local network's DNS resolver)

---

## Task 2: IP Addressing

### What is an IPv4 Address?
An IPv4 address is a 32-bit number written as 4 octets (0-255) separated by dots.
Example: `192.168.1.10`
- Each octet = 8 bits
- Total: 4 × 8 = 32 bits → ~4.3 billion possible addresses

### Public vs Private IPs

| Type    | Range Example       | Who uses it |
|---------|---------------------|-------------|
| Private | `192.168.1.10`      | Home/office networks, not routable on internet |
| Public  | `142.250.70.110`    | Routable globally, assigned by ISP |

### Private IP Ranges (RFC 1918)
```
10.0.0.0     – 10.255.255.255    (/8  — 16M addresses)
172.16.0.0   – 172.31.255.255   (/12 — 1M addresses)
192.168.0.0  – 192.168.255.255  (/16 — 65K addresses)
```

### This System's IPs (`ip addr show`)
```
127.0.0.1/8         → Loopback (localhost) — private
172.16.115.78/23    → Server's main IP — private (172.16.x range)
172.17.0.1/16       → Docker bridge (docker0) — private
172.18.0.1/16       → Docker custom network bridge — private
```
All are private IPs — this server sits behind a corporate network.

---

## Task 3: CIDR & Subnetting

### What does `/24` mean in `192.168.1.0/24`?
- `/24` = the first 24 bits are the **network portion**, the remaining 8 bits are **host addresses**
- 8 remaining bits → 2^8 = 256 total addresses → 254 usable (first = network, last = broadcast)

### Why do we subnet?
- Divide large networks into smaller, manageable segments
- Limit broadcast traffic (broadcasts only go within a subnet)
- Improve security (VLANs/subnets isolate traffic)
- Efficient IP address usage

### CIDR Table

| CIDR | Subnet Mask     | Total IPs | Usable Hosts |
|------|----------------|-----------|--------------|
| /24  | 255.255.255.0  | 256       | 254          |
| /16  | 255.255.0.0    | 65,536    | 65,534       |
| /28  | 255.255.255.240| 16        | 14           |

**Formula:** Usable hosts = 2^(32 - prefix) - 2

---

## Task 4: Ports – The Doors to Services

### What is a port?
A port is a number (1-65535) that identifies a specific process/service on a machine. IP gets the packet to the right machine; the port gets it to the right application.

### Common Ports

| Port  | Service          |
|-------|-----------------|
| 22    | SSH             |
| 80    | HTTP            |
| 443   | HTTPS           |
| 53    | DNS             |
| 3306  | MySQL/MariaDB   |
| 6379  | Redis           |
| 27017 | MongoDB         |

### Listening Services on This System (`ss -tulpn`)
```
Port 22    → sshd        (SSH — we're connected through this!)
Port 8080  → docker-proxy (web app via Docker)
Port 3306  → docker-proxy (MySQL via Docker)
Port 10051 → docker-proxy (Zabbix monitoring server)
Port 9001  → java        (Java application)
Port 9002  → java        (Java application, second port)
```

**Matching ports to services:**
- Port 22 → SSH → confirmed by `nc -zv localhost 22` (Connected!)
- Port 3306 → MySQL → confirmed by `nc -zv localhost 3306` (Connected!)

---

## Task 5: Putting It Together

### `curl http://myapp.com:8080` — what's involved?

1. **DNS** resolves `myapp.com` → IP address (A record lookup)
2. **TCP** establishes a connection to `<IP>:8080` (3-way handshake: SYN, SYN-ACK, ACK)
3. **HTTP** sends the GET request over that TCP connection
4. Response travels back through same path
5. Browser renders the page

Concepts used: DNS (L7), TCP (L4), IP (L3), ports (L4), HTTP (L7)

### App can't reach DB at `10.0.1.50:3306` — first checks:

```bash
# 1. Is the DB port listening on the DB server?
ss -tulpn | grep 3306        # run on DB server

# 2. Can we reach it from the app server?
nc -zv 10.0.1.50 3306

# 3. Is it a firewall blocking us?
curl -v telnet://10.0.1.50:3306

# 4. Check routing — is the subnet reachable?
ip route | grep 10.0.1
```

---

## What I Learned

1. **DNS is a distributed database** — no single server knows all names. The recursive lookup through root → TLD → authoritative is elegant and fast (usually < 10ms).
2. **Private IPs are not routable** — containers, VMs, and internal servers use private ranges. They reach the internet through NAT (Network Address Translation) on the gateway.
3. **Ports are how one IP serves many services** — the same server runs SSH (22), MySQL (3306), Nginx (8080), and Zabbix (10051) simultaneously because each has a different port.
