---
description: How to define and submit a text-to-image or image-edit Raw Task
---

# Text-to-Image Task

An Image Task is a JSON document (`ImageTaskArgs`) that describes one Diffusers image generation or edit job. Crynux nodes resolve the pipeline from the base model's `model_index.json` and run text-to-image, image-to-image, or native image editing from the same schema.

If you only need a simple OpenAI-style generate or edit call, use the [OpenAI-Compatible Image API](../openai-compatible-image-api.md). Use the Raw Task API when you need full `ImageTaskArgs` control, batch create, long `queue_timeout` Flexible Pricing, or fields such as `steps`, `negative_prompt`, `lora`, `dtype`, and `required_gpu`.

## Sending Image Tasks via [Crynux AS](https://crynux-as.xyz) (Raw Task API)

{% hint style="info" %}
Replace `<endpoint_token>` and `your-api-key` with your project endpoint token and API key from the [Crynux AS](https://crynux-as.xyz) dashboard.
{% endhint %}

| Operation | Method and path |
| --- | --- |
| Create one task | `POST /api/<endpoint_token>/v1/inference_tasks` |
| Create up to 100 tasks | `POST /api/<endpoint_token>/v1/inference_tasks/batch` |
| Get status | `GET /api/<endpoint_token>/v1/inference_tasks/<client_task_id>` |
| Batch status | `POST /api/<endpoint_token>/v1/inference_tasks/batch/status` |
| Download PNG | `GET /api/<endpoint_token>/v1/inference_tasks/<client_task_id>/images/<index>` |

Authenticate with `Authorization: Bearer <api-key-or-owner-jwt>`.

### Top-level request fields (outside `task_args`)

| Field | Required | Notes |
| --- | --- | --- |
| `task_type` | Yes | Must be `0` for Image tasks |
| `task_args` | Yes | JSON **string** of `ImageTaskArgs` |
| `min_vram` | No | Minimum GPU VRAM in GB. When omitted and you do not set an exact GPU, [Crynux AS](https://crynux-as.xyz) resolves a default from the Image loaded-models cache. With a concrete `dtype`, an exact cache hit can supply `min_vram`; otherwise AS may use the configured default. With `dtype` omitted or `"auto"`, AS selects a matching loaded-models row and may fill concrete `dtype` / omitted `quantization_config` / `components` from that row |
| `required_gpu` + `required_gpu_vram` | No | Exact GPU model name and VRAM. Provide both together. Do not combine with `min_vram` |
| `task_version` | No | Task version string, for example `"3.7.1"` |
| `queue_timeout` | No | Queue wait budget in seconds (Flexible Pricing). Positive integer. Not part of `task_args` |

Do not send `task_fee`. [Crynux AS](https://crynux-as.xyz) owns pricing from the project Cost Level.

#### Flexible Pricing with `queue_timeout`

Crynux schedules queued tasks by task fee. A higher Cost Level / task fee ranks higher; a lower Cost Level / task fee ranks lower.

Set a low project Cost Level and a long `queue_timeout` (for example `43200` for 12 hours) so large batches that do not need an immediate result can wait for quieter network periods at lower cost.

Synchronous OpenAI Images APIs hold one HTTP request until the job finishes (about 10 minutes by default). They cannot wait for long queues. For low Cost Level + long `queue_timeout`, use this asynchronous Raw Task API (single create or `POST /inference_tasks/batch`) and poll until `status` is `success` or `failed`.

### Status response fields

| Field | Meaning |
| --- | --- |
| `id` | Public client task ID (`task_jobs.id`) |
| `status` | `running`, `success`, or `failed` |
| `phase` | `queued`, `running`, `validating`, `uploading`, `finalizing`, `success`, or `failed` |
| `estimated_completion_at` | Present when `phase` is `running` and an estimate is known |
| `error_message` | Present only when `status` is `failed` and an error was stored |

### Create, poll, and download (Python)

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
    "base_model": {"name": "Qwen/Qwen-Image-2.1", "revision": None},
    "dtype": "bfloat16",
    "prompt": "A product photo of a white ceramic cup on a wooden table",
    "task_config": {
        "image_width": 1024,
        "image_height": 1024,
        "steps": 40,
        "num_images_per_prompt": 1,
    },
}

create = requests.post(
    f"{BASE}/inference_tasks",
    headers=HEADERS,
    json={
        "task_type": 0,
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

image = requests.get(
    f"{BASE}/inference_tasks/{task_id}/images/0",
    headers={"Authorization": HEADERS["Authorization"]},
    timeout=120,
)
image.raise_for_status()
with open("output.png", "wb") as f:
    f.write(image.content)
print("saved output.png")
```

### Create, poll, and download (JavaScript)

```javascript
import fs from "fs";

const BASE = "https://api.crynux-as.xyz/api/<endpoint_token>/v1";
const HEADERS = {
  Authorization: "Bearer your-api-key",
  "Content-Type": "application/json",
};

const taskArgs = {
  version: "3.7.1",
  base_model: { name: "Qwen/Qwen-Image-2.1", revision: null },
  dtype: "bfloat16",
  prompt: "A product photo of a white ceramic cup on a wooden table",
  task_config: {
    image_width: 1024,
    image_height: 1024,
    steps: 40,
    num_images_per_prompt: 1,
  },
};

async function sleep(ms) {
  await new Promise((resolve) => setTimeout(resolve, ms));
}

const createRes = await fetch(`${BASE}/inference_tasks`, {
  method: "POST",
  headers: HEADERS,
  body: JSON.stringify({
    task_type: 0,
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

const imageRes = await fetch(`${BASE}/inference_tasks/${taskId}/images/0`, {
  headers: { Authorization: HEADERS.Authorization },
});
if (!imageRes.ok) {
  throw new Error(await imageRes.text());
}
fs.writeFileSync("output.png", Buffer.from(await imageRes.arrayBuffer()));
console.log("saved output.png");
```

## `task_args` Schema (`ImageTaskArgs`)

| Field | Notes |
| --- | --- |
| `version` | Schema version string, for example `"3.7.1"` |
| `base_model` | `{"name": "<hf_repo_id>", "revision": null}`. `name` must be a Hugging Face Diffusers repo with `model_index.json`. Absolute URLs are rejected |
| `dtype` | `"float16"`, `"bfloat16"`, `"float32"`, or `"auto"` (default `"auto"`). Concrete values are kept as-is. `"auto"` lets [Crynux AS](https://crynux-as.xyz) / the node resolve a concrete dtype from loaded-models matching when applicable |
| `prompt` | Required positive prompt |
| `negative_prompt` | Optional. Effective when the pipeline supports CFG / true CFG and guidance is greater than 1 |
| `images` | Optional list of data URLs (`"data:image/png;base64,..."`). Empty or omitted → text-to-image. Non-empty → image edit / img2img. Total string byte length of all entries must not exceed 1 MB (`1,048,576`) |
| `strength` | Optional float in `0`–`1`. Used only when the resolved img2img pipeline accepts `strength` |
| `task_config` | See below |
| `lora` | Optional `{"model": "<hf_repo_id>", "weight_file_name": "", "weight": 100}` |
| `components` | Optional map of component name → replacement source (`format` `"gguf"` or `"diffusers"`). See [Model Quantization](../quantization.md) |
| `quantization_config` | Optional object or `null`. See [Model Quantization](../quantization.md) |

### `task_config`

| Field | Notes |
| --- | --- |
| `image_width` | Default `1024` |
| `image_height` | Default `1024` |
| `steps` | Integer `1`–`100`, default `30` |
| `seed` | Integer `0`–`2147483647`. If omitted on [Crynux AS](https://crynux-as.xyz) create, AS fills a random value in that range |
| `num_images_per_prompt` | Integer `1`–`10`, default `1` |
| `guidance_scale` | Optional float `>= 0`. Mapped at runtime to the pipeline's `guidance_scale` or `true_cfg_scale` |

## Comprehensive Examples

### 1. Basic text-to-image

```json
{
  "version": "3.7.1",
  "base_model": {"name": "Qwen/Qwen-Image-2.1", "revision": null},
  "dtype": "bfloat16",
  "prompt": "A product photo of a white ceramic cup on a wooden table",
  "task_config": {
    "image_width": 1024,
    "image_height": 1024,
    "steps": 40,
    "seed": 42,
    "num_images_per_prompt": 1
  }
}
```

```json
{
  "version": "3.7.1",
  "base_model": {"name": "black-forest-labs/FLUX.2-klein-4B", "revision": null},
  "dtype": "bfloat16",
  "prompt": "A product photo of a white ceramic cup on a wooden table",
  "task_config": {
    "image_width": 1024,
    "image_height": 1024,
    "steps": 4,
    "seed": 42,
    "num_images_per_prompt": 1,
    "guidance_scale": 1
  }
}
```

### 2. Text-to-image with `negative_prompt`

```json
{
  "version": "3.7.1",
  "base_model": {"name": "stabilityai/stable-diffusion-3.5-large", "revision": null},
  "dtype": "bfloat16",
  "prompt": "A product photo of a white ceramic cup on a wooden table, studio lighting",
  "negative_prompt": "blurry, low quality, watermark, text",
  "task_config": {
    "image_width": 1024,
    "image_height": 1024,
    "steps": 28,
    "seed": 42,
    "num_images_per_prompt": 1,
    "guidance_scale": 4.5
  }
}
```

### 3. Image editing (reference images, no `strength`)

Use models that natively accept edit / conditioning images (for example `Qwen/Qwen-Image-2.1`, `Qwen/Qwen-Image-Edit`, `black-forest-labs/FLUX.2-klein-4B`).

```json
{
  "version": "3.7.1",
  "base_model": {"name": "Qwen/Qwen-Image-2.1", "revision": null},
  "dtype": "bfloat16",
  "prompt": "Change the background to a snowy mountain landscape",
  "images": ["data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAA..."],
  "task_config": {
    "image_width": 1024,
    "image_height": 1024,
    "steps": 40,
    "seed": 42,
    "num_images_per_prompt": 1
  }
}
```

### 4. Classic image-to-image (`images` + `strength`)

```json
{
  "version": "3.7.1",
  "base_model": {"name": "Tongyi-MAI/Z-Image-Turbo", "revision": null},
  "dtype": "bfloat16",
  "prompt": "A watercolor painting of the same scene",
  "images": ["data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAA..."],
  "strength": 0.7,
  "task_config": {
    "image_width": 1024,
    "image_height": 1024,
    "steps": 9,
    "seed": 42,
    "num_images_per_prompt": 1
  }
}
```

### 5. LoRA adapter

```json
{
  "version": "3.7.1",
  "base_model": {"name": "Qwen/Qwen-Image", "revision": null},
  "dtype": "bfloat16",
  "prompt": "A portrait in the style of the loaded LoRA",
  "lora": {
    "model": "flymy-ai/qwen-image-lora",
    "weight_file_name": "pytorch_lora_weights.safetensors",
    "weight": 100
  },
  "task_config": {
    "image_width": 1024,
    "image_height": 1024,
    "steps": 40,
    "seed": 42,
    "num_images_per_prompt": 1
  }
}
```

### 6. Component replacement (`components`)

#### 6a. GGUF transformer

```json
{
  "version": "3.7.1",
  "base_model": {"name": "Tongyi-MAI/Z-Image-Turbo", "revision": null},
  "dtype": "bfloat16",
  "prompt": "A product photo of a white ceramic cup on a wooden table",
  "components": {
    "transformer": {
      "format": "gguf",
      "repo": "jayn7/Z-Image-Turbo-GGUF",
      "revision": null,
      "format_kwargs": {
        "filename": "z_image_turbo-Q4_K_M.gguf"
      }
    }
  },
  "task_config": {
    "image_width": 1024,
    "image_height": 1024,
    "steps": 9,
    "seed": 0,
    "num_images_per_prompt": 1
  }
}
```

#### 6b. Standalone Diffusers VAE

```json
{
  "version": "3.7.1",
  "base_model": {"name": "Tongyi-MAI/Z-Image-Turbo", "revision": null},
  "dtype": "bfloat16",
  "prompt": "A product photo of a white ceramic cup on a wooden table",
  "components": {
    "vae": {
      "format": "diffusers",
      "repo": "org/standalone-vae",
      "revision": null,
      "format_kwargs": {}
    }
  },
  "task_config": {
    "image_width": 1024,
    "image_height": 1024,
    "steps": 9,
    "seed": 0,
    "num_images_per_prompt": 1
  }
}
```

#### 6c. Diffusers component with `subfolder`

```json
{
  "version": "3.7.1",
  "base_model": {"name": "Tongyi-MAI/Z-Image-Turbo", "revision": null},
  "dtype": "bfloat16",
  "prompt": "A product photo of a white ceramic cup on a wooden table",
  "components": {
    "text_encoder": {
      "format": "diffusers",
      "repo": "org/custom-text-encoder",
      "revision": null,
      "format_kwargs": {
        "subfolder": "text_encoder"
      }
    }
  },
  "task_config": {
    "image_width": 1024,
    "image_height": 1024,
    "steps": 9,
    "seed": 0,
    "num_images_per_prompt": 1
  }
}
```

#### 6d. Multiple components

```json
{
  "version": "3.7.1",
  "base_model": {"name": "Tongyi-MAI/Z-Image-Turbo", "revision": null},
  "dtype": "bfloat16",
  "prompt": "A product photo of a white ceramic cup on a wooden table",
  "components": {
    "transformer": {
      "format": "gguf",
      "repo": "jayn7/Z-Image-Turbo-GGUF",
      "revision": null,
      "format_kwargs": {
        "filename": "z_image_turbo-Q4_K_M.gguf"
      }
    },
    "vae": {
      "format": "diffusers",
      "repo": "org/standalone-vae",
      "revision": null,
      "format_kwargs": {}
    }
  },
  "task_config": {
    "image_width": 1024,
    "image_height": 1024,
    "steps": 9,
    "seed": 0,
    "num_images_per_prompt": 1
  }
}
```

### 7. Task-time quantization (`quantization_config`)

```json
{
  "version": "3.7.1",
  "base_model": {"name": "Tongyi-MAI/Z-Image-Turbo", "revision": null},
  "dtype": "bfloat16",
  "prompt": "A product photo of a white ceramic cup on a wooden table",
  "task_config": {
    "image_width": 1024,
    "image_height": 1024,
    "steps": 9,
    "seed": 0,
    "num_images_per_prompt": 1
  },
  "quantization_config": {
    "quant_method": "bitsandbytes",
    "components_to_quantize": ["transformer"],
    "quant_kwargs": {
      "load_in_4bit": true,
      "bnb_4bit_quant_type": "nf4",
      "bnb_4bit_compute_dtype": "bfloat16"
    }
  }
}
```

For BitsAndBytes, GGUF, Nunchaku Lite, and platform scheduling rules, see [Model Quantization](../quantization.md).
