#!/bin/sh

# Add Docker's official GPG key:
apt install ca-certificates curl gnupg
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
chmod a+r /etc/apt/keyrings/docker.gpg

# Add the repository to Apt sources:
echo \
  "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
tee /etc/apt/sources.list.d/docker.list > /dev/null
apt update

# Install packages
apt install git docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y

# Prepare xray-server project folder
mkdir -p /opt/xray-server

# Clone repo
git clone $1 /opt/xray-server

# Deploy xray-server
cd /opt/xray-server; ./deploy.sh $2
