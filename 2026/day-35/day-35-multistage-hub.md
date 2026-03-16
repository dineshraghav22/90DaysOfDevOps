# Day 35 – Multi-Stage Builds & Docker Hub

## Files Created

- `go-app/main.go` — simple Go HTTP server
- `go-app/Dockerfile.single` — single-stage build (~800MB)
- `go-app/Dockerfile` — multi-stage build (~15MB)

---

## Task 1: The Problem with Single-Stage Builds

```dockerfile
# Dockerfile.single — includes entire Go toolchain
FROM golang:1.21
WORKDIR /app
COPY . .
RUN go build -o server main.go
CMD ["./server"]
```

```bash
docker build -t go-single -f Dockerfile.single .
docker images go-single
# go-single   latest   ~800MB+
```

The image contains: Go compiler (~400MB), standard library, all build tools, source code — everything needed to BUILD the app but NOT to RUN it.

---

## Task 2: Multi-Stage Build

```dockerfile
# Stage 1: Build the app
FROM golang:1.21-alpine AS builder
WORKDIR /app
COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -o server main.go

# Stage 2: Minimal runtime image
FROM alpine:3.19
RUN adduser -D -g '' appuser
WORKDIR /app
COPY --from=builder /app/server .    # ← only copy the compiled binary
USER appuser
EXPOSE 8080
CMD ["./server"]
```

```bash
docker build -t go-multistage .
docker images go-multistage
# go-multistage   latest   ~15MB
```

**Size comparison:**
| Build | Size | Contains |
|-------|------|---------|
| Single-stage | ~800MB | Go compiler + stdlib + binary |
| Multi-stage | ~15MB | Alpine base + compiled binary only |

**Why multi-stage is so much smaller:**
The `COPY --from=builder` instruction copies ONLY the compiled binary from the build stage. The builder stage (with all the Go toolchain) is discarded. The final image never contains build tools.

---

## Task 3: Push to Docker Hub

```bash
# Login
docker login
# Username: yourdockerhubusername
# Password: (enter password or token)

# Tag the image properly
docker tag go-multistage yourdockerhubusername/go-hello:v1
docker tag go-multistage yourdockerhubusername/go-hello:latest

# Push
docker push yourdockerhubusername/go-hello:v1
docker push yourdockerhubusername/go-hello:latest

# Verify: pull it fresh
docker rmi yourdockerhubusername/go-hello:v1
docker pull yourdockerhubusername/go-hello:v1
docker run --rm -p 8086:8080 yourdockerhubusername/go-hello:v1
# Access: http://localhost:8086 → "Hello from Go!"
```

---

## Task 4: Docker Hub Repository

On Docker Hub (`hub.docker.com`):
- **Tags tab:** shows `v1` and `latest` — versioning is explicit
- **Description:** Added "Multi-stage built Go HTTP server — part of 90 Days of DevOps"
- **Pulling specific tag:**

```bash
docker pull yourusername/go-hello:v1      # specific version
docker pull yourusername/go-hello:latest  # latest tag (same or newer)
```

**Why use specific tags?**
`latest` changes when you push. In production, always pin to a specific version tag to ensure deterministic deployments.

---

## Task 5: Image Best Practices Applied

```dockerfile
# 1. Minimal base: alpine vs ubuntu
FROM alpine:3.19       # 7MB base vs ubuntu 77MB

# 2. Non-root user
RUN adduser -D -g '' appuser
USER appuser

# 3. Combined RUN commands (reduce layers)
# BAD:
RUN apt update
RUN apt install -y curl
RUN apt clean
# GOOD:
RUN apt update && apt install -y curl && rm -rf /var/lib/apt/lists/*

# 4. Specific tags (not latest)
FROM golang:1.21-alpine    # pinned version, reproducible
# NOT: FROM golang:latest   (changes without warning)
```

**Before best practices:** ~800MB, runs as root
**After best practices:** ~15MB, runs as non-root `appuser`

---

## What I Learned

1. **Multi-stage builds are the standard for compiled languages** — Go, Java, Rust: compile in a full toolchain image, copy the artifact into a minimal runtime image. The result is typically 50-100x smaller.
2. **`COPY --from=builder`** is the key instruction — it crosses stage boundaries and only brings what you explicitly copy. Everything else in the build stage is thrown away.
3. **Docker Hub is a distribution mechanism** — `docker pull yourusername/go-hello:v1` works from any machine anywhere. This is how real software is distributed: build once, run anywhere.
