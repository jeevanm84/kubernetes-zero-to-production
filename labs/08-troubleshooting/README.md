# Lab 08 — failure investigation

Use only context `kind-k8s-zero-to-production`.

Practice these controlled failures using temporary manifest copies or reversible patches:

1. Invalid image → `ImagePullBackOff`
2. Invalid command → `CrashLoopBackOff`
3. Impossible node selector → `Pending`
4. Wrong readiness path → running but unready
5. Service selector mismatch → no endpoints
6. Memory limit too low → possible `OOMKilled`
7. Missing ConfigMap → volume setup failure

For each scenario record:

```text
Incident → Symptoms → Events → Investigation commands → Root cause
→ Immediate mitigation → Permanent fix → Prevention
```

Recover by reapplying the reviewed local overlay:

```bash
kubectl apply -k apps/web/overlays/local
kubectl -n platform-demo rollout status deployment/web
```

Never delete evidence before inspecting events, status and previous container logs.
