#!/bin/sh

# Exit immediately if a command exits with a non-zero status.
set -e

# Cosmovisor settings are now set via docker-compose environment variables

# Ensure required environment variables are set
: "${NODE_HOSTNAME:?Need to set NODE_HOSTNAME}"
: "${POKTROLLD_LOG_LEVEL:?Need to set POKTROLLD_LOG_LEVEL}"

# Read the seeds from the genesis.seeds file
export SEEDS=$(cat "$DAEMON_HOME/config/genesis.seeds")

# Add skip-upgrades flag for testnet-alpha
EXTRA_FLAGS=""
if [ "$NETWORK_NAME" = "testnet-alpha" ]; then
    # TODO(@okdas): move this into the separate file in `genesis` repo like we do this for seeds. That way, we can
    # automate this in the future for all networks.
    EXTRA_FLAGS="--unsafe-skip-upgrades=83725"
fi

# Start the binary via Cosmovisor
exec cosmovisor run start \
  --p2p.external-address="${NODE_HOSTNAME}:26656" \
  --log_level="${POKTROLLD_LOG_LEVEL}" \
  --p2p.seeds="${SEEDS}" \
  ${EXTRA_FLAGS}
