# Supported Models

Crynux theoretically supports any model that can be executed by the HuggingFace `transformers` library. To use a specific model, you simply need to specify its HuggingFace model ID in the task configuration. The Crynux Nodes will then automatically fetch the model from HuggingFace and execute the task.

The primary practical limitation on the number and size of models Crynux can support is the maximum available VRAM on the nodes within the Crynux Network.

{% hint style="success" %}
If a model isn't on this list, feel free to try it out as long as you're confident it's compatible with the `transformers` library and there's sufficient VRAM available on the network.
{% endhint %}

## Model Loading and Task Latency

Changing the `model` field in the OpenAI-compatible API is enough to run a different model. The response time is not the same for every model. It mainly depends on whether that model is already available on nodes in the network.

You can think of three common situations:

* **The model is already loaded in GPU memory on some nodes.** Requests are usually the fastest. The node can start generating without downloading or loading the model first.
* **The model files are already on some nodes, but not loaded in GPU memory yet.** The request still runs without a network-wide download, but the node needs extra time to load the model into GPU memory before generation starts.
* **No node has the model yet.** The first request waits while the network downloads the model onto some nodes. This can take much longer than a normal chat completion. After the download finishes, later requests for the same model become much faster.

For a model that is new to the network, the practical approach is:

1. Check whether the model is already active (see the API below).
2. If it is not active yet, send one request with that model and wait for it to finish. Treat this as a one-time warm-up.
3. Use the same model for normal traffic afterward.

As more requests use the same model, the network automatically keeps it on more nodes, which further reduces waiting time. More detail on how models are spread across nodes is here:

{% content-ref url="../../system-design/model-distribution.md" %}
[model-distribution.md](../../system-design/model-distribution.md)
{% endcontent-ref %}

### Checking Active Models on the Network

You can query which models are currently active on the network, and how many nodes already hold each one:

```
GET https://relay.crynux.io/v2/loaded-models
```

No authentication or query parameters are required. A model appears here after at least one request that uses it has completed successfully.

Example response:

```json
{
  "message": "success",
  "data": [
    {
      "model_id": "qwen/qwen3.6-27b",
      "model_type": "llm",
      "min_vram": 70,
      "in_memory_node_count": 1,
      "on_disk_node_count": 3
    }
  ]
}
```

| Field | Meaning |
| --- | --- |
| `model_id` | Hugging Face model ID (lowercase) |
| `model_type` | `llm` or `sd` |
| `min_vram` | Smallest GPU VRAM (GB) seen on a node that successfully ran this model |
| `in_memory_node_count` | How many nodes currently have the model loaded in GPU memory |
| `on_disk_node_count` | How many nodes currently have the model files downloaded |

Higher `in_memory_node_count` and `on_disk_node_count` usually mean shorter wait times for that model.

{% hint style="info" %}
If the model is missing from this list, or `on_disk_node_count` is `0`, send one warm-up request first and wait for it to complete before putting the model into production traffic.
{% endhint %}

## Popular Models

The tables below are only a small set of examples. Crynux supports most open-source models on HuggingFace: if the model runs with the `transformers` library and the network has enough VRAM, you can use it by setting its HuggingFace model ID in the API request.

### Qwen Models

| Model ID | Hugging Face Link |
| --- | --- |
| Qwen/Qwen3-8B | [Qwen/Qwen3-8B](https://huggingface.co/Qwen/Qwen3-8B) |
| Qwen/Qwen3.5-9B | [Qwen/Qwen3.5-9B](https://huggingface.co/Qwen/Qwen3.5-9B) |
| Qwen/Qwen3.6-27B | [Qwen/Qwen3.6-27B](https://huggingface.co/Qwen/Qwen3.6-27B) |
| Qwen/Qwen3.8-27B | [Qwen/Qwen3.8-27B](https://huggingface.co/Qwen/Qwen3.8-27B) |
| Qwen/Qwen3-Next-80B-A3B-Instruct | [Qwen/Qwen3-Next-80B-A3B-Instruct](https://huggingface.co/Qwen/Qwen3-Next-80B-A3B-Instruct) |
| Qwen/Qwen3.5-122B-A10B | [Qwen/Qwen3.5-122B-A10B](https://huggingface.co/Qwen/Qwen3.5-122B-A10B) |

### DeepSeek Models

| Model ID | Hugging Face Link |
| --- | --- |
| deepseek-ai/DeepSeek-R1-Distill-Qwen-1.5B | [deepseek-ai/DeepSeek-R1-Distill-Qwen-1.5B](https://huggingface.co/deepseek-ai/DeepSeek-R1-Distill-Qwen-1.5B) |
| deepseek-ai/DeepSeek-R1-Distill-Qwen-7B | [deepseek-ai/DeepSeek-R1-Distill-Qwen-7B](https://huggingface.co/deepseek-ai/DeepSeek-R1-Distill-Qwen-7B) |
| deepseek-ai/DeepSeek-R1-Distill-Llama-8B | [deepseek-ai/DeepSeek-R1-Distill-Llama-8B](https://huggingface.co/deepseek-ai/DeepSeek-R1-Distill-Llama-8B) |

### NousResearch Models

| Model ID | Hugging Face Link |
| --- | --- |
| NousResearch/Hermes-3-Llama-3.1-8B | [NousResearch/Hermes-3-Llama-3.1-8B](https://huggingface.co/NousResearch/Hermes-3-Llama-3.1-8B) |
| NousResearch/Hermes-3-Llama-3.2-3B | [NousResearch/Hermes-3-Llama-3.2-3B](https://huggingface.co/NousResearch/Hermes-3-Llama-3.2-3B) |
