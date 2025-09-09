---
description: '[Jan 30, 2024] Decentralized GPT Task Execution Engine'
---

# Helium Network

Helium Network adds the support of the LLM text generation tasks. The Crynux Network now supports running both the Stable Diffusion image generation tasks and the LLM text generation tasks.

OpenAI-compliant APIs are implemented through the Crynux Bridge. Official OpenAI SDKs can be directly used. And [most of the LLM models on the Huggingface](https://huggingface.co/models?pipeline_tag=text-generation\&sort=trending) are supported.

To get started, follow the guide below:

{% content-ref url="../application-development/how-to-run-llm-using-crynux-network/" %}
[how-to-run-llm-using-crynux-network](../application-development/how-to-run-llm-using-crynux-network/)
{% endcontent-ref %}

## AI Chatbot Application

An AI chatbot application has been released to demonstrate the abilities. The app provides a simple chat UI in the browser, and the text generation task is sent to the [Crynux Bridge](https://github.com/crynux-network/crynux-bridge) at the backend, and then sent to the Crynux Network for execution. The task fees are paid from the wallet inside the Crynux Bridge so that the users won't have to deal with the wallet themselves.

Try the application yourself at: [https://chat.crynux.io](https://chat.crynux.io/)

The source code of the application is located on the GitHub:

[https://github.com/crynux-network/chat-web](https://github.com/crynux-network/chat-web)

## GPT Task Framework

A general framework to define and execute the GPT tasks is developed to be used in the Helium Network. A wide range of the common task types and configurations are supported. Just describe the task using JSON, and send it to the inference API:

* Unified task definition for various different large language model
* Apply model specific chat templates to input prompts automatically
* Model quantizing (INT4 or INT8)
* Fine grained control text generation arguments
* ChatGPT style response

To find out more about how to write a GPT task, go to the following page:

{% content-ref url="../application-development/execute-tasks/text-to-text-task.md" %}
[text-to-text-task.md](../application-development/execute-tasks/text-to-text-task.md)
{% endcontent-ref %}

## GPT Task Verification On-chain

The consensus protocol now supports the validation of the GPT tasks.

To support the validation of the GPT tasks, the network will select 3 nodes with the same card model to run a single task, which ensures the results will be exactly the same on all the 3 nodes.

The node selection for stable diffusion tasks remain the same, which does not require the same cards, which gives the task more candidates to use and makes the network safer.

## Task Queue & Task Pricing

The order of the task execution is now determined by the task price set by the task creator. In general, tasks with higher prices will be executed first. Task with a lower priority will be put into the task queue to be executed later.

The order is not simply determined by the total price of a task. Instead, the task execution time is also taken into account to maximize the total income of a node in a fixed time range. The network will estimate a unit value in "CNX per second" of the task to determine the actual order of the task. The details can be found in the following docs:

{% content-ref url="../system-design/task-dispatching.md" %}
[task-dispatching.md](../system-design/task-dispatching.md)
{% endcontent-ref %}

{% content-ref url="../system-design/task-pricing.md" %}
[task-pricing.md](../system-design/task-pricing.md)
{% endcontent-ref %}

## Quality of Service (QoS)

The Helium Network will calculate the Submission Speed score for each node. The score will be used in the following 2 scenarios:

* **Task fee distribution among the participating nodes**: the node that submits the result faster will get larger portion of the task fee.
* **Bad node kick out**: the node that has a lower score below the threshold will be forced to quit the network.

The details can be found in the following doc:

{% content-ref url="../system-design/quality-of-service-qos.md" %}
[quality-of-service-qos.md](../system-design/quality-of-service-qos.md)
{% endcontent-ref %}

## Mac Support

The Crynux Node could now be started on Mac with Apple Silicon Chips (m1, m2 and m3 series). Both the Stable Diffusion and GPT tasks are supported. All the mac users could now join the network to earn CNX tokens.

To start a node on Mac, just follow the tutorial below:

{% content-ref url="../node-hosting/start-a-node/start-a-node-mac.md" %}
[start-a-node-mac.md](../node-hosting/start-a-node/start-a-node-mac.md)
{% endcontent-ref %}

## Multi-chain Architecture

Crynux now supports applications and nodes running on multiple blockchains. Dymension and Near are now supported, and more will follow. Please visit the following document for details:

{% content-ref url="../crynux-token/wallet-configuration.md" %}
[wallet-configuration.md](../crynux-token/wallet-configuration.md)
{% endcontent-ref %}
