#!/usr/bin/env bash
set -euo pipefail

bash "$(dirname "$0")/rollback-to-previous.sh" /opt/eshopapi /opt/eshopapi.previous eshopapi
bash "$(dirname "$0")/rollback-to-previous.sh" /opt/eshopweb /opt/eshopweb.previous eshopweb
