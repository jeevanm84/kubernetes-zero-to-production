# Lab 01 — cluster basics

Create the fixed Kind cluster with `./scripts/create-kind-cluster.sh`. Inspect nodes, namespaces, API resources and component health.

```bash
kubectl config current-context
kubectl cluster-info
kubectl get nodes -o wide
kubectl api-resources
kubectl get --raw='/readyz?verbose'
```

Explain the roles of API server, scheduler, controllers, etcd, kubelet and container runtime. Do not treat a local control-plane container as equivalent to a managed regional control plane.

Verification: context is `kind-k8s-zero-to-production`; one control-plane and two workers are Ready.
