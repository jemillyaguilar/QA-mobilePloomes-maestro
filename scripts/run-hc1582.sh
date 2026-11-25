#!/usr/bin/env bash
# Roda um cenario da HC-1582 (build 284). O app ja deve estar logado
# (login manual): os flows nao limpam o estado e nao usam credenciais.
#
#   ./scripts/run-hc1582.sh CEN005
#
set -euo pipefail
CEN="${1:?informe o cenario, ex.: CEN005}"
FLOW=$(ls flows/hc1582/${CEN}_*.yaml)
ENV_ARGS=()
while IFS='=' read -r key value; do
  [[ -z "$key" || "$key" == \#* || "$value" == "<<"* ]] && continue
  ENV_ARGS+=( -e "${key}=${value}" )
done < <(grep -v '^[[:space:]]*#' config/env.284 | grep '=')
mkdir -p resultados/hc1582
MAESTRO="${MAESTRO:-maestro}"
"$MAESTRO" test "$FLOW" --no-reinstall-driver \
  --format junit --output "resultados/hc1582/${CEN}-junit.xml" \
  --test-output-dir "resultados/hc1582/${CEN}" "${ENV_ARGS[@]}"
