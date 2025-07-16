---
description: Start the Node using Docker Compose
---

# Docker Compose Options

The Docker container of the Node could also be started using Docker Compose, for more convenient configurations.

## Start the container using Docker Compose

#### 1. Create an empty working directory

```sh
$ mkdir h_node
$ cd h_node
```

#### 2. Create a file named `docker-compose.yml` in the working directory:

```yaml
---
version: "3.8"
name: "crynux_node"

services:
  h_node:
    image: ghcr.io/crynux-network/crynux-node:latest
    container_name: crynux_node
    restart: unless-stopped
    ports:
      - "127.0.0.1:7412:7412"
    deploy:
      resources:
        reservations:
          devices:
            - driver: nvidia
              capabilities: [gpu]

```

#### 3. Start the Docker container

```sh
docker compose up -d
```

Now you should already be able to access the WebUI from the browser.

## Mount the Model Cache Folder

Since the model preloading takes a long time, often we want to persist the model cache folder outside of the Docker container so that it survives the container recreation during updates. This is easily done by mounting the data folder `/app/data` to a local folder on the host machine:

#### 1. Create an empty data folder inside the working directory

```sh
$ ls .
docker-compose.yml

$ mkdir data

$ ls .
data/ docker-compose.yml
```

#### 2. Add the mounting point in the `docker-compose.yml` file

```yaml
---
version: "3.8"
name: "crynux_node"

services:
  h_node:
    image: ghcr.io/crynux-network/crynux-node:latest
    container_name: crynux_node
    restart: unless-stopped
    ports:
      - "127.0.0.1:7412:7412"
    volumes:
      - "./data:/app/data"
    deploy:
      resources:
        reservations:
          devices:
            - driver: nvidia
              capabilities: [gpu]
```

#### 3. Start the Docker container

```sh
docker compose up -d
```

## Mount the Config File

The configuration file could also be mounted to the local folder, so the config won't be overridden by the container recreating. It is also easier to edit the config file outside of the Docker container.

#### 1. Create an empty config folder inside the working directory

```sh
$ ls .
data/ docker-compose.yml

$ mkdir config

$ ls .
config/ data/ docker-compose.yml
```

#### 2. Add the mounting point in the `docker-compose.yml` file

```yaml
---
version: "3.8"
name: "crynux_node"

services:
  h_node:
    image: ghcr.io/crynux-network/crynux-node:latest
    container_name: crynux_node
    restart: unless-stopped
    ports:
      - "127.0.0.1:7412:7412"
    volumes:
      - "./data:/app/data"
      - "./config:/app/config"
    deploy:
      resources:
        reservations:
          devices:
            - driver: nvidia
              capabilities: [gpu]
```

#### 3. Start the Docker container

```sh
docker compose up -d
```

#### 4. A config file will be created automatically after the container creation

```sh
$ ls config/
config.yml
```

For an explanation of all the config items, please refer to the [Advanced Configuration](advanced-configuration.md).
