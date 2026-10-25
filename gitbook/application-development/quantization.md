# Model Quantization

Quantization reduces model VRAM (`min_vram`) so larger LLMs and image models can run on common 24 GB GPU nodes. Lower VRAM requirements also increase the number of matching nodes and can improve scheduling.

Crynux supports two modes:

* **Task-time quantization** — the base model is floating-point (FP16 / BF16). You pass `quantization_config` on the request so the node quantizes weights at load time.
* **Pre-quantized models and components** — the Hub repository already stores quantized weights (LLM AWQ / GPTQ / compressed-tensors, or image Nunchaku Lite / GGUF components). You select that model ID or replace a component through `components`. Do **not** stack a conflicting `quantization_config` on the same model or component.

## How to Pass Quantization Config

### OpenAI-Compatible APIs

On Chat Completions, Completions, Responses, Images Generations, and Images Edits:

* Python OpenAI SDK: pass `quantization_config` (and optional `dtype` / `components`) through `extra_body`
* JavaScript OpenAI SDK: pass the same fields as top-level request properties

See [How to Run LLM using Crynux Network](how-to-run-llm-using-crynux-network/README.md) and [OpenAI-Compatible Image API](openai-compatible-image-api.md).

### Raw Task API

Put `quantization_config` (and optional `components` for image tasks) inside the `task_args` JSON string on `POST /inference_tasks`. See [Text-to-Text Task](execute-tasks/text-to-text-task.md) and [Text-to-Image Task](execute-tasks/text-to-image-task.md).

The legacy LLM field `quantize_bits` is removed. Use `quantization_config` instead.

## LLM Quantization

### Task-time quantization shape

```json
{
  "quant_method": "<method>",
  "quant_kwargs": {}
}
```

#### BitsAndBytes 4-bit (NF4 / FP4)

Supported `quant_kwargs` include `load_in_4bit`, `bnb_4bit_quant_type` (`"nf4"` or `"fp4"`), `bnb_4bit_compute_dtype` (`"float16"`, `"bfloat16"`, `"float32"`), and `bnb_4bit_use_double_quant`.

{% tabs %}
{% tab title="OpenAI SDK (Python)" %}
```python
from openai import OpenAI

client = OpenAI(
    base_url="https://YOUR_CRYNUX_AS_URL/api/<endpoint_token>/v1",
    api_key="your-api-key",
    timeout=120,
    max_retries=1,
)

res = client.chat.completions.create(
    model="Qwen/Qwen2.5-14B-Instruct",
    messages=[{"role": "user", "content": "Say hello in one sentence."}],
    extra_body={
        "vram_limit": 24,
        "dtype": "bfloat16",
        "quantization_config": {
            "quant_method": "bitsandbytes",
            "quant_kwargs": {
                "load_in_4bit": True,
                "bnb_4bit_quant_type": "nf4",
                "bnb_4bit_compute_dtype": "bfloat16",
                "bnb_4bit_use_double_quant": False,
            },
        },
    },
)
print(res.choices[0].message.content)
```
{% endtab %}

{% tab title="Raw Task `task_args`" %}
```json
{
  "version": "3.7.1",
  "model": "Qwen/Qwen2.5-14B-Instruct",
  "messages": [{"role": "user", "content": "Say hello in one sentence."}],
  "dtype": "bfloat16",
  "seed": 42,
  "generation_config": {"max_new_tokens": 64},
  "quantization_config": {
    "quant_method": "bitsandbytes",
    "quant_kwargs": {
      "load_in_4bit": true,
      "bnb_4bit_quant_type": "nf4",
      "bnb_4bit_compute_dtype": "bfloat16",
      "bnb_4bit_use_double_quant": false
    }
  }
}
```
{% endtab %}
{% endtabs %}

#### BitsAndBytes 8-bit (INT8)

Supported `quant_kwargs` include `load_in_8bit`, `llm_int8_threshold` (for example `6.0` or `0.0`), and `llm_int8_skip_modules`.

```json
{
  "version": "3.7.1",
  "model": "Qwen/Qwen3-8B",
  "messages": [{"role": "user", "content": "Say hello in one sentence."}],
  "dtype": "bfloat16",
  "seed": 42,
  "generation_config": {"max_new_tokens": 64},
  "quantization_config": {
    "quant_method": "bitsandbytes",
    "quant_kwargs": {
      "load_in_8bit": true,
      "llm_int8_threshold": 6.0
    }
  }
}
```

#### Fine-grained FP8

Requires a GPU with compute capability 8.9 or higher.

```json
{
  "version": "3.7.1",
  "model": "Qwen/Qwen2.5-7B-Instruct",
  "messages": [{"role": "user", "content": "Say hello in one sentence."}],
  "dtype": "bfloat16",
  "seed": 42,
  "generation_config": {"max_new_tokens": 64},
  "quantization_config": {
    "quant_method": "fp8",
    "quant_kwargs": {
      "activation_scheme": "dynamic",
      "weight_block_size": [128, 128],
      "scale_fmt": "float"
    }
  }
}
```

`scale_fmt` may be `"float"` or `"ue8m0"`. Do not pass `dequantize` in `quant_kwargs`.

### Pre-quantized LLM checkpoints

Set `model` to the pre-quantized Hub repository. Omit `quantization_config` or set it to `null`.

| Method | Example model ID |
| --- | --- |
| AWQ (INT4) | `Qwen/Qwen2.5-32B-Instruct-AWQ` |
| GPTQ / GPTQModel (INT4) | `Qwen/Qwen2.5-32B-Instruct-GPTQ-Int4` |
| compressed-tensors (FP8, etc.) | `RedHatAI/Llama-3.2-1B-Instruct-FP8-dynamic` |

```python
res = client.chat.completions.create(
    model="Qwen/Qwen2.5-32B-Instruct-AWQ",
    messages=[{"role": "user", "content": "Say hello in one sentence."}],
    extra_body={
        "vram_limit": 24,
        "quantization_config": None,
    },
)
```

## Image Model Quantization

### Method 1: Task-time BitsAndBytes (per component)

```json
{
  "quant_method": "bitsandbytes",
  "components_to_quantize": ["transformer"],
  "quant_kwargs": {
    "load_in_4bit": true,
    "bnb_4bit_quant_type": "nf4",
    "bnb_4bit_compute_dtype": "bfloat16"
  }
}
```

`components_to_quantize` lists component names from the base pipeline `model_index.json`, for example `["transformer"]` or `["transformer", "text_encoder"]`.

{% tabs %}
{% tab title="OpenAI Image API (Python)" %}
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
        "quantization_config": {
            "quant_method": "bitsandbytes",
            "components_to_quantize": ["transformer"],
            "quant_kwargs": {
                "load_in_4bit": True,
                "bnb_4bit_quant_type": "nf4",
                "bnb_4bit_compute_dtype": "bfloat16",
            },
        },
    },
)
```
{% endtab %}

{% tab title="Raw Task `task_args`" %}
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
    "seed": 0,
    "num_images_per_prompt": 1,
    "guidance_scale": 1
  },
  "quantization_config": {
    "quant_method": "bitsandbytes",
    "components_to_quantize": ["transformer"],
    "quant_kwargs": {
      "load_in_4bit": true,
      "bnb_4bit_quant_type": "nf4",
      "bnb_4bit_compute_dtype": "bfloat16",
      "bnb_4bit_use_double_quant": false
    }
  }
}
```
{% endtab %}
{% endtabs %}

INT8 example for the transformer:

```json
{
  "quant_method": "bitsandbytes",
  "components_to_quantize": ["transformer"],
  "quant_kwargs": {
    "load_in_8bit": true,
    "llm_int8_threshold": 6.0
  }
}
```

### Method 2: Component GGUF through `components`

Keep `base_model` as the full Diffusers pipeline. Replace `transformer` with a community GGUF file:

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
  "quantization_config": null
}
```

Supported GGUF tensor types include `Q4_0`, `Q4_1`, `Q5_0`, `Q5_1`, `Q8_0`, `Q2_K`–`Q6_K`, and `BF16`.

You may combine a GGUF `transformer` with BitsAndBytes on other unquantized components (for example `text_encoder`). The same component must not receive two quantization methods.

### Method 3: Pre-quantized Nunchaku Lite INT4 pipeline

Use a complete Nunchaku Lite Diffusers pipeline as `base_model`. Do not set `components` or `quantization_config`.

```json
{
  "version": "3.7.1",
  "base_model": {
    "name": "lite-infer/z-image-turbo-nunchaku-lite-int4_r32-bnb4-text-encoder",
    "revision": null
  },
  "dtype": "bfloat16",
  "prompt": "A product photo of a white ceramic cup on a wooden table",
  "task_config": {
    "image_width": 1024,
    "image_height": 1024,
    "steps": 9,
    "seed": 0,
    "num_images_per_prompt": 1
  },
  "quantization_config": null
}
```

## Platform Support and Scheduling Rules

| Load | Windows CUDA | Linux / Docker CUDA |
| --- | --- | --- |
| LLM BitsAndBytes / FP8 | Supported | Supported |
| Image BitsAndBytes / GGUF | Supported | Supported |
| LLM AWQ / GPTQ / GPTQModel | Not scheduled | Supported (Relay routes only to Linux / Docker CUDA) |
| Image Nunchaku Lite | Not scheduled | Supported (Relay routes only to Linux / Docker CUDA) |

Relay detects Linux-CUDA-only loads from TaskArgs and Hub metadata. You do not need to filter nodes yourself.

Common rejection cases:

* Passing `quantization_config` for a model or component that already has embedded quantization
* Passing `dequantize` inside `quant_kwargs`
* Targeting the same component with both `components` GGUF replacement and BitsAndBytes `components_to_quantize`
