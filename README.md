# Poktrolld Docker-Compose Example <!-- omit in toc -->

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
NETWORK_NAME=testnet-validated curl https://raw.githubusercontent.com/pokt-network/pocket-network-genesis/master/poktrolld/${NETWORK_NAME}.json > poktrolld-data/config/genesis.json
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

### 0. Prerequisites

- Full Node. This Relay Miner deployment guide assumes the Full Node is deployed [in the same docker-compose stack](#deploying-a-full-node).
- A poktroll account with uPOKT tokens. Tokens can be acquired by contacting the team. We plan to add a faucet for public testnet. You are going to need a BIP39 mnemonic phrase for your account. 

### 1. Stake your supplier

Assuming the account you're planning to use for Relay Miner is already available in your local Keyring (can check with `poktrolld keys list`), create a supplier stake config and run the stake command. [This documentation page](https://dev.poktroll.com/configs/supplier_staking_config) explains what supplier staking config is and how it can be used. This command can be used as an example:

```bash
poktrolld --keyring-backend=test --node=http://YOUR_FULL_NODE_ADDRESS:26657/ tx supplier stake-supplier --config=./supplier_stake_config_example.yaml --from=YOUR_KEY_NAME
```

### 2. Configure RelayMiner and environment variables

Using [RelayMiner config](https://dev.poktroll.com/configs/relayminer_config) documentation as a reference, change the [relayminer_config.yaml](./relayminer-example/config/relayminer_config.yaml) configuration file.

Also, change the value of `RELAYMINER_MNEMONIC` in the `.env` file. The value should be a BIP39 mnemonic phrase of the account you're planning to use for RelayMiner.

### 3. Prepare and run RelayMiner containers

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

### 0. Prerequisites

- Full Node. This AppGate Server deployment guide assumes the Full Node is deployed [in the same docker-compose stack](#deploying-a-full-node).
- A poktroll account with uPOKT tokens. Tokens can be acquired by contacting the team. We plan to add a faucet for public testnet. You are going to need a BIP39 mnemonic phrase for your account. 

### 1. Stake your application

Assuming the account you're planning to use for AppGate Server is already available in your local Keyring (can check with `poktrolld keys list`), create an application stake config and run the stake command. [This documentation page](https://dev.poktroll.com/configs/app_staking_config) explains what application staking config is and how it can be used. This command can be used as an example:

```bash
poktrolld --keyring-backend=test --node=http://YOUR_FULL_NODE_ADDRESS:26657/ tx application stake-application --config=./application_stake_config_example.yaml --from=YOUR_KEY_NAME
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
