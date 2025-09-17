---
description: Find the best node to execute the task
---

# Task Dispatching

When creating a task, the application can specify criteria such as the minimum VRAM requirement or restrict the node selection to a specific GPU model. The blockchain will identify all eligible nodes that meet the criteria and then randomly select one from these candidates.

If no available nodes meet the criteria, the task will be added to the queue to await more nodes. When a node satisfying the criteria is freed, the highest-price task from the queue will be assigned to this available node.

To optimize task execution speed while maintaining consensus strength, nodes are selected randomly from candidates with different probabilities. Factors influencing a node's selection probability include its local model cache and QoS score. Nodes with faster GPUs, superior networks, fewer timeouts, or locally cached models needed for the task will have a higher likelihood of selection.

The details of the task dispatching algorithm are described in the following sections.

<figure><img src="../.gitbook/assets/fd705dac6f56dab6fcc30062a56561d.png" alt=""><figcaption><p>Task Dispatching Overview</p></figcaption></figure>

## Assigning Task to the Nodes

The nodes on the blockchain are first grouped by their card model, such as the Nvidia RTX 4090 group and the RTX 3080 group. These card model groups are then further grouped by their VRAM size. For example, the 16GB VRAM group may include the RTX 4080, RTX 3080, and RTX 4000 Ada groups. The blockchain will use these card groups to select candidates for a task.

If the application sets `Required GPU` in the task parameters, only the group with the required GPU model will be selected as the candidates. Otherwise, all the groups with VRAM equal to or larger than the task's requirement are chosen as candidates.

The node will then be selected from all the candidates using the following algorithm:

### Node Selection Algorithm

To ensure the fastest possible task execution, the selection algorithm first considers the model storage of the candidate nodes:

#### Model Storage

Initially, the selection is restricted exclusively to nodes that have the model stored locally. Crynux Network uses an on-chain registry to determine which nodes have already downloaded the model. If idle nodes are available in this group, one is selected randomly based on the selection probability factors described below.

If all such nodes are busy, the selection expands to other nodes that meet the task criteria. This event also triggers the model distribution process, prompting an equivalent number of other eligible nodes to begin downloading the model. For more details, refer to the following document:

{% content-ref url="model-distribution.md" %}
[model-distribution.md](model-distribution.md)
{% endcontent-ref %}

The process is illustrated in the following diagram:

```mermaid
graph TD
    A[New Task] --> B{Idle node with local model available?};
    B -- Yes --> C[Select a node from this group];
    C --> D[Dispatch Task];
    B -- No --> E{Other eligible nodes available?};
    E -- Yes --> F[Select a node from this group];
    F --> G[Dispatch Task];
    F --> H[Trigger Model Distribution];
    H --> I[Prompt other eligible nodes to download the model];
    E -- No --> J[Enqueue Task];
```


#### Node Selection Probability

Once a group of candidate nodes has been identified, one node is chosen to execute the task. The selection is made through a weighted random process, where each node's probability of being chosen is proportional to a weight calculated from the factors described below. This method ensures that nodes that are better suited for the task are more likely to be selected.

*1. Model in Memory*

When a node's immediately preceding task utilized the same model required for the current one, it is highly probable the model remains in memory (VRAM). Selecting such a node circumvents the model loading process, which significantly accelerates task startup. Consequently, these nodes receive a higher selection probability.

The Model in Memory score ($$M_i$$) for a node $$i$$ is defined as:

$$
M_i = \begin{cases} 2 & \text{if model is in memory} \\ 1 & \text{otherwise} \end{cases}
$$

*2. Staking*

To align a node's economic incentives with the long-term health and security of the network, the amount of staked tokens is a key factor in the selection probability. Nodes with a higher stake are given a higher probability of being assigned tasks.

A Staking Score ($$S_i$$) for a node $$i$$ is calculated by normalizing the square root of its staked amount against the maximum square root of stake in the network:

$$
S_i = \frac{ \sqrt{s_i} } { \max( \sqrt{s_j} \mid j \in N ) }
$$

Where $$s_i$$ is the amount staked by node $$i$$, and $$\max( \sqrt{s_j} \mid j \in N )$$ is the maximum square root of the staked amount among all nodes $$N$$.

This square-root staking dampens the marginal advantage of very large stakes, similar in spirit to quadratic voting. Doubling the stake increases the score by only $$\sqrt{2}$$ rather than 2, which reduces large-holder dominance and helps prevent monopolization, while still rewarding meaningful economic commitment and preserving Sybil resistance.

This design is fundamental to network security, as it significantly raises the cost of a successful Sybil attack. To successfully disrupt the network, an attacker's malicious nodes must be selected to perform tasks. Because the network prioritizes nodes with a higher stake for task assignment, an attacker cannot rely on a large number of cheap, low-stake nodes. Instead, they are forced to consolidate their capital into high-stake nodes just to be considered for selection.

This directly ties the cost of an attack to the cost of controlling the network's most trusted and active participants. It forces the attacker to lock up significant funds in the very nodes they wish to use for malicious purposes, dramatically increasing the economic risk and capital required to disrupt a meaningful portion of the network's operations. This makes the entire system more resilient by making attacks economically impractical.

*3. QoS Score*

A node's performance is determined by its underlying hardware; for example, GPUs with higher clock speeds execute tasks more quickly, and superior network connectivity leads to faster result submission. To encourage faster task execution, Crynux Network prioritizes faster nodes by giving them higher selection probabilities.

To prevent nodes from reporting fake frequencies and GPU models, Crynux Network uses the calculated `Submission Speed Score` instead of the reported frequencies. This score evaluates nodes by comparing their speed in a task validation group. Nodes that complete the task faster receive a higher QoS score and are thus more likely to be selected for future tasks.

Details about the QoS scores can be found in the following document:

{% content-ref url="quality-of-service-qos.md" %}
[quality-of-service-qos.md](quality-of-service-qos.md)
{% endcontent-ref %}

*4. Final Selection Weight*

The final selection weight for a node is calculated by combining the scores from the factors above.

To ensure a node is both secure (high stake) and performant (high QoS), the Staking and QoS scores are combined using the harmonic mean (`2 * S_i * Q_i / (S_i + Q_i)`). This method penalizes imbalance; a node cannot compensate for a very low QoS score with a high stake, or vice-versa.

The final weight `W_i` is calculated by multiplying this harmonic mean by the `Model in Memory` score (`M_i`). To normalize the final weight to a value between 0 and 1, the result is divided by 2 (the maximum possible value for `M_i`).

The simplified formula is defined as:

$$
W_i = \frac{M_i \cdot S_i \cdot Q_i}{S_i + Q_i}
$$

Where:

*   $$W_i$$ is the final selection weight for node $$i$$.
*   $$M_i$$ is the node's Model in Memory score.
*   $$S_i$$ is the node's Staking Score.
*   $$Q_i$$ is the node's QoS Score.

The probability of a node being selected is then its individual weight divided by the sum of the weights of all candidate nodes.

If there are not enough candidate nodes to be selected from, the task will be added to the task queue and wait for more nodes to become available.

## Task Queue

Tasks added to the queue are grouped based on VRAM and GPU model requirements. Initially, tasks are sorted into VRAM groups (e.g., 16GB, 24GB). Within these groups, tasks are further categorized by GPU model (e.g., 4090, A100). If no specific GPU model is required, tasks are placed in an "Any" group.

Tasks within the same group are sorted by **task value**. When a task is taken from the queue, the task with the highest value is prioritized. The task value, represented as "CNX per second", is calculated by dividing the task fee by the estimated execution time. For more details on task value estimation, refer to the following document:

{% content-ref url="task-pricing.md" %}
[task-pricing.md](task-pricing.md)
{% endcontent-ref %}

### Dequeue a Task for a Newly Available Node

The blockchain will try to retrieve a task from the task queue when a new node becomes available. Which will happen when one of the following situations occurs:

* A running task is finished.
* A new node joins the network.
* A node resumes from the paused status.

> When a new task is sent to the blockchain, it attempts to dispatch the task immediately to the nodes, regardless of the task queue’s status. Tasks remain in the queue only if there are not enough **matching** nodes available. Even if the task queue isn't empty, there might still be available nodes in the network matching the new task, providing a chance for the new task to execute first.

Depending on the GPU model and the VRAM size of the node, the candidate task groups including:

* The task group of the same GPU model
* The "Any" groups that have a equal or smaller VRAM requirement

The first tasks of each candidate group are compared, and the task with the highest value is selected.

### Max Size of the Task Queue

The max size of the task queue is estimated dynamically using the total number of nodes of the network:

$$
S = \alpha * N
$$

Where $$N$$ is the number of nodes in the network, and $$\alpha$$ is a fixed multiplier that will be set as the network parameter.

If the max size is reached, when a new task is sent to the task queue, the task with the lowest task value in the queue will be removed and aborted. The task creator of the removed task will receive the `TaskAborted` event.
