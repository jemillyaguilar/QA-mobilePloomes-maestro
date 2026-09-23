#!/usr/bin/env bash
# CT21 — paridade iOS x Android. Nao e um flow: e a MESMA suite da 263
# executada nos dois devices, com o SO/versao registrado na evidencia.
set -euo pipefail

echo "=== CT21 | paridade iOS x Android ==="
echo "Devices conectados:"
maestro devices || true
echo
echo "Rode uma vez por device, com o device selecionado:"
echo "  maestro --device <ID_ANDROID> test flows --include-tags build263 --exclude-tags subflow"
echo "  maestro --device <ID_IOS>     test flows --include-tags build263,-android --exclude-tags subflow"
echo
echo "Registrar na evidencia: plataforma, versao de SO e modelo do device."
