# Lab 03 — networking and service discovery

Trace selectors, EndpointSlices, ports and DNS:

```bash
kubectl -n platform-demo get service web -o yaml
kubectl -n platform-demo get endpointslice -l kubernetes.io/service-name=web
kubectl -n platform-demo port-forward service/web 8080:80
```

Scenario: change the Service selector to a nonexistent label, observe empty endpoints, diagnose from Service and Pod labels, then restore the declarative overlay.

Discuss ClusterIP, NodePort, LoadBalancer, Ingress and Gateway API without assuming they provide the same cloud behavior in Kind.
