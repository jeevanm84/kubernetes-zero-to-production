# Kubernetes troubleshooting handbook

Start with the resource's desired state, current state, conditions and events. Avoid deleting a Pod before collecting evidence.

## Standard investigation sequence

```bash
kubectl config current-context
kubectl get namespaces
kubectl -n <namespace> get deployment,replicaset,pods -o wide
kubectl -n <namespace> describe pod <pod>
kubectl -n <namespace> get events --sort-by=.metadata.creationTimestamp
kubectl -n <namespace> logs <pod> --all-containers --tail=100
kubectl -n <namespace> logs <pod> --all-containers --previous --tail=100
```

## Incident — `ImagePullBackOff`

**Symptoms:** Pod remains pending and reports `ErrImagePull` or `ImagePullBackOff`.

**Investigation:** Inspect the exact image, registry event, pull secret reference, node network path and architecture compatibility.

```bash
kubectl -n platform-demo describe pod <pod>
kubectl -n platform-demo get pod <pod> -o jsonpath='{.spec.containers[*].image}'
```

**Root causes:** Missing tag/digest, authentication failure, registry outage, rate limit, network/DNS failure, unsupported platform.

**Mitigation:** Restore a known-good digest or registry access. Do not change to `latest` to bypass diagnosis.

**Prevention:** Digest promotion, registry monitoring, pull-through strategy, image signature policy, and rollout verification.

## Incident — `CrashLoopBackOff`

**Symptoms:** Container repeatedly starts and exits; restart count increases.

**Investigation:**

```bash
kubectl -n platform-demo logs <pod> --previous
kubectl -n platform-demo get pod <pod> -o jsonpath='{.status.containerStatuses[*].lastState}'
kubectl -n platform-demo describe pod <pod>
```

Check command/arguments, configuration, permissions, dependencies, OOM termination and probe behavior.

**Mitigation:** Roll back a known regression or correct the smallest failed dependency/configuration. Do not disable liveness blindly.

## Incident — Pod remains `Pending`

**Symptoms:** Pod has no node assignment or reports scheduling failures.

**Investigation:** Read scheduler events and compare requests, selectors, affinity, taints, topology and volumes with available nodes.

```bash
kubectl describe pod <pod>
kubectl get nodes --show-labels
kubectl describe nodes
```

**Common causes:** Insufficient CPU/memory, impossible topology spread, unmatched node selector, unhandled taint, unbound PVC, quota.

## Incident — Service has no endpoints

**Symptoms:** Service exists but requests fail; EndpointSlice contains no ready endpoints.

```bash
kubectl -n platform-demo get service web -o yaml
kubectl -n platform-demo get pods --show-labels
kubectl -n platform-demo get endpointslice -l kubernetes.io/service-name=web -o yaml
```

**Root causes:** Selector mismatch, Pods not Ready, wrong namespace, target port mismatch.

**Permanent fix:** Test selector/label contracts and readiness behavior in CI and rollout verification.

## Incident — Readiness never succeeds

**Symptoms:** Containers run but receive no Service traffic.

Inspect probe path, named port, scheme, timeout, dependency assumptions, process binding address and startup duration. A readiness probe should answer whether this instance can safely serve traffic now.

Do not make readiness depend on every downstream system if doing so could remove all replicas during a dependency outage.

## Incident — rollout is stuck

```bash
kubectl -n platform-demo rollout status deployment/web
kubectl -n platform-demo rollout history deployment/web
kubectl -n platform-demo get replicaset
kubectl -n platform-demo describe deployment web
```

Check unavailable capacity, quota, probes, image pull, scheduling, disruption constraints, and `maxUnavailable`/`maxSurge` interaction.

Immediate mitigation may be:

```bash
kubectl -n platform-demo rollout undo deployment/web
```

Record evidence and understand the revision before rollback.

## Incident — `OOMKilled` or CPU throttling

Correlate container termination state, resource limits, workload demand, latency and node pressure. Raising limits without capacity and leak analysis may move the failure elsewhere.

Review:

```bash
kubectl -n platform-demo describe pod <pod>
kubectl top pod -n platform-demo
kubectl top node
```

## Incident — NetworkPolicy blocks traffic

Confirm the CNI enforces NetworkPolicy. Inspect source/destination namespace labels, Pod labels, ports, protocols, DNS egress and return traffic assumptions.

Use a dedicated diagnostic Pod approved for the lab; do not weaken production policy globally to test connectivity.

## Incident — PVC remains pending

Inspect PVC events, StorageClass, provisioner, access mode, requested capacity, topology and volume binding mode. On Kind, available provisioners differ from managed cloud platforms.

## Incident — context mistake

**Symptoms:** A valid command targets the wrong cluster or namespace.

**Mitigation:** Stop immediately, record actions, assess impact and use explicit contexts/namespaces. Repository mutation scripts require `kind-k8s-zero-to-production`.

**Prevention:** Context in shell prompt, separate kubeconfig files, least privilege, protected production access, and command wrappers that assert expected context.
