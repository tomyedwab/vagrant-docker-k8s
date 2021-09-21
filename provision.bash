#!/bin/bash

set -e

# Docker/Microk8s prerequisites
apt-get update
apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release \
    snapd \
    ntp

# Install Docker
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo \
    "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian \
    $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
apt-get update
apt-get install -y \
    docker-ce \
    docker-ce-cli \
    containerd.io

# Expose docker daemon over TCP
sed -i 's/ExecStart=\/usr\/bin\/dockerd -H fd:\/\//ExecStart=\/usr\/bin\/dockerd -H tcp:\/\/0.0.0.0:2375/' /lib/systemd/system/docker.service
systemctl daemon-reload
systemctl restart docker.service

# Install Microk8s
snap install microk8s --classic --channel=1.21
/snap/bin/microk8s status --wait-ready

# Enable storage to support provisioning of PVCs
/snap/bin/microk8s enable storage

# Enable local registry that we can load the dev image into
/snap/bin/microk8s enable registry

# Enable dns resolution between running services
/snap/bin/microk8s enable dns

# Copy kubectl config file into the configs/ directory
/snap/bin/microk8s config |sed 's/10\.[0-9]\+\.[0-9]\+\.[0-9]\+/kubernetes.default/' > /vagrant/configs/config

# Load test cluster service account credentials to pull from gcr.io
/snap/bin/microk8s kubectl create secret docker-registry gcr-json-key \
  --docker-server=gcr.io \
  --docker-username=_json_key \
  --docker-password="$(cat /vagrant/secrets/gcp-service-account.json)" \
  --docker-email="$(cat /vagrant/secrets/gcp-service-account-name)"
/snap/bin/microk8s kubectl patch serviceaccount default -p '{"imagePullSecrets": [{"name": "gcr-json-key"}]}'
