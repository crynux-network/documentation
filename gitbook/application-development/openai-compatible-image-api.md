# OpenAI-Compatible Image API

Crynux Network provides OpenAI-compatible Image Generation and Image Edit APIs. You can use the official OpenAI SDK with only a Crynux base URL and API key.

{% hint style="info" %}
The examples below use a Crynux AS project endpoint. Replace `https://YOUR_CRYNUX_AS_URL/api/<endpoint_token>/v1` and `your-api-key` with your project Base URL and API key from the Crynux AS dashboard.
{% endhint %}

## Quick Start: Image Generation

Call `POST /v1/images/generations` through the OpenAI SDK `images.generate` method:

{% tabs %}
{% tab title="Python" %}
```python
import base64
from openai import OpenAI

client = OpenAI(
    base_url="https://YOUR_CRYNUX_AS_URL/api/<endpoint_token>/v1",
    api_key="your-api-key",
    timeout=300,
    max_retries=1,
)

result = client.images.generate(
    model="Qwen/Qwen-Image-2.1",
    prompt="A product photo of a white ceramic cup on a wooden table",
    size="1024x1024",
    response_format="b64_json",
)

image_bytes = base64.b64decode(result.data[0].b64_json)
with open("output.png", "wb") as f:
    f.write(image_bytes)
```
{% endtab %}

{% tab title="JavaScript" %}
```javascript
import fs from "fs";
import OpenAI from "openai";

const client = new OpenAI({
  baseURL: "https://YOUR_CRYNUX_AS_URL/api/<endpoint_token>/v1",
  apiKey: "your-api-key",
  timeout: 300000,
  maxRetries: 1,
});

async function main() {
  const result = await client.images.generate({
    model: "Qwen/Qwen-Image-2.1",
    prompt: "A product photo of a white ceramic cup on a wooden table",
    size: "1024x1024",
    response_format: "b64_json",
  });

  const imageBytes = Buffer.from(result.data[0].b64_json, "base64");
  fs.writeFileSync("output.png", imageBytes);
}

main();
```
{% endtab %}
{% endtabs %}

## Image Editing

Call `POST /v1/images/edits` to create images from one or more input images and a text prompt. You can send images as multipart file uploads or as JSON data URLs.

### Multipart upload with the OpenAI SDK

{% tabs %}
{% tab title="Python" %}
```python
import base64
from openai import OpenAI

client = OpenAI(
    base_url="https://YOUR_CRYNUX_AS_URL/api/<endpoint_token>/v1",
    api_key="your-api-key",
    timeout=300,
    max_retries=1,
)

with open("input.png", "rb") as image_file:
    result = client.images.edit(
        model="Qwen/Qwen-Image-2.1",
        image=image_file,
        prompt="Change the background to a snowy mountain landscape",
        size="1024x1024",
        response_format="b64_json",
    )

image_bytes = base64.b64decode(result.data[0].b64_json)
with open("edited.png", "wb") as f:
    f.write(image_bytes)
```
{% endtab %}

{% tab title="JavaScript" %}
```javascript
import fs from "fs";
import OpenAI from "openai";

const client = new OpenAI({
  baseURL: "https://YOUR_CRYNUX_AS_URL/api/<endpoint_token>/v1",
  apiKey: "your-api-key",
  timeout: 300000,
  maxRetries: 1,
});

async function main() {
  const result = await client.images.edit({
    model: "Qwen/Qwen-Image-2.1",
    image: fs.createReadStream("input.png"),
    prompt: "Change the background to a snowy mountain landscape",
    size: "1024x1024",
    response_format: "b64_json",
  });

  const imageBytes = Buffer.from(result.data[0].b64_json, "base64");
  fs.writeFileSync("edited.png", imageBytes);
}

main();
```
{% endtab %}
{% endtabs %}

The multipart form accepts one or more file parts named `image` or `image[]`. You can upload 1 to 16 images.

### JSON request with data URLs

```python
import base64
import requests

with open("input.png", "rb") as f:
    data_url = "data:image/png;base64," + base64.b64encode(f.read()).decode("ascii")

response = requests.post(
    "https://YOUR_CRYNUX_AS_URL/api/<endpoint_token>/v1/images/edits",
    headers={
        "Authorization": "Bearer your-api-key",
        "Content-Type": "application/json",
    },
    json={
        "model": "Qwen/Qwen-Image-2.1",
        "prompt": "Change the background to a snowy mountain landscape",
        "images": [{"image_url": data_url}],
        "size": "1024x1024",
        "response_format": "b64_json",
    },
    timeout=300,
)

print(response.json())
```

JSON requests must use `images` as a non-empty array of objects. Each object provides exactly one `image_url` as a `data:image/<type>;base64,...` data URL. Absolute `http` and `https` URLs are not supported. The total size of all `images` strings must not exceed 1 MB (`1,048,576` bytes).

## Supported Standard OpenAI Parameters

| Parameter | Required | Notes |
| --- | --- | --- |
| `model` | Yes | Hugging Face Diffusers image model ID, for example `Qwen/Qwen-Image-2.1`, `Tongyi-MAI/Z-Image-Turbo`, or `black-forest-labs/FLUX.2-klein-4B` |
| `prompt` | Yes | Text prompt, at most 32,000 characters |
| `images` / `image` | Edits only | 1 to 16 input images. JSON uses `images: [{"image_url": "data:image/...;base64,..."}]`. Multipart uses `image` or `image[]` file parts |
| `n` | No | Number of images to generate, integer from 1 to 10, default `1` |
| `size` | No | Default or `"auto"` becomes `1024x1024`. Named sizes: `256x256`, `512x512`, `1024x1024`, `1024x1536`, `1536x1024`, `1792x1024`, `1024x1792`. Custom `WIDTHxHEIGHT` must use positive integers divisible by 8, aspect ratio in `[1/3, 3]`, each edge at most `3840`, and pixel count at most `3840 * 2160` |
| `quality` | No | Maps to denoising steps: `"low"` → `20`; omitted / `"auto"` / `"medium"` / `"standard"` → `40`; `"high"` / `"hd"` / `"xhigh"` / `"max"` → `50` |
| `response_format` | No | Only `"b64_json"` is supported |
| `output_format` | No | Only `"png"` is supported |
| `safety_identifier`, `user` | No | Accepted with no side effects |

## Crynux Extended Parameters

Crynux extends the OpenAI Images APIs with the fields below. In the Python OpenAI SDK, pass them through `extra_body`. In the JavaScript OpenAI SDK, pass them as top-level request fields.

| Parameter | Notes |
| --- | --- |
| `vram_limit` | Minimum GPU VRAM in GB. You can also set it in the URL path as `/v1/<vram_limit>/images/generations` or `/v1/<vram_limit>/images/edits`. The path value overrides the body value. When omitted, Crynux uses the matched loaded-model `min_vram` |
| `queue_timeout` | Queue wait budget in seconds. See Flexible Pricing below |
| `quantization_config` | Optional object or `null` for task-time quantization. See [Model Quantization](quantization.md). For multipart `/images/edits`, send either one JSON form field or OpenAI SDK bracket fields such as `quantization_config[quant_kwargs][load_in_4bit]` |
| `components` | Optional object or `null` that replaces pipeline components, for example a GGUF `transformer` or a standalone `vae`. See [Model Quantization](quantization.md) and [Text-to-Image Task](execute-tasks/text-to-image-task.md) |

### Flexible Pricing with `queue_timeout`

Crynux schedules queued tasks by task fee. That is Flexible Pricing: a higher Cost Level / task fee ranks higher in the queue, and a lower Cost Level / task fee ranks lower.

You can combine a low project Cost Level with a long `queue_timeout` (for example several hours). The task stays in the queue longer and can run when the network is quieter, which is cheaper for large batches that do not need an immediate result.

Synchronous Image APIs (`/v1/images/generations` and `/v1/images/edits`) hold one HTTP request until the job finishes. That hold is limited (about 10 minutes by default) and is not suitable for long queue waits. For low Cost Level + long `queue_timeout`, do not use the synchronous Images APIs. Use the asynchronous Raw Task API instead: create the task with `POST /inference_tasks` or `POST /inference_tasks/batch`, poll status, then download the PNG when the task succeeds. See [Text-to-Image Task](execute-tasks/text-to-image-task.md).

### Example with extended parameters

{% tabs %}
{% tab title="Python" %}
```python
from openai import OpenAI

client = OpenAI(
    base_url="https://YOUR_CRYNUX_AS_URL/api/<endpoint_token>/v1",
    api_key="your-api-key",
    timeout=300,
    max_retries=1,
)

result = client.images.generate(
    model="Tongyi-MAI/Z-Image-Turbo",
    prompt="A product photo of a white ceramic cup on a wooden table",
    size="1024x1024",
    response_format="b64_json",
    extra_body={
        "vram_limit": 24,
        "queue_timeout": 3600,
        "quantization_config": {
            "quant_method": "bitsandbytes",
            "components_to_quantize": ["transformer"],
            "quant_kwargs": {
                "load_in_4bit": True,
                "bnb_4bit_quant_type": "nf4",
                "bnb_4bit_compute_dtype": "bfloat16",
            },
        },
        "components": {
            "transformer": {
                "format": "gguf",
                "repo": "jayn7/Z-Image-Turbo-GGUF",
                "revision": None,
                "format_kwargs": {
                    "filename": "z_image_turbo-Q4_K_M.gguf",
                },
            }
        },
    },
)
```
{% endtab %}

{% tab title="JavaScript" %}
```javascript
import OpenAI from "openai";

const client = new OpenAI({
  baseURL: "https://YOUR_CRYNUX_AS_URL/api/<endpoint_token>/v1",
  apiKey: "your-api-key",
  timeout: 300000,
  maxRetries: 1,
});

const result = await client.images.generate({
  model: "Tongyi-MAI/Z-Image-Turbo",
  prompt: "A product photo of a white ceramic cup on a wooden table",
  size: "1024x1024",
  response_format: "b64_json",
  vram_limit: 24,
  queue_timeout: 3600,
  quantization_config: {
    quant_method: "bitsandbytes",
    components_to_quantize: ["transformer"],
    quant_kwargs: {
      load_in_4bit: true,
      bnb_4bit_quant_type: "nf4",
      bnb_4bit_compute_dtype: "bfloat16",
    },
  },
  components: {
    transformer: {
      format: "gguf",
      repo: "jayn7/Z-Image-Turbo-GGUF",
      revision: null,
      format_kwargs: {
        filename: "z_image_turbo-Q4_K_M.gguf",
      },
    },
  },
});
```
{% endtab %}
{% endtabs %}

## Unsupported Parameters and Endpoints

These values return HTTP 400 with an OpenAI invalid-request error shape:

* Endpoint: `POST /v1/images/variations`
* OpenAI fields or values: `response_format="url"`, `output_format` other than `"png"`, `output_compression`, `background`, `moderation`, `style`, `stream=true`, `partial_images`
* Image edits only: `mask`, `input_fidelity`, `file_id`, and non-data-URL `http://` or `https://` image links
* Underlying Raw Task fields that are not accepted on the OpenAI Images APIs: `dtype`, `lora`, `steps`, `negative_prompt`, `seed`, `strength`, `guidance_scale`

## Need More Complex Features? Use the Raw Task API

Use the OpenAI-compatible Images APIs when you want a simple generation or edit call. Use the Raw Task API when you need finer control, for example:

* custom `steps`, `negative_prompt`, `guidance_scale`, fixed `seed`, or img2img `strength`
* LoRA adapters (`lora`)
* explicit `dtype`
* a specific GPU model through `required_gpu` and `required_gpu_vram`
* asynchronous create-and-poll, batch create (`POST /inference_tasks/batch`), or long `queue_timeout` Flexible Pricing jobs

{% content-ref url="execute-tasks/text-to-image-task.md" %}
[Text-to-Image Task](execute-tasks/text-to-image-task.md)
{% endcontent-ref %}

## Checking Available Image Models

List currently loaded image models for your project:

```
GET /api/<endpoint_token>/v1/models/image
```

Each list entry includes `id`, `min_vram`, `on_disk_node_count`, `execution_dtype`, `quantization_config`, `components`, and `lora`. The OpenAI Images APIs resolve a concrete `execution_dtype` from a matching loaded-model row when you do not control `dtype` directly on the OpenAI request.

## Response Format

A successful response looks like this:

```json
{
  "created": 1710000000,
  "data": [
    {
      "b64_json": "iVBORw0KGgoAAAANSUhEUgAA..."
    }
  ],
  "size": "1024x1024",
  "quality": "auto",
  "output_format": "png"
}
```

The response includes `created`, `data[].b64_json`, and echoed `size`, `quality`, and `output_format`. It does not include `url`, `revised_prompt`, `usage`, `background`, or `safety_identifier`.
