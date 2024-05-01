#!/bin/bash

# Check if APPGATE_SERVER_MNEMONIC environment variable is empty
if [ -z "$APPGATE_SERVER_MNEMONIC" ]; then
    echo "The variable is empty. Please enter your AppGate server mnemonic phrase in the .env file."
    exit 1
fi

# Check if key "key-for-appgateserver" exists
if poktrolld --keyring-backend=test --home=/root/.poktroll/ keys show key-for-appgateserver >/dev/null 2>&1; then
    echo "Key 'key-for-appgateserver' already exists."
else
    # Add key "key-for-appgateserver" using the mnemonic
    echo "$APPGATE_SERVER_MNEMONIC" | poktrolld --keyring-backend=test --home=/root/.poktroll/ keys add key-for-appgateserver --recover
    if [ $? -ne 0 ]; then
        echo "Failed to add key 'key-for-appgateserver'. Exiting."
        exit 1
    fi
fi

# Execute poktrolld with specified parameters
poktrolld \
    appgate-server \
    --home=/root/.poktroll/ \
    --keyring-backend=test \
    --config=/root/.poktroll/config/appgate_config.yaml
