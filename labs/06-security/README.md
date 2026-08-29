# Lab 06 — workload security

Render the local overlay and identify every security control:

```bash
kubectl kustomize apps/web/overlays/local
kubectl -n platform-demo auth can-i --list --as=system:serviceaccount:platform-demo:web
```

Attempt to add a privileged container or run as UID 0 in a temporary copy and observe restricted Pod Security admission behavior.

Explain why admission, runtime, RBAC, NetworkPolicy, image trust and secret management are separate controls. Restore the reviewed overlay after the experiment.
