# End-to-end Kubernetes guide

This is the primary learning path. Modules 0–9 run locally. Module 10 discusses EKS architecture and readiness but does not provision AWS resources.

## Progress map

| Module | Capability | Environment |
|---:|---|---|
| 0 | Validate manifests and policy | Offline |
| 1 | Create and inspect a local cluster | Kind |
| 2 | Deploy and reconcile workloads | Kind |
| 3 | Discover and route service traffic | Kind |
| 4 | Manage configuration and secrets safely | Kind |
| 5 | Understand persistent storage lifecycle | Kind |
| 6 | Apply workload and network security | Offline + Kind |
| 7 | Observe health, resources, events and rollout state | Kind |
| 8 | Diagnose injected failures | Kind |
| 9 | Understand declarative delivery and GitOps | Offline |
| 10 | Evaluate production EKS architecture | Architecture only |

## Module 0 — validate without a cluster

```bash
git clone https://github.com/jeevanm84/kubernetes-zero-to-production.git
cd kubernetes-zero-to-production
./scripts/check.sh
```

The check renders local and production-example overlays, verifies security and availability requirements, validates documentation, and uses `kubeconform` when available. No API server is contacted.

Checkpoint: explain why rendering Kustomize and validating schemas still cannot prove runtime readiness.

## Module 1 — create a local cluster

Prerequisites: Docker running, `kubectl`, and Kind. Install the pinned Kind binary locally if needed:

```bash
./scripts/install-kind.sh
./scripts/create-kind-cluster.sh
kubectl cluster-info --context kind-k8s-zero-to-production
kubectl get nodes -o wide
```

The cluster contains one control-plane node and two workers. It models scheduling across nodes, not cloud Availability Zones.

Checkpoint: all three nodes report `Ready`, and the current context is `kind-k8s-zero-to-production`.

## Module 2 — deploy and inspect reconciliation

```bash
kubectl apply -k apps/web/overlays/local
kubectl -n platform-demo rollout status deployment/web
kubectl -n platform-demo get deployment,replicaset,pods -o wide
kubectl -n platform-demo describe deployment web
```

Change the overlay replica count, apply it, and watch Kubernetes reconcile actual state to desired state:

```bash
kubectl -n platform-demo get pods --watch
```

Checkpoint: distinguish Deployment, ReplicaSet, and Pod responsibilities.

## Module 3 — service discovery and traffic

```bash
kubectl -n platform-demo get service web
kubectl -n platform-demo get endpointslice -l kubernetes.io/service-name=web
kubectl -n platform-demo port-forward service/web 8080:80
```

In another terminal:

```bash
curl --fail http://localhost:8080/healthz
curl --fail http://localhost:8080/
```

Checkpoint: trace `Service port 80 → named targetPort http → container port 8080` and explain how selectors determine endpoints.

## Module 4 — configuration and secrets

Inspect how the ConfigMap becomes mounted files:

```bash
kubectl -n platform-demo get configmap web-content -o yaml
kubectl -n platform-demo exec deployment/web -- cat /etc/nginx/conf.d/default.conf
```

Update `index.html`, apply the overlay, and observe whether the mounted file and running process behavior change. Learn why a rollout annotation or immutable/config-version pattern is often used in production.

Do not store real secrets in Git. Kubernetes Secret values are encoded, not inherently encrypted. See [Security and Production Readiness](SECURITY_AND_PRODUCTION.md).

## Module 5 — storage lifecycle

Complete [Lab 05](../labs/05-storage/README.md) using a disposable PersistentVolumeClaim. Observe binding, pod attachment, and what happens when the consuming Pod is recreated.

Checkpoint: explain PersistentVolume, PersistentVolumeClaim, StorageClass, access mode, reclaim policy, and why a StatefulSet does not itself make data highly available.

## Module 6 — security controls

Inspect the rendered workload:

```bash
kubectl kustomize apps/web/overlays/local | less
kubectl -n platform-demo auth can-i --list --as=system:serviceaccount:platform-demo:web
kubectl -n platform-demo get networkpolicy
```

Identify:

- Restricted Pod Security labels
- Non-root execution
- RuntimeDefault seccomp
- Dropped capabilities
- Read-only root filesystem
- Disabled token automount
- Requests and limits
- Deny-by-default network policy

Checkpoint: explain which controls are admission-time, runtime, network-plugin-dependent, and application-dependent.

## Module 7 — observe health and rollout state

```bash
kubectl -n platform-demo get pods
kubectl -n platform-demo describe pods
kubectl -n platform-demo get events --sort-by=.metadata.creationTimestamp
kubectl -n platform-demo logs deployment/web --all-pods=true --tail=50
kubectl top pods -n platform-demo
```

`kubectl top` requires Metrics Server, which Kind does not install by default. Treat its absence as an observability dependency to identify, not a reason to install unreviewed manifests.

Run:

```bash
./scripts/verify-cluster.sh
```

## Module 8 — troubleshoot failures

Use the scenarios in [Lab 08](../labs/08-troubleshooting/README.md). For every incident, follow:

```text
Symptoms → Events → Desired state → Current state → Logs
→ Network/config/resources → Root cause → Mitigation → Prevention
```

Never inject failures into a context other than `kind-k8s-zero-to-production`.

## Module 9 — GitOps reasoning

Complete [Lab 09](../labs/09-gitops/README.md). Compare imperative changes with Git-reviewed desired state and design a reconciliation, promotion, rollback, drift, and secret-management flow.

Checkpoint: explain why GitOps is continuous reconciliation, not merely running `kubectl apply` from CI.

## Module 10 — production and EKS

Complete [Lab 10](../labs/10-production-eks/README.md). Evaluate:

- Account and cluster isolation
- Regional control plane and multi-AZ workers
- Private networking and endpoints
- Workload identity
- Ingress, DNS, certificates and WAF
- Managed storage and backup/restore
- Cluster and workload autoscaling
- Logs, metrics, traces, SLOs and alerting
- Policy and supply-chain controls
- Upgrade strategy and disaster recovery
- Cost allocation and cleanup

This repository intentionally does not provide an automatic EKS deployment. A later AWS/platform repository may implement the reviewed design with explicit cost controls.

## Cleanup

Remove the application, or delete only the fixed learning cluster:

```bash
kubectl delete -k apps/web/overlays/local
./scripts/destroy-kind-cluster.sh
```

Kind runs locally, but its nodes and images consume Docker disk space until removed.

## Completion checklist

- [ ] I can explain reconciliation from Deployment to Pod.
- [ ] I can trace Service selection and endpoint routing.
- [ ] I understand configuration, Secret, and storage boundaries.
- [ ] I can identify the workload security controls in the rendered manifest.
- [ ] I inspect events, status, logs, probes, resources, and policies systematically.
- [ ] I recovered at least three injected failure scenarios.
- [ ] I can explain GitOps and its security boundaries.
- [ ] I can identify what Kind cannot prove about EKS or production readiness.
- [ ] I removed the local cluster after completing the labs.
