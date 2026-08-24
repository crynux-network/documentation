---
description: Estimate task execution time from successful tasks
---

# Task Execution Time Estimation

Relay continuously estimates how long a task will take on a given GPU. The estimate is built from the measured execution times of successful tasks, and is kept separately for each GPU variant and each model configuration.

The estimate is used in two places:

* **Task pricing**: when a task is created, Relay uses the estimate as $$T$$ in the priority formula, so that queue order reflects fee per unit of expected node time rather than fee alone. See:

{% content-ref url="task-pricing.md" %}
[task-pricing.md](task-pricing.md)
{% endcontent-ref %}

* **QoS and execution timeout**: after a node is selected, Relay turns the same estimate into the execution deadline for that task. A deadline that is too short wrongly punishes honest nodes; a deadline that is too long lets slow or failing nodes occupy capacity. Fair timeout handling is part of the QoS design. See:

{% content-ref url="quality-of-service-qos.md" %}
[quality-of-service-qos.md](quality-of-service-qos.md)
{% endcontent-ref %}

## Calibration Overview

Execution time depends on the GPU, the model, and whether the node must load a different base model before it can start. The calibration keeps an independent parameter record for each exact combination of:

* task type
* GPU name and GPU VRAM
* model name
* model variant, when the task type uses one
* execution dtype
* quantization bits, when the task type uses them

Each valid successful task contributes one sample to the matching record. Relay fits a small set of coefficients that map the task's measured workload to the observed execution duration. Later tasks with the same GPU and model configuration reuse those coefficients.

{% hint style="info" %}
For LLM tasks, Relay also fits a separate **model-switch** term. When the selected node must unload its current base models and load the ones required by the task, that cost is added to the execution timeout. Queue priority is calculated before a node is known, so the model-switch term is zero at task creation and does not change the frozen priority.
{% endhint %}

When a task does not name a required GPU, Relay averages the compatible calibrated GPU records whose VRAM meets the task's minimum requirement, giving each compatible record equal weight. When a task names a required GPU, Relay uses that GPU's parameters directly.

Before a GPU and model combination has enough successful samples, Relay falls back to configured initial coefficients, or to the maximum complete prediction among already-ready records on the same VRAM. After enough samples accumulate, the record uses its own fitted coefficients.

## Public Execution-Time API

Relay exposes public endpoints that return the current calibrated coefficients for a model. Callers supply either a minimum VRAM requirement or an exact GPU name and VRAM. The API returns coefficients only; it does not accept workload values and does not return a combined estimated duration. The caller multiplies the coefficients by its own workload.

{% tabs %}
{% tab title="LLM" %}
```
GET /v2/models/llm/execution-time
```

| Parameter | Required | Meaning |
| --- | --- | --- |
| `model` | yes | Model name. Relay normalizes it the same way as task creation. |
| `dtype` | no | Requested dtype. When omitted or empty, Relay treats it as `auto`. |
| `quantize_bits` | no | Quantization bits. When omitted, Relay uses `0`. |
| `min_vram` | exclusive | Minimum VRAM in GB. Use this mode without `gpu_name` / `gpu_vram`. |
| `gpu_name` + `gpu_vram` | exclusive | Exact GPU name and VRAM in GB. Use this mode without `min_vram`. |

Example response:

```json
{
  "message": "success",
  "data": {
    "constant_seconds": 30,
    "seconds_per_input_token": 0.0004,
    "seconds_per_output_token": 0.1,
    "model_switch_seconds": 120,
    "seconds_per_image": 10,
    "seconds_per_megapixel": 5
  }
}
```

Estimated duration:

$$
\begin{aligned}
T =\ &constant\_seconds \\
&+ seconds\_per\_input\_token \times input\_tokens \\
&+ seconds\_per\_output\_token \times output\_tokens \\
&+ model\_switch\_seconds \times model\_switched \\
&+ seconds\_per\_image \times image\_count \\
&+ seconds\_per\_megapixel \times \frac{image\_pixels}{10^{6}}
\end{aligned}
$$

`model_switched` is `1` when the selected node must switch models, and `0` otherwise.

{% hint style="info" %}
Relay stores and fits LLM text-input cost as seconds per input byte. The public API converts that coefficient to `seconds_per_input_token` by multiplying by 4, so callers can work in approximate token units. The response does not include `seconds_per_input_byte`.
{% endhint %}
{% endtab %}

{% tab title="SD" %}
```
GET /v2/models/sd/execution-time
```

| Parameter | Required | Meaning |
| --- | --- | --- |
| `model` | yes | Model name. Relay normalizes it the same way as task creation. |
| `dtype` | no | Requested dtype. When omitted or empty, Relay treats it as `auto`. |
| `variant` | no | Base-model variant. |
| `min_vram` | exclusive | Minimum VRAM in GB. Use this mode without `gpu_name` / `gpu_vram`. |
| `gpu_name` + `gpu_vram` | exclusive | Exact GPU name and VRAM in GB. Use this mode without `min_vram`. |

Example response:

```json
{
  "message": "success",
  "data": {
    "overhead_seconds": 30,
    "seconds_per_sd_pixel_step": 0.00003814697265625
  }
}
```

Estimated duration:

$$
T = overhead\_seconds + num\_images \times width \times height \times steps \times seconds\_per\_sd\_pixel\_step
$$
{% endtab %}
{% endtabs %}

Both endpoints are public and do not require authentication. A model that has never been calibrated still returns coefficients: Relay uses matching records when they exist, and configured initial parameters otherwise.

## LLM Formula

### Design

LLM runtime has several independent parts. Prompt encoding and generation scale differently; images add both a per-image cost and a resolution-related cost; loading a different base model can dominate short tasks.

Relay therefore fits six coefficients against the measured duration of successful LLM tasks:

* a constant term for fixed per-task work
* a text-input term based on a deterministic encoding of the request
* an output term based on the verified number of generated tokens
* a model-switch term
* an image-count term
* an image-resolution term in megapixels

Text input is measured as UTF-8 byte length after Relay strips `base64` payloads from image blocks, so large image bytes do not inflate the text-input coefficient. Image count and decoded pixel area are stored separately. Output work uses the actual `completion_tokens` from the uploaded result only after that result's hash matches the validated score.

### Formula

$$
\begin{aligned}
T =\ &constant\_seconds \\
&+ seconds\_per\_input\_byte \times text\_input\_bytes \\
&+ seconds\_per\_output\_token \times completion\_tokens \\
&+ model\_switch\_seconds \times model\_switched \\
&+ seconds\_per\_image \times image\_count \\
&+ seconds\_per\_megapixel \times \frac{image\_pixels}{10^{6}}
\end{aligned}
$$

At task creation and for queue priority, Relay uses the declared `max_new_tokens` (or the configured default) in place of later `completion_tokens`, and sets `model_switched` to `0`. After node selection, Relay sets `model_switched` from a one-time comparison of the node's in-use base models with the task's required base models, and uses that value only for the execution timeout.

### Explanation

The constant term covers fixed setup that does not scale with prompt size or generation length. The input-byte and output-token terms separate prompt processing from generation. The image terms keep vision workload out of the text-input coefficient. The model-switch term isolates cold model-load cost so that short tasks on a node that already holds the model are not overcharged, while tasks that force a switch receive a longer deadline.

Relay updates the six coefficients only from LLM tasks whose uploaded result has been verified. Tasks that fail validation, abort, report an error, or lack a verifiable completion-token count do not change the fit.

## SD Formula

### Design

Image-generation runtime grows with the number of images, the resolution, and the number of denoising steps. Treating each pixel at each step as one unit of work gives a workload that scales with all three factors at once.

Model load, pipeline setup, and other fixed costs appear even on small tasks. The fit therefore separates a constant overhead from a per-pixel-step rate.

### Formula

Relay measures the workload as:

$$
sd\_units = num\_images \times image\_width \times image\_height \times steps
$$

One SD unit is one pixel executed for one step. The fitted execution time is:

$$
T = overhead\_seconds + seconds\_per\_sd\_pixel\_step \times sd\_units
$$

### Explanation

`overhead_seconds` absorbs the fixed cost that does not grow with resolution or steps. `seconds_per_sd_pixel_step` is the calibrated cost of one pixel-step on that GPU and model configuration.

Relay updates these two coefficients from successful, validated SD tasks. The actual sample duration is the time from task start to score-ready. Failed, aborted, or invalidated tasks do not update the fit.

## From Estimate to Execution Timeout

When Relay converts the fitted prediction into an execution timeout, it multiplies by a configured timeout multiplier, then clamps the result between configured minimum and maximum timeout bounds. For tasks that use this calibration, this happens after the exact GPU is selected. The stage deadlines themselves are described in:

{% content-ref url="task-lifecycle/task-state-transitions.md" %}
[task-state-transitions.md](task-lifecycle/task-state-transitions.md)
{% endcontent-ref %}
