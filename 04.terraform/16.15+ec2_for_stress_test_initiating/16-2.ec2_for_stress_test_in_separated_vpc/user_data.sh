#!/bin/bash

# Check if the system architecture is amd64
ARCH=$(uname -m)

if [[ "$ARCH" == "x86_64" ]]; then
    echo "System architecture is amd64, proceeding with installation."

    # Step 1) Install Docker (for amd64 architecture)
    sudo apt-get update
    sudo apt-get install apt-transport-https ca-certificates curl software-properties-common -y
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
    sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
    sudo apt-get update
    sudo apt-get install docker-ce -y

    # Install Docker Compose
    sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
    echo "Docker and Docker Compose installed successfully."

    # Step 2) Install k6 (for amd64 architecture)
    echo "Installing k6 for load testing..."
    sudo docker pull grafana/k6
    echo "k6 installed successfully."

    # Step 3) Install Git (for amd64 architecture)
    echo "Installing Git..."
    sudo apt-get install git -y
    echo "Git installed successfully."

    # Step 4) Clone the eCommerce project repository
    echo "Cloning the eCommerce project repository..."
    cd /home/ubuntu/
    sudo git clone --depth 1 https://github.com/Doohwancho/ecommerce.git
    cd ecommerce/
    sudo chown -R ubuntu:ubuntu .
    echo "eCommerce project cloned successfully."

    # Confirm that everything has been set up properly
    echo "All installations completed successfully."

else
    echo "This script is designed for amd64 architecture. Exiting installation."
    exit 1
fi
