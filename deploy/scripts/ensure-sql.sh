#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SQL_DIR="${SCRIPT_DIR}/../sql"

if ! command -v docker >/dev/null 2>&1; then
  echo "Docker bulunamadi. Bir kez calistir: sudo bash deploy/scripts/setup-wsl.sh"
  exit 1
fi

if docker ps --format '{{.Names}}' | grep -qx 'eshop-sql'; then
  echo "SQL Server (eshop-sql) zaten calisiyor"
else
  echo "SQL Server baslatiliyor..."
  docker compose -f "${SQL_DIR}/docker-compose.yml" up -d
fi

for attempt in $(seq 1 30); do
  if bash -c 'echo > /dev/tcp/127.0.0.1/1433' 2>/dev/null; then
    echo "SQL Server port 1433 hazir (deneme $attempt)"
    exit 0
  fi
  echo "SQL Server bekleniyor (deneme $attempt/30)..."
  sleep 2
done

echo "SQL Server 60 saniye icinde hazir olmadi"
exit 1
