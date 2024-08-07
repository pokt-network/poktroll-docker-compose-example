# Poktrolld Docker-Compose Example <!-- omit in toc -->

- [TODOs](#todos)
- [Key Terms](#key-terms)
- [Understanding Actors in the Shannon upgrade](#understanding-actors-in-the-shannon-upgrade)
- [Prerequisites](#prerequisites)
  - [0. Software \& Tooling](#0-software--tooling)
  - [1. Clone the Repository](#1-clone-the-repository)
  - [2. Operational Helpers](#2-operational-helpers)
  - [3. Environment Variables](#3-environment-variables)
- [A. Deploying a Full Node](#a-deploying-a-full-node)
  - [1. Launch the Node](#1-launch-the-node)
- [2. Inspecting the Full Node](#2-inspecting-the-full-node)
  - [CometBFT Status](#cometbft-status)
  - [Latest Block](#latest-block)
  - [Watch the height](#watch-the-height)
  - [3. Get a way to fund your accounts](#3-get-a-way-to-fund-your-accounts)
    - [3.1 Funding using a Faucet](#31-funding-using-a-faucet)
    - [\[Requires Grove Team Support\] 3.2 Funding using faucet account](#requires-grove-team-support-32-funding-using-faucet-account)
  - [4. Restarting a full node after re-genesis](#4-restarting-a-full-node-after-re-genesis)
  - [5. Docker image updates](#5-docker-image-updates)
- [B. Creating a Supplier and Deploying a RelayMiner](#b-creating-a-supplier-and-deploying-a-relayminer)
  - [0. Prerequisites for a RelayMiner](#0-prerequisites-for-a-relayminer)
  - [1. Create, configure and fund a Supplier account](#1-create-configure-and-fund-a-supplier-account)
  - [2. Configure and stake your Supplier](#2-configure-and-stake-your-supplier)
  - [3. Configure and run your RelayMiner](#3-configure-and-run-your-relayminer)
- [C. Deploying an AppGate Server](#c-deploying-an-appgate-server)
  - [0. Prerequisites for an AppGate Server](#0-prerequisites-for-an-appgate-server)
  - [1. Create, configure and fund your Application](#1-create-configure-and-fund-your-application)
  - [2. Configure and stake your Application](#2-configure-and-stake-your-application)
  - [3. Configure and run your AppGate Server](#3-configure-and-run-your-appgate-server)
  - [4. Send a relay](#4-send-a-relay)
- [D. Deploying an Gateway Server](#d-deploying-an-gateway-server)
  - [0. Prerequisites for a Gateway Server](#0-prerequisites-for-a-gateway-server)
  - [1. Create, configure and fund your Gateway](#1-create-configure-and-fund-your-gateway)
  - [2. Configure and stake your Gateway](#2-configure-and-stake-your-gateway)
  - [3. Configure and run your Gateway Server](#3-configure-and-run-your-gateway-server)
  - [6. Delegate your Application to the Gateway](#6-delegate-your-application-to-the-gateway)
  - [5. Send a relay](#5-send-a-relay)

## TODOs

- [ ] Copy-paste the image from [Shannon actors documentation](https://dev.poktroll.com/actors) here
- [ ] Move this documentation to [dev.poktroll.com](https://dev.poktroll.com)
- [ ] Create a table comparing the actors in `Morse` and `Shannon`
- [ ] Simplify the copy-pasta commands by leveraging `helpers.sh`
- [ ] Publicly expose [this document](https://www.notion.so/buildwithgrove/How-to-re-genesis-a-Shannon-TestNet-a6230dd8869149c3a4c21613e3cfad15?pvs=4)
      on how to do a re-genesis
- [ ] Pre-stake some applications on TestNet others can reuse to get started sooner

## Key Terms

- `Morse` - The current version of the Pocket Network MainNet (a.k.a v0).
- `Shannon` - The upcoming version of the Pocket Network MainNet (a.k.a v1).
- `Validator` - A node that participates in the consensus process.
  - In `Morse`Same in `Morse` and `Shannon`.
  - In `Shannon`
- `Node` - A `Morse` actor that stakes to provide Relay services.
  - In `Morse` - All `Validator` are nodes but only the top 1000 stakes `Node`s are `Validator`s
  - This actor is not present in `Shannon` and decoupled into `Supplier` and a `RelayMiner`.
- `Supplier` - The on-chain actor that stakes to provide Relay services.
  - In `Shannon` - This actor is responsible needs access to a Full Node (sovereign or node).
- `RelayMiner` - The off-chain service that provides Relay services on behalf of a `Supplier`.
  - In `Shannon` - This actor is responsible for providing the Relay services.
- `AppGate Server` - The off-chain service that provides Relay services on behalf of an `Application` or `Gateway`.

For more details, please refer to the [Shannon actors documentation](https://dev.poktroll.com/actors).

## Understanding Actors in the Shannon upgrade

For those familiar with `Morse`, Pocket Network Mainnet, the introduction of
multiple node types in the upcoming `Shannon` requires some explanation.

In `Shannon`, the `Supplier` role is separated from the `Full node` role.

In `Morse`, a `Validator` or a staked `Node` was responsible for both holding
a copy of the on-chain data, as well as performing relays. With `Shannon`, the
`RelayMiner` software, which runs the supplier logic, is distinct from the full-node/validator.

Furthermore, `Shannon` introduces the `AppGate Server`, a software component that
acts on behalf of either `Applications` or `Gateways` to access services provided
by Pocket Network `Supplier`s via `RelayMiners`.

For more details, please refer to the [Shannon actors documentation](https://dev.poktroll.com/actors).

## Prerequisites

_Note: the system must be capable of exposing ports to the internet for
peer-to-peer communication._

### 0. Software & Tooling

Ensure the following software is installed on your system:

- [git](https://github.com/git-guides/install-git)
- [Docker](https://docs.docker.com/engine/install/)
- [docker-compose](https://docs.docker.com/compose/install/#installation-scenarios)

### 1. Clone the Repository

```bash
git clone https://github.com/pokt-network/poktroll-docker-compose-example.git
cd poktroll-docker-compose-example
```

### 2. Operational Helpers

Run the following command, or add it to your `~/.bashrc` to have access to helpers:

```bash
source helpers.sh
```

### 3. Environment Variables

Create and configure your `.env` file from the sample:

```bash
cp .env.sample .env
```

Update `NODE_HOSTNAME` in `.env` to the IP address or hostname of your node. For example:

```bash
sed -i -e s/NODE_HOSTNAME=/NODE_HOSTNAME=69.42.690.420/g .env
```

## A. Deploying a Full Node

### 1. Launch the Node

_Note: You may need to replace `docker-compose` with `docker compose` if you are
running a newer version of Docker where `docker-compose` is integrated into `docker` itself._

Initiate the node with:

```bash
docker-compose up -d poktrolld
```

Monitor node activity through logs with:

```bash
docker-compose logs -f --tail 100 poktrolld
```

## 2. Inspecting the Full Node

If you run `docker ps`, you should see a `full_node` running which you can inspect
using the commands below.

### CometBFT Status

```bash
curl -s -X POST localhost:26657/status | jq
```

### Latest Block

```bash
curl -s -X POST localhost:26657/block | jq
```

### Watch the height

```bash
watch -n 1 "curl -s -X POST localhost:26657/block | jq '.result.block.header.height'"
```

### 3. Get a way to fund your accounts

Throughout these instructions, you will need to fund your account with tokens
at multiple points in time.

#### 3.1 Funding using a Faucet

When you need to fund an account, you can make use of the [Faucet](https://faucet.testnet.pokt.network/).

#### [Requires Grove Team Support] 3.2 Funding using faucet account

If you require a larger amount of tokens or are a core contributor, you can add the `faucet`
account to fund things yourself directly.

```bash
poktrolld keys add --recover -i faucet
```

When you see the `> Enter your bip39 mnemonic` prompt, paste the mnemonic
provided by the Pocket team for testnet.

When you see the `> Enter your bip39 passphrase. This is combined with the mnemonic to derive the seed. Most users should just hit enter to use the default, ""`
prompt, hit enter without adding a passphrase. Finish funding your account by using the command below:

You can view the balance of the faucet address at [shannon.testnet.pokt.network/](https://shannon.testnet.pokt.network/).

### 4. Restarting a full node after re-genesis

If the team has completed a re-genesis, you will need to wipe existing data
and restart your node from scratch. The following is a quick and easy way to
start from a clean slate:

```bash

# Stop & remove existing containers
docker-compose down
docker rm $(docker ps -aq) -f

# Remove existing data and renew genesis
rm -rf poktrolld-data/config/addrbook.json poktrolld-data/config/genesis.json poktrolld-data/data/

# Re-start the node
docker-compose up -d
docker-compose logs -f --tail 100
```

### 5. Docker image updates

The `.env` file contains `POKTROLLD_IMAGE_TAG` which can be updated based on the
images available on [ghcr](https://github.com/pokt-network/poktroll/pkgs/container/poktrolld/versions)
to update the version of the `full_node` deployed.

## B. Creating a Supplier and Deploying a RelayMiner

A Supplier is an on-chain record that advertises services it'll provide.

A RelayMiner is an operator / service that provides services to offer on the Pocket Network.

### 0. Prerequisites for a RelayMiner

- **Full Node**: This RelayMiner deployment guide assumes the Full Node is
  deployed in the same `docker-compose` stack; see section (A).
- **A poktroll account with uPOKT tokens**: Tokens can be acquired by contacting
  the team or using the faucet. You are going to need a BIP39 mnemonic phrase for
  an existing funded account before continuing below.

### 1. Create, configure and fund a Supplier account

On the host where you started the full node container, run the commands below to
create your account.

Create a new `supplier` account:

```bash
poktrolld keys add supplier-1
```

1. Copy the mnemonic that's printed to the screen to the `SUPPLIER_MNEMONIC`
   variable in your `.env` file.

   ```bash
   export SUPPLIER_MNEMONIC="foo bar ..."
   ```

2. Save the outputted address to a variable for simplicity::

   ```bash
   export SUPPLIER_ADDR="pokt1..."
   ```

Make sure to:

```bash
source .env
```

And fund your supplier account:

```bash
poktrolld tx bank send faucet $SUPPLIER_ADDR 10000upokt --chain-id=poktroll --yes
```

You can check that your address is funded correctly by running:

```bash
poktrolld query bank balances $SUPPLIER_ADDR
```

If you're waiting to see if your transaction has been included in a block, you can run:

```bash
poktrolld query tx --type=hash <hash>
```

### 2. Configure and stake your Supplier

:::tip Supplier staking config

[dev.poktroll.com/operate/configs/supplier_staking_config](https://dev.poktroll.com/operate/configs/supplier_staking_config)
explains what supplier staking config is and how it can be used.

:::

Verify that the account you're planning to use for `SUPPLIER` (created above)
is available in your local Keyring:

```bash
poktrolld keys list --list-names | grep "supplier-1"
```

Update the provided example supplier stake config:

```bash
sed -i -e s/YOUR_NODE_IP_OR_HOST/$NODE_HOSTNAME/g ./stake_configs/supplier_stake_config_example.yaml
```

Use the configuration to stake your supplier:

```bash
poktrolld tx supplier stake-supplier --config=./stake_configs/supplier_stake_config_example.yaml --from=supplier-1 --chain-id=poktroll --yes
```

:::warning Upstaking to restake

If you need to change any of the configurations in your staking config, you MUST
increase the stake by at least one uPOKT. This is the `stake_amount` field
in the `supplier_stake_config_example.yaml` file above.

:::

Verify your supplier is staked:

```bash
poktrolld query supplier show-supplier $SUPPLIER_ADDR
```

### 3. Configure and run your RelayMiner

:::tip RelayMiner operation config

[dev.poktroll.com/operate/configs/relayminer_config](https://dev.poktroll.com/operate/configs/relayminer_config)
explains what the RelayMiner operation config is and how it can be used.

:::

Update the provided example RelayMiner operation config:

```bash
sed -i -e s/YOUR_NODE_IP_OR_HOST/$NODE_HOSTNAME/g relayminer-example/config/relayminer_config.yaml
```

Update the `backend_url` in `relayminer_config.yaml` with a valid `0021` (i.e. ETH MainNet)
service URL. We suggest using your own node, but you can get one from Grove for testing purposes.

```bash
sed -i -e s/backend_url: ""/backend_url: "https://eth-mainnet.rpc.grove.city/v1/<APP_ID>"/g relayminer-example/config/relayminer_config.yaml
```

Start up the RelayMiner:

```bash
docker-compose up -d relayminer-example
```

Check logs and confirm the node works as expected:

```bash
docker-compose logs -f --tail 100 relayminer-example
```

## C. Deploying an AppGate Server

AppGate Server allows to use services provided by other operators on Pocket Network.

### 0. Prerequisites for an AppGate Server

- **Full Node**: This AppGate Server deployment guide assumes the Full Node is
  deployed in the same docker-compose stack; see section A.
- **A poktroll account with uPOKT tokens**: Tokens can be acquired by contacting
  the team. You are going to need a BIP39 mnemonic phrase for an existing
  funded account.

### 1. Create, configure and fund your Application

On the host where you started the full node container, run the commands below to
create your account.

Create a new `application` account:

```bash
poktrolld keys add application-1
```

1. Copy the mnemonic that's printed to the screen to the `APPLICATION_MNEMONIC`
   variable in your `.env` file.

   ```bash
   export APPLICATION_MNEMONIC="foo bar ..."
   ```

2. Save the outputted address to a variable for simplicity::

   ```bash
   export APPLICATION_ADDR="pokt1..."
   ```

Make sure to:

```bash
  source .env
```

And fund your application account:

```bash
poktrolld tx bank send faucet $APPLICATION_ADDR 10000upokt --chain-id=poktroll --yes
```

You can check that your address is funded correctly by running:

```bash
poktrolld query bank balances $APPLICATION_ADDR
```

Assuming the account you're planning to use for AppGate Server is already available in your local Keyring (can check with `poktrolld keys list`), create an application stake config and run the stake command. [This documentation page](https://dev.poktroll.com/operate/configs/app_staking_config) explains what application staking config is and how it can be used. This command can be used as an example:

```bash
poktrolld tx application stake-application --config=./stake_configs/application_stake_config_example.yaml --from=application-1 --chain-id=poktroll --yes
```

### 2. Configure and stake your Application

:::tip Application staking config

[dev.poktroll.com/operate/configs/application_staking_config](https://dev.poktroll.com/operate/configs/application_staking_config)
explains what application staking config is and how it can be used.

:::

Verify that the account you're planning to use for `APPLICATION` (created above)
is available in your local Keyring:

```bash
poktrolld keys list --list-names | grep "application-1"
```

Use the configuration to stake your application:

```bash
poktrolld tx application stake-application --config=./stake_configs/application_stake_config_example.yaml --from=application-1 --chain-id=poktroll --yes
```

Verify your application is staked

```bash
poktrolld query application show-application $APPLICATION_ADDR
```

### 3. Configure and run your AppGate Server

:::tip AppGate Server operation config

[dev.poktroll.com/operate/configs/appgate_server_config](https://dev.poktroll.com/operate/configs/appgate_server_config)
explains what the AppGate Server operation config is and how it can be used.

:::

appgate-server-example/config/appgate_config.yaml

```bash
docker-compose up -d appgate-server-example
```

Check logs and confirm the node works as expected:

```bash
docker-compose logs -f --tail 100 appgate-server-example
```

### 4. Send a relay

You can send requests to the newly deployed AppGate Server. If there are any
Suppliers on the network that can provide the service, the request will be
routed to them.

The endpoint you want to send request to is: `http://your_node:appgate_server_port/service_id`. For example, this is how the request can be routed to `ethereum`
represented by `0021`:

```bash
curl http://$NODE_HOSTNAME:85/0021 \
  -X POST \
  -H "Content-Type: application/json" \
  --data '{"method":"eth_blockNumber","params":[],"id":1,"jsonrpc":"2.0"}'
```

You should expect a result that looks like so:

```bash
{"jsonrpc":"2.0","id":1,"result":"0x1289571"}
```

## D. Deploying an Gateway Server

Gateway Server allows to use services provided by other operators on Pocket Network.

### 0. Prerequisites for a Gateway Server

- **Full Node**: This Gateway Server deployment guide assumes the Full Node is
  deployed in the same docker-compose stack; see section A.
- **A poktroll account with uPOKT tokens**: Tokens can be acquired by contacting
  the team. You are going to need a BIP39 mnemonic phrase for an existing
  funded account.

### 1. Create, configure and fund your Gateway

On the host where you started the full node container, run the commands below to
create your account.

Create a new `gateway` account:

```bash
poktrolld keys add gateway-1
```

1. Copy the mnemonic that's printed to the screen to the `GATEWAY_MNEMONIC`
   variable in your `.env` file.

   ```bash
   export GATEWAY_MNEMONIC="foo bar ..."
   ```

2. Save the outputted address to a variable for simplicity::

   ```bash
   export GATEWAY_ADDR="pokt1..."
   ```

Make sure to:

```bash
  source .env
```

And fund your gateway account:

```bash
poktrolld tx bank send faucet $GATEWAY_ADDR 10000upokt --chain-id=poktroll --yes
```

You can check that your address is funded correctly by running:

```bash
poktrolld query bank balances $GATEWAY_ADDR
```

### 2. Configure and stake your Gateway

:::tip Gateway staking config

[dev.poktroll.com/operate/configs/gateway_staking_config](https://dev.poktroll.com/operate/configs/gateway_staking_config)
explains what gateway staking config is and how it can be used.

:::

Verify that the account you're planning to use for `GATEWAY` (created above)
is available in your local Keyring:

```bash
poktrolld keys list --list-names | grep "gateway-1"
```

Use the configuration to stake your gateway:

```bash
poktrolld tx gateway stake-gateway --config=./stake_configs/gateway_stake_config_example.yaml --from=gateway-1 --chain-id=poktroll --yes
```

Verify your gateway is staked

```bash
poktrolld query gateway show-gateway $GATEWAY_ADDR
```

### 3. Configure and run your Gateway Server

:::tip Gateway Server operation config

[dev.poktroll.com/operate/configs/appgate_server_config](https://dev.poktroll.com/operate/configs/appgate_server_config)
explains what the Gateway Server operation config is and how it can be used.

:::

appgate-server-example/config/gateway_config.yaml

```bash
docker-compose up -d gateway-example
```

Check logs and confirm the node works as expected:

```bash
docker-compose logs -f --tail 100 gateway-example
```

### 6. Delegate your Application to the Gateway

poktrolld tx application delegate-to-gateway $GATEWAY_ADDR --from=application-1 --chain-id=poktroll --chain-id=poktroll --yes

### 5. Send a relay

You can send requests to the newly deployed Gateway Server. If there are any
Suppliers on the network that can provide the service, the request will be
routed to them.

The endpoint you want to send request to is: `http://your_node:gateway_server_port/service_id`. For example, this is how the request can be routed to `ethereum`
represented by `0021`:

```bash
curl http://$NODE_HOSTNAME:84/0021?applicationAddr=$APPLICATION_ADDR \
  -X POST \
  -H "Content-Type: application/json" \
  --data '{"method":"eth_blockNumber","params":[],"id":1,"jsonrpc":"2.0"}'
```

You should expect a result that looks like so:

```bash
{"jsonrpc":"2.0","id":1,"result":"0x1289571"}
```
