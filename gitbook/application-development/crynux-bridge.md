---
description: How to Start a Crynux Bridge Locally
---

# Crynux Bridge

Crynux Bridge is middleware that connects applications to the Crynux Network. It owns the application wallet, signs Relay and blockchain requests, runs the full task lifecycle, and exposes asynchronous Raw Task and Batch Task HTTP APIs. The application sends task parameters and polls for results; it does not sign Relay requests or submit on-chain transactions itself.

{% hint style="info" %}
Self-hosting Crynux Bridge is an advanced option. For most applications, [Crynux AS](https://crynux-as.xyz) is easier: it manages Credits, project API keys, and pricing, and it provides OpenAI-compatible LLM and Image APIs as well as an AS-facing Raw Task API. Prefer [Crynux AS](https://crynux-as.xyz) unless you need to run your own Bridge and control wallet, fees, and task lifecycle directly.
{% endhint %}

## Features

1. **Automatic VSS task validation** — When VRF selects multi-node validation for a task, Bridge creates the extra validation members, waits until the group is ready, and submits single-task or group validation to Relay. The application only creates the task and polls for the result; it does not implement validation-group logic.
2. **Repeat tasks for higher success rate and faster completion** — Bridge can run multiple concurrent primary submissions for one logical task (`task.repeat_num` in Bridge config). The first successful result wins. This is Bridge configuration, not an API parameter.
3. **Wallet and Relay fee management** — Bridge loads the application wallet and signs Relay and chain operations on its behalf.
4. **Raw Task API and Batch Task API** — Create one task or up to 100 tasks per request, poll status (including batch status), and download image PNG or LLM JSON results.
5. **Multi-user support and Role-Based Access Control (RBAC)** — API keys with roles, use quotas, and rate limits so multiple clients can share one Bridge instance with controlled access.

## Prefer Crynux AS for most applications

Deploying your own Bridge means operating Docker, a database, a funded application wallet / Relay Account, API keys, and Bridge configuration (including optional repeat tasks). That is more complex than using the hosted [Crynux AS](https://crynux-as.xyz) service.

Use [Crynux AS](https://crynux-as.xyz) when you want:

* OpenAI-compatible Chat Completions, Completions, Responses, and Image APIs
* Credits-based billing and project Cost Level without setting `task_fee` yourself
* A managed Raw Task API under `/api/<endpoint_token>/v1/inference_tasks`

Use a self-hosted Bridge when you need direct control over the wallet, Relay fees, repeat-task settings, or the Bridge Raw / Batch APIs without going through Crynux AS.

For OpenAI-compatible usage, see:

{% content-ref url="how-to-run-llm-using-crynux-network/README.md" %}
[How to Run LLM using Crynux Network](how-to-run-llm-using-crynux-network/README.md)
{% endcontent-ref %}

{% content-ref url="openai-compatible-image-api.md" %}
[OpenAI-Compatible Image API](openai-compatible-image-api.md)
{% endcontent-ref %}

## Raw Task API and Batch Task API

Bridge exposes asynchronous task APIs under `/v1`. Authenticate with `Authorization: Bearer <api_key>`.

| Operation | Method and path |
| --- | --- |
| Create one task | `POST /v1/inference_tasks` |
| Create up to 100 tasks | `POST /v1/inference_tasks/batch` |
| Get status | `GET /v1/inference_tasks/<client_task_id>` |
| Batch status | `POST /v1/inference_tasks/batch/status` |
| Download image PNG | `GET /v1/inference_tasks/<client_task_id>/images/<index>` |
| Download LLM JSON | `GET /v1/inference_tasks/<client_task_id>/llm` |

### Create fields

| Field | Required | Notes |
| --- | --- | --- |
| `task_type` | Yes | `0` Image (SD), `1` LLM |
| `task_args` | Yes | JSON **string** of `ImageTaskArgs` or `GPTTaskArgs` |
| `task_fee` | Yes | Final task fee in Wei as a decimal string |
| `min_vram` | No | Minimum GPU VRAM in GB |
| `required_gpu` + `required_gpu_vram` | No | Exact GPU selection; provide both together |
| `queue_timeout` | No | Queue wait budget in seconds for ordinary Image and LLM tasks |

Create returns immediately with a client task `id` and `phase` `queued`. Poll until `status` is `success` or `failed`, then download the result.

Task argument schemas are documented in:

{% content-ref url="execute-tasks/text-to-image-task.md" %}
[Text-to-Image Task](execute-tasks/text-to-image-task.md)
{% endcontent-ref %}

{% content-ref url="execute-tasks/text-to-text-task.md" %}
[Text-to-Text Task](execute-tasks/text-to-text-task.md)
{% endcontent-ref %}

### Create, poll, and download

{% tabs %}
{% tab title="Python" %}
```python
import json
import time
import requests

BASE = "http://127.0.0.1:5028/v1"
HEADERS = {
    "Authorization": "Bearer your-api-key",
    "Content-Type": "application/json",
}

task_args = {
    "version": "3.7.1",
    "model": "Qwen/Qwen2.5-7B-Instruct",
    "messages": [
        {"role": "user", "content": "What is the capital of France?"}
    ],
    "generation_config": {
        "max_new_tokens": 128,
        "temperature": 0.7,
        "top_p": 0.9,
    },
    "dtype": "auto",
}

create = requests.post(
    f"{BASE}/inference_tasks",
    headers=HEADERS,
    json={
        "task_type": 1,
        "task_args": json.dumps(task_args),
        "task_fee": "1000000000000000000",
        "min_vram": 24,
        "queue_timeout": 3600,
    },
    timeout=60,
)
create.raise_for_status()
task_id = create.json()["data"]["id"]
print("created", task_id)

while True:
    status = requests.get(
        f"{BASE}/inference_tasks/{task_id}",
        headers=HEADERS,
        timeout=60,
    )
    status.raise_for_status()
    data = status.json()["data"]
    print(data["status"], data["phase"])
    if data["status"] in ("success", "failed"):
        break
    time.sleep(5)

if data["status"] != "success":
    raise RuntimeError(data.get("error_message") or "task failed")

result = requests.get(
    f"{BASE}/inference_tasks/{task_id}/llm",
    headers=HEADERS,
    timeout=120,
)
result.raise_for_status()
print(result.json())
```
{% endtab %}

{% tab title="JavaScript" %}
```javascript
const BASE = "http://127.0.0.1:5028/v1";
const HEADERS = {
  Authorization: "Bearer your-api-key",
  "Content-Type": "application/json",
};

const taskArgs = {
  version: "3.7.1",
  model: "Qwen/Qwen2.5-7B-Instruct",
  messages: [{ role: "user", content: "What is the capital of France?" }],
  generation_config: {
    max_new_tokens: 128,
    temperature: 0.7,
    top_p: 0.9,
  },
  dtype: "auto",
};

async function sleep(ms) {
  await new Promise((resolve) => setTimeout(resolve, ms));
}

const createRes = await fetch(`${BASE}/inference_tasks`, {
  method: "POST",
  headers: HEADERS,
  body: JSON.stringify({
    task_type: 1,
    task_args: JSON.stringify(taskArgs),
    task_fee: "1000000000000000000",
    min_vram: 24,
    queue_timeout: 3600,
  }),
});
if (!createRes.ok) {
  throw new Error(await createRes.text());
}
const taskId = (await createRes.json()).data.id;
console.log("created", taskId);

let data;
for (;;) {
  const statusRes = await fetch(`${BASE}/inference_tasks/${taskId}`, {
    headers: { Authorization: HEADERS.Authorization },
  });
  if (!statusRes.ok) {
    throw new Error(await statusRes.text());
  }
  data = (await statusRes.json()).data;
  console.log(data.status, data.phase);
  if (data.status === "success" || data.status === "failed") {
    break;
  }
  await sleep(5000);
}

if (data.status !== "success") {
  throw new Error(data.error_message || "task failed");
}

const resultRes = await fetch(`${BASE}/inference_tasks/${taskId}/llm`, {
  headers: { Authorization: HEADERS.Authorization },
});
if (!resultRes.ok) {
  throw new Error(await resultRes.text());
}
console.log(await resultRes.json());
```
{% endtab %}
{% endtabs %}

### Batch create and batch status

{% tabs %}
{% tab title="Python" %}
```python
import json
import requests

BASE = "http://127.0.0.1:5028/v1"
HEADERS = {
    "Authorization": "Bearer your-api-key",
    "Content-Type": "application/json",
}

def make_task(prompt: str) -> dict:
    task_args = {
        "version": "3.7.1",
        "model": "Qwen/Qwen2.5-7B-Instruct",
        "messages": [{"role": "user", "content": prompt}],
        "generation_config": {"max_new_tokens": 64},
        "dtype": "auto",
    }
    return {
        "task_type": 1,
        "task_args": json.dumps(task_args),
        "task_fee": "1000000000000000000",
        "min_vram": 24,
        "queue_timeout": 43200,
    }

batch = requests.post(
    f"{BASE}/inference_tasks/batch",
    headers=HEADERS,
    json={
        "tasks": [
            make_task("Name one European capital."),
            make_task("Name one Asian capital."),
        ]
    },
    timeout=60,
)
batch.raise_for_status()
items = batch.json()["data"]
task_ids = [
    item["client_task"]["id"]
    for item in items
    if item.get("client_task") is not None
]

status = requests.post(
    f"{BASE}/inference_tasks/batch/status",
    headers=HEADERS,
    json={"client_task_ids": task_ids},
    timeout=60,
)
status.raise_for_status()
print(status.json())
```
{% endtab %}

{% tab title="JavaScript" %}
```javascript
const BASE = "http://127.0.0.1:5028/v1";
const HEADERS = {
  Authorization: "Bearer your-api-key",
  "Content-Type": "application/json",
};

function makeTask(prompt) {
  const taskArgs = {
    version: "3.7.1",
    model: "Qwen/Qwen2.5-7B-Instruct",
    messages: [{ role: "user", content: prompt }],
    generation_config: { max_new_tokens: 64 },
    dtype: "auto",
  };
  return {
    task_type: 1,
    task_args: JSON.stringify(taskArgs),
    task_fee: "1000000000000000000",
    min_vram: 24,
    queue_timeout: 43200,
  };
}

const batchRes = await fetch(`${BASE}/inference_tasks/batch`, {
  method: "POST",
  headers: HEADERS,
  body: JSON.stringify({
    tasks: [
      makeTask("Name one European capital."),
      makeTask("Name one Asian capital."),
    ],
  }),
});
if (!batchRes.ok) {
  throw new Error(await batchRes.text());
}
const items = (await batchRes.json()).data;
const taskIds = items
  .filter((item) => item.client_task != null)
  .map((item) => item.client_task.id);

const statusRes = await fetch(`${BASE}/inference_tasks/batch/status`, {
  method: "POST",
  headers: HEADERS,
  body: JSON.stringify({ client_task_ids: taskIds }),
});
if (!statusRes.ok) {
  throw new Error(await statusRes.text());
}
console.log(await statusRes.json());
```
{% endtab %}
{% endtabs %}

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

When Crynux Bridge runs tasks, Relay deducts task fees from the wallet's Relay Account balance instead of charging the wallet through on-chain transactions. The wallet is still required for Bridge startup and signing operations, but the wallet itself can have zero token balance as long as its corresponding Relay Account is funded in advance.

To deposit into the Relay Account before starting production traffic:

1. Open the [Crynux Portal](https://portal.crynux.io).
2. Connect the same wallet you will use as the Bridge application wallet.
3. Go to the wallet dashboard and locate the **Relay Account** section.
4. Click **Deposit**, enter the amount, and confirm the on-chain transaction in your wallet.

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

Use the Raw Task and Batch Task examples above with your Bridge base URL (for example `http://127.0.0.1:5028/v1`) and the API key from step 5.

## API List

The description of the APIs can be accessed as the OpenAPI Specification on the started Crynux Bridge instance. Assume the IP address of the instance is 192.168.1.2, the JSON schema of the specification can be accessed at:

```
http://192.168.1.2:5028/openapi.json
```

And a human readable documentation can be accessed at:

```
http://192.168.1.2:5028/static/api_docs.html
```
