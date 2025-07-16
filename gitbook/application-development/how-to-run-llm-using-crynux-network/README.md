# How to Run LLM using Crynux Network

Running LLM tasks with various open-source models can be as simple as calling an OpenAI-compliant API via the Crynux Network. The example below demonstrates how to send an LLM chat completion task to the Crynux Network using the official OpenAI SDK:

{% tabs %}
{% tab title="Python" %}
```python
from openai import OpenAI

client = OpenAI(
    base_url="https://bridge.crynux.io/v1/llm",
    api_key="q3hXHA_8O0LuGJ1_tou4_KamMlQqAo-aYwyAIDttdmI=", # For public demonstration only, strict rate limit applied.
    timeout=180,
    max_retries=1,
)

res = client.chat.completions.create(
    model="Qwen/Qwen2.5-7B",
    messages=[
        {
            "role": "user",
            "content": "What is the capital of France?",
        },
    ],
    stream=False
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
  timeout: 180000,
  maxRetries: 1,
});

async function main() {
  try {
    const chatCompletion = await client.chat.completions.create({
      model: "Qwen/Qwen2.5-7B",
      messages: [
        {
          role: "user",
          content: "What is the capital of France?",
        },
      ],
      stream: false,
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

{% embed url="https://codepen.io/0x-Berry/pen/raaorYP" %}

The API, provided by the official Crynux Bridge, supports both OpenAI-compliant `/completions` and `/chat/completions` endpoints. Features like streaming, tool-calling, and numerous other configuration options are also supported. For a comprehensive list of supported features, please refer to the[ Crynux Bridge documentation](../crynux-bridge.md).

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
