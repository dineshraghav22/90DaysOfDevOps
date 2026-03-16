# Multi-stage build for Flask Todo API
FROM python:3.11-slim AS builder

WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir --user -r requirements.txt

# Final stage: minimal runtime
FROM python:3.11-slim

WORKDIR /app

# Non-root user
RUN adduser --disabled-password --gecos '' appuser

# Copy installed packages from builder
COPY --from=builder /root/.local /home/appuser/.local

# Copy app code
COPY --chown=appuser:appuser . .

USER appuser
ENV PATH=/home/appuser/.local/bin:$PATH

EXPOSE 5000
CMD ["python", "app.py"]
