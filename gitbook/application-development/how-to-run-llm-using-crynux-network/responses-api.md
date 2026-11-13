# Responses API

Crynux Network supports the OpenAI [Responses API](https://platform.openai.com/docs/api-reference/responses). Compared with a single `chat/completions` request that must stay open until the model finishes, Responses lets you create a job, disconnect immediately, and poll for the result later.

This is useful when your application needs to run long tasks, recover after offline or reconnect periods, or submit a large number of tasks without holding many long-lived HTTP connections.

Crynux supports:

* `POST /v1/responses` to create a response
* `GET /v1/responses/{response_id}` to retrieve status and result
* `background=true` for asynchronous execution with client-side polling
* `previous_response_id` to continue a conversation from a completed response
* structured output through `text.format`
* function tools through `tools` and `tool_choice`

Unsupported on `/responses`:

* `stream=true`
* built-in tools
* `conversation`
* Chat Completions nested `response_format` as a top-level Responses field; use `text.format` instead

{% hint style="info" %}
The code examples below use the official OpenAI SDK. Point `base_url` at `https://api.crynux-as.xyz/api/<endpoint_token>/v1` and replace `<endpoint_token>` and `your-api-key` with values from [Crynux AS](https://crynux-as.xyz), the same way as in the [parent guide](./README.md).
{% endhint %}

## Using the OpenAI SDK with Background Polling

Set `background=true` when creating a response. The create call returns quickly with a response ID and a non-terminal status such as `queued` or `in_progress`. Keep calling retrieve until the status becomes `completed` or `failed`.

{% tabs %}
{% tab title="Python" %}
```python
import time
from openai import OpenAI

client = OpenAI(
    base_url="https://api.crynux-as.xyz/api/<endpoint_token>/v1",
    api_key="your-api-key",
    timeout=60,
    max_retries=1,
)

response = client.responses.create(
    model="Qwen/Qwen3.5-9B",
    input="Write a short plan for building a todo app.",
    background=True,
    extra_body={
        "vram_limit": 24,
    },
)

print(f"created: id={response.id}, status={response.status}")

while response.status in ("queued", "in_progress"):
    time.sleep(2)
    response = client.responses.retrieve(response.id)
    print(f"polling: status={response.status}")

if response.status == "completed":
    print(response.output_text)
else:
    print(f"failed: {response.error}")
```
{% endtab %}

{% tab title="Node.js" %}
```javascript
import OpenAI from "openai";

const client = new OpenAI({
  baseURL: "https://api.crynux-as.xyz/api/<endpoint_token>/v1",
  apiKey: "your-api-key",
  timeout: 60000,
  maxRetries: 1,
});

function sleep(ms) {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

async function main() {
  let response = await client.responses.create({
    model: "Qwen/Qwen3.5-9B",
    input: "Write a short plan for building a todo app.",
    background: true,
    vram_limit: 24,
  });

  console.log(`created: id=${response.id}, status=${response.status}`);

  while (response.status === "queued" || response.status === "in_progress") {
    await sleep(2000);
    response = await client.responses.retrieve(response.id);
    console.log(`polling: status=${response.status}`);
  }

  if (response.status === "completed") {
    console.log(response.output_text);
  } else {
    console.error("failed:", response.error);
  }
}

main();
```
{% endtab %}
{% endtabs %}

{% hint style="success" %}
You can also set `background=false` (or omit it). In that mode, `responses.create` waits until the job finishes and returns the final response in one call, similar to a synchronous `chat/completions` request.
{% endhint %}

## Structured Output with `text.format`

Use `text.format` for JSON Object or JSON Schema generation. The result remains a string in `output_text`.

{% tabs %}
{% tab title="Python" %}
```python
from openai import OpenAI

client = OpenAI(
    base_url="https://api.crynux-as.xyz/api/<endpoint_token>/v1",
    api_key="your-api-key",
)

response = client.responses.create(
    model="Qwen/Qwen3.5-9B",
    input="Alice and Bob are going to a Science Fair on 2024-05-10.",
    text={
        "format": {
            "type": "json_schema",
            "name": "calendar_event",
            "strict": True,
            "schema": {
                "type": "object",
                "properties": {
                    "name": {"type": "string"},
                    "date": {"type": "string"},
                    "participants": {
                        "type": "array",
                        "items": {"type": "string"},
                    },
                },
                "required": ["name", "date", "participants"],
                "additionalProperties": False,
            },
        }
    },
    extra_body={"vram_limit": 24},
)

print(response.output_text)
```
{% endtab %}

{% tab title="Node.js" %}
```javascript
import OpenAI from "openai";

const client = new OpenAI({
  baseURL: "https://api.crynux-as.xyz/api/<endpoint_token>/v1",
  apiKey: "your-api-key",
});

async function main() {
  const response = await client.responses.create({
    model: "Qwen/Qwen3.5-9B",
    input: "Alice and Bob are going to a Science Fair on 2024-05-10.",
    text: {
      format: {
        type: "json_schema",
        name: "calendar_event",
        strict: true,
        schema: {
          type: "object",
          properties: {
            name: { type: "string" },
            date: { type: "string" },
            participants: {
              type: "array",
              items: { type: "string" },
            },
          },
          required: ["name", "date", "participants"],
          additionalProperties: false,
        },
      },
    },
    vram_limit: 24,
  });

  console.log(response.output_text);
}

main();
```
{% endtab %}
{% endtabs %}

For Chat Completions `response_format`, schema limits, and LangChain options, see [Structured Output](structured-ouput.md).

## Function Tools

Responses uses a flat function tool shape. Named `tool_choice` is also flat: `{"type":"function","name":"..."}`.

{% tabs %}
{% tab title="Python" %}
```python
from openai import OpenAI

client = OpenAI(
    base_url="https://api.crynux-as.xyz/api/<endpoint_token>/v1",
    api_key="your-api-key",
)

tools = [
    {
        "type": "function",
        "name": "get_current_weather",
        "description": "Get the current weather in a given location",
        "parameters": {
            "type": "object",
            "properties": {
                "location": {"type": "string"},
                "unit": {"type": "string", "enum": ["celsius", "fahrenheit"]},
            },
            "required": ["location"],
        },
        "strict": True,
    }
]

response = client.responses.create(
    model="Qwen/Qwen3.5-9B",
    input="What's the weather like in Boston today?",
    tools=tools,
    tool_choice="required",
    extra_body={"vram_limit": 24},
)

for item in response.output:
    if item.type == "function_call":
        print(item.name, item.arguments, item.call_id)
```
{% endtab %}

{% tab title="Node.js" %}
```javascript
import OpenAI from "openai";

const client = new OpenAI({
  baseURL: "https://api.crynux-as.xyz/api/<endpoint_token>/v1",
  apiKey: "your-api-key",
});

const tools = [
  {
    type: "function",
    name: "get_current_weather",
    description: "Get the current weather in a given location",
    parameters: {
      type: "object",
      properties: {
        location: { type: "string" },
        unit: { type: "string", enum: ["celsius", "fahrenheit"] },
      },
      required: ["location"],
    },
    strict: true,
  },
];

async function main() {
  const response = await client.responses.create({
    model: "Qwen/Qwen3.5-9B",
    input: "What's the weather like in Boston today?",
    tools,
    tool_choice: "required",
    vram_limit: 24,
  });

  for (const item of response.output) {
    if (item.type === "function_call") {
      console.log(item.name, item.arguments, item.call_id);
    }
  }
}

main();
```
{% endtab %}
{% endtabs %}

To continue after a function call, send the previous `function_call` item plus a `function_call_output` item in the next `input`, or use `previous_response_id` and only send the new items. The `tool_choice` semantics match [Tool Use](tool-use.md): `none`, `auto`, `required`, and named function. On Crynux models, `auto` enables a tool grammar only when at least one tool sets `strict: true`.

## Using `langchain-crynux`

[`langchain-crynux`](https://pypi.org/project/langchain-crynux/) wraps the Responses background flow inside a normal LangChain `invoke` / `ainvoke` call. With `background=True`, `ChatCrynux` creates the Responses job, polls until it finishes, and returns a completed `AIMessage`.

{% hint style="warning" %}
`langchain-openai` supports the Responses API through `use_responses_api=True`, but only in the foreground path: the HTTP call waits until the response is finished. It does **not** implement `background=true` create-and-poll. If you need background execution from LangChain or LangGraph, use `langchain-crynux`.
{% endhint %}

### Installation

```bash
pip install langchain-crynux
```

### Background example

```python
from langchain_crynux import ChatCrynux

chat = ChatCrynux(
    base_url="https://api.crynux-as.xyz/api/<endpoint_token>/v1",
    api_key="your-api-key",
    model="Qwen/Qwen3.5-9B",
    vram_limit=24,
    use_responses_api=True,
    background=True,
    timeout=600,       # total polling timeout in seconds
    http_timeout=60,   # timeout for each create / retrieve HTTP call
    poll_interval=2.0, # seconds between retrieve calls
)

response = chat.invoke("Write a short plan for building a todo app.")
print(response.content)
```

| Parameter | Meaning when `background=True` |
| --- | --- |
| `use_responses_api` | Must be `True` (or omitted; `ChatCrynux` enables it automatically when `background=True`) |
| `background` | Sends `background=true` and polls inside `ChatCrynux` |
| `timeout` / `request_timeout` | Total time allowed for the whole poll loop |
| `http_timeout` | Timeout for each individual `create` / `retrieve` HTTP request |
| `poll_interval` | Seconds to wait between retrieve calls |

Streaming is not supported when `background=True`.

If you only need Responses without background polling, you can set `use_responses_api=True` and `background=False`, or use `langchain-openai` with `use_responses_api=True`.

For general LangChain and LangGraph setup, see:

{% content-ref url="langchain.md" %}
[Integration with LangChain & LangGraph](./langchain.md)
{% endcontent-ref %}

## Continuing a Conversation with `previous_response_id`

After a Responses job completes, you can start a new Responses call with `previous_response_id` set to the previous response's `id`. Crynux reconstructs the prior conversation history on the server, so the new request only needs to send the new user input.

{% tabs %}
{% tab title="Python" %}
```python
import time
from openai import OpenAI

client = OpenAI(
    base_url="https://api.crynux-as.xyz/api/<endpoint_token>/v1",
    api_key="your-api-key",
)


def wait_until_done(response):
    while response.status in ("queued", "in_progress"):
        time.sleep(2)
        response = client.responses.retrieve(response.id)
    return response


first = client.responses.create(
    model="Qwen/Qwen3.5-9B",
    input="My name is Alice. Remember it.",
    background=True,
    extra_body={"vram_limit": 24},
)
first = wait_until_done(first)
print(first.output_text)

second = client.responses.create(
    model="Qwen/Qwen3.5-9B",
    input="What is my name?",
    previous_response_id=first.id,
    background=True,
    extra_body={"vram_limit": 24},
)
second = wait_until_done(second)
print(second.output_text)
```
{% endtab %}

{% tab title="Node.js" %}
```javascript
import OpenAI from "openai";

const client = new OpenAI({
  baseURL: "https://api.crynux-as.xyz/api/<endpoint_token>/v1",
  apiKey: "your-api-key",
});

function sleep(ms) {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

async function waitUntilDone(response) {
  while (response.status === "queued" || response.status === "in_progress") {
    await sleep(2000);
    response = await client.responses.retrieve(response.id);
  }
  return response;
}

async function main() {
  let first = await client.responses.create({
    model: "Qwen/Qwen3.5-9B",
    input: "My name is Alice. Remember it.",
    background: true,
    vram_limit: 24,
  });
  first = await waitUntilDone(first);
  console.log(first.output_text);

  let second = await client.responses.create({
    model: "Qwen/Qwen3.5-9B",
    input: "What is my name?",
    previous_response_id: first.id,
    background: true,
    vram_limit: 24,
  });
  second = await waitUntilDone(second);
  console.log(second.output_text);
}

main();
```
{% endtab %}
{% endtabs %}

{% hint style="info" %}
`previous_response_id` only accepts a successfully completed Responses job that is still available for lookup. Failed or unfinished responses cannot be used as the previous response. Each new call stores the fully expanded history, so later turns do not depend on older ancestor responses remaining available.
{% endhint %}

`instructions` on a new call apply only to that call. They are not inherited from the previous response.
