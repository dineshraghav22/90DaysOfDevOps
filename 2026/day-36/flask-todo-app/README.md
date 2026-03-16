# Flask Todo API

A simple REST API for managing tasks, built with Flask.

## What it does
- `GET /tasks` — list all tasks
- `POST /tasks` — add a new task
- `GET /health` — health check endpoint

## How to run with Docker Compose

```bash
# Clone and enter directory
git clone ...
cd day-36

# Start all services
docker compose up -d

# Test the API
curl http://localhost:5002/health
curl http://localhost:5002/tasks
curl -X POST http://localhost:5002/tasks \
  -H "Content-Type: application/json" \
  -d '{"title": "Learn Docker"}'

# Stop
docker compose down
```

## Environment Variables

| Variable | Description |
|----------|-------------|
| PORT | Flask server port (default: 5000) |
| DB_HOST | PostgreSQL host |
| DB_NAME | Database name |
| DB_USER | Database user |
| DB_PASSWORD | Database password |

Create `.env` file from `.env.example` and fill in values.
