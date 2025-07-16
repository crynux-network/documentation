---
description: How to Start a Crynux Bridge Locally
---

# Crynux Bridge

Crynux Bridge is middleware that connects traditional applications to the Crynux Network. It simplifies using the Crynux Network for applications by handling all complex interactions with the Crynux Network. The application only needs to interact with the Crynux Bridge by sending task parameters and waiting for the result images or texts.

More specifically, the Crynux Bridge:

1. Manages the application wallet, signs the underlying transactions and API requests.
2. Interacts with the blockchain and Relay to execute the entire task workflow.
3. Provides simpler APIs to the application to execute tasks using only the task parameters(no blockchain transactions or signatures).

Check out this simple webpage that lets users create images from text prompts. Tasks are sent to the Crynux Bridge API, and the generated image is returned:

{% embed url="https://codepen.io/Luke-Weber/pen/ExBqGrK" %}

And the following webpage that implements a chatbot using the OpenAI-compliant LLM API:

{% embed url="https://codepen.io/0x-Berry/pen/raaorYP" %}

## Features

### OpenAI-Compliant APIs for LLM text generation

The Crynux Bridge provides OpenAI-compliant LLM APIs that support both chat completions and text completions. These APIs allow you to interact with various Large Language Models (LLMs) in a conversational manner.

#### Chat Completions API

The chat completions API (`/v1/llm/chat/completions`) supports the following key parameters:

* `model`: The model to use (e.g., "Qwen/Qwen2.5-7B")
* `messages`: An array of message objects with `role` and `content`
* `temperature`: Controls randomness in the output (range: 0.0 to 2.0)
* `max_tokens`: Maximum number of tokens to generate
* `top_p`: Nucleus sampling parameter (range: 0.0 to 1.0)
* `top_k`: Top-k sampling parameter (range: 1 to Infinity)
* `min_p`: Minimum probability threshold (range: 0.0 to 1.0)
* `repetition_penalty`: Penalty for repeating tokens (range: 0.0 to 2.0)
* `frequency_penalty`: Penalty for frequent tokens (range: -2.0 to 2.0)
* `presence_penalty`: Penalty for token presence (range: -2.0 to 2.0)
* `seed`: Seed for deterministic outputs
* `n`: Number of completions to generate (default: 1)
* `stream`: Whether to stream the response (default: false)
* `stop`: Array of strings that stop generation when encountered

#### Text Completions API

The text completions API (`/v1/llm/completions`) provides a simpler interface for non-chat use cases. It's ideal for tasks like text completion, summarization, or single-turn text generation. The API supports the following key parameters:

* `model`: The model to use (e.g., "Qwen/Qwen2.5-7B")
* `prompt`: The text prompt to generate a completion for
* `temperature`: Controls randomness in the output (range: 0.0 to 2.0)
* `max_tokens`: Maximum number of tokens to generate
* `top_p`: Nucleus sampling parameter (range: 0.0 to 1.0)
* `top_k`: Top-k sampling parameter (range: 1 to Infinity)
* `min_p`: Minimum probability threshold (range: 0.0 to 1.0)
* `repetition_penalty`: Penalty for repeating tokens (range: 0.0 to 2.0)
* `frequency_penalty`: Penalty for frequent tokens (range: -2.0 to 2.0)
* `presence_penalty`: Penalty for token presence (range: -2.0 to 2.0)
* `seed`: Seed for deterministic outputs
* `n`: Number of completions to generate (default: 1)
* `stream`: Whether to stream the response (default: false)
* `stop`: Array of strings that stop generation when encountered

### Image Generation APIs

The Crynux Bridge provides an OpenAI-compatible image generation API that uses Stable Diffusion models. The API (`/v1/sd/images/generations`) supports the following key parameters:

* `model`: The model to use (default: "crynux-network/sdxl-turbo")
* `prompt`: Text description of the desired image
* `n`: Number of images to generate (default: 1)
* `size`: Image dimensions (default: "512x512", options: "256x256", "512x512", "1024x1024")
* `response_format`: Response format (default: "b64\_json")
* `output_format`: Image format (default: "png")

The response includes:

* `created`: Timestamp of when the image was generated
* `data`: Array of generated images, each containing:
  * `b64_json`: Base64-encoded image data
  * `url`: URL to the generated image (if response\_format is "url")
  * `revised_prompt`: The prompt after any automatic modifications
* `usage`: Token usage statistics

### Multi-user Support and Role-Based Access Control

The Crynux Bridge is designed to support multiple users, enabling seamless collaboration and improved management of access to both the image generation and LLM APIs. With Role-Based Access Control (RBAC), administrators can define specific roles with varying permissions, ensuring that each user can only access those features necessary for their tasks.

## Start a Crynux Bridge Locally

### 1. Get the Docker Compose files

The Docker Compose files are located in the `build` folder of the Crynux Bridge project:

{% embed url="https://github.com/crynux-network/crynux-bridge/tree/main/build" %}

Download the folder to the deployment server, or clone the whole project:

```sh
$ git clone https://github.com/crynux-network/crynux-bridge.git
$ cd build
```

### 2. Application wallet configuration

The application wallet's private key will be loaded from a file in the build folder and stored as Docker secrets. For security, this file can be deleted once the container is created. Ensure to back up the private key, as it will be required again if the container needs to be recreated.

Create a file named `privkey.txt` and paste the private key into the file. The private key should be a hex string prefixed with `0x`.

```sh
# Inside the build folder

$ cat "0xabcd...23cd" >> privkey.txt
```

### 3. Database configuration

Crynux Bridge relies on a database to store data. A MySQL instance is configured in the Docker Compose file by default.

If the default configuration meets your needs, no further action is required. If you need to use another database instance, remove the service section of MySQL in the `docker-compose.yml` file, and modify `config/config.yml` to use another database instance:

```yaml
# config/config.yml

db:
  driver: "mysql"
  connection: "crynux_bridge:crynuxbridgepass@(mysql:3306)/crynux_bridge?parseTime=true"
  log:
    level: "info"
    output: "/app/data/logs/crynux_bridge_db.log"
    max_file_size: 100
    max_days: 30
    max_file_num: 5
```

### 4. Start the Docker container

In the build folder, run the following command to start the containers:

```sh
# Inside the build folder

$ docker compose up -d
```

### 5. API keys and rate limits configuration

Once the Docker container is started, find the correct IP address of the Docker container. It is either `127.0.0.1`, or an IP address on your Docker network.

Open the following URL in your web browser:

{% embed url="https://crynux-network.github.io/crynux-bridge/examples/access-key-generation.html" %}

You should see a webpage like this:

<figure><img src="../.gitbook/assets/01218c22d23c768e6c1603307e52a93.png" alt=""><figcaption></figcaption></figure>

Enter your local Crynux Bridge IP address and port (default is 5028), along with the private key from step 2. Choose the role and set limits as needed. Click "Create Access Token" to generate and display the token on the page.

### 6. Use the APIs

Once you have created and configured your API key, you can start using the APIs. Here are examples for both LLM and SD APIs:

#### **Use the LLM API**

{% tabs %}
{% tab title="Python" %}
```python
import requests
import json

# API configuration
API_URL = "https://bridge.crynux.io/v1/llm/chat/completions"
API_KEY = "your-api-key-here"  # Replace with your API key

# Request headers
headers = {
    "Authorization": f"Bearer {API_KEY}",
    "Content-Type": "application/json"
}

# Request payload
payload = {
    "model": "Qwen/Qwen2.5-7B",
    "messages": [
        {
            "role": "user",
            "content": "What is the capital of France?"
        }
    ],
    "stream": False
}

# Make the request
response = requests.post(
    API_URL,
    headers=headers,
    json=payload,
    timeout=180
)

# Print the response
print(response.json())
```
{% endtab %}

{% tab title="JavaScript" %}
```javascript
async function getChatCompletion() {
    try {
        const API_URL = "https://bridge.crynux.io/v1/llm/chat/completions";
        const API_KEY = "your-api-key-here";  // Replace with your API key

        const response = await fetch(API_URL, {
            method: "POST",
            headers: {
                "Authorization": `Bearer ${API_KEY}`,
                "Content-Type": "application/json"
            },
            body: JSON.stringify({
                model: "Qwen/Qwen2.5-7B",
                messages: [
                    {
                        role: "user",
                        content: "What is the capital of France?"
                    }
                ],
                stream: false
            })
        });

        const data = await response.json();
        console.log(data);
    } catch (error) {
        console.error("Error:", error);
    }
}

getChatCompletion();
```
{% endtab %}
{% endtabs %}

#### **Use the image generation API**

{% tabs %}
{% tab title="Python" %}
```python
import requests
import json

# API configuration
API_URL = "https://bridge.crynux.io/v1/sd/images/generations"
API_KEY = "your-api-key-here"  # Replace with your API key

# Request headers
headers = {
    "Authorization": f"Bearer {API_KEY}",
    "Content-Type": "application/json"
}

# Request payload
payload = {
    "model": "crynux-network/sdxl-turbo",
    "prompt": "a beautiful landscape",
    "n": 1,
    "size": "512x512"
}

# Make the request
response = requests.post(
    API_URL,
    headers=headers,
    json=payload,
    timeout=180
)

# Print the response
print(response.json())
```
{% endtab %}

{% tab title="JavaScript" %}
```javascript
async function generateImage() {
    try {
        const API_URL = "https://bridge.crynux.io/v1/sd/images/generations";
        const API_KEY = "your-api-key-here"; // Replace with your API key

        const response = await fetch(API_URL, {
            method: "POST",
            headers: {
                "Authorization": `Bearer ${API_KEY}`,
                "Content-Type": "application/json"
            },
            body: JSON.stringify({
                model: "crynux-network/sdxl-turbo",
                prompt: "A beautiful sunset over a calm ocean",
                n: 1,
                size: "512x512"
            })
        });

        const data = await response.json();
        console.log(data);
    } catch (error) {
        console.error("Error:", error);
    }
}

generateImage();
```
{% endtab %}
{% endtabs %}

## API List

The description of the APIs can be accessed as the OpenAPI Specification on the started Crynux Bridge instance. Assume the IP address of the instance is 192.168.1.2, the JSON schema of the specification can be accessed at:

```
http://192.168.1.2/openapi.json
```

And a human readable documentation can be accessed at:

```
http://192.168.1.2/static/api_docs.html
```

As an example, the URLs of the Crynux Bridge used by the showcase applications online are:

{% embed url="https://api_ig.crynux.ai/openapi.json" %}

{% embed url="https://api_ig.crynux.ai/static/api_docs.html" %}
