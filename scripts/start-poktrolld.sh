#!/bin/bash

GENESIS_PATH="/root/.poktroll/config/genesis.json"
GENESIS_URL="https://raw.githubusercontent.com/pokt-network/pocket-network-genesis/master/poktrolld"

# Download the genesis file for the appropriate P2P Network if missing
if [ -n "$P2P_NETWORK" ]; then
    if [ ! -f "$GENESIS_PATH" ]; then
        curl -fs "$GENESIS_URL/$P2P_NETWORK-validated.json" > "$GENESIS_PATH"
        if [ $? -ne 0 ]; then
            echo "Failed to download Genesis JSON file for $P2P_NETWORK."
            exit 1
        fi
    fi
else
    echo "P2P_NETWORK variable not set. Please set it to either 'testnet' or 'mainnet'."
    exit 1
fi


# Execute poktrolld with specified parameters
poktrolld \
   start \
   --home=/root/.poktroll/ \
   --rpc.laddr=tcp://0.0.0.0:26657 \
   --p2p.laddr=0.0.0.0:26659 \
   --p2p.external-address=$NODE_HOSTNAME:26659 \
   --grpc.address=0.0.0.0:26658 \
   --log_level=$POKTROLLD_LOG_LEVEL \
   --p2p.seeds=$SEEDS