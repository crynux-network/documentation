# Tool Use (Function Calling)

Crynux AS supports the OpenAI-compatible function tool API on `/chat/completions` and `/responses`. You describe functions to the model, and the model can return one or more function calls with JSON arguments.

{% hint style="info" %}
Replace `<endpoint_token>` and `your-api-key` with your project endpoint token and API key from [Crynux AS](https://crynux-as.xyz).
{% endhint %}

{% hint style="warning" %}
Not every open-source model supports tool calling. Schema acceptance alone is not enough: the model must provide a compatible chat template and tool-call format.

Instruction-tuned models are more likely to work. For example, `Qwen/Qwen2.5-7B-Instruct` is a better choice than the base model `Qwen/Qwen2.5-7B`. Always check the model card for function calling or tool use support.
{% endhint %}

## Supported Parameters

Crynux supports function tools only:

```json
{
  "type": "function",
  "function": {
    "name": "get_current_weather",
    "description": "Get the current weather in a given location",
    "parameters": {
      "type": "object",
      "properties": {
        "location": {"type": "string"},
        "unit": {"type": "string", "enum": ["celsius", "fahrenheit"]}
      },
      "required": ["location"]
    },
    "strict": true
  }
}
```

| `tool_choice` | Behavior |
| --- | --- |
| `"none"` | Tools may still be sent to the chat template. No tool grammar is applied. |
| `"auto"` | The model may return normal text or tool calls. A tool grammar is applied only when at least one declared function has `strict: true`. |
| `"required"` | The model must produce at least one tool call. |
| `{"type":"function","function":{"name":"..."}}` | The model must call the named function. |

Limits and unsupported fields:

* Built-in tools such as web search are rejected.
* `parallel_tool_calls` is ignored on Crynux models.
* Legacy `functions` / `function_call` are not supported.
* If an active tool constraint and `response_format` / `text.format` are both present, the tool constraint takes precedence.

On `/chat/completions`, Crynux AS parses the model raw text into OpenAI `message.tool_calls` and sets `finish_reason` to `tool_calls` when a call is detected. The Raw Task download API does not perform that conversion.

## Chat Completions with the OpenAI SDK

{% tabs %}
{% tab title="Auto" %}
```python
from openai import OpenAI

client = OpenAI(
    base_url="https://api.crynux-as.xyz/api/<endpoint_token>/v1",
    api_key="your-api-key",
)

tools = [
    {
        "type": "function",
        "function": {
            "name": "get_current_weather",
            "description": "Get the current weather in a given location",
            "parameters": {
                "type": "object",
                "properties": {
                    "location": {
                        "type": "string",
                        "description": "The city and state, e.g. San Francisco, CA",
                    },
                    "unit": {"type": "string", "enum": ["celsius", "fahrenheit"]},
                },
                "required": ["location"],
            },
            "strict": True,
        },
    }
]

messages = [{"role": "user", "content": "What's the weather like in Boston today?"}]
completion = client.chat.completions.create(
    model="Qwen/Qwen2.5-7B-Instruct",
    messages=messages,
    tools=tools,
    tool_choice="auto",
    extra_body={"vram_limit": 24},
)

message = completion.choices[0].message
print(message.tool_calls)
```
{% endtab %}

{% tab title="Forced Call" %}
```python
from openai import OpenAI

client = OpenAI(
    base_url="https://api.crynux-as.xyz/api/<endpoint_token>/v1",
    api_key="your-api-key",
)

tools = [
    {
        "type": "function",
        "function": {
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
        },
    }
]

# Force at least one tool call:
# tool_choice="required"
#
# Or force a specific function:
completion = client.chat.completions.create(
    model="Qwen/Qwen2.5-7B-Instruct",
    messages=[{"role": "user", "content": "What's the weather like in Boston today?"}],
    tools=tools,
    tool_choice={
        "type": "function",
        "function": {"name": "get_current_weather"},
    },
    extra_body={"vram_limit": 24},
)

print(completion.choices[0].message.tool_calls)
```
{% endtab %}
{% endtabs %}

## Complete Tool Loop

A useful application usually executes the returned function, appends the tool result, and asks the model again for the final answer:

```python
import json
from openai import OpenAI

client = OpenAI(
    base_url="https://api.crynux-as.xyz/api/<endpoint_token>/v1",
    api_key="your-api-key",
)

tools = [
    {
        "type": "function",
        "function": {
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
        },
    }
]


def get_current_weather(location: str, unit: str = "celsius"):
    return {"location": location, "temperature": "22", "unit": unit, "condition": "Sunny"}


messages = [{"role": "user", "content": "What's the weather like in Boston today?"}]
completion = client.chat.completions.create(
    model="Qwen/Qwen2.5-7B-Instruct",
    messages=messages,
    tools=tools,
    tool_choice="required",
    extra_body={"vram_limit": 24},
)

assistant_message = completion.choices[0].message
messages.append(assistant_message)

for tool_call in assistant_message.tool_calls or []:
    args = json.loads(tool_call.function.arguments)
    result = get_current_weather(**args)
    messages.append(
        {
            "role": "tool",
            "tool_call_id": tool_call.id,
            "content": json.dumps(result),
        }
    )

final = client.chat.completions.create(
    model="Qwen/Qwen2.5-7B-Instruct",
    messages=messages,
    tools=tools,
    tool_choice="none",
    extra_body={"vram_limit": 24},
)
print(final.choices[0].message.content)
```

## LangChain

{% tabs %}
{% tab title="LangChain-Crynux" %}
```python
from langchain_crynux import ChatCrynux
from langchain_core.tools import tool

@tool
def get_current_weather(location: str, unit: str = "celsius"):
    """Get the current weather in a given location"""
    return {
        "location": location,
        "temperature": "22",
        "unit": unit,
        "condition": "Sunny",
    }

llm = ChatCrynux(
    base_url="https://api.crynux-as.xyz/api/<endpoint_token>/v1",
    model="Qwen/Qwen2.5-7B-Instruct",
    vram_limit=24,
    api_key="your-api-key",
)

llm_with_tools = llm.bind_tools([get_current_weather])
response = llm_with_tools.invoke("What's the weather like in Boston today?")
print(response.tool_calls)
```
{% endtab %}

{% tab title="LangChain-OpenAI" %}
```python
from langchain_openai import ChatOpenAI
from langchain_core.tools import tool

@tool
def get_current_weather(location: str, unit: str = "celsius"):
    """Get the current weather in a given location"""
    return {
        "location": location,
        "temperature": "22",
        "unit": unit,
        "condition": "Sunny",
    }

llm = ChatOpenAI(
    base_url="https://api.crynux-as.xyz/api/<endpoint_token>/v1",
    api_key="your-api-key",
    model="Qwen/Qwen2.5-7B-Instruct",
    model_kwargs={"vram_limit": 24},
)

llm_with_tools = llm.bind_tools([get_current_weather])
response = llm_with_tools.invoke("What's the weather like in Boston today?")
print(response.tool_calls)
```
{% endtab %}
{% endtabs %}

## Responses API

Responses uses a flat function tool shape and returns `function_call` output items. Continue the conversation with `function_call_output` items, or use `previous_response_id`. See [Responses API](responses-api.md).

## Raw Task API

Raw Task `GPTTaskArgs` accepts the same `tools` and `tool_choice` fields. The download result keeps tool-call syntax in `choices[].message.content` and does not populate OpenAI `message.tool_calls`. Prefer `/chat/completions` or `/responses` when you need the parsed OpenAI tool-call objects. See [Text-to-Text Task](../execute-tasks/text-to-text-task.md).

## Parameter Details

### `tools`

`tools` is the list of functions the model may call. Crynux accepts only OpenAI-style function tools:

* `type` must be `"function"`
* `function.name` is required and must be unique in the list
* `function.description` and `function.parameters` are optional
* `function.strict` is optional; see below

Built-in tools such as web search are not supported. Legacy `functions` / `function_call` fields are not supported. `parallel_tool_calls` is ignored on Crynux models.

### `tool_choice`

`tool_choice` controls whether the model must call a tool, and how strongly Crynux constrains generation:

* `"none"`: do not require a tool call. Tools may still be passed into the chat template, but no tool grammar is applied. Use this on the final turn after you already have tool results.
* `"auto"`: the model may return normal text or tool calls. Crynux applies a tool grammar only when at least one declared function has `strict: true`. If every tool omits `strict` or sets `strict: false`, generation is not forced into valid tool-call syntax.
* `"required"`: the request must declare at least one tool, and generation is constrained to include at least one tool call.
* Named function, Chat Completions shape: `{"type":"function","function":{"name":"get_current_weather"}}`. Generation is constrained to that function. Responses uses the flat shape `{"type":"function","name":"get_current_weather"}`.

If an active tool constraint and `response_format` / `text.format` are both present, the tool constraint takes precedence and structured output is ignored.

### `strict`

`function.strict` is a per-tool boolean:

* With `tool_choice="auto"`, at least one `strict: true` tool is required before Crynux enables the tool grammar.
* When a tool grammar is active, `strict` is also passed into that grammar so function arguments follow the declared parameter schema more closely.
* `strict` is not a global switch that forces every tool to be called.

### Response fields

On `/chat/completions`, Crynux AS parses successful tool-call syntax into `message.tool_calls` and sets `finish_reason` to `tool_calls`. On `/responses`, parsed calls appear as `function_call` output items. Set `max_tokens` / `max_output_tokens` high enough for a complete call; a `finish_reason="length"` result may contain an incomplete tool-call prefix.
