# Day 31 – Dockerfile: Build Your Own Images

## Dockerfiles Created

1. `my-first-image/Dockerfile` — ubuntu + curl, custom CMD
2. `my-website/Dockerfile` — nginx:alpine serving custom HTML
3. `my-website/.dockerignore` — excludes md, git, env, node_modules

---

## Task 1: First Dockerfile – my-first-image

```dockerfile
FROM ubuntu:22.04
RUN apt-get update && apt-get install -y curl && rm -rf /var/lib/apt/lists/*
CMD ["echo", "Hello from my custom image!"]
```

```bash
docker build -t my-ubuntu:v1 .
docker run --rm my-ubuntu:v1
# Output: Hello from my custom image!
```

---

## Task 2: Dockerfile Instructions Reference

| Instruction | Purpose | Example |
|-------------|---------|---------|
| `FROM` | Base image to start from | `FROM ubuntu:22.04` |
| `RUN` | Execute commands during build | `RUN apt install -y curl` |
| `COPY` | Copy files from host to image | `COPY app.py /app/` |
| `WORKDIR` | Set working directory for subsequent instructions | `WORKDIR /app` |
| `EXPOSE` | Document which port the app listens on | `EXPOSE 80` |
| `CMD` | Default command when container starts | `CMD ["nginx", "-g", "daemon off;"]` |

---

## Task 3: CMD vs ENTRYPOINT

**CMD — replaceable at runtime:**
```dockerfile
CMD ["echo", "hello"]
```
```bash
docker run myimage           # prints: hello
docker run myimage echo bye  # prints: bye  (CMD is overridden)
```

**ENTRYPOINT — fixed executable:**
```dockerfile
ENTRYPOINT ["echo"]
```
```bash
docker run myimage           # prints nothing (no args)
docker run myimage hello     # prints: hello
docker run myimage foo bar   # prints: foo bar
```

**Combined (best practice):**
```dockerfile
ENTRYPOINT ["python3", "app.py"]
CMD ["--port", "8080"]       # default args, overridable
```

**When to use which:**
- **CMD only** — when the whole command should be replaceable (e.g., shell images)
- **ENTRYPOINT** — when the container has a fixed executable purpose
- **Both together** — ENTRYPOINT = command, CMD = default arguments

---

## Task 4: Static Website – my-website

```dockerfile
FROM nginx:alpine

COPY index.html /usr/share/nginx/html/index.html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
```

```bash
docker build -t my-website:v1 .
docker run -d -p 8082:80 --name my-site my-website:v1
# Access: http://localhost:8082
```

**Image size: ~43MB** (nginx:alpine is tiny vs nginx on ubuntu which would be ~200MB)

---

## Task 5: .dockerignore

```
*.md
.git
.env
node_modules
```

Without `.dockerignore`, `COPY . .` would include all these files in the build context (sent to Docker daemon) and potentially in the image. With it, only relevant files are included.

---

## Task 6: Build Optimization – Layer Order Matters

**Bad order (slow rebuilds):**
```dockerfile
FROM python:3.9-slim
COPY . .                    # changes every time
RUN pip install -r requirements.txt  # reinstalls every time even if deps unchanged
```

**Good order (fast rebuilds):**
```dockerfile
FROM python:3.9-slim
COPY requirements.txt .     # only changes when deps change
RUN pip install -r requirements.txt  # cached unless requirements.txt changed
COPY . .                    # changes most often → goes LAST
```

**Why this works:** Docker caches each layer. If a layer hasn't changed, it reuses the cache. Once a layer changes, all subsequent layers are rebuilt. Put stable instructions first (base image, deps), dynamic instructions last (app code).

---

## Images Built

```bash
docker images my-ubuntu:v1 my-website:v1
# my-ubuntu:v1    (ubuntu + curl)
# my-website:v1   (nginx:alpine + custom HTML)
```

---

## What I Learned

1. **`RUN` cleanup is critical** — always chain `apt install` with `rm -rf /var/lib/apt/lists/*` in the same `RUN` command. If you clean in a separate `RUN`, the apt lists are still in the previous layer and the image is still large.
2. **Alpine base images are the right default** — `nginx:alpine` at ~43MB vs `nginx` at ~187MB. Unless you need Ubuntu-specific tooling, always use `alpine` or `slim` variants.
3. **Layer order = build speed** — organizing Dockerfile so frequently-changing files come last dramatically speeds up iterative development. A 5-minute build becomes 10 seconds when deps are cached.
