#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck disable=SC1091
source "${repo_root}/scripts/versions.env"

case "$(uname -s)" in
  Darwin) os="darwin" ;;
  Linux) os="linux" ;;
  *) echo "Unsupported operating system: $(uname -s)" >&2; exit 1 ;;
esac

case "$(uname -m)" in
  x86_64|amd64) architecture="amd64" ;;
  arm64|aarch64) architecture="arm64" ;;
  *) echo "Unsupported architecture: $(uname -m)" >&2; exit 1 ;;
esac

tool_dir="${repo_root}/.tools/bin"
temporary_dir="$(mktemp -d "${TMPDIR:-/tmp}/kind-install.XXXXXX")"
cleanup() { rm -rf -- "${temporary_dir}"; }
trap cleanup EXIT

binary_url="https://github.com/kubernetes-sigs/kind/releases/download/${KIND_VERSION}/kind-${os}-${architecture}"
checksum_url="${binary_url}.sha256sum"

curl --fail --silent --show-error --location "${binary_url}" --output "${temporary_dir}/kind"
curl --fail --silent --show-error --location "${checksum_url}" --output "${temporary_dir}/kind.sha256sum"

expected="$(awk '{ print $1 }' "${temporary_dir}/kind.sha256sum")"
actual="$(shasum -a 256 "${temporary_dir}/kind" | awk '{ print $1 }')"
if [[ "${actual}" != "${expected}" ]]; then
  echo "Kind checksum verification failed." >&2
  exit 1
fi

mkdir -p "${tool_dir}"
install -m 0755 "${temporary_dir}/kind" "${tool_dir}/kind"
echo "Installed Kind ${KIND_VERSION} at ${tool_dir}/kind"
