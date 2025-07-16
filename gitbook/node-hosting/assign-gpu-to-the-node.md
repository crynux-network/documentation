---
description: How to run multiple nodes on a single device with multiple GPUs
---

# Assign GPU to the Node

If you have multiple GPUs in a single computer, you can optimize performance by starting multiple nodes on the computer and assigning each GPU to a different node.

To enable GPU assignment, use the Docker version of Crynux Node. For a guide on the basics of starting a Crynux Node as a Docker container, please refer to the tutorial below:

{% content-ref url="start-a-node/start-a-node-docker.md" %}
[start-a-node-docker.md](start-a-node/start-a-node-docker.md)
{% endcontent-ref %}

## Find the ID of the specific GPU

If you want to assign a specific GPU to a node, you must find the ID of the GPU first. This can be done using the `nvidia-smi` toolkit. Start a terminal and run the following command:

```
$ nvidia-smi
```

And you will get the output similar to the following:

<figure><img src="../.gitbook/assets/image (2).png" alt=""><figcaption></figcaption></figure>

Find the ID as highlighted in the image above. In this case, we have a single GPU installed in the computer, the ID of the GPU is `0`.&#x20;

## GPU assignment using Docker Compose

In the `docker-compose.yml` file, find the following section:

```
deploy:
      resources:
        reservations:
          devices:
            - driver: nvidia
              capabilities: [gpu]
```

And add another line below:

<pre><code><strong>deploy:
</strong>      resources:
        reservations:
          devices:
            - driver: nvidia
              capabilities: [gpu]
              device_ids: ["0"]
</code></pre>

## GPU assignment using command line

The GPU id could also be given to the container in the starting command. If you are starting the container using the following command before:

```
docker run -p 7412:7412 --name crynux_node --gpus all ghcr.io/crynux-network/crynux-node:latest
```

You could change it to:

```
docker run -p 7412:7412 --name crynux_node --gpus '"device=0"' ghcr.io/crynux-network/crynux-node:latest
```

The change is on the `--gpus` argument, from `all`, which provides all the GPUs to the container, to `'"device=0"'`, which provides only the GPU with id `0`.

## Start multiple containers for each of the GPUs on the same computer

For each of the GPUs, follow the tutorial to clone the docker compose project:

{% content-ref url="start-a-node/start-a-node-docker.md" %}
[start-a-node-docker.md](start-a-node/start-a-node-docker.md)
{% endcontent-ref %}

For example, if you have 3 GPUs on the same computer, just clone the docker compose project 3 times, after renaming the folders, you have 3 working folders locally:

```
$ ls
crynux_node_docker_compose_1  crynux_node_docker_compose_2  crynux_node_docker_compose_3
```

In each of the working folders, find the `docker-compose.yml` file, and edit the content:

#### 1. Change the name, service name and the container name, so that every container is using a different one:

&#x20;from:

```
name: "crynux_node"
services:
  crynux_node:
    container_name: crynux_node
```

to:

```
name: "crynux_node_2"
services:
  crynux_node_2:
    container_name: crynux_node_2
```

#### 2. Add a line to specify the GPU id as mentioned above:

<pre><code><strong>deploy:
</strong>      resources:
        reservations:
          devices:
            - driver: nvidia
              capabilities: [gpu]
              device_ids: ["0"]
</code></pre>

#### 3. Change the exposing port. So that every container is using a different port:

from:

```
ports:
  - "127.0.0.1:7412:7412"
```

to:

```
ports:
  - "127.0.0.1:7413:7412"
```

for the second container.  And use `7414` for the third one.

The complete `docker-compose.yml` files for each of the 3 containers is shown below:

#### Node 1

`crynux_node_docker_compose_1/docker-compose.yml`

```
---
version: "3.8"
name: "crynux_node"

services:
  crynux_node:
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
              device_ids: ["0"]
```

#### Node 2

`crynux_node_docker_compose_2/docker-compose.yml`

```
---
version: "3.8"
name: "crynux_node_2"

services:
  crynux_node_2:
    image: ghcr.io/crynux-network/crynux-node:latest
    container_name: crynux_node_2
    restart: unless-stopped
    ports:
      - "127.0.0.1:7413:7412"
    volumes:
      - "./data:/app/data"
      - "./config:/app/config"
    deploy:
      resources:
        reservations:
          devices:
            - driver: nvidia
              capabilities: [gpu]
              device_ids: ["1"]
```

#### Node 3

`crynux_node_docker_compose_3/docker-compose.yml`

```
---
version: "3.8"
name: "crynux_node_3"

services:
  crynux_node_3:
    image: ghcr.io/crynux-network/crynux-node:latest
    container_name: crynux_node_3
    restart: unless-stopped
    ports:
      - "127.0.0.1:7414:7412"
    volumes:
      - "./data:/app/data"
      - "./config:/app/config"
    deploy:
      resources:
        reservations:
          devices:
            - driver: nvidia
              capabilities: [gpu]
              device_ids: ["2"]
```

Finally, in each of the folders, run the `docker compose up` command to start the container:

```
$ cd crynux_node_docker_compose_1
$ docker compose up -d
$ cd ../crynux_node_docker_compose_2
$ docker compose up -d
$ cd ../crynux_node_docker_compose_3
$ docker compose up -d
```
