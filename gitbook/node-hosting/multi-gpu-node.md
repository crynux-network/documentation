---
description: How Crynux Node uses multiple GPUs on a single machine
---

# Multi-GPU Node

## Overview

Crynux Node can automatically use multiple GPUs installed on the same machine. You do not need to start one node per GPU.

The current limitation is that the node only uses GPUs of the same model. When the machine has mixed GPU models, the node groups the cards by model name, selects the group with the largest number of cards, and ignores the rest. For example, if the machine has three RTX 4090 cards and one RTX 3090 card, the node uses the three RTX 4090 cards and leaves the RTX 3090 unused.

The selected GPUs are reported to the network as one aggregated GPU. With more than one card, the reported name looks like `2x NVIDIA GeForce RTX 4090`, and the reported VRAM is the sum of the selected cards.

## Tensor Parallel and Device Map

For LLM and vision-language inference, a multi-GPU node runs in one of two modes: **Tensor Parallel (TP)** or **Device Map**.

### Tensor Parallel (TP)

Tensor Parallel is the default mode when the node runs on Docker or Linux and at least two identical GPUs are selected.

In TP mode, the model weights are sharded across the selected GPUs. Each GPU holds part of the model and participates in the forward pass. This lets a single node use the combined VRAM of multiple cards more effectively, which is especially useful for larger models that are difficult or impossible to run on one card.

Not every model supports Tensor Parallel. Support depends on the model's loaded configuration and Tensor Parallel plan. The node does not maintain a fixed allowlist of model IDs; compatibility is decided at runtime for each task.

{% hint style="info" %}
For most models, Tensor Parallel also requires the GPU count to be a power of two, such as 2, 4, or 8. With 3, 5 or 6 GPUs, many models cannot run in TP mode for that GPU count and fall back to Device Map instead. If you want as many LLM and VLM tasks as possible to run in TP mode, prefer a machine whose selected identical-GPU group has 2, 4, or 8 cards.
{% endhint %}

### Device Map

In Device Map mode, the model is loaded with layer sharding across the selected GPUs. Whole layers are placed on different cards. There is no cross-GPU floating-point reduction in this path, so the computed results are bitwise identical to those of a single-GPU node with the same GPU model.

Device Map is used when Tensor Parallel is not the active executor mode. Common cases include:

* The node is running on Windows (the Windows binary uses Device Map for multi-GPU LLM inference).
* The selected GPU group has only one card.
* A model does not support Tensor Parallel for the current GPU count. In that case, the task automatically falls back to Device Map and still uses the selected GPUs.

Image generation and other non-LLM tasks always use the Device Map path. Multi-GPU still applies: the selected cards remain available for layer placement.

{% hint style="info" %}
TP results and Device Map results are not numerically identical, because Tensor Parallel combines partial results across GPUs and changes the floating-point summation order. The network keeps the two modes in separate matching pools through the reported GPU name. When TP is active, the aggregated name includes a `TP` marker, for example `2x NVIDIA GeForce RTX 4090 TP`.
{% endhint %}

### Supported vs unsupported models

| Model situation | Behavior on a multi-GPU node |
| --------------- | ---------------------------- |
| LLM / VLM that supports Tensor Parallel | Runs in TP mode when TP is the active executor (Docker / Linux, 2+ identical GPUs). |
| LLM / VLM that does not support Tensor Parallel | Automatically falls back to Device Map and uses the selected GPUs for layer sharding. |
| Image generation and other non-LLM tasks | Always use Device Map on the selected GPUs. |

## Start a Multi-GPU Node

No extra configuration is required. After the node starts, it enumerates the visible NVIDIA GPUs, selects the largest identical-model group, and uses that group for both reporting and task execution.

If you start the node with Docker, make sure all GPUs on the host are visible to the container. The official Crynux Docker Compose project already requests all GPUs (`count: all`), so following the Docker tutorial is enough:

{% content-ref url="start-a-node/start-a-node-docker.md" %}
[start-a-node-docker.md](start-a-node/start-a-node-docker.md)
{% endcontent-ref %}

After the node joins the network, check the GPU name shown in the WebUI. A multi-GPU node reports an aggregated name such as `2x NVIDIA GeForce RTX 4090` or `2x NVIDIA GeForce RTX 4090 TP`, instead of a single-card name.
