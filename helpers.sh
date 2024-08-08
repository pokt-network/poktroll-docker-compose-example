function poktrolld() {
    docker exec -it full_node poktrolld "$@"
}

function full_node_cli() {
    docker exec -it full_node bash
}

function watch_height() {
    watch -n 1 "curl -s -X POST localhost:26657/block | jq '.result.block.header.height'"
}

function explorer_urls() {
    echo "Gateway: https://shannon.testnet.pokt.network/poktroll/account/$GATEWAY_ADDR"
    echo "Supplier: https://shannon.testnet.pokt.network/poktroll/account/$SUPPLIER_ADDR"
    echo "Application: https://shannon.testnet.pokt.network/poktroll/account/$APPLICATION_ADDR"
}

function query_supplier() {
    poktrolld query supplier show-supplier $SUPPLIER_ADDR
}
