# Day 36 – Docker Project: Dockerize a Full Application

## App: Flask Todo REST API

**Why this app?**
Simple, real-world REST API with an explicit database dependency — perfect for demonstrating Docker networking, volumes, and healthchecks.

---

## Project Structure

```
day-36/
├── flask-todo-app/
│   ├── app.py           # Flask REST API
│   ├── requirements.txt
│   ├── Dockerfile       # Multi-stage build, non-root user
│   ├── .dockerignore
│   └── README.md
├── docker-compose.yml   # Full stack: API + Postgres
└── .env                 # Database credentials
```

---

## Dockerfile (Annotated)

```dockerfile
# Stage 1: Install Python packages
FROM python:3.11-slim AS builder
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir --user -r requirements.txt
# --user installs to /root/.local (copy this to final image)

# Stage 2: Minimal runtime
FROM python:3.11-slim

WORKDIR /app

# Create non-root user FIRST (best practice)
RUN adduser --disabled-password --gecos '' appuser

# Copy packages from builder (no pip needed in final image)
COPY --from=builder /root/.local /home/appuser/.local

# Copy app code with correct ownership
COPY --chown=appuser:appuser . .

# Switch to non-root user
USER appuser
ENV PATH=/home/appuser/.local/bin:$PATH

EXPOSE 5000
CMD ["python", "app.py"]
```

**Key practices applied:**
- Multi-stage build — packages installed in builder, only copied to final
- Non-root user — app runs as `appuser`, not root
- `--chown` on COPY — files owned by appuser immediately
- `--no-cache-dir` — reduces image size (no pip cache)

---

## Docker Compose

```yaml
services:
  app:
    build: ./flask-todo-app      # build from local Dockerfile
    ports: ["5002:5000"]
    depends_on:
      db:
        condition: service_healthy
    restart: on-failure

  db:
    image: postgres:15-alpine
    volumes:
      - todo-db-data:/var/lib/postgresql/data
    restart: always
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U ${DB_USER} -d ${DB_NAME}"]
      interval: 10s
      timeout: 5s
      retries: 5

networks:
  todo-network:
    driver: bridge

volumes:
  todo-db-data:
```

---

## Running the Stack

```bash
# Start all services
docker compose up -d --build

# Test
curl http://localhost:5002/health
# {"status": "healthy", "service": "todo-api"}

curl http://localhost:5002/tasks
# []

curl -X POST http://localhost:5002/tasks \
  -H "Content-Type: application/json" \
  -d '{"title": "Learn Docker Compose"}'
# {"done": false, "id": 1, "title": "Learn Docker Compose"}

# Stop
docker compose down
```

---

## Ship It (Docker Hub)

```bash
# Build image
docker build -t flask-todo-api:v1 ./flask-todo-app

# Tag for Docker Hub
docker tag flask-todo-api:v1 yourdockerhubusername/flask-todo-api:v1

# Push
docker push yourdockerhubusername/flask-todo-api:v1

# Test fresh pull
docker rmi yourdockerhubusername/flask-todo-api:v1
docker pull yourdockerhubusername/flask-todo-api:v1
docker run --rm -p 5002:5000 yourdockerhubusername/flask-todo-api:v1
```

---

## Challenges & Solutions

| Challenge | Solution |
|-----------|---------|
| App starts before DB ready | `depends_on: condition: service_healthy` + pg_isready healthcheck |
| Permissions on copied files | `COPY --chown=appuser:appuser` |
| pip packages not found as non-root | `--user` install + add local bin to PATH |

---

## Final Image Size

```bash
docker images flask-todo-api:v1
# flask-todo-api   v1   ~130MB
# (python:3.11-slim base ~130MB + flask ~2MB)
```

Much smaller than python:3.11 (~1GB). For further reduction, use Alpine-based Python.

---

## What I Learned

1. **`--user` pip installs require PATH adjustment** — installing packages as non-root with `--user` puts them in `~/.local/bin`. Must update `PATH` in Dockerfile or they won't be found.
2. **Multi-stage for Python** — unlike Go (single binary), Python multi-stage requires copying the entire `site-packages` directory. The gains are modest vs compiled languages but still worth it for removing build tools.
3. **The whole flow works** — build → push → pull fresh → `docker compose up` and it just works. This is exactly what production CI/CD pipelines do: build in CI, push to registry, pull in production.
