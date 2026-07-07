#!/usr/bin/env bash
set -euo pipefail

DEPLOY_DIR="${1:-/opt/eshopapi}"
PREVIOUS_DIR="${2:-/opt/eshopapi.previous}"
SERVICE_NAME="${3:-eshopapi}"

if [ ! -d "$PREVIOUS_DIR" ]; then
  echo "Geri alinacak surum yok: $PREVIOUS_DIR"
  exit 1
fi

pkill -f "dotnet ${DEPLOY_DIR}" || true
sleep 1
rm -rf "$DEPLOY_DIR"
cp -a "$PREVIOUS_DIR" "$DEPLOY_DIR"
systemctl restart "${SERVICE_NAME}"
echo "Onceki surume geri alindi: $PREVIOUS_DIR -> $DEPLOY_DIR"
