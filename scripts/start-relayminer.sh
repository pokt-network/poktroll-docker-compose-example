#!/bin/bash

# Check if SUPPLIER_MNEMONIC environment variable is empty
if [ -z "$SUPPLIER_MNEMONIC" ]; then
    echo "The variable is empty. Please enter your relay miner mnemonic phrase in the .env file."
    exit 1
fi

# Check if key "key-for-supplier1" exists
if poktrolld --keyring-backend=test keys show key-for-supplier1 >/dev/null 2>&1; then
    echo "Key 'key-for-supplier1' already exists."
else
    # Add key "key-for-supplier1" using the mnemonic
    echo "$SUPPLIER_MNEMONIC" | poktrolld --keyring-backend=test keys add key-for-supplier1 --recover
    if [ $? -ne 0 ]; then
        echo "Failed to add key 'key-for-supplier1'. Exiting."
        exit 1
    fi
fi

# Execute poktrolld with specified parameters
poktrolld \
    relayminer \
    --keyring-backend=test \
    --config=/home/pocket/.poktroll/config/relayminer_config.yaml
