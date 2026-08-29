#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cluster_name="k8s-zero-to-production"

if [[ -x "${repo_root}/.tools/bin/kind" ]]; then
  kind_binary="${repo_root}/.tools/bin/kind"
elif command -v kind >/dev/null 2>&1; then
  kind_binary="$(command -v kind)"
else
  echo "Kind is not installed; no managed lab cluster can be removed." >&2
  exit 1
fi

if ! "${kind_binary}" get clusters | grep -Fxq "${cluster_name}"; then
  echo "Kind cluster does not exist: ${cluster_name}"
  exit 0
fi

"${kind_binary}" delete cluster --name "${cluster_name}"
echo "Deleted only the managed Kind cluster: ${cluster_name}"
