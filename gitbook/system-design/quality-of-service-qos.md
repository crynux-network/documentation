# Quality of Service (QoS)

To encourage nodes to provide better service to the network — faster execution, reliable availability, and fewer failures — the QoS (Quality of Service) system evaluates each node's performance and directly influences its role in the network.

The QoS score of a node is continuously updated as it executes tasks. It combines two factors operating at different time scales — a long-term performance factor and a short-term reliability factor — so that the score reflects both a node's sustained hardware quality and its current operational status. The score is then used to influence several key aspects of the network's operation, including task allocation priority, reward distribution, and node removal decisions.

By giving more advantages to higher-scoring nodes, the network encourages nodes to improve their hardware and network environment, thereby improving the overall service quality for applications.

## QoS Score Usage

### Task Allocation Priority

A node's QoS score directly affects its probability of being selected for new tasks. Nodes with higher QoS scores are more likely to be chosen, ensuring that high-performing nodes handle more work and earn more rewards. For the detailed selection mechanism, see:

{% content-ref url="task-dispatching.md" %}
[task-dispatching.md](task-dispatching.md)
{% endcontent-ref %}

### Bad Node Removal

If a node consistently underperforms over a sustained period, the node is permanently removed from the network. This prevents persistently underperforming nodes — such as those that have been shut down without properly leaving the network — from degrading application experience. See [Permanent Kickout](#permanent-kickout) for details.

## Node QoS Score

The QoS score evaluates node quality through two factors that operate at different time scales:

- **Long-term performance factor**: A rolling average of recent validation task scores that captures whether a node is consistently fast.
- **Short-term reliability factor**: A multiplier that reacts immediately to timeout failures, capturing whether a node is currently dependable.

A single long-term average alone would react too slowly to sudden failures — a node could time out on many consecutive tasks before its score drops meaningfully. Conversely, relying only on short-term signals would make the score too volatile and fail to reflect a node's true hardware quality. By combining both, the QoS score can immediately suppress unreliable nodes (protecting applications) while still accurately ranking nodes by their sustained performance (rewarding better hardware).

The final QoS score for a node $$i$$ is the product of both factors:

$$
QoS_i = \frac{Q_{long}}{Q_{max}} \times H
$$

Where $$Q_{long}$$ is the node's long-term performance score (rolling average of task scores), $$Q_{max} = 10$$ is the maximum possible task score, and $$H$$ is the short-term reliability factor (range 0 to 1). New nodes that have not yet completed any validation tasks are assigned a default long-term score equivalent to $$Q_{long} / Q_{max} = 0.5$$.

### Long-term Performance Factor

The long-term factor measures a node's sustained execution speed across its recent validation tasks. It changes gradually and reflects the node's typical hardware and network quality.

#### Task Score

To measure performance objectively, the network uses **validation task groups** where the same task is assigned to multiple nodes (typically 3) simultaneously. The network measures the time each node takes to submit its result. The nodes in the group are ranked by execution speed, and each receives a fixed task score based on its ranking:

<figure><img src="../.gitbook/assets/96ba525e88bb1faabe5d1c376193601.png" alt=""><figcaption><p>The task score of a node by its submission order and status</p></figcaption></figure>

Faster submissions earn a higher task score, directly rewarding nodes for improving all factors that affect submission speed — GPU performance, network quality, memory bandwidth, and system optimization.

{% hint style="info" %}
If a node's task is aborted before the group validation completes, it receives a task score of 0. If **all 3 tasks** in a group are aborted (likely due to a misconfigured or invalid application task), the scores are set to NULL and excluded from the rolling average entirely, so that application-caused failures do not penalize any node.
{% endhint %}

#### Rolling Average

Each node maintains a long-term performance score that represents its recent performance. This is a **rolling average** of the task scores from its most recent validation tasks.

The system keeps a rolling pool of the last **50 task scores** for each node. When a new task score arrives, it is appended to the pool. If the pool exceeds 50 entries, the oldest entry is removed. The long-term score is the **arithmetic mean** of all scores in the pool:

$$
Q_{long} = \frac{\sum_{j=1}^{n} {ts}_j}{n}
$$

Where $$n$$ is the number of task scores in the pool (up to 50), and $${ts}_j$$ is the task score for the $$j$$-th most recent validation task.

{% hint style="info" %}
The rolling pool approach means the long-term score reflects recent performance rather than lifetime history. A node that improves its hardware or network setup will see its score improve as new, higher scores push out older, lower ones.
{% endhint %}

### Short-term Reliability Factor

The long-term factor operates on a slow time scale — it takes many validation tasks to shift the 50-task rolling average. This means the long-term factor alone cannot protect applications from a node that suddenly starts failing. A node could time out on dozens of consecutive tasks before its long-term score degrades enough to trigger any consequence.

The short-term reliability factor addresses this gap. It is designed to balance two competing goals:

- **Application quality**: When a node times out, it should be immediately excluded from receiving further tasks so that applications are not affected by unreliable nodes.
- **Node protection**: An otherwise healthy node should not be permanently removed due to a short burst of failures (e.g., caused by invalid application tasks or transient network issues). It should be given a chance to recover and prove itself.

The mechanism achieves both by sharply reducing a failing node's QoS score on each timeout (protecting applications), while allowing the score to recover automatically over time and through successful task completions (protecting nodes). Each node carries a short-term reliability factor $$H$$ (range 0.0 to 1.0, default 1.0). This factor directly scales the node's QoS score:

- On each **timeout failure**, $$H$$ is immediately multiplied by a penalty factor (0.3), causing a sharp drop in the QoS score. Consecutive timeouts compound rapidly — two timeouts reduce the score to less than 10% of its original value.
- When $$H$$ drops below a **hard exclusion threshold** (0.1), the node is completely excluded from task selection. It receives zero tasks, which from the application's perspective is equivalent to the node being offline.
- The penalty is **temporary**. $$H$$ recovers through two complementary mechanisms: passive time-based recovery (exponential decay back toward 1.0) and active success-based recovery (a discrete boost for each successfully completed task).
- When a node **joins or re-joins** the network, $$H$$ is reset to 1.0.

#### Penalty on Timeout

Every time a task assigned to a node ends with a timeout, the short-term reliability factor is reduced:

$$
H_{new} = H_{current} \times 0.3
$$

The penalty compounds rapidly with consecutive timeouts:

| Consecutive Timeouts | Short-term Factor (H) | Effect |
|---------------------|-------------------|--------|
| 0 | 1.0 | Normal QoS score |
| 1 | 0.30 | 70% reduction in QoS score |
| 2 | 0.09 | Effectively excluded (below threshold) |
| 3 | 0.027 | Deep exclusion |

#### Hard Exclusion

When a node's short-term reliability factor drops below **0.1**, it is completely excluded from task selection — it receives zero tasks. The node automatically becomes eligible again as the factor recovers above the threshold through the recovery mechanisms described below.

#### Recovery

The penalty is temporary. A node's short-term reliability factor recovers through two complementary mechanisms:

**1. Passive time-based recovery.** Even if no tasks are assigned to the node, the factor slowly drifts back toward 1.0 over time. This follows an exponential curve with a 30-minute time constant:

$$
H(t) = H_{base} + (1 - H_{base}) \cdot (1 - e^{-(t - t_{base}) / \tau})
$$

Where $$\tau = 30$$ minutes. This means approximately 63% recovery after 30 minutes, 86% after 60 minutes, and 95% after 90 minutes. Passive recovery is critical because it is the **only** mechanism that works in the exclusion zone (where the node receives no tasks and therefore cannot earn success boosts).

**2. Active success-based recovery.** Every time the node completes a task successfully, the factor receives a discrete boost:

$$
H_{new} = \min(1.0, \ H_{current} + 0.15)
$$

This is faster than passive recovery and serves as a proof-of-work mechanism — a node that actively demonstrates it can complete tasks recovers faster than one that simply waits.

{% hint style="info" %}
The two recovery mechanisms are complementary across different ranges of H. In the **exclusion zone** (H < 0.1), the node receives no tasks, so only passive time-based recovery works — it slowly brings H back above the threshold. In the **low probability zone** (H = 0.1 ~ 0.3), the node starts receiving occasional tasks, and each success provides a meaningful relative boost. In the **moderate zone** (H > 0.3), success-based recovery becomes the dominant force, creating a positive feedback loop: each success increases H, which increases the QoS score, which increases selection probability, which leads to more tasks and more successes.
{% endhint %}

## Permanent Kickout

The permanent kickout mechanism removes nodes whose long-term performance demonstrates sustained poor quality. It uses the 50-task rolling average long-term score and evaluates two conditions, both of which must be true:

1. The node's long-term score has dropped below the kickout threshold (default: **2.0**).
2. The node has completed enough validation tasks to fill the rolling pool (default: **50 tasks**).

The second condition prevents premature removal of nodes that have only completed a few validation tasks — the system waits until there is a statistically meaningful sample before making a permanent decision.

When a node is kicked out:

- Its status is set to quit and it is removed from the active node pool.
- Its stake is returned (the node is **not slashed** — permanent kickout is distinct from cheating penalties).
- A kickout event is emitted on the blockchain.

Due to validation task sampling, a node must execute a large number of total tasks before the 50-task pool is full. Permanent kickout is a long-term backstop that catches nodes with genuinely persistent problems, while the short-term reliability factor handles immediate issues.
