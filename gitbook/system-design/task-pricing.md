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

Queue priority changes only dispatch order. It does not extend or shorten the queue deadline.

## Task Execution Time

$$T$$ is Relay's estimate of how long the selected node will spend from task start until it submits a score or reports a task error. The estimate is calibrated from successful tasks, separately for each GPU variant and model configuration. Stable Diffusion fine-tuning does not use this estimate; it keeps the creator-supplied timeout.

How the estimate is built, how Stable Diffusion and LLM workloads are measured, and how to query the current coefficients from Relay are described here:

{% content-ref url="task-execution-time.md" %}
[task-execution-time.md](task-execution-time.md)
{% endcontent-ref %}

The priority and its workload values are fixed when the task is created. Later calibration changes do not reorder an existing queued task.

## Node Capacity Weight

Besides the execution time, tasks also differ in the kind of node they require. A task demanding a large amount of VRAM can only run on the high-end nodes, which are scarcer in the network, while a lightweight task can run on almost any node.

If the queue ordering considered time alone, a task occupying a scarce high-end node would be treated the same as a task occupying an abundant low-end node for the same duration, even though the former consumes a much more valuable resource.

To account for this, the priority calculation applies a weight based on the VRAM requirement of the task: the more VRAM a task requires beyond the baseline, the proportionally larger its weight, and the more fee it needs to pay to reach the same priority. Tasks whose VRAM requirement is at or below the baseline all share the same weight of 1.

The weight only affects the ordering of the waiting queue. It changes neither the task fee charged to the creator, nor which nodes are eligible to execute the task.
