# Day 37 – Docker Revision & Cheat Sheet

## Self-Assessment Checklist

| Skill | Status |
|-------|--------|
| Run a container from Docker Hub (interactive + detached) | Can do confidently |
| List, stop, remove containers and images | Can do confidently |
| Explain image layers and how caching works | Can do confidently |
| Write a Dockerfile from scratch with FROM, RUN, COPY, WORKDIR, CMD | Can do confidently |
| Explain CMD vs ENTRYPOINT | Can do confidently |
| Build and tag a custom image | Can do confidently |
| Create and use named volumes | Can do confidently |
| Use bind mounts | Can do confidently |
| Create custom networks and connect containers | Can do confidently |
| Write a docker-compose.yml for a multi-container app | Can do confidently |
| Use environment variables and .env files in Compose | Can do confidently |
| Write a multi-stage Dockerfile | Can do confidently |
| Push an image to Docker Hub | Comfortable |
| Use healthchecks and depends_on | Can do confidently |

---

## Quick-Fire Questions

**1. What is the difference between an image and a container?**
An image is a read-only template (like a class). A container is a running instance of an image (like an object). Many containers can be created from one image, each isolated.

**2. What happens to data inside a container when you remove it?**
It's permanently deleted. Containers are ephemeral — their writable layer is removed with `docker rm`. Only data in named volumes or bind mounts survives container removal.

**3. How do two containers on the same custom network communicate?**
Via container name as hostname. Docker's built-in DNS on custom networks resolves service names to their current IPs. Example: `ping db` from the `web` container resolves to the `db` container's IP.

**4. What does `docker compose down -v` do differently from `docker compose down`?**
`docker compose down` removes containers and networks but preserves named volumes. `docker compose down -v` also removes named volumes — destroying all persisted data (databases, uploaded files). Use with caution.

**5. Why are multi-stage builds useful?**
They separate build toolchain from runtime. Stage 1 has compilers, dev dependencies, and build tools. Stage 2 copies only the final artifact (binary, compiled code). Result: 10-100x smaller images with no build tools in production.

**6. What is the difference between `COPY` and `ADD`?**
`COPY` just copies files/directories. `ADD` also extracts tar files and can download from URLs. Best practice: always use `COPY` unless you specifically need `ADD`'s extra features. `ADD` hides magic behavior that makes Dockerfiles harder to understand.

**7. What does `-p 8080:80` mean?**
Map port 8080 on the HOST to port 80 inside the CONTAINER. Requests to `localhost:8080` are forwarded to the container's internal port 80. Format: `-p <host-port>:<container-port>`.

**8. How do you check how much disk space Docker is using?**
```bash
docker system df
```
Shows breakdown by: images, containers, volumes, build cache. Use `docker system prune` to reclaim unused space.

---

## Revisited Weak Areas

### 1. Custom Networks & DNS (revisited)
```bash
docker network create test-net
docker run -d --name alpha --network test-net alpine sleep 300
docker run -d --name beta  --network test-net alpine sleep 300

# Beta can resolve alpha by name
docker exec beta ping -c 2 alpha   # works!
docker exec beta nslookup alpha    # returns alpha's container IP

docker network rm test-net
docker stop alpha beta && docker rm alpha beta
```
**Confirmed:** Custom bridge networks have built-in DNS. Default bridge doesn't.

### 2. Build Cache Behavior (revisited)
```dockerfile
# Test: change only app.py, not requirements.txt
# Layer 1: FROM python  → cached
# Layer 2: COPY requirements.txt → cached (file unchanged)
# Layer 3: RUN pip install → CACHED (no change in requirements)
# Layer 4: COPY . . → REBUILT (app.py changed)
```
Rebuild only takes seconds when requirements are cached. Ordering matters.

---

## Key Insights After 8 Days of Docker

1. **Containers on this server are production** — the Zabbix stack (4 containers, 10 volumes, custom network) has been running for 2+ weeks without issues. Docker Compose in production is real.
2. **Volumes outlive containers** — I can `docker compose down && docker compose up --build` to rebuild the app image, and all data (database, configs) survives in volumes.
3. **The mental model:** image (template) → container (instance) → volume (storage) → network (communication). Get these four relationships right and Docker makes sense.
