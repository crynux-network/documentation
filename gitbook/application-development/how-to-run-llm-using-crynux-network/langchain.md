# LangChain & LangGraph

The Crynux Bridge provides an OpenAI-compatible API, making it seamless to integrate with [LangChain](https://www.langchain.com/) and [LangGraph](https://langchain-ai.github.io/langgraph/). You can use Crynux Bridge API as a drop-in replacement for OpenAI API in your AI applications.

There are two ways to use Crynux with LangChain:
1.  **Using `langchain-crynux`**: A dedicated package optimized for Crynux.
2.  **Using `langchain-openai`**: The standard OpenAI integration package.

## Method 1: Using `langchain-crynux` (Recommended)

The `langchain-crynux` package is a drop-in replacement for `ChatOpenAI` that is specifically tuned for the Crynux Network. It provides first-class support for Crynux-specific parameters like `vram_limit`.

### Installation

```bash
pip install langchain-crynux
```

### Usage

```python
import os
from langchain_crynux import ChatCrynux

# You can set the API key in the environment variable
# os.environ["OPENAI_API_KEY"] = "your-api-key"

chat = ChatCrynux(
    base_url="https://bridge.crynux.io/v1/llm",
    model="Qwen/Qwen3.5-9B",
    vram_limit=24,  # Specify the required VRAM in GB
    # api_key="your-api-key", # Or pass it directly
)

response = chat.invoke("Hello, introduce yourself.")
print(response.content)
```

The `vram_limit` parameter is essential for the Crynux Network to route your task to a node with sufficient GPU memory. The default is 24GB.

## Method 2: Using `langchain-openai`

Since the Crynux Bridge is fully compatible with the OpenAI API, you can also use the standard `langchain-openai` library. This is useful if you already have an existing project using LangChain's OpenAI integration.

### Installation

```bash
pip install langchain-openai
```

### Usage

To use `ChatOpenAI` with Crynux, you simply need to override the `base_url` and pass Crynux-specific parameters via `model_kwargs`.

```python
from langchain_openai import ChatOpenAI

llm = ChatOpenAI(
    base_url="https://bridge.crynux.io/v1/llm",
    api_key="your-api-key", # Use a real key or a dummy one for local bridges
    model="Qwen/Qwen3.5-9B",
    temperature=0.7,
    # Pass Crynux-specific parameters in model_kwargs
    model_kwargs={
        "vram_limit": 24
    }
)

messages = [
    ("system", "You are a helpful assistant."),
    ("human", "What is the capital of France?"),
]

ai_msg = llm.invoke(messages)
print(ai_msg.content)
```

## Using with LangGraph

Both methods above return a standard LangChain Runnable, which can be directly used in LangGraph workflows. Here is a simple example of a LangGraph agent using a Crynux model.

### Installation

```bash
pip install langgraph langchain-crynux
```

### Example

```python
from typing import Annotated, TypedDict
from langgraph.graph import StateGraph, END
from langchain_crynux import ChatCrynux

# 1. Define the State
class State(TypedDict):
    messages: list

# 2. Initialize the Model
model = ChatCrynux(
    base_url="https://bridge.crynux.io/v1/llm",
    model="Qwen/Qwen3.5-9B",
    vram_limit=24,
    api_key="your-api-key"
)

# 3. Define the Nodes
def chatbot(state: State):
    return {"messages": [model.invoke(state["messages"])]}

# 4. Build the Graph
graph_builder = StateGraph(State)
graph_builder.add_node("chatbot", chatbot)
graph_builder.set_entry_point("chatbot")
graph_builder.add_edge("chatbot", END)

graph = graph_builder.compile()

# 5. Run the Graph
response = graph.invoke({"messages": [("user", "Tell me a joke about AI.")]})
print(response["messages"][-1].content)
```
