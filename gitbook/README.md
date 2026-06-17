---
description: Truly permissionless DeAI on GPU@edge
---

# Crynux Network

[![](https://dcbadge.limes.pink/api/server/https://discord.gg/y8YKxb7uZk)](https://discord.gg/y8YKxb7uZk)
[![X](https://img.shields.io/badge/@crynuxio-%23000000.svg?style=for-the-badge&logo=X&logoColor=white)](https://x.com/crynuxio)
[![GitHub Org's stars](https://img.shields.io/github/stars/crynux-network?style=for-the-badge&logo=github)](https://github.com/crynux-network)

Crynux Network is a decentralized AI compute network that turns edge GPUs into a shared cloud for modern LLM/VLM inference and fine-tuning tasks. Its vssML consensus protocol keeps the network permissionless and open to large-scale node participation while making malicious behavior detectable and punishable, bringing decentralized execution close to centralized-platform efficiency. On top of this compute layer, Crynux enables model and data assets that can support new AI-native DeFi applications.

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

## Lithium Network

Lithium Network is the first mainnet release of Crynux Network. It turns Crynux into a production AI computing network where applications can use decentralized GPU nodes for LLM inference, vision-language model tasks, image generation, and model fine-tuning.

### Production AI Workloads

Applications can use Crynux for LLM inference, Vision Language Model tasks, image generation, and model fine-tuning through familiar APIs.

{% content-ref url="application-development/how-to-run-llm-using-crynux-network/" %}
[how-to-run-llm-using-crynux-network](application-development/how-to-run-llm-using-crynux-network/)
{% endcontent-ref %}

### AI Ecosystem Integration

Lithium integrates with the AI ecosystem developers already use. Through the OpenAI-compatible Crynux Bridge API, applications can connect Crynux to agent frameworks, tool-use workflows, LangChain, LangGraph, Hermes Agent, and Vision Language Model applications without rebuilding their stack around a new protocol.

{% content-ref url="application-development/how-to-run-llm-using-crynux-network/vision-language-models.md" %}
[vision-language-models.md](application-development/how-to-run-llm-using-crynux-network/vision-language-models.md)
{% endcontent-ref %}

{% content-ref url="application-development/how-to-run-llm-using-crynux-network/hermes-agent-integration.md" %}
[hermes-agent-integration.md](application-development/how-to-run-llm-using-crynux-network/hermes-agent-integration.md)
{% endcontent-ref %}

{% content-ref url="application-development/how-to-run-llm-using-crynux-network/langchain.md" %}
[langchain.md](application-development/how-to-run-llm-using-crynux-network/langchain.md)
{% endcontent-ref %}

### Delegated Staking

Delegated staking lets CNX holders participate in network rewards without running a node. Stake CNX to reliable node operators through [Crynux Portal](https://portal.crynux.io), support the compute providers you trust, and start sharing in the rewards generated by the network.

Read more about Lithium Network:

{% content-ref url="releases/lithium-network.md" %}
[lithium-network.md](releases/lithium-network.md)
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
            <td>Base</td>
            <td>Windows</td>
            <td>Nvidia GPU with 8GB VRAM</td>
            <td><a href="https://drive.google.com/uc?id=1_PLIoOfqCbz9YCL2TuDGifRKeqOQ5bGN&export=download">crynux-node-lithium-v3.0.0-base-windows-x64.zip</a></td>
        </tr>
        <tr>
            <td>Base</td>
            <td>Mac</td>
            <td>M1/M2/M3 and later</td>
            <td><a href="https://github.com/crynux-network/crynux-node/releases/download/v3.0.0/crynux-node-lithium-v3.0.0-base-mac-arm64-unsigned.dmg">crynux-node-lithium-v3.0.0-base-mac-arm64-signed.dmg</a></td>
        </tr>
        <tr>
            <td>Near</td>
            <td>Windows</td>
            <td>Nvidia GPU with 8GB VRAM</td>
            <td><a href="https://drive.google.com/uc?id=1qUc56xNMY7L2vy3D2rt45LDEBJNUAfxw&export=download">crynux-node-lithium-v3.0.0-near-windows-x64.zip</a></td>
        </tr>
        <tr>
            <td>Near</td>
            <td>Mac</td>
            <td>M1/M2/M3 and later</td>
            <td><a href="https://github.com/crynux-network/crynux-node/releases/download/v3.0.0/crynux-node-lithium-v3.0.0-near-mac-arm64-unsigned.dmg">crynux-node-lithium-v3.0.0-near-mac-arm64-signed.dmg</a></td>
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
