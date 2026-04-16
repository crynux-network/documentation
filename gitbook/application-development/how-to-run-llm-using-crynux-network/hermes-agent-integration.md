# Hermes Agent Integration

This guide shows the fastest way to connect Hermes Agent to Crynux Bridge as a custom LLM provider.

Hermes Agent is an open-source, self-improving AI agent from Nous Research. It is designed as an autonomous assistant for chat, automation, tools, and coding workflows, and it supports OpenAI-compatible endpoints, so Crynux Bridge can be used directly as a custom provider backend. Learn more on the official website: [https://hermes-agent.nousresearch.com/](https://hermes-agent.nousresearch.com/).

The core setup is simple:

- set Hermes provider to `custom`
- set Crynux Bridge `base_url`
- set your Crynux API token

## Before You Start

Prepare these three items before configuration:

### 1) Base URL

The standard Crynux Bridge endpoint is:

- `https://bridge.crynux.io/v1/llm`

You can also set the VRAM limit directly in the path:

- `https://bridge.crynux.io/v1/llm/24` means VRAM limit is set to `24`

`vram_limit` is a Crynux-specific routing parameter. It defines the minimum GPU VRAM requirement (in GB) for your request, so Crynux can dispatch the task to nodes with enough GPU memory. If you choose a value that is too low for your model, the task may fail or timeout.

If you do not specify a VRAM limit, the default value is `24`.

### 2) Access Token

The public demo token has strict rate limits and is not suitable for normal use.

To get a free token with better quota:

1. Join the Crynux Discord: [https://discord.gg/y8YKxb7uZk](https://discord.gg/y8YKxb7uZk)
2. Go to the **applications** channel
3. Request a Crynux Bridge API token from an admin

### 3) Model

Crynux generally supports open-source models that are compatible with the Hugging Face `transformers` library. In practice, the main limitation is available VRAM on network nodes, so larger models require higher VRAM settings.

Hermes workflows require tool use/function calling support, so choose a model that supports tool calling. Instruction-tuned models are usually safer choices (for example, `Qwen/Qwen2.5-7B-Instruct`). For details, refer to:

- [Tool Use/Function Calling](./tool-use.md)
- [Supported Models](./supported-models.md)

{% tabs %}
{% tab title="Interactive Setup (hermes model)" %}
Run:

```bash
hermes model
```

Then in the menu:

1. Choose **Custom endpoint (self-hosted / VLLM / etc.)**
2. API base URL: `https://bridge.crynux.io/v1/llm`
3. API key: paste your Crynux token
4. Model name: for example `Qwen/Qwen2.5-7B-Instruct`
5. Context length: keep auto-detect, or enter a value manually if prompted

Start Hermes:

```bash
hermes
```
{% endtab %}

{% tab title="Config File Setup (Local and Docker)" %}
Use this method for both local runtime and Docker runtime.

- Local runtime files: `~/.hermes/config.yaml` and `~/.hermes/.env`
- Docker runtime files (with `-v ~/.hermes:/opt/data`): same host files

Update these exact config items in `~/.hermes/config.yaml`:

- `model.provider`: `custom`
- `model.default`: your selected model (example: `Qwen/Qwen2.5-7B-Instruct`)
- `model.base_url`: `https://bridge.crynux.io/v1/llm`
- `model.api_key`: `${CRYNUX_API_KEY}`

Optional:

- `model.context_length`: set this only if auto-detection is incorrect

### `~/.hermes/config.yaml`

```yaml
model:
  provider: custom
  default: Qwen/Qwen2.5-7B-Instruct
  base_url: https://bridge.crynux.io/v1/llm
  api_key: ${CRYNUX_API_KEY}
```

### `~/.hermes/.env`

```bash
CRYNUX_API_KEY=your_real_crynux_token_here
```

After saving, start Hermes:

```bash
hermes
```

Or with Docker:

```bash
docker run -it --rm \
  -v ~/.hermes:/opt/data \
  nousresearch/hermes-agent
```
{% endtab %}
{% endtabs %}
