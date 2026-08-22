#!/bin/bash
set -e

apt-get update
apt-get upgrade -y

# Install packages required to use Docker's official repository
apt-get install -y ca-certificates curl

# Create a directory for repository signing keys
install -m 0755 -d /etc/apt/keyrings

# Download Docker's official GPG signing key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
  -o /etc/apt/keyrings/docker.asc

chmod a+r /etc/apt/keyrings/docker.asc

# Add Docker's official Ubuntu repository
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" \
  > /etc/apt/sources.list.d/docker.list

# Refresh package indexes now that the Docker repository exists
apt-get update

# Install Docker Engine and Docker Compose
apt-get install -y \
  docker-ce \
  docker-ce-cli \
  containerd.io \
  docker-buildx-plugin \
  docker-compose-plugin

# Ensure Docker starts now and on future boots
systemctl enable --now docker

# Allow the default Ubuntu user to run Docker without sudo
usermod -aG docker ubuntu
