#!/bin/bash

# Minikube Installation Script for Ubuntu 24.04
# Includes crictl and CNI plugins for Kubernetes 1.24+ and the 'none' driver

set -e

echo "Updating system packages..."
sudo apt-get update -y
sudo apt-get upgrade -y

echo "Installing dependencies..."
sudo apt-get install -y apt-transport-https curl wget conntrack socat

# Install Docker (required container runtime)
echo "Installing Docker..."
sudo apt-get remove -y docker docker-engine docker.io containerd runc || true
sudo apt-get install -y docker.io
sudo systemctl enable docker
sudo systemctl start docker

# Install kubectl
echo "Installing kubectl..."
curl -LO "https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install kubectl /usr/local/bin/

# Install crictl (required by Kubernetes 1.24+)
echo "Installing crictl..."
VERSION="v1.31.0"
wget https://github.com/kubernetes-sigs/cri-tools/releases/download/${VERSION}/crictl-${VERSION}-linux-amd64.tar.gz
sudo tar -xvf crictl-${VERSION}-linux-amd64.tar.gz -C /usr/local/bin
sudo chmod +x /usr/local/bin/crictl

# Install CNI Plugins
echo "Installing CNI plugins..."
CNI_VERSION="v1.2.0"
wget https://github.com/containernetworking/plugins/releases/download/${CNI_VERSION}/cni-plugins-linux-amd64-${CNI_VERSION}.tgz
sudo mkdir -p /opt/cni/bin
sudo tar -xvf cni-plugins-linux-amd64-${CNI_VERSION}.tgz -C /opt/cni/bin

# Verify crictl and CNI plugins installation
echo "Verifying crictl and CNI plugins installation..."
crictl --version
ls /opt/cni/bin

# Install Minikube
echo "Installing Minikube..."
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube

# Add current user to the Docker group (non-root user setup)
echo "Configuring Docker permissions for non-root user..."
CURRENT_USER=$(whoami)
sudo usermod -aG docker $CURRENT_USER
newgrp docker <<EOF

# Start Minikube
echo "Starting Minikube..."
minikube start --driver=none

EOF

# Verify Installation
echo "Verifying Minikube installation..."
minikube version
kubectl version --client
minikube status

echo "Minikube installation completed successfully!"
