# tl;dr Vultr Debian Setup <!-- omit in toc -->

:::warning Olshansky's docs

This is a tl;dr copy-pasta (by and for Olshansky) while setting up a Vultr server.
It is not intended to act as proper documentation so use at your own risk.

:::

- [Deploy your server](#deploy-your-server)
- [Install Dependencies](#install-dependencies)
- [Retrieve the source code](#retrieve-the-source-code)
- [Update your environment](#update-your-environment)
- [Start up the full node](#start-up-the-full-node)
- [Create new addresses for all your accounts](#create-new-addresses-for-all-your-accounts)

## Deploy your server

1. Go to [vultr's console](https://my.vultr.com/deploy)
2. Choose `Cloud Compute - Shared CPU`
3. Choose `Debian 12 x64`
4. Select `AMD High Performance`
5. Choose the `100GB NVMe` storage w/ `4GB` memory and `2 vCPU`
6. Disable `Auto Backups`
7. Deploy

## Install Dependencies

See [docker's official instructions here](https://docs.docker.com/engine/install/debian/).

Prepare the system:

```bash
# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
```

And then install docker:

```bash
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

## Retrieve the source code

Then install docker-compose

```bash
mkdir ~/workspace && cd ~/workspace
git clone https://github.com/pokt-network/poktroll-docker-compose-example.git
cd poktroll-docker-compose-example
```

## Update your environment

```bash
echo "source $(pwd)/helpers.sh" >> ~/.bashrc
cp .env.sample .env
sed -i -e s/NODE_HOSTNAME=/NODE_HOSTNAME=104.207.159.194/g .env
```

## Start up the full node

```bash
docker compose up -d poktrolld poktrolld
# Optional: watch the block height sync up & logs
docker-compose logs -f --tail 100 poktrolld
watch -n 1 "curl -s -X POST localhost:26657/block | jq '.result.block.header.height'"
```

## Create new addresses for all your accounts

Supplier:

```bash
poktrolld keys add supplier >> /tmp/supplier
mnemonic=$(tail -n 1 /tmp/supplier | tr -d '\r') sed -i "s|SUPPLIER_MNEMONIC=\".*\"|SUPPLIER_MNEMONIC=\"$mnemonic\"|" .env
address=$(awk '/address:/{print $3}' /tmp/supplier | tr -d '\r'); sed -i "s|SUPPLIER_ADDR=\".*\"|SUPPLIER_ADDR=\"$address\"|" .env
```

Application:

```bash
poktrolld keys add application >> /tmp/application
mnemonic=$(tail -n 1 /tmp/application | tr -d '\r') sed -i "s|APPLICATION_MNEMONIC=\".*\"|APPLICATION_MNEMONIC=\"$mnemonic\"|" .env
address=$(awk '/address:/{print $3}' /tmp/application | tr -d '\r'); -i sed "s|APPLICATION_ADDR=\".*\"|APPLICATION_ADDR=\"$address\"|" .env
```

Gateway::

```bash
poktrolld keys add gateway >> /tmp/gateway
mnemonic=$(tail -n 1 /tmp/gateway | tr -d '\r') sed -i "s|GATEWAY_MNEMONIC=\".*\"|GATEWAY_MNEMONIC=\"$mnemonic\"|" .env
address=$(awk '/address:/{print $3}' /tmp/gateway | tr -d '\r'); -i sed "s|GATEWAY_ADDR=\".*\"|GATEWAY_ADDR=\"$address\"|" .env
```
