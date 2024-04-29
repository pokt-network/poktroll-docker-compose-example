# Poktrolld Docker-Compose Example <!-- omit in toc -->

- [Key Terms](#key-terms)
- [TODOs](#todos)
- [Understanding Actors in the Shannon upgrade](#understanding-actors-in-the-shannon-upgrade)
- [Deploying a Full Node](#deploying-a-full-node)
  - [0. Prerequisites](#0-prerequisites)
  - [1. Clone the Repository](#1-clone-the-repository)
  - [2. Download Network Genesis](#2-download-network-genesis)
  - [3. Configure Environment Variables](#3-configure-environment-variables)
  - [4. Launch the Node](#4-launch-the-node)
- [Deploying a Relay Miner](#deploying-a-relay-miner)
  - [0. Prerequisites for a Relay Miner](#0-prerequisites-for-a-relay-miner)
  - [1. Fund your account](#1-fund-your-account)
  - [2. Stake your supplier](#2-stake-your-supplier)
  - [3. Configure RelayMiner and environment variables](#3-configure-relayminer-and-environment-variables)
  - [4. Prepare and run RelayMiner containers](#4-prepare-and-run-relayminer-containers)
- [Deploying an AppGate Server](#deploying-an-appgate-server)
  - [0. Prerequisites](#0-prerequisites-1)
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

## Deploying a Full Node

### 0. Prerequisites

Ensure the following software is installed on your system:

- [git](https://github.com/git-guides/install-git);
- [Docker](https://docs.docker.com/engine/install/);
- [docker-compose](https://docs.docker.com/compose/install/#installation-scenarios);

Additionally, the system must be capable of exposing ports to the internet for
peer-to-peer communication.

### 1. Clone the Repository

```bash
git clone https://github.com/pokt-network/poktroll-docker-compose-example.git
cd poktroll-docker-compose-example
```

### 2. Download Network Genesis

The Poktrolld blockchain deploys various networks: DevNet, TestNet, MainNet, etc...

Access the list of Poktrolld networks available for community participation at [Poktrolld Networks](https://github.com/pokt-network/pocket-network-genesis/tree/master/poktrolld).

Download and place the `genesis.json` for your chosen network (e.g., `testnet-validated`)
into the `poktrolld/config` directory:

E.g. Testnet-validated:

```bash
curl https://raw.githubusercontent.com/pokt-network/pocket-network-genesis/master/poktrolld/testnet-validated.json > poktrolld-data/config/genesis.json
```

### 3. Configure Environment Variables

Create and configure your `.env` file from the sample:

```bash
cp .env.sample .env
```

Update `NODE_HOSTNAME` in `.env` to the IP address or hostname of your node. For example:

```bash
sed -i -e  s/YOUR_NODE_IP_OR_HOST/69.42.690.420/g .env
```

### 4. Launch the Node

Note: You may need to replace `docker-compose` with `docker compose` if you are
running a newer version of Docker.

Initiate the node with:

```bash
docker-compose up -d
```

Monitor node activity through logs with:

```bash
docker-compose logs -f
```

## Deploying a Relay Miner

Relay Miner provides services to offer on the Pocket Network.

### 0. Prerequisites for a Relay Miner

- **Full Node**: This Relay Miner deployment guide assumes the Full Node is deployed [in the same docker-compose stack](#deploying-a-full-node).
- **A poktroll account with uPOKT tokens**: Tokens can be acquired by contacting the team. We plan to add a faucet for public testnet. You are going to need a BIP39 mnemonic phrase for your account.

### 1. Fund your account

On the host where you started the full node container, run the commands below to
fund your account.

Create a new `RelayMiner` account:

```bash
docker exec -it poktroll-docker-compose-example-poktrolld-1 poktrolld keys add relayminer-1
```

Copy the mnemonic that's printed to the screen to the `RELAYMINER_MNEMONIC` variable in your `.env` file.

Save the outputted address to a variable for simplicity::

```bash
export RELAYMINER_ADDR=pokt1...
```

```bash
docker exec -it poktroll-docker-compose-example-poktrolld-1 poktrolld keys add --recover -i pocket-team
```

When you see the `> Enter your bip39 mnemonic` prompt, paste the mnemonic provided by the Pocket team for testnet.

When you see the `> Enter your bip39 passphrase. This is combined with the mnemonic to derive the seed. Most users should just hit enter to use the default, ""` prompt, hit enter without adding a passphrase. Finish funding your account by using the command below:

```bash
docker exec -it poktroll-docker-compose-example-poktrolld-1 poktrolld tx bank send pocket-team $RELAYMINER_ADDR 10000upokt -y --chain-id poktroll
```

You can check that your address is funded correctly by running:

```bash
docker exec -it poktroll-docker-compose-example-poktrolld-1 poktrolld query bank balances $RELAYMINER_ADDR
```

### 2. Stake your supplier

Verify that the account you're planning to use for `RelayMiner` is available in your local Keyring:

```bash
docker exec -it poktroll-docker-compose-example-poktrolld-1 poktrolld keys list
```

Assuming the account you're planning to use for `RelayMiner` is already available in your local Keyring (can check with `poktrolld keys list`), create a supplier stake config and run the stake command. [This documentation page](https://dev.poktroll.com/configs/supplier_staking_config) explains what supplier staking config is and how it can be used. This command can be used as an example:

```bash
docker exec -it poktroll-docker-compose-example-poktrolld-1 poktrolld tx supplier stake-supplier --config=./supplier_stake_config_example.yaml --from=relayminer-1 --chain-id poktroll
```

### 3. Configure RelayMiner and environment variables

Using [RelayMiner config](https://dev.poktroll.com/configs/relayminer_config) documentation as a reference, change the [relayminer_config.yaml](./relayminer-example/config/relayminer_config.yaml) configuration file.

Also, change the value of `RELAYMINER_MNEMONIC` in the `.env` file. The value should be a BIP39 mnemonic phrase of the account you're planning to use for RelayMiner.

### 4. Prepare and run RelayMiner containers

By default, we commented out `relayminer-example` and `relayminer-mnemonic-import` in [docker-compose.yml](./docker-compose.yml).
Uncomment these containers so docker-compose is aware of them, and run:

```bash
docker-compose up -d
```

Check logs and confirm the node works as expected:

```bash
docker-compose logs -f relayminer-example
```

## Deploying an AppGate Server

AppGate Server allows to use services provided by other operators on Pocket Network.

### 0. Prerequisites

- **Full Node**: This AppGate Server deployment guide assumes the Full Node is deployed [in the same docker-compose stack](#deploying-a-full-node).
- **A poktroll account with uPOKT tokens**: Tokens can be acquired by contacting the team. We plan to add a faucet for public testnet. You are going to need a BIP39 mnemonic phrase for your account.

### 1. Stake your application

Assuming the account you're planning to use for AppGate Server is already available in your local Keyring (can check with `poktrolld keys list`), create an application stake config and run the stake command. [This documentation page](https://dev.poktroll.com/configs/app_staking_config) explains what application staking config is and how it can be used. This command can be used as an example:

```bash
docker exec -it poktroll-docker-compose-example-poktrolld-1 poktrolld tx application stake-application --config=./application_stake_config_example.yaml --from=YOUR_KEY_NAME --chain-id poktroll
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
