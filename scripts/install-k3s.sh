#!/usr/bin/env bash
# install-k3s.sh — Install K3s on an Ubuntu/Debian host (manual / local use)
# Usage: sudo bash scripts/install-k3s.sh
set -euo pipefail

K3S_VERSION="${K3S_VERSION:-v1.29.4+k3s1}"

echo "==> Installing K3s ${K3S_VERSION}..."
curl -sfL https://get.k3s.io | INSTALL_K3S_VERSION="${K3S_VERSION}" sh -s - server \
  --disable traefik \
  --write-kubeconfig-mode 644

echo "==> Waiting for K3s to be ready..."
until kubectl get nodes 2>/dev/null | grep -q " Ready"; do
  echo "    Still waiting..."
  sleep 5
done

echo "==> K3s is ready."
kubectl get nodes

echo ""
echo "==> To use kubectl outside root, run:"
echo "    export KUBECONFIG=/etc/rancher/k3s/k3s.yaml"
