# Lab 05 — persistent storage

## Objective

Understand claim binding and data behavior when a consuming Pod is replaced.

## Exercise

Create a disposable PVC using the default Kind StorageClass, mount it into a temporary Pod, write a marker, delete only the Pod, recreate it with the same claim, and verify the marker remains.

Before applying anything, inspect available storage:

```bash
kubectl get storageclass
kubectl get persistentvolume
kubectl get persistentvolumeclaim --all-namespaces
```

## Scenario questions

- What does the reclaim policy do after claim deletion?
- Does a retained volume equal a tested backup?
- How does topology affect volume scheduling?
- What RPO/RTO would the application require?

Delete the temporary Pod and claim after the exercise. Do not reuse production data or storage credentials.
