#!/bin/sh

# Exit immediately if a command exits with a non-zero status.
set -e

# Cosmovisor settings. More environment variables documented here:
# https://docs.cosmos.network/v0.47/build/tooling/cosmovisor#command-line-arguments-and-environment-variables
export DAEMON_NAME="poktrolld"
export DAEMON_HOME="$HOME/.poktroll"
export DAEMON_RESTART_AFTER_UPGRADE=true
export DAEMON_ALLOW_DOWNLOAD_BINARIES=true
export UNSAFE_SKIP_BACKUP=false

# Ensure required environment variables are set
: "${NODE_HOSTNAME:?Need to set NODE_HOSTNAME}"
: "${POKTROLLD_LOG_LEVEL:?Need to set POKTROLLD_LOG_LEVEL}"

# Read the seeds from the genesis.seeds file
export SEEDS=$(cat "$DAEMON_HOME/config/genesis.seeds")

# Initialize Cosmovisor if the genesis binary doesn't exist yet
if [ ! -f "$DAEMON_HOME/cosmovisor/genesis/bin/poktrolld" ]; then
  # Copies the `/bin/poktrolld` into the Cosmovisor directory. Cosmovisor upgrades will NOT update the `/bin/poktrolld` binary
  # because it comes from the container image. The binary in `/bin` will only change when the container image tag is updated.
  cosmovisor init /bin/poktrolld
fi

# Start the binary via Cosmovisor
cosmovisor run start \
  --p2p.external-address="${NODE_HOSTNAME}:26656" \
  --log_level="${POKTROLLD_LOG_LEVEL}" \
  --p2p.seeds="${SEEDS}"
