#!/bin/bash

# Check if GATEWAY_MNEMONIC environment variable is empty
if [ -z "$GATEWAY_MNEMONIC" ]; then
    echo "The variable is empty. Please enter your AppGate server mnemonic phrase in the .env file."
    exit 1
fi

# Check if key "key-for-gateway" exists
if poktrolld --keyring-backend=test keys show key-for-gateway >/dev/null 2>&1; then
    echo "Key 'key-for-gateway' already exists."
else
    # Add key "key-for-gateway" using the mnemonic
    echo "$GATEWAY_MNEMONIC" | poktrolld --keyring-backend=test keys add key-for-gateway --recover
    if [ $? -ne 0 ]; then
        echo "Failed to add key 'key-for-gateway'. Exiting."
        exit 1
    fi
fi

# Execute poktrolld with specified parameters
poktrolld \
    appgate-server \
    --keyring-backend=test \
    --config=/home/pocket/.poktroll/config/gateway_config.yaml
