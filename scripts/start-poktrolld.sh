#!/bin/sh

# Exit immediately if a command exits with a non-zero status.
set -e

# Cosmovisor settings are now set via docker-compose environment variables

# Ensure required environment variables are set
: "${NODE_HOSTNAME:?Need to set NODE_HOSTNAME}"
: "${POKTROLLD_LOG_LEVEL:?Need to set POKTROLLD_LOG_LEVEL}"

# Read the seeds from the genesis.seeds file
export SEEDS=$(cat "$DAEMON_HOME/config/genesis.seeds")

# Start the binary via Cosmovisor
exec cosmovisor run start \
  --p2p.external-address="${NODE_HOSTNAME}:26656" \
  --log_level="${POKTROLLD_LOG_LEVEL}" \
  --p2p.seeds="${SEEDS}"
