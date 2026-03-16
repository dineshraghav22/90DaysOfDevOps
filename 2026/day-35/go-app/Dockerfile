# Multi-stage: Build in Go, run in Alpine
# Stage 1: Build
FROM golang:1.21-alpine AS builder

WORKDIR /app
COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -o server main.go

# Stage 2: Minimal runtime image
FROM alpine:3.19

# Non-root user for security
RUN adduser -D -g '' appuser

WORKDIR /app
COPY --from=builder /app/server .

USER appuser

EXPOSE 8080
CMD ["./server"]
# Image size: ~15MB (only the compiled binary + alpine base)
