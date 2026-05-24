#!/bin/bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
BIN_DIR="${REPO_DIR}/bin"
SYSTEMD_UNIT="/etc/systemd/system/forgejo.service"

# Default version — update here and commit to upgrade
FORGEJO_VERSION="10.0.0"

# Source local overrides if present (gitignored, never committed)
if [[ -f "${REPO_DIR}/versions.env" ]]; then
  source "${REPO_DIR}/versions.env"
fi

FORGEJO_URL="https://codeberg.org/forgejo/forgejo/releases/download/v${FORGEJO_VERSION}/forgejo-${FORGEJO_VERSION}-linux-amd64"
FORGEJO_SHA256_URL="${FORGEJO_URL}.sha256"

echo "==> Downloading Forgejo ${FORGEJO_VERSION}"
curl -fLo "${BIN_DIR}/forgejo" "${FORGEJO_URL}"
curl -fLo "${BIN_DIR}/forgejo.sha256" "${FORGEJO_SHA256_URL}"

echo "==> Verifying checksum"
(cd "${BIN_DIR}" && sed "s/forgejo-${FORGEJO_VERSION}-linux-amd64/forgejo/" forgejo.sha256 | sha256sum -c)
rm "${BIN_DIR}/forgejo.sha256"

chmod +x "${BIN_DIR}/forgejo"
chown -R git:git "${REPO_DIR}"

echo "==> Installing systemd unit"
cp "${REPO_DIR}/systemd/forgejo.service" "${SYSTEMD_UNIT}"
systemctl daemon-reload

echo "==> Done. Configure etc/app.ini then: systemctl enable --now forgejo"
