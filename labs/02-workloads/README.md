# Lab 02 — workloads and reconciliation

Apply the local overlay, observe Deployment → ReplicaSet → Pod ownership, scale replicas, and perform a rolling image/configuration change.

```bash
kubectl apply -k apps/web/overlays/local
kubectl -n platform-demo get deployment,replicaset,pods -o wide
kubectl -n platform-demo get pod <pod> -o jsonpath='{.metadata.ownerReferences}'
kubectl -n platform-demo rollout history deployment/web
```

Failure exercise: delete one Pod and watch the ReplicaSet replace it. Explain why deleting the Pod treats a symptom rather than changing desired state.
