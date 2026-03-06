#!/usr/bin/env bash
# setup-argocd.sh — Install ArgoCD into a running K3s cluster and register the app
# Usage: bash scripts/setup-argocd.sh
set -euo pipefail

ARGOCD_NAMESPACE="argocd"
ARGOCD_VERSION="${ARGOCD_VERSION:-stable}"

echo "==> Creating ArgoCD namespace..."
kubectl create namespace "${ARGOCD_NAMESPACE}" --dry-run=client -o yaml | kubectl apply -f -

echo "==> Installing ArgoCD (${ARGOCD_VERSION})..."
kubectl apply -n "${ARGOCD_NAMESPACE}" \
  -f "https://raw.githubusercontent.com/argoproj/argo-cd/${ARGOCD_VERSION}/manifests/install.yaml"

echo "==> Waiting for ArgoCD pods to be ready..."
kubectl rollout status deployment/argocd-server -n "${ARGOCD_NAMESPACE}" --timeout=300s

echo "==> Applying ArgoCD project and application manifests..."
kubectl apply -f argocd/project.yaml
kubectl apply -f argocd/application.yaml

echo ""
echo "==> ArgoCD setup complete!"
echo ""
echo "    Retrieve the initial admin password with:"
echo "    kubectl get secret argocd-initial-admin-secret -n argocd \\"
echo "      -o jsonpath='{.data.password}' | base64 -d && echo"
echo ""
echo "    Port-forward the ArgoCD UI with:"
echo "    kubectl port-forward svc/argocd-server -n argocd 8080:443"
echo ""
echo "    Then open: https://localhost:8080  (user: admin)"
