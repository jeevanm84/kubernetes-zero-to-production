# Security and production readiness

## Threat boundaries

Review security across four planes:

1. **Supply chain:** source, dependencies, images, SBOM, signing and provenance.
2. **Control plane:** API exposure, authentication, authorization, admission and audit.
3. **Workload:** identity, Pod security, secrets, network access and runtime behavior.
4. **Operations:** privileged access, break-glass procedures, monitoring, backup and incident response.

## Controls demonstrated in this repository

| Control | Implementation | Limitation |
|---|---|---|
| Pod Security | Namespace enforces `restricted` | Admission labels do not validate application logic |
| Non-root | UID/GID 101 and `runAsNonRoot` | Image contents must support the selected identity |
| Seccomp | `RuntimeDefault` | Runtime profiles vary by platform |
| Capabilities | Drop `ALL` | Some workloads need a reviewed minimal addition |
| Filesystem | Read-only root with explicit temporary volumes | Writable application data needs designed storage |
| Service identity | Dedicated account, token automount disabled | Add workload identity only when the app requires AWS/API access |
| Resources | CPU/memory requests and limits | Values require load and capacity testing |
| Image integrity | Version and multi-architecture digest | Add signatures, provenance and controlled promotion |
| Network | Default deny plus explicit ingress | Enforcement depends on a capable CNI; Kind default networking may not enforce policy |

## Secrets

Base64 is encoding, not encryption. Do not commit real Secret manifests. Production choices may include:

- External Secrets with a managed secret store
- Secrets Store CSI Driver
- Encrypted etcd with managed key controls
- Short-lived workload identity instead of static credentials
- Rotation, audit and application reload behavior

Define what happens when the secret backend is unavailable or a secret is rotated incorrectly.

## RBAC

Start with no Kubernetes API permission for the web workload. If an application needs API access:

1. Document the exact resource, namespace and verbs.
2. Create a namespaced Role when cluster scope is unnecessary.
3. Bind only the workload service account.
4. Test allowed and denied actions with `kubectl auth can-i`.
5. Monitor use and review continued need.

Avoid wildcard resources, verbs, and cluster-admin bindings.

## Production-readiness checklist

### Architecture and availability

- [ ] Failure domains and replica topology are documented.
- [ ] Pod and node disruption behavior is tested.
- [ ] Dependencies have timeouts, retries, circuit breaking, and capacity assumptions.
- [ ] Rollout and rollback criteria are automated.
- [ ] Control-plane and worker upgrade paths are rehearsed.

### Security

- [ ] Images are scanned, signed, verified and promoted by digest.
- [ ] Admission policy rejects prohibited workload settings.
- [ ] Workload identity replaces static cloud credentials.
- [ ] NetworkPolicy is enforced and tested by the chosen CNI.
- [ ] Secrets are externally managed, rotated and audited.
- [ ] Audit logs and privileged actions are monitored.

### Reliability and observability

- [ ] SLIs, SLOs, error budgets and ownership exist.
- [ ] Metrics, logs and traces include useful service context.
- [ ] Alerts are symptom-based, actionable and routed.
- [ ] Capacity and autoscaling behavior are load-tested.
- [ ] Backup restoration—not only backup creation—is tested.

### Operations and recovery

- [ ] Runbooks cover common failures and access dependencies.
- [ ] Recovery time and recovery point objectives are approved.
- [ ] GitOps/controller outages and repository compromise are considered.
- [ ] Cluster, regional and identity-provider failure scenarios are exercised.
- [ ] Resource ownership, cost allocation and cleanup are visible.

## Future improvements

- Policy-as-code tests with Kyverno or Gatekeeper
- Signed image admission using organization-approved tooling
- Prometheus/OpenTelemetry observability stack
- Horizontal/vertical and node autoscaling labs
- Gateway API and TLS lifecycle
- Stateful backup and restore lab
- GitOps controller bootstrap with a separate configuration repository
- Optional reviewed EKS implementation in the AWS/platform portfolio
