#!/bin/bash

# Check if APPLICATION_MNEMONIC environment variable is empty
if [ -z "$APPLICATION_MNEMONIC" ]; then
    echo "The variable is empty. Please enter your AppGate server mnemonic phrase in the .env file."
    exit 1
fi

# Check if key "key-for-application" exists
if poktrolld --keyring-backend=test --home=/root/.poktroll/ keys show key-for-application >/dev/null 2>&1; then
    echo "Key 'key-for-application' already exists."
else
    # Add key "key-for-application" using the mnemonic
    echo "$APPLICATION_MNEMONIC" | poktrolld --keyring-backend=test --home=/root/.poktroll/ keys add key-for-application --recover
    if [ $? -ne 0 ]; then
        echo "Failed to add key 'key-for-application'. Exiting."
        exit 1
    fi
fi

# Execute poktrolld with specified parameters
poktrolld \
    appgate-server \
    --home=/root/.poktroll/ \
    --keyring-backend=test \
    --config=/root/.poktroll/config/appgate_config.yaml
