#!/usr/bin/env bash

# This script installs docker and kubernetes
set -e

# Install the docker.io package
sudo apt install -y docker.io

# Create or replace the contents of /etc/docker/daemon.json to enable the systemd cgroup driver

cat > ~/daemon.json <<EOF
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2"
}
EOF

sudo mv ~/daemon.json /etc/docker/daemon.json

# swapoff
sudo sed -i 's/vm.swappiness=100/vm.swappiness=1/g' /etc/sysctl.conf
sudo swapoff -a  

# Enable net.bridge.bridge-nf-call-iptables and -iptables6

cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF

sudo sysctl --system

# Add the packages.cloud.google.com atp key

curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -

# Add the Kubernetes repo
cat <<EOF | sudo tee /etc/apt/sources.list.d/kubernetes.list
deb https://apt.kubernetes.io/ kubernetes-xenial main
EOF

# Update the apt cache and install kubelet, kubeadm, and kubectl
sudo apt update && sudo apt install -y kubelet kubeadm kubectl

# Disable (mark as held) updates for the Kubernetes packages
sudo apt-mark hold kubelet kubeadm kubectl

