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

### 2. Download Network Genesis and Metadata

The Poktrolld blockchain deploys various networks (e.g., testnets, mainnet). Access the list of Poktrolld networks available for community participation here: [Poktrolld Networks](https://github.com/pokt-network/pocket-network-genesis/tree/master/poktrolld).

Each network provides two essential files:
- `.json` — a `genesis.json` file.
- `.txt` - file containing metadata required for operating a full node (will be used in the next step).

Place genesis.json in the poktrolld/config directory using the following command for the public-testnet network:

```bash
curl https://raw.githubusercontent.com/pokt-network/pocket-network-genesis/master/poktrolld/public-testnet.json > poktrolld-data/config/genesis.json
```

### 3. Configure Environment Variables

Duplicate the sample environment file and name it `.env`:

```bash
cp .env.sample .env
```

Edit the .env file with the following details:
1. `NODE_HOSTNAME` should match the IP address or hostname of your full node for network discovery purposes.
2. Obtain `POKTROLL_NAMESPACE`, `DA_START_HEIGHT`, and `SEEDS` from the `.txt` metadata file mentioned previously.

### 4. Launch the Node

Initiate the node with:

```bash
docker-compose up -d
```

Monitor node activity through logs with:
```bash
docker-compose logs -f poktrolld
```
