# Security policy

## Private reporting

Use GitHub private vulnerability reporting for security defects in scripts, workflows, manifests, or Pages content. Do not include credentials, kubeconfig data, tokens, account identifiers, private endpoints, or exploit details in a public issue.

## Scope

Security fixes target the latest `main` on a best-effort basis. This repository is a learning reference and does not provide production support or guarantee suitability for an organization's threat model.

## Safe execution

Cluster mutation scripts are restricted to the fixed Kind context and cluster name. Review manifests and commands before running them. Never point learning failure-injection commands at a shared, corporate, or production cluster.
