# Day 30 – Docker Images & Container Lifecycle

## Task 1: Docker Images

```bash
# Pull images
docker pull nginx
docker pull ubuntu
docker pull alpine

# List all images with sizes
docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}"
```

**Images on this system:**
```
REPOSITORY                          TAG              SIZE
ghcr.io/sooperset/mcp-atlassian     latest           125MB
envoyproxy/envoy                    tools-v1.31-latest 286MB
python                              3.9-slim         126MB
zabbix/zabbix-web-apache-mysql      6.4.13-centos    425MB
zabbix/zabbix-server-mysql          6.4.13-centos    229MB
mariadb                             10.11.5          403MB (full MariaDB)
```

### Ubuntu vs Alpine — Why Such a Size Difference?

```bash
docker pull ubuntu && docker pull alpine
docker images ubuntu alpine
# ubuntu:latest    ~77MB
# alpine:latest    ~7MB
```

- **Ubuntu** includes a full Debian-based userspace, package manager, many pre-installed tools
- **Alpine** is minimal — based on musl libc and busybox. Ships only what's essential to run.
- For production containers, prefer Alpine: smaller attack surface, faster pulls, less storage

### Inspect an Image
```bash
docker inspect nginx | head -50
# Shows: architecture, OS, layers, exposed ports, volumes, env vars, entrypoint
```

### Remove an Image
```bash
docker rmi alpine
docker image prune   # remove all dangling (untagged) images
```

---

## Task 2: Image Layers

```bash
docker image history mariadb:10.11.5
```

**Output:**
```
IMAGE         CREATED     CREATED BY                              SIZE
f3ccb05c76f7  2 years ago /bin/sh -c #(nop) CMD ["mariadbd"]     0B
<missing>     2 years ago /bin/sh -c #(nop) EXPOSE 3306           0B
<missing>     2 years ago /bin/sh -c #(nop) ENTRYPOINT [...]      0B
<missing>     2 years ago /bin/sh -c #(nop) COPY file:...         23.2kB
<missing>     2 years ago /bin/sh -c #(nop) VOLUME [/var/lib/...]  0B
<missing>     2 years ago /bin/sh -c #(nop) RUN install mariadb   311MB
<missing>     2 years ago ARG REPOSITORY=http://...               0B
```

### What are Layers?
Each instruction in a Dockerfile creates a layer. Layers are:
- **Cached** — if a layer hasn't changed, Docker reuses it from cache (fast builds)
- **Shared** — multiple images can share the same base layers (saves disk space)
- **Stacked** — the final image is the union of all layers

Lines showing `0B` are metadata layers (ENV, EXPOSE, CMD) — no filesystem changes.
The `311MB` layer is the actual package installation.

---

## Task 3: Container Lifecycle

```bash
# 1. Create (without starting)
docker create --name lifecycle-test nginx

# 2. Start
docker start lifecycle-test
docker ps  # Status: Up

# 3. Pause
docker pause lifecycle-test
docker ps  # Status: Up (Paused)

# 4. Unpause
docker unpause lifecycle-test
docker ps  # Status: Up

# 5. Stop (SIGTERM, then SIGKILL after timeout)
docker stop lifecycle-test
docker ps -a  # Status: Exited (0)

# 6. Restart
docker restart lifecycle-test
docker ps  # Status: Up

# 7. Kill (immediate SIGKILL, no graceful shutdown)
docker kill lifecycle-test
docker ps -a  # Status: Exited (137)

# 8. Remove
docker rm lifecycle-test
docker ps -a  # gone
```

**State transitions:**
```
Created → Started → Running ←→ Paused
                     ↓
                   Stopped → Removed
```

---

## Task 4: Working with Running Containers

```bash
# Use the existing zabbix-web container as example
CONTAINER="zabbix-web-apache-mysql"

# View logs
docker logs $CONTAINER | tail -20

# Follow logs in real time
docker logs -f $CONTAINER

# Exec into container
docker exec -it $CONTAINER bash
# Inside: ls /var/www/html, cat /etc/apache2/ports.conf

# Run single command without entering
docker exec $CONTAINER ls /etc/zabbix/

# Inspect container — find IP, port mappings, mounts
docker inspect $CONTAINER | python3 -c "
import sys, json
data = json.load(sys.stdin)[0]
nets = data['NetworkSettings']['Networks']
print('IP:', list(nets.values())[0]['IPAddress'])
print('Ports:', data['NetworkSettings']['Ports'])
"
```

---

## Task 5: Cleanup

```bash
# Docker disk usage on this system
docker system df
```
```
TYPE            TOTAL   ACTIVE  SIZE      RECLAIMABLE
Images          11      10      2.563GB   351.4MB (13%)
Containers      14      4       4.356MB   4.279MB (98%)
Local Volumes   10      10      524.3MB   0B (0%)
Build Cache     16      0       10.42MB   10.42MB
```

```bash
# Stop all running containers (excluding production ones!)
docker stop $(docker ps -q)

# Remove all stopped containers
docker container prune

# Remove unused images
docker image prune -a

# Nuclear option — remove everything not in use
docker system prune -a --volumes

# Check space after cleanup
docker system df
```

---

## Key Commands Learned Today

```bash
docker pull <image>                   # download image
docker images                         # list images
docker image history <image>          # show layers
docker inspect <image|container>      # detailed info
docker rmi <image>                    # remove image
docker create --name <n> <image>      # create without starting
docker start / stop / restart <name>  # lifecycle
docker pause / unpause <name>         # pause/unpause
docker kill <name>                    # immediate kill
docker rm <name>                      # remove container
docker logs -f <name>                 # follow logs
docker exec -it <name> bash           # interactive shell
docker system df                      # disk usage
docker system prune                   # cleanup
```

---

## What I Learned

1. **Image layers enable caching and sharing** — when you build an image, Docker only rebuilds layers that changed. Putting rarely-changing instructions (like `apt install`) before frequently-changing ones (like `COPY . .`) makes builds dramatically faster.
2. **Pause vs Stop vs Kill** — `pause` freezes the process in place (memory preserved). `stop` sends SIGTERM for graceful shutdown. `kill` sends SIGKILL immediately. Use `stop` in production, `kill` only as last resort.
3. **`docker system prune` is powerful** — on this server, there's 10MB of unused build cache and 351MB of reclaimable image space. Regular pruning keeps disk usage in check.
