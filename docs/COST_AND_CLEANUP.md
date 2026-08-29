# Cost and cleanup

## Local path

Static checks cost nothing. Kind uses local CPU, memory, disk, Docker networks, containers, and cached images.

Cleanup:

```bash
./scripts/destroy-kind-cluster.sh
```

The script deletes only the fixed cluster `k8s-zero-to-production`. Docker may retain downloaded images; inspect them before performing any broader cleanup.

## Production and EKS cost drivers

This repository does not create EKS resources. When evaluating a future design, estimate current regional pricing for:

- Managed control plane
- EC2, Fargate, or autoscaled compute
- Load balancers and processed traffic
- NAT gateways and cross-AZ data transfer
- EBS/EFS storage, snapshots and provisioned performance
- Container registry storage and transfer
- Logs, metrics, traces, dashboards and retention
- Security, policy and scanning services
- Backup, disaster recovery and standby capacity
- Public IPv4 addresses and DNS

## Cost controls

- Tag and label ownership, environment and cost center.
- Right-size requests using measured utilization rather than guesses.
- Use autoscaling with tested minimum, maximum and disruption constraints.
- Review namespace and workload cost allocation.
- Control log cardinality and retention.
- Remove abandoned load balancers, volumes, snapshots and public IPs.
- Evaluate Spot only with interruption-tolerant workload design.
- Treat multi-AZ and disaster-recovery capacity as explicit reliability investments.

Never create an EKS cluster only to complete the local learning path.
