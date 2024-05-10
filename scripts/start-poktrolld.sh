#!/bin/bash

GENESIS_PATH="/root/.poktroll/config/genesis.json"
GENESIS_URL="https://raw.githubusercontent.com/pokt-network/pocket-network-genesis/master/poktrolld"

# Download the genesis file for the appropriate P2P Network if missing
if [ -n "$NETWORK_NAME" ]; then
    if [ ! -f "$GENESIS_PATH" ]; then
        curl -fs "$GENESIS_URL/$NETWORK_NAME.json" > "$GENESIS_PATH"
        if [ $? -ne 0 ]; then
            echo "Failed to download Genesis JSON file for $NETWORK_NAME."
            exit 1
        fi
    fi
else
    echo "NETWORK_NAME variable not set. Please set it to either 'testnet' or 'mainnet'."
    exit 1
fi


# rpc.laddr 0.0 26657 -> "def 127."
# p2p.laddr 0.0 26659 -> def 0.0 26656
# grpc.address 0.0 26658 -> localhost:9090


# Execute poktrolld with specified parameters
poktrolld \
   start \
   --p2p.external-address=$NODE_HOSTNAME:26656 \
   --log_level=$POKTROLLD_LOG_LEVEL \
   --p2p.seeds=$SEEDS