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

Relay estimates only the selected node's execution time, from task start until the node submits a score or reports a task error. Waiting for application validation and uploading a validated result are separate deadline stages and are not included in this estimate.

For Stable Diffusion inference, the workload is:

$$
sd\_units = num\_images \times image\_width \times image\_height \times steps
$$

The estimated node time is the fixed execution overhead plus `sd_units` multiplied by the calibrated seconds per pixel-step.

For LLM inference, Relay deterministically encodes `messages`, `tools`, and `template_args` and measures the UTF-8 byte length as `input_bytes`. The estimated node time is:

$$
T = constant\_seconds + input\_bytes \times seconds\_per\_input\_byte + max\_new\_tokens \times seconds\_per\_output\_token
$$

The generation configuration uses its declared `max_new_tokens`, or the configured default when it is absent. Queue ordering does not reduce this value based on historical early stopping.

Stable Diffusion fine-tuning keeps its creator-supplied timeout and existing pricing rule.

### Automatic Calibration

Relay calibrates execution parameters from completed, validated tasks for each exact `(GPUName, GPUVram)` variant. A task that explicitly requires a GPU variant uses that variant's parameters directly.

A task without `RequiredGPU` uses an in-memory aggregate for its task type and VRAM demand. The aggregate includes calibrated variants whose VRAM is at least the demand and gives each compatible GPU variant equal weight. A successful calibration sample updates its exact GPU variant and immediately recalculates every initialized aggregate that includes that variant.

The parameter key intentionally excludes model ID, model architecture, dtype, quantization, scheduler, and other model configuration. Different models on the same exact GPU variant can therefore execute faster or slower than the estimate. This error affects queue priority and the Relay-owned execution timeout only. It does not affect validation, consensus, fee settlement, or slashing.

The priority and its workload values are fixed when the task is created. Later calibration changes do not reorder an existing queued task.

Queue priority changes only dispatch order. It does not extend or shorten the queue deadline.

## Node Capacity Weight

Besides the execution time, tasks also differ in the kind of node they require. A task demanding a large amount of VRAM can only run on the high-end nodes, which are scarcer in the network, while a lightweight task can run on almost any node.

If the queue ordering considered time alone, a task occupying a scarce high-end node would be treated the same as a task occupying an abundant low-end node for the same duration, even though the former consumes a much more valuable resource.

To account for this, the priority calculation applies a weight based on the VRAM requirement of the task: the more VRAM a task requires beyond the baseline, the proportionally larger its weight, and the more fee it needs to pay to reach the same priority. Tasks whose VRAM requirement is at or below the baseline all share the same weight of 1.

The weight only affects the ordering of the waiting queue. It changes neither the task fee charged to the creator, nor which nodes are eligible to execute the task.
