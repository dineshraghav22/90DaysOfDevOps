# Docker Cheat Sheet

## Container Commands

```bash
docker run <image>                          # run container
docker run -d <image>                       # detached (background)
docker run -it <image> bash                 # interactive shell
docker run -p 8080:80 <image>              # port mapping host:container
docker run --name myapp <image>             # custom name
docker run -e VAR=value <image>             # environment variable
docker run -v vol:/path <image>             # attach volume
docker run --network mynet <image>          # custom network
docker run --rm <image>                     # auto-remove on exit

docker ps                                   # running containers
docker ps -a                                # all containers
docker stop <name/id>                       # graceful stop (SIGTERM)
docker kill <name/id>                       # immediate stop (SIGKILL)
docker start <name/id>                      # start stopped container
docker restart <name/id>                    # stop + start
docker pause <name/id>                      # freeze process
docker unpause <name/id>                    # resume

docker rm <name/id>                         # remove stopped container
docker rm -f <name/id>                      # force remove running container

docker logs <name/id>                       # view logs
docker logs -f <name/id>                    # follow logs (live)
docker logs --tail 50 <name>                # last 50 lines

docker exec -it <name> bash                 # shell in running container
docker exec <name> <command>                # run command in container

docker inspect <name/id>                    # detailed container info
docker stats                                # live resource usage
docker top <name>                           # running processes in container

docker cp <name>:/path/file .              # copy from container to host
docker cp ./file <name>:/path/             # copy from host to container
```

---

## Image Commands

```bash
docker images                               # list images
docker images --format "table {{.Repository}}\t{{.Size}}"

docker pull <image>:<tag>                   # download image
docker push <user>/<image>:<tag>            # push to registry

docker build -t name:tag .                  # build from Dockerfile
docker build -f Dockerfile.dev -t name .   # specify Dockerfile
docker build --no-cache -t name .           # build without cache

docker tag <image> <new-name>:<tag>         # tag an image

docker rmi <image>                          # remove image
docker rmi -f <image>                       # force remove

docker image history <image>                # show layers
docker image inspect <image>                # detailed image info

docker login                                # login to Docker Hub
docker logout                               # logout
```

---

## Volume Commands

```bash
docker volume create <name>                 # create named volume
docker volume ls                            # list volumes
docker volume inspect <name>                # volume details
docker volume rm <name>                     # delete volume
docker volume prune                         # remove unused volumes
```

---

## Network Commands

```bash
docker network create <name>                # create custom bridge network
docker network create --driver host <name>  # host network
docker network ls                           # list networks
docker network inspect <name>               # network details
docker network connect <net> <container>    # connect container to network
docker network disconnect <net> <container> # disconnect
docker network rm <name>                    # remove network
docker network prune                        # remove unused networks
```

---

## Compose Commands

```bash
docker compose up                           # start (foreground)
docker compose up -d                        # start (detached)
docker compose up --build                   # start + rebuild images
docker compose up --scale web=3             # scale service

docker compose down                         # stop + remove containers + networks
docker compose down -v                      # also remove volumes

docker compose ps                           # list services
docker compose logs                         # all service logs
docker compose logs -f <service>            # follow specific service logs

docker compose stop                         # stop without removing
docker compose start                        # start stopped services
docker compose restart                      # restart all services
docker compose restart <service>            # restart specific service

docker compose exec <service> bash          # shell in service container
docker compose run <service> <cmd>          # one-off command
docker compose config                       # validate compose file
```

---

## Cleanup Commands

```bash
docker system df                            # disk usage
docker system prune                         # remove stopped containers, unused images, networks
docker system prune -a                      # also remove all unused images
docker system prune -a --volumes            # also remove unused volumes

docker container prune                      # remove stopped containers
docker image prune                          # remove dangling images
docker image prune -a                       # remove all unused images
docker volume prune                         # remove unused volumes
docker network prune                        # remove unused networks
```

---

## Dockerfile Instructions

| Instruction | Purpose | Example |
|-------------|---------|---------|
| `FROM` | Base image | `FROM ubuntu:22.04` |
| `RUN` | Build command | `RUN apt install -y curl` |
| `COPY` | Copy from host | `COPY . /app` |
| `ADD` | Copy + extract tar/URL | `ADD app.tar.gz /app` |
| `WORKDIR` | Set working directory | `WORKDIR /app` |
| `EXPOSE` | Document port | `EXPOSE 8080` |
| `ENV` | Set environment variable | `ENV PORT=8080` |
| `ARG` | Build-time variable | `ARG VERSION=1.0` |
| `CMD` | Default command (overridable) | `CMD ["python", "app.py"]` |
| `ENTRYPOINT` | Fixed executable | `ENTRYPOINT ["python"]` |
| `USER` | Switch user | `USER appuser` |
| `VOLUME` | Declare mount point | `VOLUME ["/data"]` |
| `HEALTHCHECK` | Health check command | `HEALTHCHECK CMD curl -f http://localhost/health` |
| `LABEL` | Add metadata | `LABEL version="1.0"` |
| `ONBUILD` | Trigger on child image build | `ONBUILD COPY . /app` |
