# Poktrolld Docker-Compose Example

## Deploying a Full Node Using Docker-Compose

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

Download and place the genesis.json for your chosen network (e.g., public-testnet) into the poktrolld/config directory:

```bash
NETWORK_NAME=public-testnet curl https://raw.githubusercontent.com/pokt-network/pocket-network-genesis/master/poktrolld/${NETWORK_NAME}.json > poktrolld-data/config/genesis.json
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

