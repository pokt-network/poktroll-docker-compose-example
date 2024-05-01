# Poktrolld Docker-Compose Example <!-- omit in toc -->

- [Key Terms](#key-terms)
- [TODOs](#todos)
- [Understanding Actors in the Shannon upgrade](#understanding-actors-in-the-shannon-upgrade)
- [Prerequisites](#prerequisites)
  - [0. Software \& Tooling](#0-software--tooling)
  - [1. Clone the Repository](#1-clone-the-repository)
  - [2. Operational Helpers](#2-operational-helpers)
  - [3. Environment Variables](#3-environment-variables)
- [A. Deploying a Full Node](#a-deploying-a-full-node)
  - [1. Download Network Genesis](#1-download-network-genesis)
  - [2. Launch the Node](#2-launch-the-node)
  - [3. Add PNF (funding) Account](#3-add-pnf-funding-account)
  - [4. Restarting a full node after re-genesis](#4-restarting-a-full-node-after-re-genesis)
- [Inspecting the Full Node](#inspecting-the-full-node)
  - [CometBFT Status](#cometbft-status)
  - [Latest Block](#latest-block)
- [B. Deploying a Relay Miner](#b-deploying-a-relay-miner)
  - [0. Prerequisites for a Relay Miner](#0-prerequisites-for-a-relay-miner)
  - [1. Create, configure and fund a RelayMiner account](#1-create-configure-and-fund-a-relayminer-account)
  - [2. Configure and stake your Supplier](#2-configure-and-stake-your-supplier)
  - [3. Configure and run your RelayMiner](#3-configure-and-run-your-relayminer)
- [C. Deploying an AppGate Server](#c-deploying-an-appgate-server)
  - [0. Prerequisites for an AppGate Server](#0-prerequisites-for-an-appgate-server)
  - [1. Stake your application](#1-stake-your-application)
  - [2. Configure AppGate Server and environment variables](#2-configure-appgate-server-and-environment-variables)
  - [3. Prepare and run AppGate Server containers](#3-prepare-and-run-appgate-server-containers)
  - [4. Send a relay](#4-send-a-relay)

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

## TODOs

- [ ] Copy-paste the image from [Shannon actors documentation](https://dev.poktroll.com/actors) here
- [ ] Move this documentation to dev.poktroll.com
- [ ] Create a table comparing the actors in `Morse` and `Shannon`
- [ ] Simplify the copy-pasta commands by leveraging `helpers.sh`
- [ ] Publicly expose [this document](https://www.notion.so/buildwithgrove/How-to-re-genesis-a-Shannon-TestNet-a6230dd8869149c3a4c21613e3cfad15?pvs=4)
      on how to do a re-genesis

## Understanding Actors in the Shannon upgrade

For those familiar with `Morse`, Pocket Network Mainnet,, the introduction of
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

_Note: he system must be capable of exposing ports to the internet for
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
sed -i -e  s/NODE_HOSTNAME/69.42.690.420/g .env
```

## A. Deploying a Full Node

### 1. Download Network Genesis

The Poktrolld blockchain deploys various networks: DevNet, TestNet, MainNet, etc...

Access the list of Poktrolld networks available for community participation at [Poktrolld Networks](https://github.com/pokt-network/pocket-network-genesis/tree/master/poktrolld).

Download and place the `genesis.json` for your chosen network (e.g., `testnet-validated`)
into the `poktrolld/config` directory:

E.g. Testnet-validated:

```bash
curl https://raw.githubusercontent.com/pokt-network/pocket-network-genesis/master/poktrolld/testnet-validated.json > poktrolld-data/config/genesis.json
```

### 2. Launch the Node

Note: You may need to replace `docker-compose` with `docker compose` if you are
running a newer version of Docker.

Initiate the node with:

```bash
docker-compose up -d
```

Monitor node activity through logs with:

```bash
docker-compose logs -f --tail 100
```

### 3. Add PNF (funding) Account

:::tip TODO: Faucet

Change to using `faucet` instead of `pnf`

:::

Add the `pnf` account to environment so you can fund all of your accounts

```bash
poktrolld keys add --recover -i pnf
```

When you see the `> Enter your bip39 mnemonic` prompt, paste the mnemonic
provided by the Pocket team for testnet.

When you see the `> Enter your bip39 passphrase. This is combined with the mnemonic to derive the seed. Most users should just hit enter to use the default, ""`
prompt, hit enter without adding a passphrase. Finish funding your account by using the command below:

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
curl https://raw.githubusercontent.com/pokt-network/pocket-network-genesis/master/poktrolld/testnet-validated.json > poktrolld-data/config/genesis.json

# Re-start the node
docker compose up -d
docker-compose logs -f --tail 100
```

## Inspecting the Full Node

### CometBFT Status

```bash
curl -s -X POST localhost:26657/status | jq
```

### Latest Block

```bash
curl -s -X POST localhost:26657/block | jq
```

## B. Deploying a Relay Miner

Relay Miner provides services to offer on the Pocket Network.

### 0. Prerequisites for a Relay Miner

- **Full Node**: This Relay Miner deployment guide assumes the Full Node is
  deployed in the same docker-compose stack; see section A.
- **A poktroll account with uPOKT tokens**: Tokens can be acquired by contacting
  the team. You are going to need a BIP39 mnemonic phrase for an existing
  funded account.

### 1. Create, configure and fund a RelayMiner account

On the host where you started the full node container, run the commands below to
create your account.

Create a new `RelayMiner` account:

```bash
poktrolld keys add relayminer-1
```

1. Copy the mnemonic that's printed to the screen to the `RELAYMINER_MNEMONIC`
   variable in your `.env` file.

   ```bash
   export RELAYMINER_MNEMONIC="foo bar ..."
   ```

2. Save the outputted address to a variable for simplicity::

   ```bash
   export RELAYMINER_ADDR="pokt1..."
   ```

```bash
poktrolld tx bank send pnf $RELAYMINER_ADDR 10000upokt --chain-id=poktroll --yes
```

You can check that your address is funded correctly by running:

```bash
poktrolld query bank balances $RELAYMINER_ADDR
```

### 2. Configure and stake your Supplier

:::tip Supplier staking config

[dev.poktroll.com/configs/supplier_staking_config](https://dev.poktroll.com/configs/supplier_staking_config)
explains what supplier staking config is and how it can be used.

:::

Verify that the account you're planning to use for `RelayMiner` (created above)
is available in your local Keyring:

```bash
poktrolld keys list --list-names | grep "relayminer-1"
```

Update the provided example supplier stake config:

```bash
sed -i -e s/YOUR_NODE_IP_OR_HOST/$NODE_HOSTNAME/g ./supplier_stake_config_example.yaml
```

Use the configuration to stake your supplier:

```bash
poktrolld tx supplier stake-supplier --config=./supplier_stake_config_example.yaml --from=relayminer-1 --chain-id=poktroll --yes
```

Verify your supplier is staked

```bash
poktrolld query supplier show-supplier $RELAYMINER_ADDR
```

### 3. Configure and run your RelayMiner

:::tip RelayMiner operation config

[dev.poktroll.com/configs/relayminer_config](https://dev.poktroll.com/configs/relayminer_config)
explains what the RelayMiner operation config is and how it can be used.

:::

Update the provided example relay miner operation config:

```bash
sed -i -e s/YOUR_NODE_IP_OR_HOST/$NODE_HOSTNAME/g relayminer-example/config/relayminer_config.yaml
```

Update the `backend_url` in `relayminer_config.yaml` with a valid `0021` (i.e. ETH MainNet)
service URL. We suggest using your own node, but you can get one from Grove for testing purposes.

```bash
sed -i -e s/backend_url: ""/backend_url: "https://eth-mainnet.rpc.grove.city/v1/<APP_ID>"/g relayminer-example/config/relayminer_config.yaml
```

Uncomment the `relayminer-example` and `relayminer-mnemonic-import` in [docker-compose.yml](./docker-compose.yml).
Note that these were commented by default for example purposes.

Start up the RelayMiner:

```bash
docker-compose up -d
```

Check logs and confirm the node works as expected:

```bash
docker-compose logs -f --tail 100 relayminer-example
```

## C. Deploying an AppGate Server

AppGate Server allows to use services provided by other operators on Pocket Network.

### 0. Prerequisites for an AppGate Server

- **Full Node**: This AppGate Server deployment guide assumes the Full Node is deployed [in the same docker-compose stack](#deploying-a-full-node).
- **A poktroll account with uPOKT tokens**: Tokens can be acquired by contacting the team. We plan to add a faucet for public testnet. You are going to need a BIP39 mnemonic phrase for your account.

### 1. Stake your application

Assuming the account you're planning to use for AppGate Server is already available in your local Keyring (can check with `poktrolld keys list`), create an application stake config and run the stake command. [This documentation page](https://dev.poktroll.com/configs/app_staking_config) explains what application staking config is and how it can be used. This command can be used as an example:

```bash
poktrolld tx application stake-application --config=./application_stake_config_example.yaml --from=YOUR_KEY_NAME --chain-id=poktroll --yes
```

### 2. Configure AppGate Server and environment variables

Using [AppGate Server config](https://dev.poktroll.com/configs/appgate_server_config) documentation as a reference, change the [appgate_config.yaml](./appgate-server-example/config/appgate_config.yaml) configuration file.

Also, change the value of `APPGATE_SERVER_MNEMONIC` in the `.env` file. The value should be a BIP39 mnemonic phrase of the account you're planning to use for AppGate Server.

### 3. Prepare and run AppGate Server containers

By default, we commented out `appgate-server-example` and `appgate-server-mnemonic-import` in [docker-compose.yml](./docker-compose.yml).
Uncomment these containers so docker-compose is aware of them, and run:

```bash
docker-compose up -d
```

Check logs and confirm the node works as expected:

```bash
docker-compose logs -f appgate-server-example
```

### 4. Send a relay

You can send requests to the newly deployed AppGate Server. If there are any suppliers on the network that can provide the service,
the request will be routed to them.

The endpoint you want to send request to is: `http://your_node:appgate_server_port/service_id`. For example, this is how the request can be routed to `etherium` service id:

```bash
❯ curl http://my-node:85/0021 \
  -X POST \
  -H "Content-Type: application/json" \
  --data '{"method":"eth_blockNumber","params":[],"id":1,"jsonrpc":"2.0"}'
{"jsonrpc":"2.0","id":1,"result":"0x1289571"}
```
