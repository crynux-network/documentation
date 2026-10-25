---
description: How to define and submit a text-to-text Raw Task
---

# Text-to-Text Task

A GPT Task is a JSON document (`GPTTaskArgs`) that describes one LLM generation job. Crynux nodes load the Hugging Face model, apply the chat template, run generation, and return a structured JSON result.

If you only need standard chat, tool calling, structured output, or the Responses API, use the [OpenAI-compatible LLM API](../how-to-run-llm-using-crynux-network/README.md). Use the Raw Task API when you need full `GPTTaskArgs` control, batch create, exact GPU selection, or a create-and-poll flow you manage yourself.

For most applications, submit Raw Tasks through [Crynux AS](https://crynux-as.xyz) as shown below. If you need more complex control—such as managing your own wallet and Relay `task_fee`, Bridge-side repeat tasks, or operating without Crynux AS—deploy your own [Crynux Bridge](../crynux-bridge.md) and call its Raw Task and Batch Task APIs.

## Sending Text-to-Text Tasks via [Crynux AS](https://crynux-as.xyz) (Raw Task API)

{% hint style="info" %}
Replace `<endpoint_token>` and `your-api-key` with your project endpoint token and API key from the [Crynux AS](https://crynux-as.xyz) dashboard.
{% endhint %}

| Operation | Method and path |
| --- | --- |
| Create one task | `POST /api/<endpoint_token>/v1/inference_tasks` |
| Create up to 100 tasks | `POST /api/<endpoint_token>/v1/inference_tasks/batch` |
| Get status | `GET /api/<endpoint_token>/v1/inference_tasks/<client_task_id>` |
| Batch status | `POST /api/<endpoint_token>/v1/inference_tasks/batch/status` |
| Download LLM JSON | `GET /api/<endpoint_token>/v1/inference_tasks/<client_task_id>/llm` |

Authenticate with `Authorization: Bearer <api-key-or-owner-jwt>`.

### Top-level request fields (outside `task_args`)

| Field | Required | Notes |
| --- | --- | --- |
| `task_type` | Yes | Must be `1` for LLM tasks |
| `task_args` | Yes | JSON **string** of `GPTTaskArgs` |
| `min_vram` | No | Minimum GPU VRAM in GB. When omitted, [Crynux AS](https://crynux-as.xyz) matches the loaded-models cache using model id plus `quantization_config` / `dtype` when present; otherwise it selects the row with the greatest `min_vram` for that model |
| `required_gpu` + `required_gpu_vram` | No | Exact GPU model name and VRAM. Provide both together. Do not combine with `min_vram` |
| `task_version` | No | Task version string, for example `"3.7.1"` |
| `queue_timeout` | No | Queue wait budget in seconds (Flexible Pricing). Positive integer. Not part of `task_args` |

Do not send `task_fee`. [Crynux AS](https://crynux-as.xyz) owns pricing from the project Cost Level.

#### Flexible Pricing with `queue_timeout`

Crynux schedules queued tasks by task fee. A higher Cost Level / task fee ranks higher; a lower Cost Level / task fee ranks lower.

Set a low project Cost Level and a long `queue_timeout` (for example `43200` for 12 hours) so large batches that do not need an immediate result can wait for quieter network periods at lower cost.

Synchronous APIs such as `/v1/chat/completions` hold one HTTP request until the job finishes (about 10 minutes by default). They cannot wait for long queues. For low Cost Level + long `queue_timeout`, use this asynchronous Raw Task API, or use the [Responses API](../how-to-run-llm-using-crynux-network/responses-api.md) with `background=true`.

### Status response fields

| Field | Meaning |
| --- | --- |
| `id` | Public client task ID (`task_jobs.id`) |
| `status` | `running`, `success`, or `failed` |
| `phase` | `queued`, `running`, `validating`, `uploading`, `finalizing`, `success`, or `failed` |
| `estimated_completion_at` | Present when `phase` is `running` and an estimate is known |
| `error_message` | Present only when `status` is `failed` and an error was stored |

### Create, poll, and download

{% tabs %}
{% tab title="Python" %}
```python
import json
import time
import requests

BASE = "https://api.crynux-as.xyz/api/<endpoint_token>/v1"
HEADERS = {
    "Authorization": "Bearer your-api-key",
    "Content-Type": "application/json",
}

task_args = {
    "version": "3.7.1",
    "model": "Qwen/Qwen2.5-7B-Instruct",
    "messages": [
        {"role": "user", "content": "What is the capital of France?"}
    ],
    "generation_config": {
        "max_new_tokens": 128,
        "temperature": 0.7,
        "top_p": 0.9,
    },
    "dtype": "auto",
}

create = requests.post(
    f"{BASE}/inference_tasks",
    headers=HEADERS,
    json={
        "task_type": 1,
        "task_args": json.dumps(task_args),
        "min_vram": 24,
        "task_version": "3.7.1",
        "queue_timeout": 3600,
    },
    timeout=60,
)
create.raise_for_status()
task_id = create.json()["data"]["id"]
print("created", task_id)

while True:
    status = requests.get(
        f"{BASE}/inference_tasks/{task_id}",
        headers=HEADERS,
        timeout=60,
    )
    status.raise_for_status()
    data = status.json()["data"]
    print(data["status"], data["phase"])
    if data["status"] in ("success", "failed"):
        break
    time.sleep(5)

if data["status"] != "success":
    raise RuntimeError(data.get("error_message") or "task failed")

result = requests.get(
    f"{BASE}/inference_tasks/{task_id}/llm",
    headers=HEADERS,
    timeout=120,
)
result.raise_for_status()
print(result.json())
```
{% endtab %}

{% tab title="JavaScript" %}
```javascript
const BASE = "https://api.crynux-as.xyz/api/<endpoint_token>/v1";
const HEADERS = {
  Authorization: "Bearer your-api-key",
  "Content-Type": "application/json",
};

const taskArgs = {
  version: "3.7.1",
  model: "Qwen/Qwen2.5-7B-Instruct",
  messages: [{ role: "user", content: "What is the capital of France?" }],
  generation_config: {
    max_new_tokens: 128,
    temperature: 0.7,
    top_p: 0.9,
  },
  dtype: "auto",
};

async function sleep(ms) {
  await new Promise((resolve) => setTimeout(resolve, ms));
}

const createRes = await fetch(`${BASE}/inference_tasks`, {
  method: "POST",
  headers: HEADERS,
  body: JSON.stringify({
    task_type: 1,
    task_args: JSON.stringify(taskArgs),
    min_vram: 24,
    task_version: "3.7.1",
    queue_timeout: 3600,
  }),
});
if (!createRes.ok) {
  throw new Error(await createRes.text());
}
const taskId = (await createRes.json()).data.id;
console.log("created", taskId);

let data;
for (;;) {
  const statusRes = await fetch(`${BASE}/inference_tasks/${taskId}`, {
    headers: { Authorization: HEADERS.Authorization },
  });
  if (!statusRes.ok) {
    throw new Error(await statusRes.text());
  }
  data = (await statusRes.json()).data;
  console.log(data.status, data.phase);
  if (data.status === "success" || data.status === "failed") {
    break;
  }
  await sleep(5000);
}

if (data.status !== "success") {
  throw new Error(data.error_message || "task failed");
}

const resultRes = await fetch(`${BASE}/inference_tasks/${taskId}/llm`, {
  headers: { Authorization: HEADERS.Authorization },
});
if (!resultRes.ok) {
  throw new Error(await resultRes.text());
}
console.log(await resultRes.json());
```
{% endtab %}
{% endtabs %}

### Batch create and batch status

{% tabs %}
{% tab title="Python" %}
```python
import json
import requests

BASE = "https://api.crynux-as.xyz/api/<endpoint_token>/v1"
HEADERS = {
    "Authorization": "Bearer your-api-key",
    "Content-Type": "application/json",
}

def make_task(prompt: str) -> dict:
    task_args = {
        "version": "3.7.1",
        "model": "Qwen/Qwen2.5-7B-Instruct",
        "messages": [{"role": "user", "content": prompt}],
        "generation_config": {"max_new_tokens": 64},
        "dtype": "auto",
    }
    return {
        "task_type": 1,
        "task_args": json.dumps(task_args),
        "min_vram": 24,
        "queue_timeout": 43200,
    }

batch = requests.post(
    f"{BASE}/inference_tasks/batch",
    headers=HEADERS,
    json={
        "tasks": [
            make_task("Name one European capital."),
            make_task("Name one Asian capital."),
        ]
    },
    timeout=60,
)
batch.raise_for_status()
items = batch.json()["data"]
task_ids = [
    item["client_task"]["id"]
    for item in items
    if item.get("client_task") is not None
]

status = requests.post(
    f"{BASE}/inference_tasks/batch/status",
    headers=HEADERS,
    json={"client_task_ids": task_ids},
    timeout=60,
)
status.raise_for_status()
print(status.json())
```
{% endtab %}

{% tab title="JavaScript" %}
```javascript
const BASE = "https://api.crynux-as.xyz/api/<endpoint_token>/v1";
const HEADERS = {
  Authorization: "Bearer your-api-key",
  "Content-Type": "application/json",
};

function makeTask(prompt) {
  const taskArgs = {
    version: "3.7.1",
    model: "Qwen/Qwen2.5-7B-Instruct",
    messages: [{ role: "user", content: prompt }],
    generation_config: { max_new_tokens: 64 },
    dtype: "auto",
  };
  return {
    task_type: 1,
    task_args: JSON.stringify(taskArgs),
    min_vram: 24,
    queue_timeout: 43200,
  };
}

const batchRes = await fetch(`${BASE}/inference_tasks/batch`, {
  method: "POST",
  headers: HEADERS,
  body: JSON.stringify({
    tasks: [
      makeTask("Name one European capital."),
      makeTask("Name one Asian capital."),
    ],
  }),
});
if (!batchRes.ok) {
  throw new Error(await batchRes.text());
}
const items = (await batchRes.json()).data;
const taskIds = items
  .filter((item) => item.client_task != null)
  .map((item) => item.client_task.id);

const statusRes = await fetch(`${BASE}/inference_tasks/batch/status`, {
  method: "POST",
  headers: HEADERS,
  body: JSON.stringify({ client_task_ids: taskIds }),
});
if (!statusRes.ok) {
  throw new Error(await statusRes.text());
}
console.log(await statusRes.json());
```
{% endtab %}
{% endtabs %}

## `task_args` (`GPTTaskArgs`) Definition

```json
{
  "version": "3.7.1",
  "model": "Qwen/Qwen2.5-7B-Instruct",
  "revision": null,
  "messages": [
    {
      "role": "user",
      "content": "I want to create a chat bot. Any suggestions?"
    }
  ],
  "generation_config": {
    "max_new_tokens": 128,
    "stop_strings": null,
    "do_sample": true,
    "num_beams": 1,
    "temperature": 1.0,
    "typical_p": 1.0,
    "top_k": 20,
    "top_p": 1.0,
    "min_p": 0.0,
    "repetition_penalty": 1.0,
    "num_return_sequences": 1
  },
  "tools": null,
  "tool_choice": null,
  "response_format": null,
  "template_args": {
    "enable_thinking": false
  },
  "seed": 42,
  "dtype": "auto",
  "quantization_config": null
}
```

More runnable samples are available in the [gpt-task GitHub repository](https://github.com/crynux-network/gpt-task/tree/main/examples).

### `version`

Schema version string, for example `"3.7.1"`.

### `model` and `revision`

`model` is a Hugging Face model ID suitable for text generation or chat. `revision` is an optional branch name or commit. Absolute URLs are rejected on [Crynux AS](https://crynux-as.xyz).

### `messages`

A list of message objects. Each message has `role` (`user`, `assistant`, `system`, or `tool`) and `content`.

`content` may be a plain string, or a list of multimodal parts:

* `{"type": "text", "text": "..."}`
* `{"type": "image", "base64": "<raw_base64>"}` — on Raw Task, use a **raw** base64 string, not a `data:image/...;base64,` data URL

Messages may also carry `tool_calls` / `tool_call_id` for tool-calling conversations.

During execution, messages are formatted with the model's chat template. Models without a chat template concatenate message contents.

### `generation_config`

Controls decoding. Field meanings match the [Hugging Face GenerationConfig](https://huggingface.co/docs/transformers/main_classes/text_generation#transformers.GenerationConfig).

| Field | Notes |
| --- | --- |
| `max_new_tokens` | Maximum new tokens to generate |
| `stop_strings` | Optional stop strings |
| `do_sample` | Sampling vs greedy decoding |
| `num_beams` | Beam search width; `1` disables beam search |
| `temperature` | Sampling temperature |
| `typical_p` | Local typical sampling |
| `top_k` | Top-k filtering |
| `top_p` | Nucleus sampling |
| `min_p` | Min-p sampling, float in `0.0`–`1.0` |
| `repetition_penalty` | Penalty for repeated tokens; `1.0` means no penalty |
| `num_return_sequences` | Number of independent sequences to return |

### `tools`, `tool_choice`, `response_format`

Optional structured-output and function-calling definitions, aligned with OpenAI-style tool schemas and response formats. Prefer the OpenAI-compatible API when you only need these features without managing Raw Task lifecycle.

### `template_args`

Optional object passed to the Hugging Face chat template, for example `{"enable_thinking": true}` or `{"enable_thinking": false}`.

### `seed`

Integer seed for reproducible sampling. If omitted on [Crynux AS](https://crynux-as.xyz) create, AS fills a random integer from `0` through `2147483647`.

### `dtype`

`"float16"`, `"bfloat16"`, `"float32"`, or `"auto"`.

### `quantization_config`

Optional object or `null` for task-time quantization.

```json
{
  "quant_method": "bitsandbytes",
  "quant_kwargs": {
    "load_in_4bit": true,
    "bnb_4bit_quant_type": "nf4",
    "bnb_4bit_compute_dtype": "bfloat16"
  }
}
```

See [Model Quantization](../quantization.md) for BitsAndBytes, FP8, AWQ, GPTQ, and platform rules.

## GPT Task Response

`GET .../llm` returns a `GPTTaskResponse` JSON object:

```json
{
  "model": "Qwen/Qwen2.5-7B-Instruct",
  "choices": [
    {
      "finish_reason": "stop",
      "message": {
        "role": "assistant",
        "content": "The capital of France is Paris."
      },
      "index": 0
    }
  ],
  "usage": {
    "prompt_tokens": 18,
    "completion_tokens": 8,
    "total_tokens": 26
  }
}
```

### `model`

The model used for generation.

### `choices`

One choice per `num_return_sequences`. Each choice has:

* `finish_reason` — `"stop"` (natural end / EOS) or `"length"` (hit `max_new_tokens`)
* `message` — assistant message (`role` is always `"assistant"`; may include `tool_calls` when tools were used)
* `index` — zero-based index in `choices`

### `usage`

Token counts:

* `prompt_tokens` — input tokens
* `completion_tokens` — sum of completion tokens across choices
* `total_tokens` — `prompt_tokens + completion_tokens`
