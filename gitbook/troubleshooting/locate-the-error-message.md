---
description: Find out what exactly goes wrong
---

# Locate the Error Message

To identify the cause of the problem, refer to the log file for the detailed error message and full stack trace. If seeking community help, providing these details initially can save a lot of time.

## Locate the log file

{% tabs %}
{% tab title="Windows" %}
Go to the directory where you click `Crynux Node.exe`, there is a sub directory with name `data`, and inside `data` folder there is a folder with name `logs`, all the log files can be found inside.
{% endtab %}

{% tab title="Mac" %}
Open a Finder window, go to the `Applications` folder, right click on the `Crynux Node.app`  and select `Show Package Content`, then go to the folder `Contents/Resources/data/logs`, and the log files are located inside.
{% endtab %}

{% tab title="Docker" %}
### Find the logs in the container output

Find the container name of the Crynux Node:

```bash
$ docker ps
```

The output should be similar to:

```
CONTAINER ID   IMAGE                                COMMAND              CREATED          STATUS          PORTS                      NAMES
77e559a0d707   ghcr.io/crynux-network/crynux-node:2.0.4  "bash start.sh run"  33 minutes ago   Up 32 minutes   127.0.0.1:7412->7412/tcp   ecstatic_chatterjee
```

In this case, the container name is `ecstatic_chatterjee`.

In a terminal, type in the following command:

```bash
$ docker logs {container_name}
```

If you want to save the logs to a file, use the following command:

```bash
$ docker logs {container_name} >> crynux.log
```

### Find the log file inside the container

The log file can also be found under `/app/logs` inside the container.
{% endtab %}

{% tab title="Linux" %}
If you downloaded the binary release version of Linux server, the log files can be found in the `logs` folder of the project root.
{% endtab %}

{% tab title="Source Code" %}
The log file is located at `logs/crynux-server.log`, relative to the project root folder.
{% endtab %}
{% endtabs %}

There are several log files inside the `log` folder. The content of each file is described below:

* `crynux-server.log`: Node manager related logs.&#x20;
* `crynux-worker.log`: Task executor related logs.
* `crynux_worker_inference.log`: Task execution logs.
* `crynux_worker_prefetch.log`: Model downloading logs.
* `main.log`: GUI related logs. Not available on Docker versions.

Most of the error messages could be identified in the first two log files: `crynux-server.log` and `crynux-worker.log`.

## Locate the error message

Open the log file in a text editor. Navigate to the time where you encountered the error, and find the lines with `[ERROR]`, which is usually the error message. And there will be a stack trace around the error message. **If you are asking for help, remember to provide the full stack trace from the first line to the last**.

Here is an example of a log file with error message and the stack trace:

```
[2024-05-15 18:08:27] [INFO    ] crynux_worker.prefetch: Start worker process: worker, data/huggingface, data/external
[2024-05-15 18:08:27] [INFO    ] crynux_worker.prefetch: Start prefetching models
[2024-05-15 18:08:35] [ERROR   ] crynux_server.node_manager.node_manager: Node manager init error: init task cancelled
Traceback (most recent call last):
  File "D:\Crynux Node\_internal\crynux_server\node_manager\node_manager.py", line 454, in _run
    async with create_task_group() as init_tg:
  File "anyio\_backends\_asyncio.py", line 597, in __aexit__
  File "anyio\_backends\_asyncio.py", line 668, in task_done
  File "D:\Crynux Node\_internal\crynux_server\node_manager\node_manager.py", line 262, in _init
    async for attemp in AsyncRetrying(
  File "tenacity\_asyncio.py", line 71, in __anext__
  File "tenacity\__init__.py", line 314, in iter
  File "concurrent\futures\_base.py", line 449, in result
  File "concurrent\futures\_base.py", line 401, in __get_result
  File "D:\Crynux Node\_internal\crynux_server\node_manager\node_manager.py", line 269, in _init
    await to_thread.run_sync(
  File "anyio\to_thread.py", line 33, in run_sync
  File "anyio\_backends\_asyncio.py", line 877, in run_sync_in_worker_thread
asyncio.exceptions.CancelledError
[2024-05-15 18:08:35] [INFO    ] crynux_server.node_manager.state_manager: Node status is NodeStatus.Stopped, cannot leave the network automatically
```

In this case, the error message is:

```
crynux_server.node_manager.node_manager: Node manager init error: init task cancelled
```

And the full stack trace is:

```
Traceback (most recent call last):
  File "D:\Crynux Node\_internal\crynux_server\node_manager\node_manager.py", line 454, in _run
    async with create_task_group() as init_tg:
  File "anyio\_backends\_asyncio.py", line 597, in __aexit__
  File "anyio\_backends\_asyncio.py", line 668, in task_done
  File "D:\Crynux Node\_internal\crynux_server\node_manager\node_manager.py", line 262, in _init
    async for attemp in AsyncRetrying(
  File "tenacity\_asyncio.py", line 71, in __anext__
  File "tenacity\__init__.py", line 314, in iter
  File "concurrent\futures\_base.py", line 449, in result
  File "concurrent\futures\_base.py", line 401, in __get_result
  File "D:\Crynux Node\_internal\crynux_server\node_manager\node_manager.py", line 269, in _init
    await to_thread.run_sync(
  File "anyio\to_thread.py", line 33, in run_sync
  File "anyio\_backends\_asyncio.py", line 877, in run_sync_in_worker_thread
asyncio.exceptions.CancelledError
```
