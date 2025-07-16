---
description: Use the Crynux Network as the inference API
---

# Application Workflow

{% hint style="info" %}
The easiest method to connect an application to the Crynux Network is to deploy a Crynux Bridge, and connect the application to the bridge using API. The Crynux Bridge will take care of the application wallet, and all the interactions with the blockchain and Relay. The tutorial can be found in the following document:

[Crynux Bridge](crynux-bridge.md)

Another convenient method is to use the SDK to embed the workflow directly into the application. The details of the SDKs are explained in the following document:

[Crynux SDK](crynux-sdk.md)
{% endhint %}

The application can utilize the Crynux Network as an API service. It sends inference tasks to the network and receives images or texts in return. Two types of inference tasks are supported: Stable Diffusion image generation and GPT text generation.

The application interacts with two network components: the blockchain node and the Relay. To send tasks successfully, it must have a wallet with sufficient Test CNX tokens for payment. Test CNX tokens can be acquired for free on the [Discord Server of Crynux](https://discord.gg/y8YKxb7uZk).

Reference applications are provided for both image generation and text generation tasks. The source code can be found on the GitHub.

As the first step, we will provide a high-level overview of the complete workflow, outlining the main steps involved in the process.

## Overview

The application workflow is illustrated in the graph below:

```mermaid
sequenceDiagram
    Participant A as Application
    Participant B as Blockchain
    Participant R as DA/Relay

    A ->> B: Create task
    activate B
    note over A,B: Task Criteria<br/>Task Fee
    B -->> A: Transaction confirmed
    deactivate B
    activate A
    A ->> R: Send task parameters
    activate R
    note over A,R: Task Parameters
    deactivate A
    R -->> A: Task parameters saved
    deactivate R
    B ->> A: Event: TaskSuccess
    activate A
    A ->> R: Get task result
    deactivate A
    activate R
    R -->> A: Task result
    deactivate R
```

The application initiates the workflow by calling the `CreateTask` method of the smart contract. This method receives task parameters related to the task criteria, such as the task type and VRAM requirements, which the network uses to select suitable nodes.

The application transfers the task fee to the contract address by specifying it in the transaction's `value` field. Upon task completion, tokens are sent to the nodes. If the task fails, the fee is refunded to the application's wallet.

After the transaction is confirmed on-chain, the application should then send the task parameters to the Relay.

> Selected nodes will retrieve task parameters from the Relay and then execute the tasks locally.
>
> When images or texts are generated, nodes will create proofs and send them to the blockchain. The blockchain will verify the correctness of these proofs and transfer tokens to the nodes upon successful verification.
>
> The nodes will upload the result images/texts to the Relay, which will compare the results with the on-chain proofs to verify their accuracy.

After sending the task parameters to the Relay, the application should wait for the `TaskSuccess` event from the blockchain. Once the event is received, the application can retrieve the images or texts from the Relay, marking the completion of the task workflow.

The results have already been verified by the Relay, so no further verification by the application is necessary.

For a detailed workflow involving all network participants, please refer to the task lifecycle document:

{% content-ref url="../system-design/task-lifecycle/" %}
[task-lifecycle](../system-design/task-lifecycle/)
{% endcontent-ref %}

## The Reference Applications

The workflow has been fully implemented in the showcase applications: the Image Generator and the AI Chatbot. Which can be accessed at:

The Image Generator: [https://ig.crynux.io](https://ig.crynux.io)

The AI Chatbot: [https://chat.crynux.io](https://chat.crynux.io)

Both applications utilize the Crynux Bridge as the backend. The Crynux Bridge includes a built-in wallet to cover task fees, eliminating the need for applications to manage their own wallets. Additionally, it isolates the blockchain and Relay from the applications. This allows applications to simply submit task parameters via API and await the result without further action.

The Crynux Bridge can be used by all the applications. The source code of the Crynux Bridge can be found at:

{% embed url="https://github.com/crynux-network/crynux-bridge" %}

The source code of the web UI of the Image Generator:

{% embed url="https://github.com/crynux-network/ig-web" %}

The source code of the web UI of the AI Chatbot

{% embed url="https://github.com/crynux-network/chat-web" %}

## Application Workflow Step by Step

### 1. Prepare the application wallet

{% hint style="info" %}
Crynux Network is currently deployed on the L2 blockchain of Dymension as a testnet Rollapp. **Test CNX tokens are used**. You could[ join the Discord Server of Crynux ](https://discord.gg/y8YKxb7uZk)to get the test tokens for free.
{% endhint %}

An Ethereum compatible wallet must be generated. Which will be used by the application to invoke the smart contracts on-chain.

Ensure the wallet has sufficient Test CNX tokens to cover both task and transaction fees. The application should continuously monitor the wallet balance and alert admins to replenish tokens before it drops below the required amount for upcoming tasks.

{% hint style="info" %}
In the DApp, an application wallet is not required. The DApp will create the transaction and send it to Metamask for the user to sign directly in the browser.
{% endhint %}

### 2. Create the Task on the Blockchain

#### Construct the task parameters

The task parameters are organized as a JSON string. An example of the parameters of an image generation task is given below:

```json
{
    "version": "2.0.0",
    "base_model": {
        "name": "stabilityai/sdxl-turbo"
    },
    "prompt": "best quality, ultra high res, photorealistic++++, 1girl, desert, full shot, dark stillsuit, "
              "stillsuit mask up, gloves, solo, highly detailed eyes,"
              "hyper-detailed, high quality visuals, dim Lighting, ultra-realistic, sharply focused, octane render,"
              "8k UHD",
    "negative_prompt": "no moon++, buried in sand, bare hands, figerless gloves, "
                       "blue stillsuit, barefoot, weapon, vegetation, clouds, glowing eyes++, helmet, "
                       "bare handed, no gloves, double mask, simplified, abstract, unrealistic, impressionistic, "
                       "low resolution,",
    "task_config": {
        "num_images": 9,
        "steps": 1,
        "cfg": 0
    },
    "lora": {
        "model": "https://civitai.com/api/download/models/178048"
    },
    "controlnet": {
        "model": "diffusers/controlnet-canny-sdxl-1.0",
        "image_dataurl": "data:image/png;base64,12FE1373...",
        "preprocess": {
            "method": "canny"
        },
        "weight": 70
    },
    "scheduler": {
        "method": "EulerAncestralDiscreteScheduler",
        "args": {
            "timestep_spacing": "trailing"
        }
    }
}
```

The task definition above follows the schema given in the [Stable Diffusion Task Framework](https://github.com/crynux-network/stable-diffusion-task). A wide range of common configurations are supported. The framework also provides a JSON schema to validate task parameters. More information about the framework can be found in the document below:&#x20;

{% content-ref url="execute-tasks/text-to-image-task.md" %}
[text-to-image-task.md](execute-tasks/text-to-image-task.md)
{% endcontent-ref %}

A similar framework for the GPT text generation task is also provided in the following document:

{% content-ref url="execute-tasks/text-to-text-task.md" %}
[text-to-text-task.md](execute-tasks/text-to-text-task.md)
{% endcontent-ref %}

{% hint style="info" %}
The application must validate task parameters against the schema before sending them to the network, especially when the task parameters are generated by the user on the frontend.
{% endhint %}

#### Send the create task transaction to the blockchain

Once the JSON string for the task parameters is ready, the application must create and send the `CreateTask` transaction to the blockchain.

`CreateTask` method of the [Task Contract](https://github.com/crynux-network/crynux-contracts/blob/75a2f7014d9d797df9721be17161ec32c745b9dd/contracts/Task.sol#L75) has five arguments:

```solidity
function createTask(
    uint taskType,
    bytes32 taskHash,
    bytes32 dataHash,
    uint vramLimit,
    uint cap
)
```

* `taskType` is an integer that identifies the task type: 0 for SD task and 1 for GPT task.
* `taskHash` is the keccak256 hash of the JSON string of the task arguments.
* `dataHash` is reserved for the future features and is not used right now. The application could just pass 32 zero bytes to it.
* `vramLimit` indicates the minimum VRAM required to execute the task. The Crynux Network will select the capable nodes based on this value.
* `cap` indicates the task size. It is used to estimate the task execution time by the Crynux Network. It should be set to the number of images in the SD task, and 0 in a GPT task.

In addition to the arguments listed above, the task fee should be set in the `value` field of the transaction. The application is free to choose any task fee value, a higher task fee will result in a faster task execution, while lower task fee will result in longer waiting time.

The source code that implements the invocation of the `CreateTask` method in the Crynux Bridge [can be found here](https://github.com/crynux-network/crynux-bridge/blob/652ea694980da774a283782886bedaa362a53a50/blockchain/task.go#L32).

#### Wait for the transaction confirmation

After sending the transaction, the application should wait for confirmation before proceeding. The transaction might be reverted by the blockchain for various reasons. All possible reasons for a transaction being reverted can be found [in the source code](https://github.com/crynux-network/crynux-contracts/blob/43f98cc0d0b6726c54dc93103739414c6313a6c9/contracts/Task.sol#L59C21-L59C21).

If the transaction is reverted, no event will be emitted. Therefore, the creation result can only be queried using the transaction hash or the receipt provided by the blockchain when sending the `CreateTask` transaction.

### 3. Upload the Task Parameters to the Relay

Once the transaction is confirmed, the next step is to upload the task parameters JSON string to the Relay. Use the following API endpoint:

{% swagger src="https://dy.relay.crynux.io/openapi.json" path="/v1/inference_tasks" method="post" %}
[https://dy.relay.crynux.io/openapi.json](https://dy.relay.crynux.io/openapi.json)
{% endswagger %}

The complete API documentation can be found in the [OpenAPI Specifications](https://dy.relay.crynux.io/openapi.json) of the Relay server.

To upload, simply invoke the API to the Relay server. Ensure the request is signed by the application wallet before sending.

> The Relay tracks the blockchain for task creations, recording the task ID and the creator's address (application wallet) upon creation. To upload task arguments, the request must originate from the same task creator's wallet with a verified signature.

The signature is generated using ECDSA with the same curve as Ethereum, on the Keccak256 hash of a string. This string is created by including all query and body parameters (except `timestamp` and `signature`) from the request in a JSON string with keys sorted alphabetically and concatenated with the current Unix timestamp.

The reference implementation of the signing method in Crynux Bridge [can be found here](https://github.com/crynux-network/crynux-bridge/blob/main/relay/sign_data.go). The code to upload the task parameters to the Relay can also be found [in the source code](https://github.com/crynux-network/crynux-bridge/blob/652ea694980da774a283782886bedaa362a53a50/relay/inference_task.go#L41).

### 4. Wait for the Task to Finish

When the task finishes, either the `TaskSuccess` or `TaskAborted` event will be emitted. If the `TaskSuccess` event is emitted, the application can retrieve the result from the Relay. If the `TaskAborted` event is emitted, indicating a failure, the application can retry by creating a new task.

Several reasons can cause task execution failure. Task arguments might not pass node schema validation, some nodes might not run the consensus protocol correctly, or a task might take too long on a single node. The exact reason is included as an argument in the emitted event.

If a task is aborted, CNX tokens may either be returned to the application wallet or still paid to the nodes. This depends on who is at fault for the task's failure.

There are two ways the application could monitor the blockchain for relevant events.

#### Tracking new blocks and filtering the target events

The first method involves continuously tracking new blocks and filtering them for these two types of events.

To ensure reliable block tracking, the application must handle potential crashes caused by unhandled bugs. Additionally, extended downtime can result in delays when catching up with new blocks.

#### Query for the task status periodically

Another approach is to extract the task ID from the creation transaction, store it, and periodically check the blockchain for the latest task status. This method eliminates the need to track the block, but it is less efficient due to a high volume of unnecessary queries.

The Crynux Bridge uses the first method, the source code of the block synchronization [can be found here](https://github.com/crynux-network/crynux-bridge/blob/main/tasks/sync_block.go).

### 5. Fetch the result from the Relay

The final step is to retrieve the actual images or texts from the Relay. This can be accomplished by calling the Relay's API as follows:

#### Get images

The URL could be treated like an image downloading link as it returns the binary stream of the image content directly. The signature and timestamp is still required.

{% swagger src="https://dy.relay.crynux.io/openapi.json" path="/v1/inference_tasks/{task_id}/results/{image_num}" method="get" %}
[https://dy.relay.crynux.io/openapi.json](https://dy.relay.crynux.io/openapi.json)
{% endswagger %}

#### Get texts

The API endpoint to get text results from the Relay is the same as the endpoint above, except that the `image_num` should be set to zero.

{% hint style="info" %}
When the application accesses the above URL after the `TaskSuccess` event is received, it could keep getting `404 not found` for a short while before it gets the correct results. The reason is that the node will start to upload images/texts to the Relay only after the `TaskSuccess` event is received. So before the uploading is done, the application can not find the results on the Relay. Several times of retrying is required at this place.
{% endhint %}

When the application accesses the URL after receiving the `TaskSuccess` event, it might encounter `404 not found` errors temporarily. This occurs because the node initiates the upload of images/texts to the Relay only after the `TaskSuccess` event is triggered. Therefore, the results won't be available on the Relay until the upload is complete. Retrying the request several times may be necessary.

The source code where the Crynux Bridge downloads the images is [located here](https://github.com/crynux-network/crynux-bridge/blob/aba6390424904c14b8f8676d5559c8ec9f6da503/relay/inference_task.go#L93).
