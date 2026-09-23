#!/usr/bin/env bash
# Fallback: se a versao do Maestro instalada NAO interpolar ${APP_ID} no
# campo appId do header, este script fixa o appId literal em todos os flows.
set -euo pipefail
APP_ID="${1:?uso: ./scripts/set-app-id.sh com.exemplo.app}"
find flows subflows -name '*.yaml' -print0 \
  | xargs -0 sed -i "s|^appId: .*|appId: ${APP_ID}|"
echo "appId fixado em $(find flows subflows -name '*.yaml' | wc -l) arquivos: ${APP_ID}"
