# Lab 09 — GitOps design

## Scenario

Development, staging and production consume reviewed desired state. A controller reconciles approved commits; operators need drift visibility, safe promotion and rollback.

Design:

```text
Application source → build/test/scan/sign → immutable image digest
→ configuration pull request → policy and schema checks → review
→ environment branch/directory → GitOps reconciliation → health verification
```

Answer:

- Who can change application and environment repositories?
- How are images promoted without rebuilding?
- Where are secrets stored and decrypted?
- What happens when Git, registry, controller or admission policy is unavailable?
- How is manual drift detected and remediated?
- What constitutes rollback: Git revert, image rollback, data recovery, or all three?

GitOps is reconciliation from reviewed desired state—not simply `kubectl apply` in CI.
