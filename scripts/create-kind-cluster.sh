#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cluster_name="k8s-zero-to-production"

if [[ -x "${repo_root}/.tools/bin/kind" ]]; then
  kind_binary="${repo_root}/.tools/bin/kind"
elif command -v kind >/dev/null 2>&1; then
  kind_binary="$(command -v kind)"
else
  echo "Kind is required. Run ./scripts/install-kind.sh first." >&2
  exit 1
fi

if ! docker info >/dev/null 2>&1; then
  echo "Docker is not running. Start Docker and try again." >&2
  exit 1
fi

if "${kind_binary}" get clusters | grep -Fxq "${cluster_name}"; then
  echo "Kind cluster already exists: ${cluster_name}"
  exit 0
fi

"${kind_binary}" create cluster \
  --name "${cluster_name}" \
  --config "${repo_root}/clusters/kind/cluster.yaml" \
  --wait 180s

kubectl config use-context "kind-${cluster_name}" >/dev/null
kubectl get nodes -o wide
