# Execute Tasks

Crynux Network executes work as typed Raw Tasks. Each task carries a `task_type` and a `task_args` JSON string that matches the schema for that type. Applications usually submit tasks through [Crynux AS](https://crynux-as.xyz), which prices the job, reserves Credits, and forwards the task to the network.

For more direct control over the application wallet, Relay fees, repeat-task settings, or Bridge-owned Raw / Batch APIs, you can deploy your own [Crynux Bridge](../crynux-bridge.md). Self-hosting Bridge is a more advanced option; [Crynux AS](https://crynux-as.xyz) is usually easier for application development.

## Crynux AS Raw Task endpoints

Under `/api/<endpoint_token>/v1`:

| Operation | Method and path |
| --- | --- |
| Create one task | `POST /inference_tasks` |
| Create up to 100 tasks | `POST /inference_tasks/batch` |
| Get status | `GET /inference_tasks/<client_task_id>` |
| Batch status | `POST /inference_tasks/batch/status` |
| Download LLM JSON | `GET /inference_tasks/<client_task_id>/llm` |
| Download image PNG | `GET /inference_tasks/<client_task_id>/images/<index>` |
| List loaded image models | `GET /models/image` |

Common top-level create fields (outside `task_args`):

* `task_type` — `0` for Image, `1` for LLM
* `task_args` — JSON string of the task schema
* `min_vram` — optional minimum GPU VRAM in GB
* `required_gpu` / `required_gpu_vram` — optional exact GPU selection (use together; do not combine with `min_vram`)
* `task_version` — optional task version string
* `queue_timeout` — optional queue wait budget in seconds (Flexible Pricing)

For OpenAI-compatible chat and image endpoints, see [How to Run LLM using Crynux Network](../how-to-run-llm-using-crynux-network/README.md) and [OpenAI-Compatible Image API](../openai-compatible-image-api.md). For quantization options shared by both task types, see [Model Quantization](../quantization.md).

## Task guides

{% content-ref url="text-to-image-task.md" %}
[Text-to-Image Task](text-to-image-task.md)
{% endcontent-ref %}

{% content-ref url="text-to-text-task.md" %}
[Text-to-Text Task](text-to-text-task.md)
{% endcontent-ref %}

{% content-ref url="text-to-music-task.md" %}
[Text-to-Music Task](text-to-music-task.md)
{% endcontent-ref %}

{% content-ref url="text-to-video-task.md" %}
[Text-to-Video Task](text-to-video-task.md)
{% endcontent-ref %}

{% content-ref url="fine-tuning-task.md" %}
[Fine-Tuning Task](fine-tuning-task.md)
{% endcontent-ref %}
