#!/usr/bin/env bash
set -euo pipefail

if [ "$(id -u)" -ne 0 ]; then
  echo "Root ile calistir: sudo bash deploy/scripts/setup-wsl.sh"
  exit 1
fi

echo "Docker kuruluyor..."
apt-get update -qq
apt-get install -y docker.io docker-compose-v2
systemctl enable --now docker

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
bash "${SCRIPT_DIR}/ensure-sql.sh"

cat > /etc/systemd/system/eshopapi.service <<'EOF'
[Unit]
Description=eShop PublicApi .NET Service
After=network.target docker.service

[Service]
WorkingDirectory=/opt/eshopapi
ExecStart=/usr/share/dotnet/dotnet /opt/eshopapi/PublicApi.dll --urls http://0.0.0.0:5200
Restart=always
RestartSec=5
Environment=ASPNETCORE_ENVIRONMENT=Production
Environment=DOTNET_USE_POLLING_FILE_WATCHER=1
Environment=hostBuilder__reloadConfigOnChange=false

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable eshopapi

cat > /etc/systemd/system/eshopweb.service <<'EOF'
[Unit]
Description=eShop Web Storefront .NET Service
After=network.target docker.service eshopapi.service

[Service]
WorkingDirectory=/opt/eshopweb
ExecStart=/usr/share/dotnet/dotnet /opt/eshopweb/Web.dll --urls http://0.0.0.0:5001
Restart=always
RestartSec=5
Environment=ASPNETCORE_ENVIRONMENT=Production
Environment=DOTNET_USE_POLLING_FILE_WATCHER=1
Environment=hostBuilder__reloadConfigOnChange=false

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable eshopweb
echo "Kurulum tamam. Ilk deploy sonrasi: systemctl start eshopapi eshopweb"
echo "Magaza: http://WSL-IP:5001"
echo "API: http://WSL-IP:5200/swagger"
echo "Health API: http://WSL-IP:5200/health"
