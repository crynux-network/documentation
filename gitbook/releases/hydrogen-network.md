---
description: '[Nov 8, 2023] Decentralized Stable Diffusion Task Execution Engine'
---

# Hydrogen Network

Hydrogen Network is the first testnet of the Crynux Network. Hydrogen Network implements an AI inference task execution engine that supports running the Stable Diffusion image generation tasks for the applications.

The computation power comes from a decentralized network of home computers and servers that are coordinated by a consensus protocol running on the Blockchain. The individuals who have the spared computation power could connect their devices to the network, exchanging the computation power for tokens by running the inference tasks for the applications.

## Inference API

To the applications, Hydrogen Network is an inference API service that could be used to generate images using the Stable Diffusion.

The application should prepare a wallet, to pay the tokens for the inference task. But other than that, the invocation of the API is no different than the invocation of a traditional API service on AWS. The decentralized execution process is completely invisible to the applications.

If you are an application developer, get started from here:

{% content-ref url="../application-development/application-workflow.md" %}
[application-workflow.md](../application-development/application-workflow.md)
{% endcontent-ref %}

#### Stable Diffusion Task Framework

A general framework to define and execute the Stable Diffusion tasks is developed to be used in the Hydrogen Network. A wide range of the common task types and configurations are supported. Just describe the task using JSON, and send it to the inference API:

* Unified task definition for Stable Diffusion 1.5, 2.1 and Stable Diffusion XL
* SDXL - Base + Refiner ([ensemble of expert denoisers](https://research.nvidia.com/labs/dir/eDiff-I/)) and standalone Refiner
* Controlnet and various preprocessing methods
* LoRA
* VAE
* Textual Inversion
* Long prompt
* Prompt weighting using [Compel](https://github.com/damian0815/compel)
* Auto LoRA and Textual Inversion model downloading from non-Huggingface URL

The following document gives more information on how to write a Stable Diffusion task:

{% content-ref url="../application-development/execute-tasks/text-to-image-task.md" %}
[text-to-image-task.md](../application-development/execute-tasks/text-to-image-task.md)
{% endcontent-ref %}

And more examples can be found in the GitHub repository:

{% embed url="https://github.com/crynux-network/stable-diffusion-task/tree/main/examples" %}

#### The Image Generator

The Image Generator is a showcase application that provides a web interface (just like [`stable-diffusion-webui`](https://github.com/AUTOMATIC1111/stable-diffusion-webui)) for the users to generate images in the browser.&#x20;

The users could select between different versions of the Stable Diffusion models, such as Stable Diffusion 1.5 and Stable Diffusion XL, and apply a LoRA model on it by specifying the download link of the LoRA model on Civitai.

Thanks to the Hydrogen Network, the application could be used on the devices that do not have a capable GPU integrated. If the browser exists, the Image Generator could be used.

Give it a try:

{% embed url="https://ig.crynux.io" %}

The Image Generator also serves as a reference implementation for the traditional centralized applications who want to integrate the inference API. The source code of the Image Generator is also hosted on GitHub:

**The backend:**

The Crynux Bridge is serving as the backend of the Image Generator. The bridge transparently handles the blockchain transaction processing and wallet signatures at the backend, and provides simple traditional APIs to the web UI:

{% embed url="https://github.com/crynux-network/crynux-bridge" %}

**The frontend:**

{% embed url="https://github.com/crynux-network/ig-web" %}

## Node Hosting

The contributor of the spared computation power could join the network by hosting a node on the local computer. The node could be easily started in just a few steps:

{% content-ref url="../node-hosting/start-a-node/" %}
[start-a-node](../node-hosting/start-a-node/)
{% endcontent-ref %}

## Consensus Protocol

The consensus protocol ensures that all the malicious behaviors could be identified and panelized in the network. Thanks to the consensus protocol, the Hydrogen Network allows everyone to join freely as the computation power contributor, without asking for permissions.

The consensus protocol works by asking the node to stake certain amount of tokens before joining the network, and if the malicious behavior is detected from the node, the staked tokens will be slashed. By a calculation based on the probability, the attacking against the network will highly likely to cause the attacker to loose money rather than earn.

The malicious behaviors are discovered by dispatching the same task to 3 nodes randomly at the same time, and compare the results returned by the nodes on the Blockchain. A similarity score is used to overcome the randomness problem in the inference computation.

The consensus protocol is described in detail in the following doc:

{% content-ref url="../system-design/consensus-protocol/" %}
[consensus-protocol](../system-design/consensus-protocol/)
{% endcontent-ref %}

## The Blockchain In Use

The Hydrogen Network is running on a private blockchain whose node can be accessed using the RPC endpoint:

```url
https://block-node.crynux.io/rpc
```

The reason for a private Blockchain is that public Blockchains with strong consensus protocol, such as Ethereum, is not fast enough alone to support the throughput of the Hydrogen Network, or any other networks of Crynux in the future. The solution will be a layer 2 scaling tech such as [ZK-Rollups](https://blockworks.co/news/zk-rollups-future-of-smart-contract-blockchains). We will be either using a generalized solution that is well known to the industry, or developing our own for better performance(under the limit of our use cases).

Our focus right now, however, is to support more features, such as the GPT tasks and training tasks.  And we will launch a network on the public blockchain when the network has a rich set of features, and is ready to be used by a large number of applications. The layer 2 solution will be implemented when we are close to it.

When the test networks are running on the private blockchain, the test tokens are free to acquire from our community. The node providers are contributing their computation power for free in a belief of the open and democratized future. And their contributions are recorded by the private blockchain. We believe their efforts will be paid out eventually.

The test tokens are required for both starting a node, or calling the inference API. To get the test tokens, just join the Discord of Crynux and bind your wallet address using the bot:

{% embed url="https://docs.crynux.ai/happyaigen#bind-the-wallet-address" %}

The private blockchain in use in the Hydrogen Network is built using the [Frontier project](https://paritytech.github.io/frontier/), which contains an EVM running on top of the [Substrate Blockchain](https://substrate.io/). The Blockchain is Ethereum compatible, most of the existing tools for the Ethereum can be used directly.

The Hydrogen Network is coordinated by three smart contracts on the Blockchain:

<table><thead><tr><th width="186">Contract</th><th>Address</th></tr></thead><tbody><tr><td>Token</td><td>0x95E7e7Ed5463Ff482f61585605a0ff278e0E1FFb</td></tr><tr><td>Node</td><td>0xB0E9A451Ce0CC181EA9888C7B42BB8Ad90b73C78</td></tr><tr><td>Task</td><td>0xba2489a25A5f542877D3825Ab802651f28878C4a</td></tr></tbody></table>

The CNX token is just an standard ERC20 token. The tokens will be operated by the other contracts to implement the required functions.

The source code of the smart contracts is hosted on the GitHub:

{% embed url="https://github.com/crynux-network/crynux-contracts" %}

## The Relay In Use

The relay server could be accessed at:

```url
https://relay.h.crynux.io
```

The source code of the relay is hosted at:

{% embed url="https://github.com/crynux-network/crynux-relay" %}
