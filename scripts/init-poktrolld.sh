#!/bin/sh

mkdir -p /home/pocket/.poktroll/data/
if [ ! -f /home/pocket/.poktroll/data/priv_validator_state.json ]; then
  echo "{\"height\": \"0\", \"round\": 0, \"step\": 0}" > /home/pocket/.poktroll/data/priv_validator_state.json
fi

# 1025 is the `pocket` user on production images. `1025` is the UID/GID adopted as standard on heighliner.
chmod -R 755 /home/pocket/.poktroll/data/

if [ -n "$NETWORK_NAME" ]; then
  if [ ! -f /home/pocket/.poktroll/config/genesis.json ]; then
    wget -O /home/pocket/.poktroll/config/genesis.json https://raw.githubusercontent.com/pokt-network/pocket-network-genesis/master/poktrolld/$NETWORK_NAME.json
    if [ $? -ne 0 ]; then
      echo "Failed to download Genesis JSON file for $NETWORK_NAME."
      exit 1
    fi
  fi

  if [ ! -f /home/pocket/.poktroll/config/genesis.seeds ]; then
    wget -O /home/pocket/.poktroll/config/genesis.seeds https://raw.githubusercontent.com/pokt-network/pocket-network-genesis/master/poktrolld/$NETWORK_NAME.seeds
    if [ $? -ne 0 ]; then
      echo "Failed to download seeds file for $NETWORK_NAME."
      exit 1
    fi
  fi
else
  echo "NETWORK_NAME variable not set. Please set it to either 'testnet' or 'mainnet'."
  exit 1
fi

chown -R 1025:1025 /home/pocket/.poktroll/