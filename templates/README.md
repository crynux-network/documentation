---
description: Truly permissionless DeAI on GPU@edge
---

# Crynux Network

[![](https://dcbadge.limes.pink/api/server/https://discord.gg/y8YKxb7uZk)](https://discord.gg/y8YKxb7uZk)
[![X](https://img.shields.io/badge/@crynuxio-%23000000.svg?style=for-the-badge&logo=X&logoColor=white)](https://x.com/crynuxio)
[![GitHub Org's stars](https://img.shields.io/github/stars/crynux-network?style=for-the-badge&logo=github)](https://github.com/crynux-network)

### Truly Permissionless

The key component of Crynux is a robust consensus protocol that enables the permissionless joining and using of the decentralized network by millions.

The ability to identify and penalize all malicious behaviors ensures the ecosystem's sustainability while facilitating healthy growth in the long term.

The innovative [vssML](https://docs.crynux.io/system-design/verifiable-secret-sampling) technology significantly enhances network efficiency, rivaling centralized platforms while remaining decentralized and permissionless.

### Production-Ready AI Services Cloud, on Edge

As the foundation layer, Crynux Network is composed of the edge nodes, including home computers and mobile devices, who provide hardware to the network in exchange for tokens.

Applications could run tasks such as GPT text generation and Stable Diffusion image generation using various models hosted on the Crynux Network. The integration could be implemented in one-line of code using Crynux SDK.

Model developers use Crynux Network to train/fine-tune their models, and provide models as a service for applications and other developers, earning from the usage of their models.

Mobile devices could also be AI-enhanced by running larger and faster models beyond their current capabilities.

### DeFi Ecosystem built on the Tokenized Model and Data Assets

Building on top of the AI services, an innovative DeFi ecosystem could emerge around "Model Assets" and "Data Assets". All the current DeFi applications could be reimagined using the brand-new assets as their base assets.

For example, the developers of AI models can tokenize the models using Crynux, sharing the rewards from model usage with the model token holders.

Model tokens can be used as collateral in various DeFi applications. These applications can be deployed directly on the Crynux Blockchain or as modular L2 chains that connect to Crynux via cross-chain communication. Existing DeFi applications on other blockchains are also supported.

By utilizing the Blockchain, Zero-knowledge Proofs and Privacy Preserving Computation technologies, Crynux aims to build a completely decentralized and trustless infrastructure that is always accessible to everyone.

## Helium Network

Helium Network is the latest testnet of the Crynux Network. Helium Network implements a decentralized AI task execution engine that supports running the Stable Diffusion image generation tasks and the LLM text generation tasks.

Although called a testnet, the featured consensus protocol is robust enough to allow everyone to join at this moment. Everyone has an Nvidia GPU, or Mac with the Apple Silicon chips (M1, M2 and M3 series), could have already joined the network using our node software. And the applications could also use the network to run AI tasks such as LLM inference, Stable Diffusion image generation and fine-tuning already.

### LLM Text Generation

The OpenAI-compliant APIs for LLM inference are provided through the Crynux Bridge, the applications could use the official OpenAI SDKs with the Crynux Bridge API for LLM tasks. Most of the models using transformers on Huggingface could be used directly. Please read the following document for details:

{% content-ref url="application-development/how-to-run-llm-using-crynux-network" %}
[How to Run LLM Using Crynux Network](application-development/how-to-run-llm-using-crynux-network)
{% endcontent-ref %}

A chatbot web application has been developed as an example for the developers. The web application provides a simple chat UI in the browser, and connects to the [Crynux Bridge](https://github.com/crynux-network/crynux-bridge) at the backend to interact with the Crynux Network.

The chatbot can be accessed at [https://chat.crynux.io](https://chat.crynux.io)

### Stable Diffusion Image Generation

The applications could now send the Stable Diffusion image generation tasks to the network using the inference API, and get the images back instantly.

A showcase application has been developed to demonstrate the abilities. The app provides a web interface (just like [`stable-diffusion-webui`](https://github.com/AUTOMATIC1111/stable-diffusion-webui)) for the users to generate images in the browser. Thanks to the Helium Network, the users could use the application on any devices that do not have a capable GPU integrated.

The complexity of the blockchain and tokens are taken care of at the backend using [Crynux Bridge](https://github.com/crynux-network/crynux-bridge). To the end users, this is just a traditional easy-to-use web application, nothing special.

Give it a try at [https://ig.crynux.io](https://ig.crynux.io)

To read more about the Helium Network release, go to the following page:

{% content-ref url="releases/helium-network.md" %}
[helium-network.md](releases/helium-network.md)
{% endcontent-ref %}

## Getting Started

### Start a Node

Download the package according to your platform, and follow the tutorials below:

<table>
    <thead>
        <tr>
            <th width="131">Blockchain</th>
            <th width="131">Platform</th>
            <th width="261">Requirements</th>
            <th data-type="content-ref">Download Link</th>
        </tr>
    </thead>
    <tbody>
        <tr>
            <td>Dymension</td>
            <td>Windows</td>
            <td>Nvidia GPU with 8GB VRAM</td>
            <td><a href="WINDOWS_DOWNLOAD_LINK_DYMENSION">crynux-node-helium-vRELEASE_VERSION-dymension-windows-x64.zip</a></td>
        </tr>
        <tr>
            <td>Dymension</td>
            <td>Mac</td>
            <td>M1/M2/M3 and later</td>
            <td><a href="MAC_LINK_DYMENSION">crynux-node-helium-vRELEASE_VERSION-dymension-mac-arm64-signed.dmg</a></td>
        </tr>
        <tr>
            <td>Near</td>
            <td>Windows</td>
            <td>Nvidia GPU with 8GB VRAM</td>
            <td><a href="WINDOWS_DOWNLOAD_LINK_NEAR">crynux-node-helium-vRELEASE_VERSION-near-windows-x64.zip</a></td>
        </tr>
        <tr>
            <td>Near</td>
            <td>Mac</td>
            <td>M1/M2/M3 and later</td>
            <td><a href="MAC_LINK_NEAR">crynux-node-helium-vRELEASE_VERSION-near-mac-arm64-signed.dmg</a></td>
        </tr>
    </tbody>
</table>

To start a node on your Windows computer:

{% content-ref url="node-hosting/start-a-node/start-a-node-windows.md" %}
[start-a-node-windows.md](node-hosting/start-a-node/start-a-node-windows.md)
{% endcontent-ref %}

If you are using Mac with Apple Silicon Chips (M1/M2/M3 and later):

{% content-ref url="node-hosting/start-a-node/start-a-node-mac.md" %}
[start-a-node-mac.md](node-hosting/start-a-node/start-a-node-mac.md)
{% endcontent-ref %}

To start a node on cloud services based on Docker:

*Vast.ai*

{% content-ref url="node-hosting/start-a-node/start-a-node-vast.md" %}
[start-a-node-vast.md](node-hosting/start-a-node/start-a-node-vast.md)
{% endcontent-ref %}

*Octa.space*

{% content-ref url="node-hosting/start-a-node/start-a-node-octa.md" %}
[start-a-node-octa.md](node-hosting/start-a-node/start-a-node-octa.md)
{% endcontent-ref %}

You can also start the node using Docker:

{% content-ref url="node-hosting/start-a-node/start-a-node-docker.md" %}
[start-a-node-docker.md](node-hosting/start-a-node/start-a-node-docker.md)
{% endcontent-ref %}

### Develop an application

If you are an application developer who want to utilize the AI abilities provided by the Crynux Network, follow the tutorial below:

{% content-ref url="application-development/application-workflow.md" %}
[application-workflow.md](application-development/application-workflow.md)
{% endcontent-ref %}

## Research

Checkout our latest research paper about Crynux Network here:

{% embed url="https://www.researchgate.net/publication/380564678_A_Review_on_Decentralized_Artificial_Intelligence_in_the_Era_of_Large_Models" %}

{% embed url="https://www.researchgate.net/publication/377567611_Crynux_Hydrogen_Network_H-Net_Decentralized_AI_Serving_Network_on_Blockchain" %}

## Links

Join the Crynux community on Discord:

[![](https://dcbadge.limes.pink/api/server/https://discord.gg/y8YKxb7uZk)](https://discord.gg/y8YKxb7uZk)

All the codes are open sourced at GitHub, feel free to submit issues and PRs:

{% embed url="https://github.com/crynux-network" %}

The Crynux Blog contains the technical explanations and our latest progress:

{% embed url="https://blog.crynux.io" %}

And follow us on Twitter:

{% embed url="https://x.com/crynuxio" fullWidth="true" %}
