#!/usr/bin/env bash
set -euo pipefail

expected_context="kind-k8s-zero-to-production"
current_context="$(kubectl config current-context)"

if [[ "${current_context}" != "${expected_context}" ]]; then
  echo "Refusing verification: expected context ${expected_context}, found ${current_context}." >&2
  exit 1
fi

kubectl get nodes
kubectl -n platform-demo rollout status deployment/web --timeout=180s
kubectl -n platform-demo get pods -o wide
kubectl -n platform-demo get service,poddisruptionbudget,networkpolicy
kubectl -n platform-demo get endpointslice -l kubernetes.io/service-name=web

ready_replicas="$(kubectl -n platform-demo get deployment web -o jsonpath='{.status.readyReplicas}')"
if [[ "${ready_replicas:-0}" -lt 2 ]]; then
  echo "Expected at least two ready web replicas; found ${ready_replicas:-0}." >&2
  exit 1
fi

echo "Local platform verification passed."
