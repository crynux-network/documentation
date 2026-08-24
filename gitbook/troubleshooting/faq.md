# FAQ

## Node Starting Questions

<details>

<summary>Can I start multiple node instances on a single GPU?</summary>

**TLDR: you may get even less rewards by starting multiple nodes on a single device**

No one can stop you doing that.

If your GPU is powerful enough, the bottleneck becomes the consensus process (you will be waiting for other nodes to submit results), in such cases you could start multiple nodes to fully utilize the power of the GPU.

However, if your nodes are executing too many tasks simultaneously, the task execution will become slower (due to the bottleneck on GPU or network bandwidth). And if you are slower than the other 2 nodes in a task,

* You will get a smaller portion from the task fee.
* Your chance of receiving tasks will decrease, and you will get less tasks.
* Your node could be kicking out of the network. It is not a slashing though, the staked tokens are still safe.

The details can be found in the doc:

[Quality of Service (QoS)](../system-design/quality-of-service-qos.md)

</details>

<details>

<summary>Can I start a node on multiple GPUs?</summary>

Yes. A single Crynux Node can automatically use multiple GPUs on the same machine. The node selects the largest group of identical GPU models and uses them together. Details are in:

[Multi-GPU Node](../node-hosting/multi-gpu-node.md)

</details>

<details>

<summary>Can I use the same wallet on multiple node instances?</summary>

No you can't do it.

The same wallet can only get one task from the network at the same time. If multiple nodes are started with the same wallet, they will be executing the same task at the same time, and the nodes who submit the result later will just fail.

After the hot/cold wallet architecture is implemented, [as described in this doc](../node-hosting/private-key-security.md), it can also be used to easily collect funds from multiple nodes to a single cold wallet.

</details>

<details>

<summary>Can I use AMD Radeon cards to run a node?</summary>

Nope. The AMD GPUs are not supported at this moment. Only Nvidia GPU and Apple M1/M2/M3 are supported.

We will add support for AMD GPUs in a future release.

</details>

<details>

<summary>Can I start a node without GPU?</summary>

No. GPU is required to execute the AI tasks from the applications, which is the fundamental requirement of a Crynux Node.

</details>

<details>

<summary>Can I start a node on VPS?</summary>

If you mean VPS without GPUs, the answer is no. GPU is required to execute the AI tasks from the applications, which is the fundamental requirement of a Crynux Node.

</details>

## Node is not Working as Expected

<details>

<summary>Node manager init error: Failed to download models due to network issue</summary>

### If you are using the Windows binary release

please find the log file according to this document:

[Locate the Error Message](locate-the-error-message.md)

If there are error messages similar to:

```
FileNotFoundError: [Errno 2] No such file or directory: 'C:\\Users\\...\\crynux-node-helium-v2.0.7-windows-x64\\crynux-node-helium-v2.0.7-windows-x64\\data\\huggingface\\models--stabilityai--stable-diffusion-xl-base-1.0\\snapshots\\462165984030d82259a11f4367a4eed129e94a7b\\unet\\diffusion_pytorch_model.fp16.safetensors'
```

It is due to the long path limitation on Windows. Please enable the long path support according to this guide, and then restart the computer:

**Enable Long Path Support on Windows**

Open the Windows Registry Editor by pressing `Win + R` and typing `regedit`. Navigate to `HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\FileSystem`. Find the `LongPathsEnabled` DWORD (create it if not exist) and set its value to `1`.

### Otherwise

Make sure you could connect to Huggingface on the device running the node. If you are using a proxy, please provide the proxy config to the node according to the doc:

[Proxy Settings](../node-hosting/proxy-settings.md)

</details>

<details>

<summary>Node manager init error: The initial inference task exceeded the timeout limit(5 min)</summary>

Your computer is too slow to run a Crynux Node. If the time required for your node to finish a task exceeds the timeout period, other nodes will abort the task since they do not want to waste more time on the waiting. And your node will get no reward at all.

Besides, more timeout on the tasks will decrease the QoS score of your node, which will eventually cause your node being kicked out of the network.

Please use a more powerful device to run the node instead. To understand the details, please refer to:

[Quality of Service (QoS)](../system-design/quality-of-service-qos.md)

</details>

<details>

<summary>The node status shows <code>Stopped</code> after running for a while</summary>

If there is no other error messages shown, the node is probably kicked out of the network due to frequent timeout on tasks.

* You may be running more nodes than your GPU could handle
* Your device may not be powerful enough to run a node

If the node has a slow GPU, or poor network, the task submission will be slow. If the time required to finish a task exceeds the timeout period, other nodes will abort the task since they do not want to waste more time on the waiting.

More timeout on the tasks will decrease the QoS score of the timeout node, which will eventually cause the node being kicked out of the network. It is not a slashing though, the staked tokens are still safe. The details can be found in the doc:

[Quality of Service (QoS)](../system-design/quality-of-service-qos.md)

</details>

<details>

<summary>Failed to execute script 'main' ... 5 validation errors for Config</summary>

If the following popup shows when starting the node on Windows:

<img src="../.gitbook/assets/image (1).png" alt="" data-size="original">

Please check your anti-virus software for deletion or quarantine of the files of the Node. The config file might have be deleted.

</details>
