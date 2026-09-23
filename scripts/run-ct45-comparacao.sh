#!/usr/bin/env bash
# CT45 — mesmo cenario "modelo sem formulario com IA" nos dois builds,
# gerando as evidencias lado a lado.
#
# Rodar com o build 262 instalado no device, depois trocar para o 263
# e rodar de novo. O script avisa qual build espera.
set -euo pipefail

BUILD="${1:?uso: ./scripts/run-ct45-comparacao.sh <262|263>}"
ENV_FILE="config/env.${BUILD}"

case "$BUILD" in
  262) ESPERADO_VAR="TXT_TITULO_TIRADOR" ;;
  263) ESPERADO_VAR="TXT_TITULO_FORM_PADRAO" ;;
  *) echo "ERRO: build precisa ser 262 ou 263" >&2; exit 1 ;;
esac

ESPERADO=$(grep "^${ESPERADO_VAR}=" "$ENV_FILE" | cut -d= -f2-)

echo "=== CT45 | build ${BUILD} | esperado: ${ESPERADO} ==="
echo "Confirme que o APK/IPA instalado no device e o 10.5.0 (${BUILD})."

ENV_ARGS=()
while IFS='=' read -r key value; do
  [[ -z "$key" || "$key" == \#* ]] && continue
  ENV_ARGS+=( -e "${key}=${value}" )
done < <(grep -v '^[[:space:]]*#' "$ENV_FILE" | grep '=')

maestro test flows/tir/CT45_comparacao_262_vs_263.yaml \
  "${ENV_ARGS[@]}" \
  -e "TXT_ESPERADO=${ESPERADO}"
