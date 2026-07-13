# Task Pricing

The capacity of the Crynux Network is limited by the total number of nodes (and the execution speed of the nodes). If there are more tasks than the network can handle, the tasks will have to wait in a queue for available nodes.

Crynux Network gives the task creator an option to pay more for a task to make it execute earlier than the others.

When the user creates a task, the total fee they are willing to pay for the task is given as an argument. The user can freely set the task fee to any value. Roughly speaking, a shorter waiting time is expected if the task fee is set higher.

However, the exact order of the tasks in the queue is not determined by the total fee directly, but by a **task priority**, which measures how much the task pays for each unit of node resource it is going to consume. A task that pays more for less resource consumption gets a higher priority.

This method allows for a more equitable distribution of the network resources across all tasks. Different tasks may differ significantly in how long they run and how powerful a node they require. By dividing the task fee by the estimated resource consumption, the system effectively identifies the tasks that provide optimal value—those that contribute a significant amount of fee without demanding an excessive portion of the network capacity. The calculation maintains a balance between efficient resource use and the satisfaction of the task creators.

## Task Priority

The task priority $$V$$ is calculated by:

$$
V = \frac{P}{T \times W}
$$

Where $$P$$ is the task fee given by the task creator, $$T$$ is the estimated task execution time, and $$W$$ is a weight representing the scarcity of the node capacity the task requires.

The priority is calculated once when the task is created, and stays fixed while the task is waiting in the queue. Tasks are dispatched in descending order of priority. If two tasks have exactly the same priority, the one created earlier goes first.

A task with a low priority will not wait forever: if it is still in the queue when its queue deadline is reached, the task is aborted and the task fee is fully refunded to the creator.

## Task Execution Time

The duration required to complete a task can fluctuate greatly based on the type of the task and the parameters involved. For example, generating 9 images in a Stable Diffusion task takes considerably longer than generating just 1 image. However, the increase in time is not directly proportional (i.e., not 9 times longer), because a significant portion of the processing time is devoted to network transportation, consensus protocol, and other non-generation activities.

The table below shows the calculation of task priority if we take only the image generation time into consideration. The first row is an SD task that generates 1 image, whose fee is set to 10 CNX by the user, and the second row is an SD task that generates 2 images, whose fee is set to 15 CNX:

<table><thead><tr><th>Task fee</th><th width="116">No. Images</th><th>Image time</th><th>Task Priority</th></tr></thead><tbody><tr><td>10 CNX</td><td>1</td><td>20s</td><td>0.5 CNX/s</td></tr><tr><td>15 CNX</td><td>2</td><td>40s</td><td>0.375 CNX/s</td></tr></tbody></table>

Apparently the second task takes 2 times longer than the first one. According to the calculation, the first task will be chosen to execute first because its priority is higher.

However, if we take the non-generation time into account, as shown in the table below, the second task becomes more worthy to be executed first:

| Task fee | No. Images | Image time | Non-image time | Task Priority |
| -------- | ---------- | ---------- | -------------- | ------------- |
| 10 CNX   | 1          | 20s        | 30s            | 0.2 CNX/s     |
| 15 CNX   | 2          | 40s        | 30s            | 0.214 CNX/s   |

To maximize the utilization of the node time, all the time-consuming activities must be taken into account when estimating the task execution time. The estimated execution time is therefore composed of two parts: a fixed overhead time, plus a workload-dependent generation time.

The overhead time covers the activities that are not related to the task arguments or the task type:

* Task arguments downloading
* Model preparation
* Waiting for the result verification
* Uploading the result to the relay

The generation time is estimated from the workload described in the task arguments, depending on the task type:

* **Image generation tasks**: the workload is measured by the number of images and the resolution of each image. Generating more images, or images at a higher resolution, is counted as a proportionally larger workload.
* **Text generation tasks**: the workload is measured by the maximum number of tokens the task is allowed to generate.
* **Fine-tuning tasks**: the execution timeout set by the task creator is used directly as the estimated execution time. Since a task is aborted once it exceeds its timeout, understating the timeout to gain a higher priority only causes the task to fail before completion, so the creator has no incentive to cheat on this value.

### Automatic Calibration

The estimation of how long a unit of workload takes—such as the time to generate one image, or one token—is not a hard-coded constant. The network continuously measures the actual execution time of the completed tasks, and uses these measurements to keep the estimation aligned with the real speed of the nodes.

As the nodes in the network upgrade their hardware, or the inference engines become faster, the time estimation adapts automatically, so the priority calculation always reflects the current real-world execution speed.

## Node Capacity Weight

Besides the execution time, tasks also differ in the kind of node they require. A task demanding a large amount of VRAM can only run on the high-end nodes, which are scarcer in the network, while a lightweight task can run on almost any node.

If the queue ordering considered time alone, a task occupying a scarce high-end node would be treated the same as a task occupying an abundant low-end node for the same duration, even though the former consumes a much more valuable resource.

To account for this, the priority calculation applies a weight based on the VRAM requirement of the task: the more VRAM a task requires beyond the baseline, the proportionally larger its weight, and the more fee it needs to pay to reach the same priority. Tasks whose VRAM requirement is at or below the baseline all share the same weight of 1.

The weight only affects the ordering of the waiting queue. It changes neither the task fee charged to the creator, nor which nodes are eligible to execute the task.
