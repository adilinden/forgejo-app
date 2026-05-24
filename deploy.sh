#!/bin/bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
BIN_DIR="${REPO_DIR}/bin"
SYSTEMD_UNIT="/etc/systemd/system/forgejo.service"

# Default version — update here and commit to upgrade
FORGEJO_VERSION="15.0.2"

# Source local overrides if present (gitignored, never committed)
if [[ -f "${REPO_DIR}/versions.env" ]]; then
  source "${REPO_DIR}/versions.env"
fi

FORGEJO_ASSET="forgejo-${FORGEJO_VERSION}-linux-amd64"
FORGEJO_URL="https://codeberg.org/forgejo/forgejo/releases/download/v${FORGEJO_VERSION}/${FORGEJO_ASSET}"
FORGEJO_SHA256_URL="${FORGEJO_URL}.sha256"

echo "==> Downloading Forgejo ${FORGEJO_VERSION}"
curl -fL --http1.1 --retry 3 --retry-delay 5 -o "${BIN_DIR}/forgejo.new" "${FORGEJO_URL}"
curl -fL --http1.1 -o "${BIN_DIR}/forgejo.new.sha256" "${FORGEJO_SHA256_URL}"

echo "==> Verifying checksum"
(cd "${BIN_DIR}" && sed "s/${FORGEJO_ASSET}/forgejo.new/" forgejo.new.sha256 | sha256sum -c)
rm "${BIN_DIR}/forgejo.new.sha256"

echo "==> Replacing binary"
mv "${BIN_DIR}/forgejo.new" "${BIN_DIR}/forgejo"
chown root:root "${BIN_DIR}/forgejo"
chmod 755 "${BIN_DIR}/forgejo"

echo "==> Installing systemd unit"
cp "${REPO_DIR}/systemd/forgejo.service" "${SYSTEMD_UNIT}"
systemctl daemon-reload

echo "==> Done. Configure etc/app.ini then: systemctl enable --now forgejo"
