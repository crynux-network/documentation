# Private Key Security

## Beneficial Address

### Keep funds off the node key

The node’s operational private key is a hot key that must remain online to sign requests and transactions. Any hot key is exposed to risks from malware, misconfiguration, or a compromised host. If that key also controls funds, an attacker can move them immediately after a breach. To safeguard funds, the system design should keep the node key strictly operational and separate from any address that holds or receives tokens.

### Beneficial address: concept and setup

A beneficial address is a separate cold wallet that receives all tokens associated with your node, including emissions, stake refunds, and Relay withdrawals. You bind your node address to this beneficial address with a one-time on-chain transaction; the binding is immutable. The private key of the beneficial address never needs to be online and is not used by the node or the Relay.

To set it up, create a new offline wallet for the beneficial address (for example, a hardware wallet or an air-gapped wallet), record the address securely, and submit the on-chain binding from your node address to the beneficial address. Then run your node with the operational (hot) key as usual.

### How it works

After you bind your node address to a beneficial address on-chain, that binding becomes the single source of truth for payouts. When emissions accrue, stake is refunded, or a Relay withdrawal is processed, the system looks up the on-chain binding and sends tokens to the beneficial address—never to the node address. The Relay independently reads the binding on-chain before sending, so a compromised UI or host cannot spoof the destination. Because the beneficial key remains offline, even if the node’s hot key is exposed, an attacker cannot change the binding or divert funds.

## Bind the Beneficial Address

Bind the beneficial address in Crynux Portal:

[https://portal.crynux.io](https://portal.crynux.io)

Connect the node’s operational wallet to the Portal to view the current binding and set a beneficial address in the dashboard.

The binding is per Crynux L2 chain, and you may set different beneficial addresses on different chains. Stake refunds and emissions are paid to the beneficial address bound on the chain where the node initially staked. Relay withdrawals let you choose a destination chain; tokens are sent to the beneficial address bound on that destination chain.
