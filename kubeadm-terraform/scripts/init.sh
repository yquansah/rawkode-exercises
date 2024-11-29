#!/bin/bash
set -e

run_kubeadm() {
  cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.ipv4.ip_forward = 1
EOF

  sudo sysctl --system

  sudo apt-get update

  sudo apt-get install -y apt-transport-https ca-certificates curl gpg

  curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.30/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

  echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.30/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list

  sudo apt-get update
  sudo apt-get install -y kubelet kubeadm kubectl

  sudo systemctl enable --now kubelet

  CONTAINERD_OUTPUT=containerd-2.0.0-linux-amd64.tar.gz
  CONTAINERD_SERVICE=containerd.service

  wget -O $CONTAINERD_SERVICE https://raw.githubusercontent.com/containerd/containerd/main/containerd.service

  wget -O $CONTAINERD_OUTPUT https://github.com/containerd/containerd/releases/download/v2.0.0/containerd-2.0.0-linux-amd64.tar.gz

  wget -O runc.amd64 https://github.com/opencontainers/runc/releases/download/v1.2.2/runc.amd64

  sudo install -m 755 runc.amd64 /usr/local/bin/runc

  tar -xzvf $CONTAINERD_OUTPUT

  sudo mv bin/* /usr/local/bin

  sudo mv $CONTAINERD_SERVICE /etc/systemd/system/$CONTAINERD_SERVICE

  sudo systemctl daemon-reload

  sudo systemctl enable --now containerd

  TOKEN=$(curl -X PUT "http://169.254.169.254/latest/api/token" \
    -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")

  PRIVATE_IP=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" -s http://169.254.169.254/latest/meta-data/local-ipv4)

  sudo kubeadm init --apiserver-advertise-address="$PRIVATE_IP"
}

run_kubeadm
