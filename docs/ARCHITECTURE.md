# Architecture

## Local learning platform

```mermaid
flowchart TB
  Operator[Operator] --> Kubeconfig[kubeconfig context guard]
  Kubeconfig --> API[Kind control-plane API]

  subgraph Workers[Two Kind workers]
    Service[ClusterIP service] --> A[Web pod A]
    Service --> B[Web pod B]
    Deployment[Deployment] --> RS[ReplicaSet]
    RS --> A
    RS --> B
    ConfigMap[ConfigMap] --> A
    ConfigMap --> B
    PDB[PodDisruptionBudget] -. voluntary disruption .-> A
    PDB -. voluntary disruption .-> B
    NetworkPolicy[Default deny + HTTP allow] -. traffic policy .-> A
    NetworkPolicy -. traffic policy .-> B
  end
```

## Reconciliation flow

```mermaid
sequenceDiagram
  actor Engineer
  participant Git
  participant API as API server
  participant D as Deployment controller
  participant S as Scheduler
  participant K as Kubelet

  Engineer->>Git: Review desired manifest
  Engineer->>API: Apply rendered overlay
  API-->>D: Desired Deployment changes
  D->>API: Reconcile ReplicaSet and Pods
  S->>API: Bind unscheduled Pods to nodes
  K->>API: Report container and probe status
  D->>API: Continue until desired availability is reached
```

Kubernetes controllers continuously compare desired and observed state. A successful API response means the desired object was accepted; it does not mean the application is healthy.

## Configuration model

The base holds reusable security and application intent. Overlays adjust environment policy:

```text
apps/web/base
  ├── namespace and Pod Security labels
  ├── service account
  ├── configuration
  ├── deployment
  ├── service
  ├── disruption budget
  └── network policies
        │
        ├── overlays/local: two replicas
        └── overlays/production-example: three replicas, minAvailable two
```

The production example deliberately remains incomplete because DNS, certificates, ingress, identity, storage, observability, and policy depend on the target platform and organization.

## Availability boundaries

| Mechanism | Protects against | Does not protect against |
|---|---|---|
| Two or three replicas | One container/Pod loss | Shared application dependency failure |
| Topology spread | Concentrating replicas on one hostname | Regional or control-plane failure |
| Readiness probe | Sending traffic to an unready container | Incorrect business results |
| Liveness probe | Some stuck-process conditions | External dependency failure without careful design |
| Disruption budget | Excess voluntary eviction | Node crash or hard infrastructure failure |
| Rolling update | Planned version replacement | An invalid new version without rollback criteria |

## Production EKS reference

```mermaid
flowchart TB
  Users((Users)) --> Edge[DNS + CDN/WAF + TLS]
  Edge --> LB[Managed load balancer]

  subgraph Region[AWS Region]
    subgraph EKS[Managed EKS control plane]
      API[Private/public-controlled API endpoint]
    end
    subgraph AZA[Availability Zone A]
      NodeA[Managed node / autoscaled capacity]
      PodA[Workload replica]
    end
    subgraph AZB[Availability Zone B]
      NodeB[Managed node / autoscaled capacity]
      PodB[Workload replica]
    end
    LB --> PodA
    LB --> PodB
    PodA --> Data[(Managed data services)]
    PodB --> Data
    API --> NodeA
    API --> NodeB
  end

  GitOps[GitOps controller] --> API
  Identity[Short-lived workload identity] --> PodA
  Identity --> PodB
  Telemetry[Metrics + logs + traces] --> Operations[SLOs + alerts + incidents]
```

This diagram is a review checklist, not a deployable promise.
