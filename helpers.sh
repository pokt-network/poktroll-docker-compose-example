function poktrolld() {
    docker exec -it full_node poktrolld "$@"
}

function full_node_cli() {
    docker exec -it full_node bash
}
