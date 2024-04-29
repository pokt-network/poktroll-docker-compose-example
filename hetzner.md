# Hetzner Ubuntu Tutorial

- [Hetzner Ubuntu Tutorial](#hetzner-ubuntu-tutorial)
- [General](#general)
- [Pocket](#pocket)
- [Install Docker](#install-docker)
- [docker compose](#docker-compose)
- [Image](#image)

# General

https://console.hetzner.cloud/projects/2902196/servers/46665701/overview
Hetzner - Setting up node

ssh root@65.21.250.214

# Pocket

```bash
git clone https://github.com/pokt-network/poktroll-docker-compose-example.git
cd poktroll-docker-compose-example

curl https://raw.githubusercontent.com/pokt-network/pocket-network-genesis/master/poktrolld/testnet-validated.json > poktrolld-data/config/genesis.json

cp .env.sample .env
sed -i -e s/YOUR_NODE_IP_OR_HOST/65.21.250.214/g .env
```

# Install Docker

Ref: https://docs.docker.com/engine/install/ubuntu/

```bash
sudo apt-get update
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

echo \
 "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
 $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
 sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update

sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

# docker compose

Ref: https://www.digitalocean.com/community/tutorials/how-to-install-and-use-docker-compose-on-ubuntu-20-04

```bash
sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
```

# Image

platform: "linux/amd64"
https://github.com/Netflix/conductor/issues/2975#issuecomment-1137164430
