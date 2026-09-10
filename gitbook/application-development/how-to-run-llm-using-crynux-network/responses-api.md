# Responses API

Crynux Network supports the OpenAI [Responses API](https://platform.openai.com/docs/api-reference/responses). Compared with a single `chat/completions` request that must stay open until the model finishes, Responses lets you create a job, disconnect immediately, and poll for the result later.

This is useful when your application needs to run long tasks, recover after offline or reconnect periods, or submit a large number of tasks without holding many long-lived HTTP connections.

Crynux supports:

* `POST /v1/responses` to create a response
* `GET /v1/responses/{response_id}` to retrieve status and result
* `background=true` for asynchronous execution with client-side polling
* `previous_response_id` to continue a conversation from a completed response

{% hint style="info" %}
The code examples below use the official OpenAI SDK. The only required change is pointing the client `base_url` at your Crynux API endpoint, the same way as in the [parent guide](./README.md).
{% endhint %}

## Using the OpenAI SDK with Background Polling

Set `background=true` when creating a response. The create call returns quickly with a response ID and a non-terminal status such as `queued` or `in_progress`. Keep calling retrieve until the status becomes `completed` or `failed`.

{% tabs %}
{% tab title="Python" %}
```python
import time
from openai import OpenAI

client = OpenAI(
    base_url="https://api.crynux-as.xyz/v1/llm",
    api_key="your-api-key",
    timeout=60,
    max_retries=1,
)

response = client.responses.create(
    model="Qwen/Qwen2.5-7B-Instruct",
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
  baseURL: "https://api.crynux-as.xyz/v1/llm",
  apiKey: "your-api-key",
  timeout: 60000,
  maxRetries: 1,
});

function sleep(ms) {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

async function main() {
  let response = await client.responses.create({
    model: "Qwen/Qwen2.5-7B-Instruct",
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
    base_url="https://api.crynux-as.xyz/v1/llm",
    api_key="your-api-key",
    model="Qwen/Qwen2.5-7B-Instruct",
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
    base_url="https://api.crynux-as.xyz/v1/llm",
    api_key="your-api-key",
)


def wait_until_done(response):
    while response.status in ("queued", "in_progress"):
        time.sleep(2)
        response = client.responses.retrieve(response.id)
    return response


first = client.responses.create(
    model="Qwen/Qwen2.5-7B-Instruct",
    input="My name is Alice. Remember it.",
    background=True,
    extra_body={"vram_limit": 24},
)
first = wait_until_done(first)
print(first.output_text)

second = client.responses.create(
    model="Qwen/Qwen2.5-7B-Instruct",
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
  baseURL: "https://api.crynux-as.xyz/v1/llm",
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
    model: "Qwen/Qwen2.5-7B-Instruct",
    input: "My name is Alice. Remember it.",
    background: true,
    vram_limit: 24,
  });
  first = await waitUntilDone(first);
  console.log(first.output_text);

  let second = await client.responses.create({
    model: "Qwen/Qwen2.5-7B-Instruct",
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
