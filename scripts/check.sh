#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
temporary_dir="$(mktemp -d "${TMPDIR:-/tmp}/k8s-zero-check.XXXXXX")"
cleanup() { rm -rf -- "${temporary_dir}"; }
trap cleanup EXIT

if ! command -v kubectl >/dev/null 2>&1; then
  echo "kubectl is required for local Kustomize rendering." >&2
  exit 1
fi

echo "==> Checking shell syntax"
while IFS= read -r script; do
  bash -n "${script}"
done < <(find "${repo_root}" -type f -name '*.sh' -not -path '*/.git/*' -not -path '*/.tools/*' | sort)

echo "==> Rendering Kustomize overlays"
kubectl kustomize "${repo_root}/apps/web/overlays/local" > "${temporary_dir}/local.yaml"
kubectl kustomize "${repo_root}/apps/web/overlays/production-example" > "${temporary_dir}/production.yaml"

echo "==> Checking security, resilience, documentation, and identity policy"
python3 "${repo_root}/scripts/check.py" "${temporary_dir}/local.yaml" "${temporary_dir}/production.yaml"

if command -v kubeconform >/dev/null 2>&1; then
  echo "==> Running Kubernetes schema validation"
  kubeconform -strict -summary "${temporary_dir}/local.yaml" "${temporary_dir}/production.yaml"
else
  echo "==> kubeconform not installed; CI performs strict schema validation"
fi

echo "All offline Kubernetes checks passed. No cluster or cloud resources were created."
