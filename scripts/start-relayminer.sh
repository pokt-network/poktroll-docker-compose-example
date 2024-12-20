#!/bin/bash

# Check if SUPPLIER_MNEMONIC environment variable is empty
if [ -z "$SUPPLIER_MNEMONIC" ]; then
    echo "The variable is empty. Please enter your relay miner mnemonic phrase in the .env file."
    exit 1
fi

# Check if key "supplier" exists
if poktrolld --keyring-backend=test keys show supplier >/dev/null 2>&1; then
    echo "Key 'supplier' already exists."
    poktrolld --keyring-backend=test keys delete supplier --yes --force
fi

# Add key "supplier" using the mnemonic
echo "$SUPPLIER_MNEMONIC" | poktrolld --keyring-backend=test keys add supplier --recover
if [ $? -ne 0 ]; then
    echo "Failed to add key 'supplier'. Exiting."
    exit 1
fi

# Execute poktrolld with specified parameters
poktrolld \
    relayminer \
    --keyring-backend=test \
    --config=/home/pocket/.poktroll/config/relayminer_config.yaml
