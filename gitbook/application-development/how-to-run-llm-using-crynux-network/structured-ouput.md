# Structured Output

While unstructured text responses are useful, building reliable AI applications often requires structured data such as JSON.

Crynux supports native structured output for open-source models through constrained generation:

* Chat Completions: `response_format`
* Responses API: `text.format`

The generation grammar constrains each token while the model runs. The response still returns the JSON as a string in assistant text. Set `max_tokens` / `max_output_tokens` high enough for a complete object. If generation stops with `finish_reason="length"`, the text may be an incomplete JSON prefix.

{% hint style="info" %}
Replace `<endpoint_token>` and `your-api-key` with your project endpoint token and API key from [Crynux AS](https://crynux-as.xyz).
{% endhint %}

## JSON Object vs JSON Schema

| Mode | Request field | Behavior |
| --- | --- | --- |
| JSON Object | Chat: `response_format={"type":"json_object"}`<br>Responses: `text.format={"type":"json_object"}` | Constrains generation to a top-level JSON object. It does not enforce a specific schema. |
| JSON Schema | Chat: `response_format={"type":"json_schema","json_schema":{...}}`<br>Responses: `text.format={"type":"json_schema",...}` | Constrains generation to the supplied JSON Schema. |

`/completions` does not support structured output.

JSON Schema limits:

* Maximum 65,536 UTF-8 bytes
* Maximum nesting depth 32
* Maximum 1,024 properties

If both an active tool constraint and `response_format` / `text.format` are present, the tool constraint takes precedence and structured output is ignored. Prefer one approach at a time.

## Chat Completions with the OpenAI SDK

{% tabs %}
{% tab title="JSON Object" %}
```python
from openai import OpenAI

client = OpenAI(
    base_url="https://api.crynux-as.xyz/api/<endpoint_token>/v1",
    api_key="your-api-key",
)

completion = client.chat.completions.create(
    model="Qwen/Qwen3.5-9B",
    messages=[
        {
            "role": "user",
            "content": "Return a JSON object with fields name and age for Alice, age 30.",
        }
    ],
    response_format={"type": "json_object"},
    extra_body={"vram_limit": 24},
)

print(completion.choices[0].message.content)
# {"name":"Alice","age":30}
```
{% endtab %}

{% tab title="JSON Schema" %}
```python
from openai import OpenAI

client = OpenAI(
    base_url="https://api.crynux-as.xyz/api/<endpoint_token>/v1",
    api_key="your-api-key",
)

completion = client.chat.completions.create(
    model="Qwen/Qwen3.5-9B",
    messages=[
        {
            "role": "user",
            "content": "Alice and Bob are going to a Science Fair on 2024-05-10.",
        }
    ],
    response_format={
        "type": "json_schema",
        "json_schema": {
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
        },
    },
    extra_body={"vram_limit": 24},
)

print(completion.choices[0].message.content)
```
{% endtab %}
{% endtabs %}

In the JSON Schema request, `name` is required for request compatibility. Generation uses the `schema` object. `description` and `strict` are accepted, but they do not change the Crynux generation constraint.

## Responses API with `text.format`

Responses uses a flat JSON Schema shape under `text.format`:

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

For background create-and-poll and conversation continuation, see [Responses API](responses-api.md).

## LangChain

`langchain-crynux` and `langchain-openai` both work with Crynux AS. `ChatCrynux.with_structured_output()` defaults to `method="function_calling"`, which implements structured output through a forced tool call. You can also use native JSON Schema through `method="json_schema"`.

{% tabs %}
{% tab title="LangChain-Crynux" %}
```python
from langchain_crynux import ChatCrynux
from pydantic import BaseModel, Field

class CalendarEvent(BaseModel):
    name: str = Field(description="The name of the event")
    date: str = Field(description="The date of the event, in YYYY-MM-DD format")
    participants: list[str] = Field(description="List of people participating")

llm = ChatCrynux(
    base_url="https://api.crynux-as.xyz/api/<endpoint_token>/v1",
    model="Qwen/Qwen3.5-9B",
    vram_limit=24,
    api_key="your-api-key",
)

# Defaults to method="function_calling"
structured_llm = llm.with_structured_output(CalendarEvent)

result = structured_llm.invoke(
    "Alice and Bob are going to a Science Fair on Friday, 2024-05-10."
)
print(result)
```
{% endtab %}

{% tab title="LangChain-OpenAI JSON Schema" %}
```python
from langchain_openai import ChatOpenAI
from pydantic import BaseModel, Field

class CalendarEvent(BaseModel):
    name: str = Field(description="The name of the event")
    date: str = Field(description="The date of the event, in YYYY-MM-DD format")
    participants: list[str] = Field(description="List of people participating")

llm = ChatOpenAI(
    base_url="https://api.crynux-as.xyz/api/<endpoint_token>/v1",
    api_key="your-api-key",
    model="Qwen/Qwen3.5-9B",
    model_kwargs={"vram_limit": 24},
)

structured_llm = llm.with_structured_output(CalendarEvent, method="json_schema")

result = structured_llm.invoke(
    "Meeting with Charlie about the project launch on Oct 15th, 2024."
)
print(result)
```
{% endtab %}
{% endtabs %}

## Raw Task API

The Raw Task API also accepts `response_format` inside `GPTTaskArgs`. Download results remain the gpt-task raw response: the JSON is still a string in `choices[].message.content`, and Crynux AS does not parse it into an object. Prefer the OpenAI-compatible APIs above unless you need Raw Task lifecycle control. See [Text-to-Text Task](../execute-tasks/text-to-text-task.md).
