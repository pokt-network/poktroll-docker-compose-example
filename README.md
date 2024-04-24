# Poktrolld Docker-Compose Example <!-- omit in toc -->

- [Understanding Shannon upgrade actors](#understanding-shannon-upgrade-actors)
- [Deploying a Full Node](#deploying-a-full-node)
  - [0. Prerequisites](#0-prerequisites)
  - [1. Clone the Repository](#1-clone-the-repository)
  - [2. Download Network Genesis](#2-download-network-genesis)
  - [3. Configure Environment Variables](#3-configure-environment-variables)
  - [4. Launch the Node](#4-launch-the-node)
- [Deploying a Relay Miner](#deploying-a-relay-miner)
  - [0. Prerequisites](#0-prerequisites-1)
  - [1. Stake your supplier](#1-stake-your-supplier)
  - [2. Configure RelayMiner and environment variables](#2-configure-relayminer-and-environment-variables)
  - [3. Prepare and run RelayMiner containers](#3-prepare-and-run-relayminer-containers)
- [Deploying an AppGate Server](#deploying-an-appgate-server)
  - [0. Prerequisites](#0-prerequisites-2)
  - [1. Stake your application](#1-stake-your-application)
  - [2. Configure AppGate Server and environment variables](#2-configure-appgate-server-and-environment-variables)
  - [3. Prepare and run AppGate Server containers](#3-prepare-and-run-appgate-server-containers)
  - [4. Send a relay](#4-send-a-relay)

## Understanding Shannon upgrade actors

For those familiar with Pocket Network Mainnet - Morse, the introduction of multiple node types in the upcoming Shannon upgrade may require some explanation. In Shannon, the "supplier" role is separated from the "full node" role.

In Morse (current Pocket Network mainnet), a validator or a full node was responsible for both holding blockchain data and performing relays. With Shannon, the RelayMiner software, which runs the supplier logic, is distinct from the full-node/validator.

Furthermore, Shannon introduces the AppGate Server, a software component that provides access to Pocket Network suppliers. This addition will be beneficial for both Applications and Gateways.

For more details, please refer to the [Shannon actors documentation](https://dev.poktroll.com/actors).

## Deploying a Full Node

### 0. Prerequisites

Ensure the following software is installed on your system:
- [git](https://github.com/git-guides/install-git);
- [Docker](https://docs.docker.com/engine/install/);
- [docker-compose](https://docs.docker.com/compose/install/#installation-scenarios);

Additionally, the system must be capable of exposing ports to the internet for peer-to-peer communication.

### 1. Clone the Repository

```
git clone https://github.com/pokt-network/poktroll-docker-compose-example.git
cd poktroll-docker-compose-example
```

### 2. Download Network Genesis

The Poktrolld blockchain deploys various networks (e.g., testnets, mainnet). Access the list of Poktrolld networks available for community participation here: [Poktrolld Networks](https://github.com/pokt-network/pocket-network-genesis/tree/master/poktrolld).

Download and place the genesis.json for your chosen network (e.g., `testnet-validated`) into the poktrolld/config directory:

```bash
curl https://raw.githubusercontent.com/pokt-network/pocket-network-genesis/master/poktrolld/testnet-validated.json > poktrolld-data/config/genesis.json
```

### 3. Configure Environment Variables

Create and configure your `.env` file from the sample:

```bash
cp .env.sample .env
```

Update `NODE_HOSTNAME` in `.env` to the IP address or hostname of your node.

### 4. Launch the Node

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

### 0. Prerequisites

- Full Node. This Relay Miner deployment guide assumes the Full Node is deployed [in the same docker-compose stack](#deploying-a-full-node).
- A poktroll account with uPOKT tokens. Tokens can be acquired by contacting the team. We plan to add a faucet for public testnet. You are going to need a BIP39 mnemonic phrase for your account. 

### 1. Fund your account
On the host where you started the full node container, run the following commands to fund your account. 
```bash
docker exec -it poktroll-docker-compose-example-poktrolld-1 poktrolld keys add relayminer-1
```
Copy the mnemonic that's pasted to the screen and copy this into your `RELAYMINER_MNEMONIC` variable in the `.env` file. Continue with the commands below: 
```bash
docker exec -it poktroll-docker-compose-example-poktrolld-1 poktrolld keys add --recover -i pocket-team
```
When you see the `> Enter your bip39 mnemonic` prompt, paste the mnemonic provided by the Pocket team for testnet. 
When you see the `> Enter your bip39 passphrase. This is combined with the mnemonic to derive the seed. Most users should just hit enter to use the default, ""` prompt, hit enter without adding a passphrase. Finish funding your account by using the command below: 

```bash
docker exec -it poktroll-docker-compose-example-poktrolld-1 poktrolld tx bank send pocket-team [your_address] 10000upokt --chain-id poktroll
```

You can check that your address is funded correctly by running:
```bash
docker exec -it poktroll-docker-compose-example-poktrolld-1 poktrolld query bank balances [your_address]
```

### 2. Stake your supplier

Assuming the account you're planning to use for Relay Miner is already available in your local Keyring (can check with `poktrolld keys list`), create a supplier stake config and run the stake command. [This documentation page](https://dev.poktroll.com/configs/supplier_staking_config) explains what supplier staking config is and how it can be used. This command can be used as an example:

```bash
poktrolld --keyring-backend=test --node=http://YOUR_FULL_NODE_ADDRESS:26657/ tx supplier stake-supplier --config=./supplier_stake_config_example.yaml --from=YOUR_KEY_NAME --chain-id poktroll
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

- Full Node. This AppGate Server deployment guide assumes the Full Node is deployed [in the same docker-compose stack](#deploying-a-full-node).
- A poktroll account with uPOKT tokens. Tokens can be acquired by contacting the team. We plan to add a faucet for public testnet. You are going to need a BIP39 mnemonic phrase for your account. 

### 1. Stake your application

Assuming the account you're planning to use for AppGate Server is already available in your local Keyring (can check with `poktrolld keys list`), create an application stake config and run the stake command. [This documentation page](https://dev.poktroll.com/configs/app_staking_config) explains what application staking config is and how it can be used. This command can be used as an example:

```bash
poktrolld --keyring-backend=test --node=http://YOUR_FULL_NODE_ADDRESS:26657/ tx application stake-application --config=./application_stake_config_example.yaml --from=YOUR_KEY_NAME --chain-id poktroll
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
