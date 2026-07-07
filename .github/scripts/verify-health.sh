#!/usr/bin/env bash
set -euo pipefail

BASE_URL="${1:-http://127.0.0.1:5200}"
MAX_ATTEMPTS="${2:-12}"
SLEEP_SECONDS="${3:-5}"

BASE_URL="${BASE_URL%/health}"
BASE_URL="${BASE_URL%/}"

check_service_up() {
  local response
  response=$(curl -fsS --max-time 10 "${BASE_URL}/health" 2>/dev/null || true)
  if echo "$response" | grep -q '"status":"ok"'; then
    echo "Kontrol: /health OK"
    return 0
  fi

  local status
  status=$(curl -s -o /dev/null -w "%{http_code}" --max-time 10 "${BASE_URL}/swagger/index.html" 2>/dev/null || echo "000")
  if [ "$status" = "200" ]; then
    echo "Kontrol: swagger 200"
    return 0
  fi

  status=$(curl -s -o /dev/null -w "%{http_code}" --max-time 10 "${BASE_URL}/" 2>/dev/null || echo "000")
  if [ "$status" = "200" ]; then
    echo "Kontrol: ana sayfa 200"
    return 0
  fi

  return 1
}

for attempt in $(seq 1 "$MAX_ATTEMPTS"); do
  if check_service_up; then
    echo "Health check basarili (deneme $attempt/$MAX_ATTEMPTS)"
    exit 0
  fi
  echo "Health check basarisiz (deneme $attempt/$MAX_ATTEMPTS), ${SLEEP_SECONDS}s bekleniyor..."
  sleep "$SLEEP_SECONDS"
done

echo "Health check $MAX_ATTEMPTS denemeden sonra basarisiz: ${BASE_URL}"
exit 1
