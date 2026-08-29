# Kubernetes interview questions

Answers should connect control-plane behavior, workload state, operational evidence, failure modes and trade-offs.

## Fundamentals

1. What happens after a Deployment manifest is applied?
2. Compare Pod, ReplicaSet, Deployment, StatefulSet, DaemonSet, Job and CronJob.
3. What is reconciliation?
4. How do labels and selectors connect workloads and Services?
5. Compare ConfigMap and Secret, including what neither solves by itself.
6. Explain requests, limits and Kubernetes QoS classes.
7. Compare readiness, liveness and startup probes.

## Intermediate

1. Trace a request from a Service to a container port.
2. Why can a running Pod still be unavailable?
3. Explain PersistentVolume, PersistentVolumeClaim, StorageClass and reclaim policy.
4. Compare node selector, affinity, topology spread, taints and tolerations.
5. How does a PodDisruptionBudget behave during voluntary and involuntary disruption?
6. Design namespace-scoped RBAC for an application that reads only one ConfigMap.
7. Explain default-deny NetworkPolicy and the role of the CNI.

## Advanced

1. Design a zero-downtime rollout and define rollback signals.
2. Diagnose a Deployment with desired replicas but zero available replicas.
3. How do Horizontal Pod Autoscaler, Vertical Pod Autoscaler and node autoscaling interact?
4. What causes API-server or etcd pressure, and how would you observe it?
5. Explain admission control and where policy engines fit.
6. How do you upgrade Kubernetes and critical add-ons safely?
7. Compare Helm and Kustomize for ownership, reuse and environment variance.

## Production

1. Design a multi-AZ EKS workload with failure-domain and cost trade-offs.
2. How would workloads access AWS APIs without static credentials?
3. Define a cluster logging, metrics and tracing architecture with ownership and retention.
4. How do you back up and restore stateful applications, and how do you prove recovery?
5. Design image promotion, signing, provenance and admission verification.
6. How would you isolate teams: namespaces, clusters, accounts, or a combination?
7. What is your response when NetworkPolicy enforcement differs between development and production?

## Senior engineer

1. When should an organization create another cluster rather than another namespace?
2. Define platform golden paths without preventing teams from handling exceptional requirements.
3. How do you prevent resource requests from becoming permanently inaccurate?
4. Design cluster and workload SLOs without alerting on every infrastructure symptom.
5. How do you investigate a regional dependency failure affecting otherwise healthy Pods?
6. What evidence is required before declaring a Kubernetes platform production-ready?

## Architect and SRE scenarios

### Scenario — cascading readiness failure

A database slows down. Every application readiness probe depends synchronously on that database, so all Pods become unready and the Service loses every endpoint. Explain impact containment, probe redesign, dependency timeouts, degradation, observability and prevention.

### Scenario — failed cluster upgrade

After a control-plane upgrade, an admission webhook is unavailable and blocks Pod creation. Explain break-glass access, failure policy, dependency ordering, rollback constraints, compatibility testing and prevention.

### Scenario — cost and reliability conflict

A team requests replicas in three AZs, on-demand capacity, large requests, aggressive log retention and a warm regional standby. Present a measurement-led cost review without silently weakening resilience objectives.

### Scenario — compromised image

A signed image is later found vulnerable. Explain inventory, admission, runtime exposure, rollout, credential rotation, evidence preservation, communication and long-term supply-chain controls.

## Answer framework

```text
Requirement → Kubernetes mechanism → Dependency or limitation
→ Failure mode → Evidence → Mitigation → Permanent control → Trade-off
```
