# Day 29 – Introduction to Docker

## Task 1: What is Docker?

### What is a Container and Why Do We Need It?
A container is a lightweight, isolated process that runs an application with everything it needs: code, runtime, libraries, and configuration. Unlike a virtual machine, a container shares the host OS kernel — making it fast to start (milliseconds), small (MBs not GBs), and portable.

**Why we need containers:**
- "It works on my machine" is solved — the container includes the exact environment
- Ship the same image to development, staging, and production — no config drift
- Run dozens of containers on one server — better resource utilization than VMs

### Containers vs Virtual Machines

| | Containers | Virtual Machines |
|---|---|---|
| Start time | Milliseconds | Minutes |
| Size | MBs | GBs |
| OS | Shares host kernel | Full OS per VM |
| Isolation | Process-level | Hardware-level |
| Overhead | Very low | High (hypervisor + full OS) |

**Rule of thumb:** VMs for strong isolation (different OS, security boundary). Containers for fast, consistent application packaging.

### Docker Architecture

```
Developer → Docker CLI → Docker Daemon (dockerd)
                              ↓
                        Docker Registry (Docker Hub)
                              ↓
                        Images → Containers
```

- **Docker CLI** — the `docker` command you type
- **Docker Daemon (dockerd)** — background process that manages images and containers
- **Images** — read-only templates for containers (like a class in OOP)
- **Containers** — running instances of images (like objects instantiated from a class)
- **Registry** — storage for images (Docker Hub is the public registry)

---

## Task 2: Docker Installation & Verification

**System already has Docker installed:**
```bash
docker --version
# Docker version 26.1.3, build b72abbb

docker run hello-world
# Hello from Docker!
# This message shows that your installation appears to be working correctly.
```

**What `hello-world` does (from the output):**
1. Docker CLI contacted the Docker daemon
2. Daemon pulled the `hello-world` image from Docker Hub
3. Daemon created and ran a container from that image
4. Container streamed the output back to the CLI

---

## Task 3: Run Real Containers

**Nginx container accessible in browser:**
```bash
docker run -d -p 8080:80 --name my-nginx nginx
# Container runs in background, port 8080 on host → port 80 in container
# Access: http://localhost:8080 → Nginx welcome page
```

**Ubuntu container interactively:**
```bash
docker run -it --name my-ubuntu ubuntu bash
# Inside the container:
ls /
cat /etc/os-release
apt update && apt install -y curl
exit
```

**Container management:**
```bash
docker ps                  # list running containers
docker ps -a               # list all containers (including stopped)
docker stop my-nginx       # stop a container gracefully
docker rm my-nginx         # remove a stopped container
docker stop my-ubuntu && docker rm my-ubuntu
```

**Current running containers on this system:**
```
25c9c0eb  zabbix-web-apache-mysql  Up 2 weeks  0.0.0.0:8080->8080/tcp
3e65df72  zabbix-server-mysql      Up 2 weeks  0.0.0.0:10051->10051/tcp
4ed5aeda  zabbix-java-gateway      Up 2 weeks  0.0.0.0:10052->10052/tcp
93a7c2e0  mariadb                  Up 2 weeks  0.0.0.0:3306->3306/tcp
```
This is a real production setup — Zabbix monitoring stack running in Docker Compose!

---

## Task 4: Explore Docker Flags

```bash
# Detached mode (-d) — runs in background, returns container ID
docker run -d nginx
# Returns: abc123def456...   (container ID only)
# Without -d: runs in foreground, logs stream to terminal

# Custom name
docker run -d --name web-server nginx

# Port mapping: -p <host-port>:<container-port>
docker run -d -p 8081:80 --name web-port nginx
# localhost:8081 → container's port 80

# View logs
docker logs web-server
docker logs -f web-server   # follow (like tail -f)

# Execute command inside running container
docker exec web-server ls /etc/nginx/
docker exec -it web-server bash   # interactive shell inside running container
```

---

## Docker Architecture (On This System)
```
Docker Daemon running on: database_vip (172.16.115.78)
Running containers: 4 (Zabbix monitoring stack + MariaDB)
Docker images: 10+ including zabbix, python, mariadb, envoy
Docker version: 26.1.3
```

---

## Key Commands Learned Today

```bash
docker run hello-world                      # test installation
docker run -it ubuntu bash                  # interactive container
docker run -d -p 8080:80 --name web nginx   # detached + port + name
docker ps                                   # running containers
docker ps -a                                # all containers
docker stop <name>                          # stop container
docker rm <name>                            # remove container
docker logs <name>                          # view logs
docker logs -f <name>                       # follow logs
docker exec -it <name> bash                 # shell inside container
```

---

## Why This Matters for DevOps
Containers solve the biggest pain point in software delivery — environment inconsistency. Docker is the foundation for every CI/CD pipeline, Kubernetes cluster, and microservice deployment in modern infrastructure.
