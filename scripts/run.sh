#!/usr/bin/env bash
# Executa a suite Maestro para um build especifico.
#
#   ./scripts/run.sh 263            -> tudo da 263
#   ./scripts/run.sh 262            -> tudo da 262
#   ./scripts/run.sh 263 P0         -> so os P0 da 263
#   ./scripts/run.sh 262 TIR        -> so o grupo TIR na 262
#
set -euo pipefail

BUILD="${1:-263}"
TAG_EXTRA="${2:-}"
ENV_FILE="config/env.${BUILD}"

if [[ ! -f "$ENV_FILE" ]]; then
  echo "ERRO: $ENV_FILE nao existe. Builds validos: 262, 263, 265" >&2
  exit 1
fi

if grep -q '<<' "$ENV_FILE"; then
  echo "ERRO: $ENV_FILE ainda tem placeholders <<...>> nao preenchidos:" >&2
  grep -n '<<' "$ENV_FILE" >&2
  echo "Preencha antes de executar. Ver docs/SELETORES.md" >&2
  exit 1
fi

CRED_FILE="config/credenciais.local"
if [[ ! -f "$CRED_FILE" ]] || grep -q '<<' "$CRED_FILE"; then
  echo "ERRO: $CRED_FILE nao existe ou nao foi preenchido." >&2
  echo "Copie config/credenciais.local.example e preencha usuario e senha." >&2
  exit 1
fi

# monta os -e a partir do arquivo de env e das credenciais
ENV_ARGS=()
while IFS='=' read -r key value; do
  [[ -z "$key" || "$key" == \#* ]] && continue
  ENV_ARGS+=( -e "${key}=${value}" )
done < <(cat "$ENV_FILE" "$CRED_FILE" | grep -v '^[[:space:]]*#' | grep '=')

TAGS="build${BUILD}"
[[ -n "$TAG_EXTRA" ]] && TAGS="${TAGS},${TAG_EXTRA}"

echo "=== Maestro | build ${BUILD} | tags: ${TAGS} ==="
# --no-reinstall-driver: reinstalar o driver a cada execucao falha no
# emulador x86_64 16 KB ("Broken pipe" / "Can't find service: package")
maestro test flows \
  --no-reinstall-driver \
  --include-tags "$TAGS" \
  --exclude-tags subflow \
  --format junit \
  --output "resultados/build${BUILD}-junit.xml" \
  "${ENV_ARGS[@]}"
