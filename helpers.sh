# TODO_IMPROVE: Add these helpers to a development CLI or a Makefile

# TODO_IMPROVE: Enable downloading poktrolld through home brew
function poktrolld() {
    docker exec -it full-node poktrolld "$@"
}

function full_node_cli() {
    docker exec -it full-node sh
}

function watch_height() {
    watch -n 1 "curl -s -X POST localhost:26657/block | jq '.result.block.header.height'"
}

function show_explorer_urls() {
    echo "Gateway: https://shannon.testnet.pokt.network/poktroll/account/$GATEWAY_ADDR"
    echo "Supplier: https://shannon.testnet.pokt.network/poktroll/account/$SUPPLIER_ADDR"
    echo "Application: https://shannon.testnet.pokt.network/poktroll/account/$APPLICATION_ADDR"
}

function show_actor_addresses() {
    echo "Gateway: $GATEWAY_ADDR"
    echo "Supplier: $SUPPLIER_ADDR"
    echo "Application: $APPLICATION_ADDR"
}

function query_supplier() {
    poktrolld query supplier show-supplier $SUPPLIER_ADDR
}

function clear_all_node_data() {
    read -p "Are you sure you want to remove all existing poktroll data? (y/N): " confirm
    if [[ "$confirm" =~ ^[Yy]$ ]]; then
        echo "Proceeding with the action..."
        rm -rf poktrolld-data/config/addrbook.json poktrolld-data/config/genesis.json poktrolld-data/config/genesis.seeds poktrolld-data/data/ poktrolld-data/config/node_key.json poktrolld-data/config/priv_validator_key.json
    else
        echo "Action cancelled."
        exit 0
    fi
}

function path_prepare_config() {
    echo """
shannon_config:
  full_node_config:
    rpc_url: ${NODE_HOSTNAME}:26657
    grpc_config:
      host_port: ${NODE_HOSTNAME}:9090
      insecure: true
    gateway_address: \"${GATEWAY_ADDR}\"
    gateway_private_key: \"Run: poktrolld keys export --unsafe --unarmored-hex  gateway\"
    delegated_app_addresses:
      - \"${APPLICATION_ADDR}\"

services:
  \"0021\":
    alias: \"eth-mainnet\"
"""
}
