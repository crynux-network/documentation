# Structured Output

While obtaining unstructured text responses is useful, building reliable AI applications often requires structured data (like JSON) to interface with other systems.

## The Challenge with Open Source Models

OpenAI's official API offers native "JSON Mode" and "Structured Outputs" (via `response_format`), which guarantee that the output matches a specific JSON schema.

However, **most open-source models and OpenAI-compatible APIs do not fully support these native strict modes**. If you simply ask an open-source model to "output JSON", it might:

* Add conversational text before or after the JSON.
* Make syntax errors (missing brackets, trailing commas).
* Hallucinate keys that aren't in your schema.

## The Solution: Simulating via Tool Use

Fortunately, we can reliably achieve structured output by leveraging [**Tool Use (Function Calling)**](tool-use.md).

Since models like `Qwen2.5-7B-Instruct` are fine-tuned to generate valid JSON arguments for tool calls, we can "trick" the model into generating structured data by:

1. Defining a "tool" whose parameters match our desired output schema.
2. Forcing the model to "call" this tool.
3. Parsing the arguments of the tool call as our final output.

**LangChain** makes this pattern extremely easy with the `.with_structured_output()` method. It automatically handles the schema conversion, tool binding, and output parsing for you.

## Examples

The following examples show how to extract a structured `CalendarEvent` object from natural language using the Crynux Network.

{% hint style="info" %}
**Model Selection**: Ensure you use an **Instruct** model (e.g., `Qwen/Qwen2.5-7B-Instruct`) that supports tool calling. Base models usually cannot handle this reliably.
{% endhint %}

{% tabs %}
{% tab title="LangChain-Crynux" %}
The `langchain-crynux` package supports `with_structured_output` out of the box. It defaults to using **Tool Use** (method="function\_calling") to ensure compatibility with open-source models on the Crynux Network.

```python
from langchain_crynux import ChatCrynux
from pydantic import BaseModel, Field

# 1. Define your desired output structure using Pydantic
class CalendarEvent(BaseModel):
    name: str = Field(description="The name of the event")
    date: str = Field(description="The date of the event, in YYYY-MM-DD format")
    participants: list[str] = Field(description="List of people participating")

# 2. Initialize the model
llm = ChatCrynux(
    base_url="https://bridge.crynux.io/v1/llm",
    model="Qwen/Qwen2.5-7B-Instruct",
    vram_limit=24,
    api_key="your-api-key"
)

# 3. Configure structured output
# This automatically converts the Pydantic model to a tool definition
# and configures the LLM to use it.
structured_llm = llm.with_structured_output(CalendarEvent)

# 4. Invoke with natural language
text = "Alice and Bob are going to a Science Fair on Friday, 2024-05-10."
result = structured_llm.invoke(text)

# 5. The result is an instance of your Pydantic model
print(f"Event: {result.name}")
print(f"Date: {result.date}")
print(f"Participants: {result.participants}")
# Output:
# Event: Science Fair
# Date: 2024-05-10
# Participants: ['Alice', 'Bob']
```
{% endtab %}

{% tab title="LangChain-OpenAI" %}
You can also use the standard `langchain-openai` library. Under the hood, it uses the OpenAI tool calling API provided by Crynux Bridge.

```python
from langchain_openai import ChatOpenAI
from pydantic import BaseModel, Field

# 1. Define your desired output structure
class CalendarEvent(BaseModel):
    name: str = Field(description="The name of the event")
    date: str = Field(description="The date of the event, in YYYY-MM-DD format")
    participants: list[str] = Field(description="List of people participating")

# 2. Initialize the model
llm = ChatOpenAI(
    base_url="https://bridge.crynux.io/v1/llm",
    api_key="your-api-key",
    model="Qwen/Qwen2.5-7B-Instruct",
    model_kwargs={"vram_limit": 24}
)

# 3. Configure structured output
# We explicitly set method="function_calling" to ensure it uses tool calls
# rather than trying to use native 'json_mode' which might not be supported.
structured_llm = llm.with_structured_output(CalendarEvent, method="function_calling")

# 4. Invoke
text = "Meeting with Charlie about the project launch on Oct 15th, 2024."
result = structured_llm.invoke(text)

print(result)
# Output:
# name='Project Launch Meeting' date='2024-10-15' participants=['Charlie']
```
{% endtab %}
{% endtabs %}
