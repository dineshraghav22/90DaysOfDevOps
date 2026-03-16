# Day 34 – Docker Compose: Real-World Multi-Container Apps

## Files Created

- `app/app.py` — Flask web application
- `app/requirements.txt` — Python dependencies
- `app/Dockerfile` — Multi-stage ready, non-root user
- `docker-compose.yml` — 3-service stack: web + db + cache
- `.env` — Database credentials

---

## Task 1: 3-Service Stack

Architecture:
```
Browser → Flask app (port 5001) → Postgres (db)
                                 → Redis (cache)
```

All three services defined in one `docker-compose.yml`, on a shared custom network `app-network`.

```bash
docker compose up -d --build
docker compose ps
```

---

## Task 2: depends_on & Healthchecks

```yaml
db:
  image: postgres:15-alpine
  healthcheck:
    test: ["CMD-SHELL", "pg_isready -U ${DB_USER} -d ${DB_NAME}"]
    interval: 10s
    timeout: 5s
    retries: 5

web:
  depends_on:
    db:
      condition: service_healthy   # waits for healthcheck to pass
```

**Without `condition: service_healthy`:** Web starts when DB container starts. DB might not be ready for connections yet → app crashes on startup.

**With `condition: service_healthy`:** Web waits until Postgres passes `pg_isready` → app connects successfully.

**Test:** `docker compose down && docker compose up -d` — watch the logs, web starts only after DB is healthy.

---

## Task 3: Restart Policies

```yaml
db:
  restart: always     # always restart, even after docker daemon restart

web:
  restart: on-failure  # only restart if container exits with non-zero code
```

| Policy | Behavior |
|--------|----------|
| `no` | Never restart (default) |
| `always` | Always restart, including on daemon restart |
| `on-failure` | Restart only if exit code is non-zero |
| `unless-stopped` | Restart unless manually stopped |

**`restart: always`** — use for databases and core services that must always be running.
**`restart: on-failure`** — use for worker processes where a crash means something went wrong.

**Test:** Kill the DB container:
```bash
docker kill day34-db-1
docker ps  # DB comes back automatically with restart: always
```

---

## Task 4: Custom Dockerfiles in Compose

```yaml
web:
  build: ./app    # builds from ./app/Dockerfile
```

```bash
# After code change in app.py:
docker compose up -d --build   # rebuild + restart in one command
```

The `build:` key tells Compose to build the image from a Dockerfile instead of pulling from a registry.

---

## Task 5: Named Networks & Volumes + Labels

```yaml
networks:
  app-network:
    driver: bridge    # explicit network definition

volumes:
  postgres-data:      # named volume for DB persistence

services:
  web:
    labels:
      - "app.component=web"
      - "app.version=1.0"
```

**Why explicit networks?** Prevents accidental access between unrelated Compose stacks that might be on the same machine.

**Labels** enable filtering:
```bash
docker ps --filter "label=app.component=database"
```

---

## Task 6: Scaling (Bonus)

```bash
docker compose up -d --scale web=3
```

**What happens:** 3 instances of the web service start, but they all try to bind port `5001:5000` — only one can own a host port. The other 2 fail.

**Why simple scaling doesn't work with port mapping:**
Port `5001` on the host can only be owned by ONE process. To scale containers, you need a load balancer (nginx/traefik) in front that distributes traffic, and remove the fixed port mapping from the web service.

```yaml
# For scalable services:
web:
  ports: []    # No fixed port — load balancer handles routing
```

---

## What I Learned

1. **`condition: service_healthy` is the right way to handle startup order** — basic `depends_on` is a common trap. Services can start but not be ready. Always combine with a healthcheck for databases.
2. **Restart policies make containers self-healing** — `restart: always` on critical services means your app recovers from crashes without human intervention. This is production behavior.
3. **Scaling requires architectural decisions** — you can't just `--scale` a service that has fixed host port bindings. Real scaling requires a reverse proxy layer (covered in Kubernetes days).
