---
name: nerdctl
description: Guide for using nerdctl, a Docker-compatible CLI for containerd. This skill should be used when the user wants to manage containers, images, volumes, or networks using nerdctl.
---

# nerdctl CLI

This skill covers the usage of `nerdctl`, a Docker-compatible command-line interface for containerd.
`nerdctl` provides a user experience similar to `docker` but interacts directly with containerd.

## Overview

`nerdctl` supports most Docker commands and adds some containerd-specific features.
- :whale: indicates Docker compatibility.
- :nerd_face: indicates nerdctl-specific features.

## Container Management

### Running Containers
**Command:** `nerdctl run [OPTIONS] IMAGE [COMMAND] [ARG...]`
- **Common Flags:**
    - `-d, --detach`: Run in background.
    - `-i, --interactive`: Keep STDIN open.
    - `-t, --tty`: Allocate a pseudo-TTY.
    - `--rm`: Automatically remove the container when it exits.
    - `--name`: Assign a name to the container.
    - `-p, --publish`: Publish a container's port(s) to the host (e.g., `-p 8080:80`).
    - `-v, --volume`: Bind mount a volume (e.g., `-v /host:/container`).
    - `--net, --network`: Connect to a network (bridge, host, none, CNI).
    - `-e, --env`: Set environment variables.
    - `--restart`: Restart policy (`no`, `always`, `on-failure`, `unless-stopped`).
    - `--platform`: Set platform (e.g., `amd64`, `arm64`).

### Listing Containers
**Command:** `nerdctl ps [OPTIONS]`
- **Flags:**
    - `-a, --all`: Show all containers (default shows just running).
    - `-q`: Only display IDs.

### Executing Commands
**Command:** `nerdctl exec [OPTIONS] CONTAINER COMMAND [ARG...]`
- **Flags:**
    - `-i`, `-t`, `-d`, `-w` (workdir), `-e` (env), `--privileged`, `-u` (user).

### Lifecycle Management
- **Start:** `nerdctl start [OPTIONS] CONTAINER`
- **Stop:** `nerdctl stop [OPTIONS] CONTAINER`
- **Restart:** `nerdctl restart [OPTIONS] CONTAINER`
- **Kill:** `nerdctl kill [OPTIONS] CONTAINER`
- **Pause/Unpause:** `nerdctl pause CONTAINER` / `nerdctl unpause CONTAINER`
- **Remove:** `nerdctl rm [OPTIONS] CONTAINER`
    - `-f, --force`: Force removal of running containers.
    - `-v`: Remove anonymous volumes.

### Inspection & Logs
- **Logs:** `nerdctl logs [OPTIONS] CONTAINER`
    - `-f`: Follow log output.
    - `--since`, `--until`: Filter by time.
    - `-n, --tail`: Show last N lines.
- **Inspect:** `nerdctl inspect CONTAINER`
    - Returns detailed JSON information about the container.
- **Port:** `nerdctl port CONTAINER`
- **Stats:** `nerdctl stats`

## Image Management

### Listing Images
**Command:** `nerdctl images [OPTIONS]`
- `-a`: Show all images.

### Pulling & Pushing
- **Pull:** `nerdctl pull [OPTIONS] NAME[:TAG]`
    - `--platform`: Pull for specific platform (can be specified multiple times).
    - `--all-platforms`: Pull all platforms.
    - `--unpack`: Unpack image (auto/true/false).
- **Push:** `nerdctl push [OPTIONS] NAME[:TAG]`
    - `--platform`, `--all-platforms`.
    - `--sign`: Sign image (cosign/notation).

### Building Images
**Command:** `nerdctl build [OPTIONS] PATH`
- `-t, --tag`: Name and tag.
- `-f, --file`: Dockerfile path.
- `--target`: Build stage target.
- `--build-arg`: Build-time variables.
- `--no-cache`: Disable cache.
- `--platform`: Set target platform.
- `--output`: Output destination (local, oci, docker, tar, image).

### Other Image Operations
- **Tag:** `nerdctl tag SOURCE TARGET`
- **Remove:** `nerdctl rmi [OPTIONS] IMAGE`
- **Load:** `nerdctl load -i <tarball>`
- **Save:** `nerdctl save -o <tarball> IMAGE`
- **History:** `nerdctl history IMAGE`
- **Prune:** `nerdctl image prune`

## Network Management

- **List:** `nerdctl network ls`
- **Create:** `nerdctl network create [OPTIONS] NETWORK`
- **Inspect:** `nerdctl network inspect NETWORK`
- **Remove:** `nerdctl network rm NETWORK`
- **Prune:** `nerdctl network prune`

## Volume Management

- **List:** `nerdctl volume ls`
- **Create:** `nerdctl volume create [OPTIONS] VOLUME`
- **Inspect:** `nerdctl volume inspect VOLUME`
- **Remove:** `nerdctl volume rm VOLUME`
- **Prune:** `nerdctl volume prune`

## Namespace Management (:nerd_face:)

`nerdctl` natively supports containerd namespaces.

- **List:** `nerdctl namespace ls`
- **Create:** `nerdctl namespace create NAME`
- **Inspect:** `nerdctl namespace inspect NAME`
- **Remove:** `nerdctl namespace remove NAME`
- **Update:** `nerdctl namespace update NAME`

## Compose

`nerdctl` supports `docker-compose` style orchestration.

**Command:** `nerdctl compose [OPTIONS] COMMAND`
- **Commands:** `up`, `down`, `ps`, `logs`, `build`, `pull`, `push`, `restart`, `start`, `stop`, `run`, `exec`, `config`.
- **Note:** Standard `docker-compose.yml` files are supported.

## System & Advanced

- **Info:** `nerdctl info`
- **Version:** `nerdctl version`
- **Prune System:** `nerdctl system prune`
- **Events:** `nerdctl events`
- **Login/Logout:** `nerdctl login`, `nerdctl logout`
- **IPFS:** `nerdctl` supports IPFS for pulling/pushing images (`ipfs://` prefix).

## Common Tasks Reference

### Run a web server
```bash
nerdctl run -d -p 8080:80 --name my-nginx nginx:alpine
```

### Build an image
```bash
nerdctl build -t my-app:v1 .
```

### Clean up unused resources
```bash
nerdctl system prune -a
```

### Explore container process
```bash
nerdctl exec -it my-container /bin/sh
```
