#!/bin/bash

# Update system packages
sudo apt update && sudo apt upgrade -y

# Install basic networking tools
sudo apt install -y net-tools curl gnupg lsb-release

# Add PostgreSQL APT repository
echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" | \
  sudo tee /etc/apt/sources.list.d/pgdg.list

# Import PostgreSQL signing key
curl -fsSL https://www.postgresql.org/media/keys/ACCC4CF8.asc | \
  gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/postgresql.gpg > /dev/null

# Update package list and install PostgreSQL 17 client
sudo apt update
sudo apt install -y postgresql-client-17