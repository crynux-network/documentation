---
description: '[Jun 17, 2026] The First Mainnet'
---

# Lithium Network

Lithium Network is the first mainnet release of Crynux Network.

Lithium turns Crynux from a public test network into a production AI computing network. Applications can use decentralized GPU nodes for LLM inference, vision-language model tasks, image generation, and model fine-tuning, while node operators earn CNX by providing compute capacity.

With the vssML consensus protocol upgrade, Lithium greatly reduces validation overhead and improves network efficiency while preserving a permissionless network where nodes can join at scale and malicious behavior remains detectable and punishable.

## Verifiable Secret Sampling

vssML, or Verifiable Secret Sampling for Machine Learning, is the core efficiency improvement in the consensus protocol behind Lithium. Previous consensus protocol sends every task to three nodes and compares the results, which provides strong security but consumes triple compute capacity. vssML validates only a secretly selected sample of tasks, and nodes must submit results before knowing whether they were selected for validation, so cheating still risks detection and slashing.

This greatly improves the efficiency of the whole network, bringing decentralized execution close to the speed of centralized platforms.

{% content-ref url="../system-design/verifiable-secret-sampling.md" %}
[verifiable-secret-sampling.md](../system-design/verifiable-secret-sampling.md)
{% endcontent-ref %}

## Staking Score

Lithium introduces staking score to connect task probabilities with economic commitment. Nodes with more stake can receive more tasks and earn more rewards, while dishonest behavior puts more capital at risk. This makes the network harder to attack, rewards operators who commit long-term resources, and keeps task dispatching aligned with network security.

{% content-ref url="../system-design/task-dispatching.md" %}
[task-dispatching.md](../system-design/task-dispatching.md)
{% endcontent-ref %}

## Delegated Staking

Delegated staking lets CNX holders participate in network rewards without running their own hardware. Users can delegate stake to trusted node operators, similar to cloud mining or cloud compute rental, while operators with better GPUs, stronger uptime, and more reliable service can attract more delegated stake and earn more task income. This creates a new market where capital and computing power work together to grow the network.

## Latest LLM and VLM Support

Lithium expands Crynux's OpenAI-compatible AI service from text-only LLMs to both LLM and Vision Language Model workloads. Applications can use latest Hugging Face models, including examples such as `Qwen/Qwen3.6-27B` and `Qwen/Qwen3.5-9B`, while keeping the same chat completion workflow through Crynux Bridge.

{% content-ref url="../application-development/how-to-run-llm-using-crynux-network/" %}
[how-to-run-llm-using-crynux-network](../application-development/how-to-run-llm-using-crynux-network/)
{% endcontent-ref %}

{% content-ref url="../application-development/how-to-run-llm-using-crynux-network/vision-language-models.md" %}
[vision-language-models.md](../application-development/how-to-run-llm-using-crynux-network/vision-language-models.md)
{% endcontent-ref %}

## AI Ecosystem Integration

Lithium works with the tools developers already use. Through the OpenAI-compatible Crynux Bridge API, existing AI applications and agent frameworks can use Crynux as a decentralized model backend. Hermes Agent can connect to Crynux as a custom LLM provider, and LangChain or LangGraph applications can use Crynux through either `langchain-crynux` or standard OpenAI-compatible integrations.

{% content-ref url="../application-development/how-to-run-llm-using-crynux-network/hermes-agent-integration.md" %}
[hermes-agent-integration.md](../application-development/how-to-run-llm-using-crynux-network/hermes-agent-integration.md)
{% endcontent-ref %}

{% content-ref url="../application-development/how-to-run-llm-using-crynux-network/langchain.md" %}
[langchain.md](../application-development/how-to-run-llm-using-crynux-network/langchain.md)
{% endcontent-ref %}

## Multi-chain Architecture

Lithium launches Crynux as a multi-chain network. Crynux runs as dedicated Layer 2 blockchains, uses CNX bridged from the corresponding Layer 1 chain as the native gas token, and keeps the wallet experience EVM-compatible. Users can connect wallets, add networks, and move CNX between networks through Crynux Portal.

{% content-ref url="../crynux-token/wallet-configuration.md" %}
[wallet-configuration.md](../crynux-token/wallet-configuration.md)
{% endcontent-ref %}
