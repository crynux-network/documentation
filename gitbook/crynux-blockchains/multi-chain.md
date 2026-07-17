---
description: Crynux Multi-chain Architecture
---

# Crynux Multi-chain Architecture

The Crynux Network is built on a multi-chain architecture, operating across multiple EVM-compatible blockchains. It currently supports Base and Near, with future plans to expand the ecosystem to more blockchains.

The architecture has three layers:

* **L0 — Ethereum**: the canonical CNX ERC20 token lives on Ethereum, together with the Emission contract that releases new CNX according to the emission schedule. All CNX in circulation originates from this layer.
* **L1 — Base and Near**: CNX is bridged from Ethereum to each supported L1 network, where it becomes the CNX token on that network. On Base, this is done through the standard Optimism token bridge; on Near, through the Rainbow Bridge.
* **L2 — Crynux Blockchains**: on each L1, Crynux runs a dedicated L2 blockchain. CNX on the L1 is bridged to the L2, where it becomes the native gas token of the chain, similar to how ETH works on Ethereum mainnet. `Crynux on Base` is launched on top of Base using Arbitrum Orbit, and `Crynux on Near` will be launched on top of Near as a Virtual Chain by Aurora.

```mermaid
flowchart BT
  CRYNUX_BASE["Crynux on Base (L2)<br/>(Arbitrum Orbit Chain)<br/>Native Token"] <-- Standard Arbitrum Token Bridge --> BASE["Base (L1)<br/>OptimismMintableERC20"]
  CRYNUX_NEAR["Crynux on Near (L2)<br/>(Virtual Chain by Aurora)<br/>Native Token"] <-- Token Bridge --> NEAR["Near (L1)<br/>NEP-141"]
  BASE <-- Standard Optimism Token Bridge --> ETH["Ethereum (L0)<br/>ERC20 + Emission"]
  NEAR <-- Rainbow Bridge --> ETH
```

You can use the Crynux Portal at [portal.crynux.io](https://portal.crynux.io) to add networks easily: open the site, connect your wallet, choose the network you want, and the portal will automatically add the corresponding network to MetaMask.

## Ethereum (L0)

Ethereum is the top layer of the architecture. It hosts the canonical CNX ERC20 token, which defines the total CNX supply across all networks, and the Emission contract, which releases new CNX to the network participants according to the emission schedule. CNX on every other network is a bridged representation of the canonical token on Ethereum.

| Contract          | Address                                                                                                               |
| ----------------- | --------------------------------------------------------------------------------------------------------------------- |
| Crynux Token      | [0xa97998Bf97f5A6A96393b85B4e02A0440AE220F2](https://etherscan.io/token/0xa97998Bf97f5A6A96393b85B4e02A0440AE220F2)     |
| Emission Contract | [0x72666bA4dE68bB46b4dE59641af99346318016DD](https://etherscan.io/address/0x72666bA4dE68bB46b4dE59641af99346318016DD) |

{% hint style="warning" %}
Crynux Portal does NOT support direct deposits and withdrawals to Ethereum Network. To move CNX between Base and Ethereum, use their standard ERC20 bridge contracts.
{% endhint %}

## Crynux Relay

Payments in Crynux go through the Crynux Relay: users deposit CNX into their Relay account, spend and earn inside the Relay, and withdraw back on-chain anytime. As a result, the Relay always holds pooled user funds on-chain.

The Relay also makes cross-chain transfers easier for users: since deposits and withdrawals are supported on multiple networks, a user can deposit CNX on one network and withdraw it on another, without interacting with the underlying bridges directly. To serve withdrawals on every supported network, the Relay maintains a reserve of CNX on each of them, so its system wallets also hold the tokens backing these cross-chain reserves.

[Crynux Portal](https://portal.crynux.io) is the web frontend of the Relay. Through the Portal, users can access the Relay's cross-chain features: it supports direct deposits and withdrawals on Base and `Crynux on Base`, and can also be used to transfer CNX between Base and `Crynux on Base` without directly interacting with the native bridge contracts.

```mermaid
flowchart BT
  RELAY(("Crynux Relay")) <-- Deposit/Withdraw --> BASE["Base (L1)"]
  RELAY <-- Deposit/Withdraw --> CRYNUX_BASE["Crynux on Base (L2)"]
  RELAY <-. Coming Soon .-> NEAR["Near (L1)"]
  RELAY <-. Coming Soon .-> CRYNUX_NEAR["Crynux on Near (L2)"]
```

### System Wallets

The Relay uses a set of system wallets on-chain:

| Wallet             | Purpose                                                                                                                                                                                                                                                                                                                                          |
| ------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| Relay Deposit Address    | Pooled user deposits. This is where users send CNX to top up their Relay accounts. Its balance is simply the aggregate deposits of all Relay users, not funds owned by the team.                                                                                                                                                                   |
| Relay Hot Wallet  | Pays out Relay withdrawals. Its key lives on a server, and since any online key is a potential attack target, the hot wallet only keeps a small working balance.                                                                                                                                                                                   |
| Relay Cold Wallet | The Relay's cold-storage reserve. The key is kept fully offline. When the hot wallet runs low, it is manually refilled from cold storage. Even if the withdrawal server were fully compromised, only the small hot-wallet float would be at risk — never the main reserve.                                                                          |

The Relay deposit address and system wallets exist on every L1 and L2 network that supports Relay deposits and withdrawals. The addresses on each network are listed in the blockchain sections below. Currently, the Relay uses the same set of wallet addresses on Ethereum and Base.

{% hint style="danger" %}
To prevent phishing, make sure to cross-check the deposit address in the [Crynux Discord](https://discord.gg/y8YKxb7uZk) and [Crynux Portal](https://portal.crynux.io/) before making the transfer.
{% endhint %}

## Crynux Blockchains

{% tabs %}
{% tab title="Base" %}
### Base (L1)

Base is an Ethereum Layer 2 chain using Optimism. In the Crynux architecture, Base serves as an L1 network. The Relay uses the same set of wallet addresses on Base as on Ethereum.

| Item                     | Address                                                                                                             |
| ------------------------ | -------------------------------------------------------------------------------------------------------------------- |
| Crynux Token CA          | [0x9557DD9E241bc9636732623B672B4090AF519396](https://basescan.org/token/0x9557DD9E241bc9636732623B672B4090AF519396) |
| Relay Deposit Address    | [0x95dAd4af9aCaDEaf1704d3C980e7f571A9c5C5a0](https://basescan.org/address/0x95dAd4af9aCaDEaf1704d3C980e7f571A9c5C5a0) |
| Relay Hot Wallet  | [0x2Dc0538727d569cD40f7a2FcfD2749A3D62f44d9](https://basescan.org/address/0x2Dc0538727d569cD40f7a2FcfD2749A3D62f44d9) |
| Relay Cold Wallet | [0x552A7D01C9e854244cC04Fd3e6C47f9036132f74](https://basescan.org/address/0x552A7D01C9e854244cC04Fd3e6C47f9036132f74) |

### Crynux on Base (L2)

`Crynux on Base` is an Arbitrum Orbit chain launched on top of Base. It uses CNX as its native gas token.

| Item           | Value                           |
| -------------- | ------------------------------- |
| JSON RPC       | https://json-rpc.base.crynux.io |
| Chain ID       | 18896214                        |
| Token Symbol   | CNX                             |
| Decimal        | 18                              |
| Block Explorer | https://cnxscan.base.crynux.io  |

The Crynux Relay uses the following wallet addresses on `Crynux on Base`:

| Wallet             | Address                                    |
| ------------------ | ------------------------------------------ |
| Relay Deposit Address    | [0x95dAd4af9aCaDEaf1704d3C980e7f571A9c5C5a0](https://cnxscan.base.crynux.io/address/0x95dAd4af9aCaDEaf1704d3C980e7f571A9c5C5a0) |
| Relay Hot Wallet  | [0x2Dc0538727d569cD40f7a2FcfD2749A3D62f44d9](https://cnxscan.base.crynux.io/address/0x2Dc0538727d569cD40f7a2FcfD2749A3D62f44d9) |
| Relay Cold Wallet | [0x552A7D01C9e854244cC04Fd3e6C47f9036132f74](https://cnxscan.base.crynux.io/address/0x552A7D01C9e854244cC04Fd3e6C47f9036132f74) |
{% endtab %}

{% tab title="Near" %}
{% hint style="info" %}
Coming soon. The Near network is still being deployed and will be available shortly.
{% endhint %}

### Near (L1)

The Crynux Token on Near is bridged from the canonical CNX ERC20 token on Ethereum through the Rainbow Bridge.

### Crynux on Near (L2)

`Crynux on Near` will be launched on top of Near as a Virtual Chain by Aurora, using CNX as its native gas token.
{% endtab %}
{% endtabs %}
