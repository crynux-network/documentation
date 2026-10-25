# How to Run LLM using Crynux Network

Running LLM tasks with various open-source models can be as simple as calling an OpenAI-compliant API via the Crynux Network. The example below demonstrates how to send an LLM chat completion task to the Crynux Network using the official OpenAI SDK:

{% tabs %}
{% tab title="Python" %}
```python
from openai import OpenAI

client = OpenAI(
    base_url="https://bridge.crynux.io/v1/llm",
    api_key="q3hXHA_8O0LuGJ1_tou4_KamMlQqAo-aYwyAIDttdmI=", # For public demonstration only, strict rate limit applied.
    timeout=60,
    max_retries=1,
)

res = client.chat.completions.create(
    model="Qwen/Qwen2.5-7B-Instruct",
    messages=[
        {
            "role": "user",
            "content": "What is the capital of France?",
        },
    ],
    stream=False,
    extra_body={
        "vram_limit": 24,
    }
)

print(res)
```
{% endtab %}

{% tab title="JavaScript" %}
```javascript
import OpenAI from "openai";

const client = new OpenAI({
  baseURL: "https://bridge.crynux.io/v1/llm",
  apiKey: "q3hXHA_8O0LuGJ1_tou4_KamMlQqAo-aYwyAIDttdmI=", // For public demonstration only, strict rate limit applied.
  timeout: 60000,
  maxRetries: 1,
});

async function main() {
  try {
    const chatCompletion = await client.chat.completions.create({
      model: "Qwen/Qwen2.5-7B-Instruct",
      messages: [
        {
          role: "user",
          content: "What is the capital of France?",
        },
      ],
      stream: false,
      vram_limit: 24,
    });
    console.log("Chat completion response:", chatCompletion);

    return chatCompletion;
  } catch (error) {
    console.error("Error:", error);
  }
}

main();
```
{% endtab %}
{% endtabs %}

This code is standard for invoking OpenAI models through their API. The only modification is the `base_url`, which is changed from the OpenAI URL to the official Crynux Bridge. A live version of this JavaScript code, embedded in a CodePen webpage, allows you to input arbitrary text and receive a response:

{% embed url="https://codepen.io/Luke-Weber/pen/RNWaOgL" %}

The API, provided by the official Crynux Bridge, supports both OpenAI-compliant `/completions` and `/chat/completions` endpoints. Features like streaming, tool-calling, and numerous other configuration options are also supported. For a comprehensive list of supported features, please refer to the[ Crynux Bridge documentation](../crynux-bridge.md).


## Crynux Extended Parameters

In addition to standard OpenAI parameters (`model`, `messages`, `temperature`, `top_p`, `max_tokens` / `max_completion_tokens`, `stop`, `seed`, `tools`, `tool_choice`, `response_format`, `stream`, and others), Crynux extends `/v1/chat/completions`, `/v1/completions`, and `/v1/responses` with the fields below.

In the Python OpenAI SDK, pass them through `extra_body`. In the JavaScript OpenAI SDK, pass them as top-level request fields.

| Parameter | Notes |
| --- | --- |
| `vram_limit` | Minimum GPU VRAM in GB. You can also set it in the URL path as `/v1/<vram_limit>/chat/completions`. When omitted, Crynux selects `min_vram` from the loaded-model cache (unknown models default to `24` GB) |
| `queue_timeout` | Queue wait budget in seconds. See Flexible Pricing below |
| `dtype` | Model load precision: `"float16"`, `"bfloat16"`, `"float32"`, or `"auto"`. Used to match a loaded-model row and write into the underlying task args |
| `quantization_config` | Optional object or `null` for task-time quantization. See [Model Quantization](../quantization.md) |
| `chat_template_kwargs` | Object passed to the Hugging Face chat template on `/chat/completions` and `/responses`, for example `{"enable_thinking": false}` |
| `reasoning_effort` | On `/chat/completions`, controls thinking mode. Value `"none"` injects `enable_thinking=false`; any other non-empty value injects `enable_thinking=true`. On `/responses`, use `reasoning.effort` with the same mapping |
| `top_k`, `min_p`, `repetition_penalty` | Extra sampling controls on `/chat/completions` and `/completions`. `top_k` is an integer; `min_p` is a float in `0.0`–`1.0`; `repetition_penalty` is a float |

### Flexible Pricing with `queue_timeout`

Crynux schedules queued tasks by task fee. That is Flexible Pricing: a higher Cost Level / task fee ranks higher in the queue, and a lower Cost Level / task fee ranks lower.

You can combine a low project Cost Level with a long `queue_timeout` (for example several hours). The task stays in the queue longer and can run when the network is quieter, which is cheaper for large batches that do not need an immediate result.

Synchronous LLM APIs (`/v1/chat/completions`, `/v1/completions`, and `/v1/responses` with `background=false`) hold one HTTP request until the job finishes. That hold is limited (about 10 minutes by default) and is not suitable for long queue waits. For low Cost Level + long `queue_timeout`, do not use those synchronous APIs. Use asynchronous APIs instead:

* [Responses API](responses-api.md) with `background=true`, or
* [Raw Task API](../execute-tasks/text-to-text-task.md) create-and-poll

### Example with extended parameters

{% tabs %}
{% tab title="Python" %}
```python
from openai import OpenAI

client = OpenAI(
    base_url="https://bridge.crynux.io/v1/llm",
    api_key="q3hXHA_8O0LuGJ1_tou4_KamMlQqAo-aYwyAIDttdmI=",  # For public demonstration only, strict rate limit applied.
    timeout=60,
    max_retries=1,
)

res = client.chat.completions.create(
    model="Qwen/Qwen2.5-14B-Instruct",
    messages=[
        {
            "role": "user",
            "content": "What is the capital of France?",
        },
    ],
    stream=False,
    extra_body={
        "vram_limit": 24,
        "queue_timeout": 3600,
        "dtype": "bfloat16",
        "chat_template_kwargs": {
            "enable_thinking": False,
        },
        "quantization_config": {
            "quant_method": "bitsandbytes",
            "quant_kwargs": {
                "load_in_4bit": True,
                "bnb_4bit_quant_type": "nf4",
                "bnb_4bit_compute_dtype": "bfloat16",
            },
        },
        "top_k": 40,
        "min_p": 0.05,
        "repetition_penalty": 1.05,
    },
)

print(res)
```
{% endtab %}

{% tab title="JavaScript" %}
```javascript
import OpenAI from "openai";

const client = new OpenAI({
  baseURL: "https://bridge.crynux.io/v1/llm",
  apiKey: "q3hXHA_8O0LuGJ1_tou4_KamMlQqAo-aYwyAIDttdmI=", // For public demonstration only, strict rate limit applied.
  timeout: 60000,
  maxRetries: 1,
});

async function main() {
  const chatCompletion = await client.chat.completions.create({
    model: "Qwen/Qwen2.5-14B-Instruct",
    messages: [
      {
        role: "user",
        content: "What is the capital of France?",
      },
    ],
    stream: false,
    vram_limit: 24,
    queue_timeout: 3600,
    dtype: "bfloat16",
    chat_template_kwargs: {
      enable_thinking: false,
    },
    quantization_config: {
      quant_method: "bitsandbytes",
      quant_kwargs: {
        load_in_4bit: true,
        bnb_4bit_quant_type: "nf4",
        bnb_4bit_compute_dtype: "bfloat16",
      },
    },
    top_k: 40,
    min_p: 0.05,
    repetition_penalty: 1.05,
  });
  console.log("Chat completion response:", chatCompletion);
}

main();
```
{% endtab %}
{% endtabs %}

## Need More Complex Features? Use the Raw Task API

Use the OpenAI-compatible LLM APIs when you want chat completions, tool calling, structured output, or Responses. Use the Raw Task API when you need finer control, for example:

* batch create up to 100 tasks with `POST /inference_tasks/batch` and batch status polling
* a specific GPU model through `required_gpu` and `required_gpu_vram`
* a specific Hugging Face `revision`
* full control over `GPTTaskArgs`, including `template_args` and task-level create-and-poll flow

{% content-ref url="../execute-tasks/text-to-text-task.md" %}
[Text-to-Text Task](../execute-tasks/text-to-text-task.md)
{% endcontent-ref %}

## Advanced Usage

For more advanced use cases like Tool Calling, Structured Output, Responses API, and integrations with LangChain/LangGraph, please refer to the following guides:

{% content-ref url="tool-use.md" %}
[Tool Use/Function Calling](./tool-use.md)
{% endcontent-ref %}

{% content-ref url="structured-ouput.md" %}
[Structured Output](./structured-ouput.md)
{% endcontent-ref %}

{% content-ref url="vision-language-models.md" %}
[Vision Language Models (VLM)](./vision-language-models.md)
{% endcontent-ref %}

{% content-ref url="responses-api.md" %}
[Responses API](./responses-api.md)
{% endcontent-ref %}

{% content-ref url="langchain.md" %}
[LangGraph/LangChain](./langchain.md)
{% endcontent-ref %}

{% content-ref url="hermes-agent-integration.md" %}
[Hermes Agent Integration](./hermes-agent-integration.md)
{% endcontent-ref %}

The API Key in the example code is for public demonstration purposes only and has a strict rate limit, making it unsuitable for production environments. To use the Crynux Network in production, choose one of the following methods:

## Method 1: Using the Official Crynux Bridge

You can request a separate API Key with a higher quota from the Crynux Discord server. Join the server and request new keys from an admin in the "applications" channel.

{% embed url="https://discord.gg/y8YKxb7uZk" %}

## Method 2: Hosting Your Own Crynux Bridge

You can host your own instance of the Crynux Bridge to provide private APIs for your application. This approach gives you greater control over various system aspects, including reliability and speed-related configurations.

Starting a Crynux Bridge is as straightforward as running a Docker container. An additional requirement is a wallet funded with sufficient (test) CNX to cover the tasks you run on the network. And at this moment, you can get test CNXs for free in the [Crynux Discord](https://discord.gg/y8YKxb7uZk) as well.

Crynux Bridge is fully open-sourced on [GitHub](https://github.com/crynux-network/crynux-bridge). A step-by-step guide for starting a Crynux Bridge instance is available in the following document:

{% content-ref url="../crynux-bridge.md" %}
[crynux-bridge.md](../crynux-bridge.md)
{% endcontent-ref %}

## Method 3: Sending Tasks Directly to the Blockchain

You can bypass the Crynux Bridge entirely and interact directly with the blockchain and Crynux Relay to send tasks. Crynux SDKs are available in various languages and can be embedded directly into your code to run LLM tasks. Please consult the Crynux SDK documentation for detailed usage instructions:

{% content-ref url="../crynux-sdk.md" %}
[crynux-sdk.md](../crynux-sdk.md)
{% endcontent-ref %}
