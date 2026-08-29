# Lab 10 — production EKS architecture review

This is an architecture exercise. It creates no AWS resources.

## Requirements

Design a customer-facing service requiring multi-AZ availability, private workers, controlled public ingress, workload identity, encrypted data, observability, safe releases, disaster recovery and cost allocation.

## Deliverables

- Context and deployment diagrams
- Account, VPC, subnet and cluster boundaries
- Control-plane endpoint policy
- Worker/capacity and autoscaling strategy
- Ingress, DNS, TLS and WAF flow
- Workload identity and secret-management flow
- Storage, backup and restore design
- GitOps and software-supply-chain controls
- SLI/SLO, telemetry and incident-routing plan
- Upgrade, rollback and regional-recovery runbooks
- Cost model and cleanup ownership

## Failure scenarios

Review impact and recovery for:

- One Pod and one worker failure
- One Availability Zone unavailable
- Registry or GitOps controller unavailable
- Admission webhook unavailable
- AWS API throttling
- Secret backend unavailable
- Database latency or regional failure
- Compromised deployment identity

## Decision record

For each choice document:

```text
Requirement → Options → Decision → Trade-off → Failure mode
→ Verification → Cost → Revisit trigger
```
