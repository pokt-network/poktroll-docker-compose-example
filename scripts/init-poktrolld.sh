#!/bin/bash

set -e

# Install required packages
apt-get update
apt-get install -y wget jq

# Can change the branch from `pocket-network-genesis` repo to test before merging to master
GENESIS_BRANCH="add-beta-seeds-rename-dirs"

# Create directories with correct permissions
mkdir -p /home/pocket/.poktroll/data/
mkdir -p /home/pocket/.poktroll/config/
mkdir -p /home/pocket/.poktroll/cosmovisor/genesis/bin

if [ ! -f /home/pocket/.poktroll/data/priv_validator_state.json ]; then
    echo "{\"height\": \"0\", \"round\": 0, \"step\": 0}" > /home/pocket/.poktroll/data/priv_validator_state.json
fi

if [ -n "$NETWORK_NAME" ]; then
    # Construct base URL using the branch and network
    BASE_URL="https://raw.githubusercontent.com/pokt-network/pocket-network-genesis/${GENESIS_BRANCH}/shannon/${NETWORK_NAME}"
    GENESIS_URL="${BASE_URL}/genesis.json"
    
    echo "Attempting to download genesis from: $GENESIS_URL"
    
    # Download genesis.json if it doesn't exist
    if [ ! -f /home/pocket/.poktroll/config/genesis.json ]; then
        wget -O /home/pocket/.poktroll/config/genesis.json "${GENESIS_URL}"
        WGET_EXIT_CODE=$?
        
        # Check if wget was successful
        if [ $WGET_EXIT_CODE -ne 0 ]; then
            echo "Failed to download Genesis JSON file from ${GENESIS_URL}"
            echo "wget exit code: $WGET_EXIT_CODE"
            # Try to curl the URL to see if it exists
            echo "Checking if URL exists:"
            curl -I "${GENESIS_URL}"
            exit 1
        fi
        echo "Successfully downloaded genesis.json"
    fi

    # Verify the file exists and has content
    if [ ! -s /home/pocket/.poktroll/config/genesis.json ]; then
        echo "Genesis file is empty or does not exist!"
        exit 1
    fi

    # Debug: Print genesis.json contents and file info
    echo "Genesis file details:"
    ls -l /home/pocket/.poktroll/config/genesis.json
    echo "Genesis.json contents:"
    cat /home/pocket/.poktroll/config/genesis.json

    # Extract version from genesis.json and download correct binary
    APP_VERSION=$(jq -r '.app_version' /home/pocket/.poktroll/config/genesis.json)
    echo "Raw jq output: $(jq '.' /home/pocket/.poktroll/config/genesis.json)"
    echo "Attempted to extract app_version, got: '$APP_VERSION'"
    
    if [ -z "$APP_VERSION" ]; then
        echo "Failed to extract app_version from genesis.json"
        exit 1
    fi
    
    echo "Using app version from genesis: $APP_VERSION"
    
    # Download the correct binary version
    ARCH=$(uname -m)
    if [ "$ARCH" = "x86_64" ]; then 
        ARCH="amd64"
    elif [ "$ARCH" = "aarch64" ]; then 
        ARCH="arm64"
    fi
    
    BINARY_URL="https://github.com/pokt-network/poktroll/releases/download/v${APP_VERSION}/poktroll_linux_${ARCH}.tar.gz"
    echo "Downloading binary from: $BINARY_URL"
    
    wget -O- "$BINARY_URL" | tar xz -C /home/pocket/.poktroll/cosmovisor/genesis/bin
    if [ $? -ne 0 ]; then
        echo "Failed to download or extract binary from $BINARY_URL"
        exit 1
    fi
    chmod +x /home/pocket/.poktroll/cosmovisor/genesis/bin/poktrolld
    echo "Successfully downloaded and installed poktrolld binary"

    # Download seeds if they don't exist
    if [ ! -f /home/pocket/.poktroll/config/genesis.seeds ]; then
        wget -O /home/pocket/.poktroll/config/genesis.seeds "${BASE_URL}/seeds"
        if [ $? -ne 0 ]; then
            echo "Failed to download seeds file for $NETWORK_NAME."
            exit 1
        fi
    fi
else
    echo "NETWORK_NAME variable not set. Please set it to 'testnet-alpha', 'testnet-beta', or 'mainnet'."
    exit 1
fi

# Set ownership and permissions for all files
chown -R 1025:1025 /home/pocket/.poktroll/
chmod -R 755 /home/pocket/.poktroll/
chmod 644 /home/pocket/.poktroll/config/genesis.json
chmod 644 /home/pocket/.poktroll/config/genesis.seeds