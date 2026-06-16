---
description: Start a node on Vast.ai
---

# Start a Node - Vast

The Crynux Node can be easily started on cloud services, such as [Vast.ai](https://vast.ai/), who supports starting a VM using Docker images directly. The steps to start a node on those services are quite similar. We will use Vast.ai as an example to show the complete steps to start a Crynux Node.

## 1. Start the container using template

We have already created the template for the Crynux Node on Vast, just use this template to start the node:

{% embed url="https://cloud.vast.ai/?ref_id=136043&template_id=bba3743eb66fac590ab6a9de83158f4b" %}

The content of the template is shown below:

<figure><img src="../../.gitbook/assets/e2e99275247966afe9197eee2f70218.png" alt=""><figcaption></figcaption></figure>

{% hint style="success" %}
**Please use the latest version tag to start the container**

you could find the available tags at:&#x20;

[**https://github.com/crynux-network/crynux-node/pkgs/container/crynux-node/versions**](https://github.com/crynux-network/crynux-node/pkgs/container/crynux-node/versions)

For example, if you want to run the 3.0.0 version of the Crynux Node under Base Network, use the image link below:

`ghcr.io/crynux-network/crynux-node:3.0.0-base`
{% endhint %}

Some other config options that worth highlighting:

* Expose port `7412` for WebUI.
* Use the default docker ENTRYPOINT to start the container. Do not use interactive shells.

After selecting your desired hardware, and starting the instance, find the instance in the `INSTANCES` tab:

<figure><img src="../../.gitbook/assets/c35f22fdcc91d9906363314ce7ff526.png" alt=""><figcaption></figcaption></figure>

Wait until the container finishes initialization, and shows the `RUNNING` status.

## 2. Find the URL to access the WebUI

Click on the network info button to show the detailed ip address and ports:

<figure><img src="../../.gitbook/assets/image (3).png" alt=""><figcaption></figcaption></figure>

The URL to access the WebUI will be shown in the popup:

<figure><img src="../../.gitbook/assets/image (4).png" alt=""><figcaption></figcaption></figure>

In this case, the URL of the WebUI is `http://213.181.122.2:40021`. Just open it in a browser window, you should see the WebUI of the Node:

<figure><img src="../../.gitbook/assets/1d2593321953160bab0838ed3d54748.png" alt=""><figcaption></figcaption></figure>

## 3. Prepare the wallet

{% hint style="danger" %}
#### Security Warning: Private key on third‑party machines

When you run a node on Vast, your Docker container is not on your own hardware. It runs on GPU machines owned and operated by other individual Vast users. Any private key you put into the container is therefore stored on those third-party machines, where a malicious host or malware on the host system could read the key and immediately transfer all funds controlled by it.

To reduce potential loss, you **MUST** set up a **Beneficial Address** so that all rewards and returned stake are paid to a separate cold wallet, and only keep the minimum necessary balance on the hot key used by the node. Please find the details of the Beneficial Address in the docs below:

[Private Key Security](../private-key-security.md)
{% endhint %}

A wallet with enough test tokens must be provided to the node. If this is the first time you start a node, click the "Create New Wallet" button and follow the instructions to create a new wallet and finish the backup of the private keys.

<figure><img src="../../.gitbook/assets/7b8bf34cf8eb9b7e850aad28e44b587.png" alt=""><figcaption></figcaption></figure>

## 4. Get the test CNX tokens from the Discord Server

Some test CNX tokens are required to start the node. The test CNX tokens can be acquired for free in the Discord server of Crynux:

{% embed url="https://discord.gg/y8YKxb7uZk" %}

Follow the instructions in the following document to get the test tokens:

{% content-ref url="../get-the-test-cnx-tokens.md" %}
[get-the-test-cnx-tokens.md](../get-the-test-cnx-tokens.md)
{% endcontent-ref %}

## 5. Wait for the system initialization to finish

If this is the first time you start a node, it could take quite a long while for the system to initialize. The most time consuming step is to download \~40GB of the commonly used model files from the Huggingface. The time may vary depending on your network speed.

After the models are downloaded, a test image generation task will be executed locally to examine the capability of your device. If the device is not capable to generate images, or the generation speed is too slow, the node will not be able to join the network. If the task is finished successfully, the initialization is completed:

<figure><img src="../../.gitbook/assets/1daf6bc8396c38c44072803a2924d09.png" alt=""><figcaption></figcaption></figure>

## 6. Join the Crynux Network

The Crynux Node will try to join the network automatically every time it is started. After the transaction is confirmed on-chain, the node has successfully joined the network. When the node is selected by the network to execute a task, the task will start automatically, and the tokens will be transferred to the node wallet after the task is finished.

<figure><img src="../../.gitbook/assets/6c659fa275de50dfa6fa82fae3f97d6.png" alt=""><figcaption></figcaption></figure>

Now the Node is fully up and running. You could just leave it there to run tasks automatically.

The Node could be paused or stopped at any time by clicking the control buttons. If the node is in the middle of running a task, after clicking the buttons, the node will go into the "pending" status and continue with the running task. When the task is finished, the node will pause/stop automatically.

The difference between pausing and stopping is that pausing will not cause the staked CNX tokens to be returned, so that the transaction costs less gas fee than stopping. If you have a plan of going back, you could use pausing rather than stopping.
