# How to Fine-tune a Stable Diffusion Model using Crynux Network

Fine-tuning Stable Diffusion models on the Crynux Network involves creating a training task and monitoring its progress. Unlike inference tasks, fine-tuning is a long-running process that requires asynchronously creating the task, tracking the task status and downloading results upon completion.

## Fine-tuning Task Execution Process

Before diving into the code examples, let's understand the complete workflow for fine-tuning a Stable Diffusion model on the Crynux Network. The process consists of four main steps:

### 1. Dataset Preparation

The first step is to prepare your training dataset. Crynux Network supports many types of dataset sources:

* **Huggingface Dataset**: You can use any dataset available on [Huggingface](https://huggingface.co/) by specifying its dataset ID (e.g., `"lambdalabs/naruto-blip-captions"`).
* **Irys Network**: The dataset can be stored on the decentralized data network of [Irys](https://irys.xyz/). And provided to the Crynux nodes as a download link.
* **Custom Dataset via URL**: Other downloadable links are also supported. The file can be compressed (ZIP, TAR, etc.) and will be automatically extracted and loaded using the Huggingface dataset library.

Your dataset should contain image-caption pairs, with images in one column and corresponding text captions in another column. The default column names are `"image"` for images and `"text"` for captions, you can also customize these in the task config.

### 2. Model Selection

Fine-tuning tasks create LoRA (Low-Rank Adaptation) models that enhance existing Stable Diffusion models. You need to specify:

* **Base Model**: Choose a pre-trained Stable Diffusion model (e.g., `"runwayml/stable-diffusion-v1-5"` or `"stabilityai/stable-diffusion-xl-base-1.0"`)
* **LoRA Parameters**: Configure how the LoRA adapter will be applied:
  * `rank`: The dimension of LoRA attention (typically 4-64)
  * `target_modules`: Which transformer modules to apply LoRA to (common choices include `["to_k", "to_q", "to_v", "to_out.0"]`)
  * `init_lora_weights`: How to initialize LoRA weights (`"gaussian"` is commonly used)

### 3. Training Parameter Configuration

Set the training hyperparameters that control the learning process:

* **Learning Rate**: The step size for gradient updates (typically 1e-4 to 1e-5)
* **Batch Size**: Number of samples processed together (usually 1-4 for fine-tuning)
* **Training Steps**: Total number of training iterations
* **Learning Rate Scheduler**: How the learning rate changes over time (e.g., `"cosine"` for gradual decay)
* **Image Resolution**: Target resolution for training images (typically 512 or 768)
* **Data Augmentation**: Whether to apply random flips, center crops, etc.

### 4. Task Execution

Once you have configured all parameters, submit the task to the Crynux Network:

1. **Create Task**: Send a POST request with your configuration to create the fine-tuning task
2. **Monitor Progress**: Poll the task status endpoint to track completion
3. **Download Results**: Once complete, download the fine-tuned LoRA model

The fine-tuned model will be returned as a ZIP file containing the LoRA weights that can be loaded into compatible Stable Diffusion inference pipelines.

## Code Examples

The example below demonstrates how to submit a fine-tuning task to the Crynux Network using HTTP requests:

{% tabs %}
{% tab title="Python" %}
```python
import time
import httpx

client = httpx.Client(
    base_url="https://bridge.crynux.io",
    timeout=180,
)

api_key = "q3hXHA_8O0LuGJ1_tou4_KamMlQqAo-aYwyAIDttdmI="  # For public demonstration only

# Fine-tuning configuration
data = {
    "model_name": "crynux-network/stable-diffusion-v1-5",
    "model_variant": "fp16",
    "dataset_url": "https://gateway.irys.xyz/GivF5FBMdJVr6xHT7hi2aE7vH55wVjrtKLpRc2E86icJ",
    "validation_num_images": 4,
    "learning_rate": 0.0001,
    "batch_size": 1,
    "num_train_steps": 100,
    "max_train_steps": 200,
    "lr_scheduler": "cosine",
    "lr_warmup_steps": 0,
    "rank": 4,
    "init_lora_weights": "gaussian",
    "target_modules": ["to_k", "to_q", "to_v", "to_out.0"],
    "center_crop": True,
    "random_flip": True,
    "mixed_precision": "fp16",
    "seed": 42,
    "timeout": 1800,
}

headers = {
    "Authorization": f"Bearer {api_key}",
}

# Step 1: Create fine-tuning task
resp = client.post(
    "/v1/images/models",
    json=data,
    headers=headers,
    timeout=180,
)
resp.raise_for_status()
res = resp.json()
task_id = res["data"]["id"]
print(f"Task ID: {task_id}")

# Step 2: Monitor task status
success = False
while True:
    resp = client.get(f"/v1/images/models/{task_id}/status")
    resp.raise_for_status()
    res = resp.json()
    status = res["data"]["status"]

    if status == "success":
        print("Task completed successfully")
        success = True
        break
    elif status == "failed":
        print("Task failed")
        success = False
        break
    elif status == "running":
        print("Task is still running...")

    time.sleep(60)  # Check status every minute

# Step 3: Download results if successful
if success:
    with client.stream(
        "GET",
        f"/v1/images/models/{task_id}/result",
        headers=headers,
        timeout=180,
    ) as resp:
        resp.raise_for_status()
        with open("finetuned_model.zip", "wb") as f:
            for chunk in resp.iter_bytes():
                f.write(chunk)
    print("Fine-tuned model downloaded as finetuned_model.zip")
```
{% endtab %}

{% tab title="JavaScript" %}
```javascript
import fetch from 'node-fetch';

const API_KEY = "q3hXHA_8O0LuGJ1_tou4_KamMlQqAo-aYwyAIDttdmI="; // For public demonstration only
const BASE_URL = "https://bridge.crynux.io";

async function finetuneStableDiffusion() {
    try {
        // Fine-tuning configuration
        const data = {
            model_name: "crynux-network/stable-diffusion-v1-5",
            model_variant: "fp16",
            dataset_url: "https://gateway.irys.xyz/GivF5FBMdJVr6xHT7hi2aE7vH55wVjrtKLpRc2E86icJ",
            validation_num_images: 4,
            learning_rate: 0.0001,
            batch_size: 1,
            num_train_steps: 100,
            max_train_steps: 200,
            lr_scheduler: "cosine",
            lr_warmup_steps: 0,
            rank: 4,
            init_lora_weights: "gaussian",
            target_modules: ["to_k", "to_q", "to_v", "to_out.0"],
            center_crop: true,
            random_flip: true,
            mixed_precision: "fp16",
            seed: 42,
            timeout: 1800,
        };

        const headers = {
            "Authorization": `Bearer ${API_KEY}`,
            "Content-Type": "application/json",
        };

        // Step 1: Create fine-tuning task
        const createResponse = await fetch(`${BASE_URL}/v1/images/models`, {
            method: "POST",
            headers: headers,
            body: JSON.stringify(data),
        });

        if (!createResponse.ok) {
            throw new Error(`Failed to create task: ${createResponse.statusText}`);
        }

        const createResult = await createResponse.json();
        const taskId = createResult.data.id;
        console.log(`Task ID: ${taskId}`);

        // Step 2: Monitor task status
        let success = false;
        while (true) {
            const statusResponse = await fetch(`${BASE_URL}/v1/images/models/${taskId}/status`);
            if (!statusResponse.ok) {
                throw new Error(`Failed to get status: ${statusResponse.statusText}`);
            }

            const statusResult = await statusResponse.json();
            const status = statusResult.data.status;

            if (status === "success") {
                console.log("Task completed successfully");
                success = true;
                break;
            } else if (status === "failed") {
                console.log("Task failed");
                success = false;
                break;
            } else if (status === "running") {
                console.log("Task is still running...");
            }

            // Wait 60 seconds before checking again
            await new Promise(resolve => setTimeout(resolve, 60000));
        }

        // Step 3: Download results if successful
        if (success) {
            const downloadResponse = await fetch(`${BASE_URL}/v1/images/models/${taskId}/result`, {
                headers: headers,
            });

            if (!downloadResponse.ok) {
                throw new Error(`Failed to download results: ${downloadResponse.statusText}`);
            }

            const fs = require('fs');
            const fileStream = fs.createWriteStream('finetuned_model.zip');
            downloadResponse.body.pipe(fileStream);

            return new Promise((resolve, reject) => {
                fileStream.on('finish', () => {
                    console.log("Fine-tuned model downloaded as finetuned_model.zip");
                    resolve();
                });
                fileStream.on('error', reject);
            });
        }
    } catch (error) {
        console.error("Error:", error);
    }
}

finetuneStableDiffusion();
```
{% endtab %}
{% endtabs %}

## Fine-tuning Process Overview

The fine-tuning process on Crynux Network consists of three main steps:

1. **Task Creation**: Submit a POST request to `/v1/images/models` with your fine-tuning configuration. This returns a task ID that you'll use to track progress.
2. **Status Monitoring**: Poll the `/v1/images/models/{task_id}/status` endpoint to check if the task has completed, failed, or is still running. Fine-tuning can take anywhere from minutes to hours depending on your configuration.
3. **Result Download**: Once the task succeeds, download the fine-tuned model using the `/v1/images/models/{task_id}/result` endpoint. The result is typically a ZIP file containing your fine-tuned model weights.

## Understanding the Task Execution Flow

When you submit a fine-tuning task, here's what happens behind the scenes:

### Task Distribution

Your fine-tuning task is distributed across multiple nodes in the Crynux Network. Each node receives the same task definition and executes it independently to ensure consensus.

### Training Execution

The training process follows these steps:

1. **Data Loading**: The dataset is downloaded and prepared according to your specifications
2. **Model Loading**: The base Stable Diffusion model is loaded with LoRA adapters applied
3. **Training Loop**: The model is trained for the specified number of steps using your hyperparameters
4. **Validation**: During training, validation images are generated to monitor progress
5. **Checkpointing**: Training checkpoints are saved periodically

### Result Generation

Upon completion, the task produces:

* **LoRA Weights**: The trained LoRA adapter weights that can be applied to the base model
* **Validation Images**: Sample images generated during training to assess model quality
* **Training Logs**: Information about the training process and metrics

### Using Your Fine-tuned Model

The downloaded ZIP file contains the LoRA weights that can be loaded into compatible Stable Diffusion pipelines. You can use these weights with the same base model to generate images with your custom style or subject matter.

## Key Configuration Parameters

The fine-tuning configuration includes various parameters that control the training process. Here are the most important parameters you'll need to configure:

### Dataset Parameters

* `dataset_url`: URL to download your custom dataset (or use `dataset_name` for Hugging Face datasets)
* `validation_num_images`: Number of validation images to generate during training

### Model Parameters

* `model_name`: The base Stable Diffusion model to fine-tune (e.g., `"runwayml/stable-diffusion-v1-5"`)
* `model_variant`: Model precision variant (`"fp16"`, `"bf16"`, or `null`)

### LoRA Parameters

* `rank`: LoRA attention dimension (typically 4-64, higher values = more capacity but larger file size)
* `target_modules`: Transformer modules to apply LoRA to (common: `["to_k", "to_q", "to_v", "to_out.0"]`)
* `init_lora_weights`: LoRA weight initialization method (`"gaussian"` recommended)

### Training Parameters

* `learning_rate`: Initial learning rate (typically 1e-4 to 1e-5)
* `batch_size`: Training batch size (usually 1-4 for fine-tuning)
* `num_train_steps`: Steps per task execution
* `max_train_steps`: Total training steps across all tasks
* `lr_scheduler`: Learning rate schedule (`"cosine"`, `"linear"`, etc.)
* `lr_warmup_steps`: Warmup steps for learning rate

### Data Processing Parameters

* `center_crop`: Whether to center crop images to resolution
* `random_flip`: Whether to randomly flip images horizontally
* `mixed_precision`: Training precision (`"fp16"` or `"bf16"`)

For a comprehensive list of all supported parameters and their detailed descriptions, please refer to the fine-tuning task's document:

{% content-ref url="execute-tasks/fine-tuning-task.md" %}
[fine-tuning-task.md](execute-tasks/fine-tuning-task.md)
{% endcontent-ref %}

## Best Practices for Fine-tuning

To achieve the best results with your fine-tuning tasks, consider these recommendations:

### Dataset Quality

* **Image Quality**: Use high-quality, consistent images (512x512 or higher resolution)
* **Caption Quality**: Write descriptive, accurate captions that capture the key features
* **Dataset Size**: Aim for 10-100 images per concept for good results
* **Diversity**: Include variations in poses, lighting, and backgrounds

### Model Selection

* **Base Model**: Choose a model that matches your target style (SD 1.5 for general use, SDXL for higher quality)
* **LoRA Rank**: Start with rank 4-8 for most use cases, increase to 16-32 for complex concepts
* **Target Modules**: Use the default `["to_k", "to_q", "to_v", "to_out.0"]` for most applications

### Training Parameters

* **Learning Rate**: Start with 1e-4, reduce to 1e-5 for sensitive concepts
* **Batch Size**: Use 1-2 for most cases to avoid memory issues
* **Training Steps**: 500-2000 steps usually sufficient, monitor validation images
* **Scheduler**: Use `"cosine"` for smooth learning rate decay

### Monitoring Progress

* **Validation Images**: Check generated validation images to assess training progress
* **Task Status**: Monitor task status regularly, especially for long-running tasks
* **Error Handling**: Implement proper error handling for failed tasks

## Get the API Key to Run Tasks

The API Key in the example code is for public demonstration purposes only and has a strict rate limit, making it unsuitable for production environments. To use the Crynux Network for fine-tuning in production, choose one of the following methods:

### Method 1: Using the Official Crynux Bridge

You can request a separate API Key with a higher quota from the Crynux Discord server. Join the server and request new keys from an admin in the "applications" channel.

{% embed url="https://discord.gg/y8YKxb7uZk" %}

### Method 2: Hosting Your Own Crynux Bridge

You can host your own instance of the Crynux Bridge to provide private APIs for your application. This approach gives you greater control over various system aspects, including reliability and speed-related configurations.

Starting a Crynux Bridge is as straightforward as running a Docker container. An additional requirement is a wallet funded with sufficient (test) CNX to cover the tasks you run on the network. And at this moment, you can get test CNXs for free in the [Crynux Discord](https://discord.gg/y8YKxb7uZk) as well.

Crynux Bridge is fully open-sourced on [GitHub](https://github.com/crynux-network/crynux-bridge). A step-by-step guide for starting a Crynux Bridge instance is available in the following document:

{% content-ref url="crynux-bridge.md" %}
[crynux-bridge.md](crynux-bridge.md)
{% endcontent-ref %}

### Method 3: Sending Tasks Directly to the Blockchain

You can bypass the Crynux Bridge entirely and interact directly with the blockchain and Crynux Relay to send fine-tuning tasks. Crynux SDKs are available in various languages and can be embedded directly into your code to run fine-tuning tasks. Please consult the Crynux SDK documentation for detailed usage instructions:

{% content-ref url="crynux-sdk.md" %}
[crynux-sdk.md](crynux-sdk.md)
{% endcontent-ref %}
