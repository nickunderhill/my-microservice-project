#!/bin/bash

set -e  # Stop on error

echo "Checking Docker..."
if ! command -v docker &> /dev/null; then
    echo "Installing Docker..."
    # Add Docker's official GPG key:
    sudo apt-get update
    sudo apt-get install ca-certificates curl
    sudo install -m 0755 -d /etc/apt/keyrings
    sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
    sudo chmod a+r /etc/apt/keyrings/docker.asc

    # Add the repository to Apt sources:
    echo \
        "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
        $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
        sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt-get update
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    echo "Docker installed."
else
    echo "Docker already installed."
fi

echo "Checking Docker Compose..."
if ! command -v docker-compose &> /dev/null; then
    echo "Installing Docker Compose..."
    sudo apt-get install docker-compose-plugin
    echo "Docker Compose installed."
else
    echo "Docker Compose already installed."
fi

echo "Checking Python 3.9+..."
if command -v python3 &> /dev/null; then
    PYTHON_VERSION=$(python3 --version 2>&1 | cut -d' ' -f2)
    MAJOR_VERSION=$(echo $PYTHON_VERSION | cut -d'.' -f1)
    MINOR_VERSION=$(echo $PYTHON_VERSION | cut -d'.' -f2)
    
    if [[ "$MAJOR_VERSION" -eq 3 && "$MINOR_VERSION" -ge 9 ]]; then
        echo "Python 3.9 or newer is already installed: $PYTHON_VERSION"
    else
        echo "Python version $PYTHON_VERSION is too old. Installing Python 3.9..."
        sudo add-apt-repository -y ppa:deadsnakes/ppa
        sudo apt-get update
        sudo apt-get install -y python3.9 python3.9-venv python3.9-dev
        echo "Python 3.9 installed."
    fi
else
    echo "Python3 not found. Installing Python 3.9..."
    sudo add-apt-repository -y ppa:deadsnakes/ppa
    sudo apt-get update
    sudo apt-get install -y python3.9 python3.9-venv python3.9-dev
    echo "Python 3.9 installed."
fi

echo "Checking pip..."
if ! command -v pip3 &> /dev/null; then
    echo "Installing pip..."
    sudo apt install -y python3-pip
    echo "pip installed."
else
    echo "pip already installed."
fi

echo "Checking Django..."
if ! pip3 show django &> /dev/null; then
    echo "Installing Django..."
    pip3 install django --break-system-packages
    echo "Django installed."
else
    echo "Django already installed."
fi


echo "All tools are installed."