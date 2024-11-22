#!/bin/sh

# Can change the branch from `pocket-network-genesis` repo to test before merging to master
GENESIS_BRANCH="master"

mkdir -p /home/pocket/.poktroll/data/
if [ ! -f /home/pocket/.poktroll/data/priv_validator_state.json ]; then
    echo "{\"height\": \"0\", \"round\": 0, \"step\": 0}" > /home/pocket/.poktroll/data/priv_validator_state.json
fi

# 1025 is the `pocket` user on production images. `1025` is the UID/GID adopted as standard on heighliner.
chmod -R 755 /home/pocket/.poktroll/data/

if [ -n "$NETWORK_NAME" ]; then
    # Construct base URL using the branch and network
    BASE_URL="https://raw.githubusercontent.com/pokt-network/pocket-network-genesis/${GENESIS_BRANCH}/shannon/${NETWORK_NAME}"
    
    # Download genesis.json if it doesn't exist
    if [ ! -f /home/pocket/.poktroll/config/genesis.json ]; then
        wget -O /home/pocket/.poktroll/config/genesis.json "${BASE_URL}/genesis.json"
        if [ $? -ne 0 ]; then
            echo "Failed to download Genesis JSON file for $NETWORK_NAME."
            exit 1
        fi
    fi

    # Download seeds if they don't exist
    if [ ! -f /home/pocket/.poktroll/config/genesis.seeds ]; then
        wget -O /home/pocket/.poktroll/config/genesis.seeds "${BASE_URL}/seeds"
        if [ $? -ne 0 ]; then
            echo "Failed to download seeds file for $NETWORK_NAME."
            exit 1
        fi
    fi

    # Extract and use app_version from genesis.json if jq is available
    if command -v jq >/dev/null 2>&1; then
        APP_VERSION=$(jq -r '.app_version' /home/pocket/.poktroll/config/genesis.json)
        if [ -n "$APP_VERSION" ]; then
            echo "Using app version from genesis: $APP_VERSION"
        fi
    fi
else
    echo "NETWORK_NAME variable not set. Please set it to 'testnet-alpha', 'testnet-beta', or 'mainnet'."
    exit 1
fi

chown -R 1025:1025 /home/pocket/.poktroll/