# Lab 07 — operational observability

Build an evidence sequence from resource status, conditions, events and container logs:

```bash
kubectl -n platform-demo get deployment web -o yaml
kubectl -n platform-demo get events --sort-by=.metadata.creationTimestamp
kubectl -n platform-demo logs deployment/web --all-pods=true --tail=50
kubectl -n platform-demo get pods -o custom-columns=NAME:.metadata.name,READY:.status.containerStatuses[*].ready,RESTARTS:.status.containerStatuses[*].restartCount
```

Design RED metrics for the web service, USE metrics for nodes, distributed trace context, SLOs, and symptom-based alerts. The repository does not install an unreviewed monitoring bundle automatically.
