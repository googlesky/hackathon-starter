#!/bin/bash

# Function to check if a command exists
command_exists() {
    command -v "$1" &> /dev/null
}

# Function to install containerd and nerdctl
install_containerd_nerdctl() {
    echo "Installing containerd and nerdctl..."

    # Update package manager and install dependencies
    sudo apt-get update -y
    sudo apt-get install -y containerd

    # Configure containerd
    sudo mkdir -p /etc/containerd
    sudo containerd config default | sudo tee /etc/containerd/config.toml

    # Restart containerd service
    sudo systemctl restart containerd
    sudo systemctl enable containerd

    # Install nerdctl
    echo "Installing nerdctl..."
    sudo apt-get install -y wget
    wget https://github.com/containerd/nerdctl/releases/download/v1.7.0/nerdctl-1.7.0-linux-amd64.tar.gz
    sudo tar Cxzvf /usr/local/bin nerdctl-1.7.0-linux-amd64.tar.gz

    # Verify installation
    if command_exists nerdctl && command_exists containerd; then
        echo "containerd and nerdctl installed successfully!"
    else
        echo "Failed to install containerd or nerdctl."
        exit 1
    fi
}

# Function to install k3s and kubectl
install_k3s() {
    echo "Installing k3s (this will also install kubectl)..."
    curl -sfL https://get.k3s.io | sh -

    # Verify installation
    if command_exists kubectl; then
        echo "k3s and kubectl installed successfully!"
    else
        echo "Failed to install k3s or kubectl."
        exit 1
    fi
}

# Check if Docker or containerd is installed
if command_exists docker; then
    echo "Docker is already installed."
elif command_exists containerd; then
    echo "containerd is already installed."
else
    echo "Neither Docker nor containerd is installed. Installing containerd and nerdctl..."
    install_containerd_nerdctl
fi

# Check if kubectl is installed and working
if command_exists kubectl; then
    echo "kubectl is installed. Checking if it's working..."
    
    # Test if kubectl is working (e.g., check the cluster info)
    if kubectl cluster-info &> /dev/null; then
        echo "kubectl is working correctly."
    else
        echo "kubectl is installed but not working. Installing k3s to fix kubectl..."
        install_k3s
    fi
else
    echo "kubectl is not installed. Installing k3s..."
    install_k3s
fi

echo "Script execution completed."