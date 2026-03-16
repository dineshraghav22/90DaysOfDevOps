# Day 32 – Docker Volumes & Networking

## Task 1: The Problem – Data Loss Without Volumes

```bash
# Run MySQL without a volume
docker run -d --name test-mysql \
  -e MYSQL_ROOT_PASSWORD=secret \
  -e MYSQL_DATABASE=mydb \
  mysql:8.0

# Create data inside
docker exec -it test-mysql mysql -uroot -psecret -e "
  USE mydb;
  CREATE TABLE users (id INT, name VARCHAR(50));
  INSERT INTO users VALUES (1, 'Dinesh'), (2, 'Tokyo');
  SELECT * FROM users;
"

# Stop and REMOVE the container
docker stop test-mysql && docker rm test-mysql

# Run a NEW container
docker run -d --name test-mysql2 \
  -e MYSQL_ROOT_PASSWORD=secret \
  -e MYSQL_DATABASE=mydb \
  mysql:8.0

docker exec -it test-mysql2 mysql -uroot -psecret -e "USE mydb; SELECT * FROM users;"
# ERROR: Table 'mydb.users' doesn't exist
```

**What happened:** When the container was removed, everything in its filesystem was deleted. No volume = no persistence.

---

## Task 2: Named Volumes – Persistent Data

```bash
# Create a named volume
docker volume create mysql-data
docker volume ls
# local   mysql-data

# Run MySQL with the named volume
docker run -d --name mysql-with-vol \
  -e MYSQL_ROOT_PASSWORD=secret \
  -e MYSQL_DATABASE=mydb \
  -v mysql-data:/var/lib/mysql \
  mysql:8.0

# Add data
docker exec -it mysql-with-vol mysql -uroot -psecret -e "
  USE mydb;
  CREATE TABLE users (id INT, name VARCHAR(50));
  INSERT INTO users VALUES (1, 'Dinesh');
"

# Stop and remove container
docker stop mysql-with-vol && docker rm mysql-with-vol

# New container, same volume
docker run -d --name mysql-restored \
  -e MYSQL_ROOT_PASSWORD=secret \
  -v mysql-data:/var/lib/mysql \
  mysql:8.0

docker exec -it mysql-restored mysql -uroot -psecret -e "SELECT * FROM mydb.users;"
# +----+--------+
# | id | name   |
# +----+--------+
# |  1 | Dinesh |
# +----+--------+
# Data survived! The volume persisted it.
```

```bash
docker volume inspect mysql-data
# Mountpoint: /var/lib/docker/volumes/mysql-data/_data
# This is where the data actually lives on the host
```

---

## Task 3: Bind Mounts

```bash
# Create host directory with HTML
mkdir -p /tmp/my-html
echo "<h1>Hello from host filesystem!</h1>" > /tmp/my-html/index.html

# Run nginx with bind mount
docker run -d -p 8083:80 --name bind-nginx \
  -v /tmp/my-html:/usr/share/nginx/html \
  nginx:alpine

# Access: http://localhost:8083 → "Hello from host filesystem!"

# Edit on host
echo "<h1>I changed this without rebuilding!</h1>" > /tmp/my-html/index.html
# Refresh browser → change is live instantly
```

### Named Volume vs Bind Mount

| | Named Volume | Bind Mount |
|---|---|---|
| Location managed by | Docker | You (host path) |
| Portability | High (works on any host) | Low (depends on host path existing) |
| Use case | Production DB data | Development (live code reload) |
| Performance | Optimized | Slightly lower on Mac/Windows |

**Rule:** Named volumes for production data. Bind mounts for development.

---

## Task 4: Docker Networking Basics

```bash
# List all networks
docker network ls
# bridge    bridge  local
# host      host    local
# none      null    local

# Inspect default bridge
docker network inspect bridge
```

**Default bridge network — containers by IP only:**
```bash
docker run -d --name cont1 alpine sleep 300
docker run -d --name cont2 alpine sleep 300

# Get cont1's IP
docker inspect cont1 | grep IPAddress
# 172.17.0.2

# From cont2, ping cont1 by IP: works
docker exec cont2 ping -c 2 172.17.0.2   # success

# From cont2, ping cont1 by NAME: fails!
docker exec cont2 ping -c 2 cont1   # ping: bad address 'cont1'
```

**Why?** The default bridge has no DNS — containers don't know each other's names.

---

## Task 5: Custom Networks – Name-Based Communication

```bash
# Create custom bridge network
docker network create my-app-net

# Run two containers on the same custom network
docker run -d --name server1 --network my-app-net alpine sleep 300
docker run -d --name server2 --network my-app-net alpine sleep 300

# Can server2 ping server1 by NAME?
docker exec server2 ping -c 2 server1   # SUCCESS!
```

**Why custom networks allow name resolution:** Docker has a built-in DNS server for custom networks. Every container gets a DNS entry using its container name. The default bridge doesn't have this.

---

## Task 6: Complete Stack – App + DB on Custom Network

```bash
# Create network
docker network create app-network

# Create volume for DB persistence
docker volume create postgres-data

# Run PostgreSQL with volume and custom network
docker run -d \
  --name postgres-db \
  --network app-network \
  -e POSTGRES_PASSWORD=devops123 \
  -e POSTGRES_DB=appdb \
  -v postgres-data:/var/lib/postgresql/data \
  postgres:15-alpine

# Run app container on same network
docker run -d \
  --name my-app \
  --network app-network \
  -e DB_HOST=postgres-db \   # ← uses container NAME as hostname
  -e DB_PASSWORD=devops123 \
  python:3.9-slim sleep 300

# App can reach DB by name
docker exec my-app ping -c 2 postgres-db   # resolves via Docker DNS
```

---

## Key Commands

```bash
docker volume create <name>           # create named volume
docker volume ls                      # list volumes
docker volume inspect <name>          # volume details
docker volume rm <name>               # delete volume
docker run -v volume_name:/path       # attach named volume
docker run -v /host/path:/container/path  # bind mount

docker network create <name>          # create custom network
docker network ls                     # list networks
docker network inspect <name>         # network details
docker run --network <name>           # attach to network
docker exec c1 ping c2                # test connectivity
```

---

## What I Learned

1. **Containers are ephemeral by design** — this is a feature, not a bug. Volumes decouple data lifecycle from container lifecycle. The DB container can be rebuilt/upgraded without losing data.
2. **Custom networks are always better than default bridge** — always create a custom network for multi-container apps. Name-based DNS is essential for containers to discover each other dynamically.
3. **The running Zabbix + MariaDB stack on this system uses exactly this pattern** — `docker-compose` created a custom network and named volumes. That's how production Docker setups work.
