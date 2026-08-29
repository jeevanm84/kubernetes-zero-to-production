#!/usr/bin/env python3
"""Validate rendered Kubernetes policy, documentation links, and identity rules."""

from pathlib import Path
import re
import sys


ROOT = Path(__file__).resolve().parents[1]
ERRORS: list[str] = []


def require(content: str, pattern: str, message: str) -> None:
    if not re.search(pattern, content, flags=re.MULTILINE):
        ERRORS.append(message)


if len(sys.argv) != 3:
    raise SystemExit("Usage: check.py LOCAL_RENDERED_YAML PRODUCTION_RENDERED_YAML")

local_rendered = Path(sys.argv[1]).read_text(encoding="utf-8")
production_rendered = Path(sys.argv[2]).read_text(encoding="utf-8")

for name, rendered in (("local", local_rendered), ("production", production_rendered)):
    require(rendered, r"^kind: Deployment$", f"{name}: Deployment missing")
    require(rendered, r"^kind: Service$", f"{name}: Service missing")
    require(rendered, r"^kind: NetworkPolicy$", f"{name}: NetworkPolicy missing")
    require(rendered, r"^kind: PodDisruptionBudget$", f"{name}: PodDisruptionBudget missing")
    require(rendered, r"runAsNonRoot: true", f"{name}: runAsNonRoot missing")
    require(rendered, r"allowPrivilegeEscalation: false", f"{name}: privilege escalation not disabled")
    require(rendered, r"readOnlyRootFilesystem: true", f"{name}: root filesystem not read-only")
    require(rendered, r"type: RuntimeDefault", f"{name}: RuntimeDefault seccomp missing")
    require(rendered, r"automountServiceAccountToken: false", f"{name}: service-account token automount not disabled")
    require(rendered, r"requests:\n\s+cpu:", f"{name}: CPU request missing")
    require(rendered, r"limits:\n\s+cpu:", f"{name}: CPU limit missing")
    require(rendered, r"startupProbe:", f"{name}: startup probe missing")
    require(rendered, r"readinessProbe:", f"{name}: readiness probe missing")
    require(rendered, r"livenessProbe:", f"{name}: liveness probe missing")
    if re.search(r"image:\s+[^\n]+:(latest|edge)(?:\s|$)", rendered):
        ERRORS.append(f"{name}: mutable image tag is forbidden")

require(local_rendered, r"replicas: 2", "local: expected two replicas")
require(production_rendered, r"replicas: 3", "production: expected three replicas")
require(production_rendered, r"minAvailable: 2", "production: expected disruption budget minAvailable 2")

markdown_files = sorted(path for path in ROOT.rglob("*.md") if ".git" not in path.parts)
for path in markdown_files:
    content = path.read_text(encoding="utf-8")
    relative = path.relative_to(ROOT)
    if content.count("```") % 2:
        ERRORS.append(f"{relative}: unmatched fenced code block")
    for target in re.findall(r"\[[^]]+\]\(([^)]+)\)", content):
        if target.startswith(("https://", "http://", "#", "mailto:")):
            continue
        clean_target = target.split("#", 1)[0]
        if clean_target and not (path.parent / clean_target).resolve().exists():
            ERRORS.append(f"{relative}: missing local link target {target}")

scannable = [
    path
    for path in ROOT.rglob("*")
    if path.is_file() and ".git" not in path.parts and ".tools" not in path.parts
]
all_text = "\n".join(
    path.read_text(encoding="utf-8", errors="ignore") for path in scannable
).lower()
for forbidden in ("mamu" + "duri", "jeevanm.aws" + "@gmail.com", "akia" + "iosf"):
    if forbidden in all_text:
        ERRORS.append("Repository contains a prohibited identity or credential pattern")

if ERRORS:
    print("Kubernetes repository validation failed:", file=sys.stderr)
    for error in ERRORS:
        print(f"- {error}", file=sys.stderr)
    raise SystemExit(1)

print(f"Policy and documentation validation passed for {len(markdown_files)} Markdown files.")
