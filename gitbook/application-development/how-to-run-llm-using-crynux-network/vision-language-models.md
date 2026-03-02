# Vision Language Models (VLM)

The Crynux Network supports Vision Language Models (VLM) through the same OpenAI-compatible API. You can send images along with text prompts to these models to perform tasks like image captioning, visual question answering, and more.

## Usage

To use a VLM, you need to construct the `messages` payload with both text and image content. The image should be provided as a base64-encoded string within a data URL.

{% hint style="info" %}
**Note**: Currently, the Crynux Network only supports passing images as base64-encoded data URLs (e.g., `data:image/jpeg;base64,...`). Passing images via HTTP/HTTPS URLs is not supported.
{% endhint %}

{% tabs %}
{% tab title="Python" %}
```python
import base64
from openai import OpenAI

# Function to encode the image
def encode_image(image_path):
  with open(image_path, "rb") as image_file:
    return base64.b64encode(image_file.read()).decode('utf-8')

# Path to your image
image_path = "path/to/your/image.jpg"

# Getting the base64 string
base64_image = encode_image(image_path)

client = OpenAI(
    base_url="https://bridge.crynux.io/v1/llm",
    api_key="YOUR_API_KEY", # Replace with your actual API key
    timeout=60,
    max_retries=1,
)

response = client.chat.completions.create(
    model="Qwen/Qwen2.5-VL-3B-Instruct",
    messages=[
        {
            "role": "user",
            "content": [
                {
                    "type": "text",
                    "text": "What is in this image?",
                },
                {
                    "type": "image_url",
                    "image_url": {
                        "url": f"data:image/jpeg;base64,{base64_image}"
                    },
                },
            ],
        }
    ],
    max_tokens=300,
    extra_body={
        "vram_limit": 24, # Ensure the node has enough VRAM
    }
)

print(response.choices[0].message.content)
```
{% endtab %}

{% tab title="JavaScript" %}
```javascript
import fs from 'fs';
import OpenAI from "openai";

const openai = new OpenAI({
  baseURL: "https://bridge.crynux.io/v1/llm",
  apiKey: "YOUR_API_KEY", // Replace with your actual API key
  timeout: 60000,
  maxRetries: 1,
});

// Function to encode the image
function encodeImage(imagePath) {
  const image = fs.readFileSync(imagePath);
  return Buffer.from(image).toString('base64');
}

const imagePath = "path/to/your/image.jpg";
const base64Image = encodeImage(imagePath);

async function main() {
  const response = await openai.chat.completions.create({
    model: "Qwen/Qwen2.5-VL-3B-Instruct",
    messages: [
      {
        role: "user",
        content: [
          { type: "text", text: "What is in this image?" },
          {
            type: "image_url",
            image_url: {
              "url": `data:image/jpeg;base64,${base64Image}`,
            },
          },
        ],
      },
    ],
    max_tokens: 300,
    vram_limit: 24, // Ensure the node has enough VRAM
  });

  console.log(response.choices[0].message.content);
}

main();
```
{% endtab %}
{% endtabs %}

## VRAM Requirement

Just like with text-only models, you should specify the `vram_limit` in the `extra_body` (Python) or directly in the options (JavaScript) to ensure the task is routed to a node with sufficient GPU memory. For the models listed above, a `vram_limit` of `24` GB is generally sufficient.
