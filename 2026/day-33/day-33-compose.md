# Day 33 – Docker Compose: Multi-Container Basics

## Compose Files Created

1. `compose-basics/docker-compose.yml` — single Nginx service
2. `wordpress-mysql/docker-compose.yml` — WordPress + MySQL with volumes and healthchecks
3. `wordpress-mysql/.env` — credentials (never commit real passwords!)

---

## Task 1: Install & Verify

```bash
docker compose version
# Docker Compose version v2.27.1

# Note: docker compose (V2, plugin) vs docker-compose (V1, standalone)
# V2 is built into Docker CLI — use: docker compose (space, not hyphen)
```

---

## Task 2: First Compose File – Single Nginx

```yaml
# compose-basics/docker-compose.yml
services:
  web:
    image: nginx:alpine
    ports:
      - "8084:80"
    restart: unless-stopped
```

```bash
cd compose-basics/
docker compose up -d        # start in detached mode
docker compose ps           # check status
docker compose down         # stop and remove
```

---

## Task 3: WordPress + MySQL

```yaml
services:
  db:
    image: mysql:8.0
    environment:
      MYSQL_ROOT_PASSWORD: ${MYSQL_ROOT_PASSWORD}
      MYSQL_DATABASE: wordpress
      MYSQL_USER: ${MYSQL_USER}
      MYSQL_PASSWORD: ${MYSQL_PASSWORD}
    volumes:
      - db-data:/var/lib/mysql
    healthcheck:
      test: ["CMD", "mysqladmin", "ping", "-h", "localhost"]
      interval: 10s
      timeout: 5s
      retries: 5

  wordpress:
    image: wordpress:latest
    ports:
      - "8085:80"
    environment:
      WORDPRESS_DB_HOST: db        # ← uses service NAME as hostname
      WORDPRESS_DB_USER: ${MYSQL_USER}
      WORDPRESS_DB_PASSWORD: ${MYSQL_PASSWORD}
      WORDPRESS_DB_NAME: wordpress
    depends_on:
      db:
        condition: service_healthy  # waits for DB to pass healthcheck

volumes:
  db-data:
```

```bash
cd wordpress-mysql/
docker compose up -d
# Access: http://localhost:8085 → WordPress setup page

docker compose down           # stop (data preserved in volume!)
docker compose up -d          # restart — WordPress data still there!
docker compose down -v        # stop AND delete volumes (data gone)
```

**How WordPress connects to MySQL:**
- `WORDPRESS_DB_HOST: db` — `db` is the service name, Compose creates DNS for it
- They're on the same auto-created network: `wordpress-mysql_default`
- WordPress resolves `db` → MySQL container's IP via Docker's DNS

---

## Task 4: Compose Commands

```bash
# Start in detached mode
docker compose up -d

# View running services
docker compose ps

# View logs of all services
docker compose logs

# View logs of specific service
docker compose logs db
docker compose logs -f wordpress    # follow/live

# Stop without removing (containers kept, network kept)
docker compose stop

# Remove containers and network (volumes kept)
docker compose down

# Remove containers, networks AND volumes
docker compose down -v

# Rebuild images (if Dockerfile changed)
docker compose up -d --build

# Scale a service (see Day 34 for limitations)
docker compose up -d --scale wordpress=2
```

---

## Task 5: Environment Variables

**Method 1: Inline in compose file**
```yaml
environment:
  MYSQL_PASSWORD: hardcoded_password   # BAD — don't commit this!
```

**Method 2: `.env` file (referenced automatically)**
```bash
# .env file
MYSQL_ROOT_PASSWORD=strongrootpassword
MYSQL_USER=wpuser
MYSQL_PASSWORD=wppassword
```
```yaml
environment:
  MYSQL_PASSWORD: ${MYSQL_PASSWORD}    # Compose reads from .env
```

**Method 3: Export to shell**
```bash
export MYSQL_PASSWORD=mypassword
docker compose up
```

**Important:** Always add `.env` to `.gitignore`. Never commit credentials to Git.

---

## What I Learned

1. **Compose creates automatic DNS** — service names in `docker-compose.yml` are automatically DNS-resolvable by other services on the same Compose network. `WORDPRESS_DB_HOST: db` works because Compose creates a DNS entry for `db`.
2. **`depends_on: condition: service_healthy`** is better than basic `depends_on` — basic `depends_on` only waits for the container to START (not be READY). The healthcheck condition actually waits for MySQL to accept connections.
3. **`.env` files are Compose's secret management** — keeping credentials out of the compose file itself makes it safe to commit the `docker-compose.yml` while `.env` stays in `.gitignore`.
