#!/usr/bin/env bash
# wbs.sh — Genera visualización WBS de avance contando items en PLAN.md
#
# Detecta automáticamente las fases del PLAN.md leyendo headers tipo
# "## F<N> ...". Cuenta los checkboxes `- [ ]` y `- [x]` dentro de cada
# sección. Compatible con headers que usen em-dash, guión o cualquier
# separador (pre-procesa em-dash → guión normal antes de awk).
#
# Uso:
#   bash scripts/wbs.sh                   # imprime a stdout
#   bash scripts/wbs.sh > status/wbs.md   # actualiza archivo
#
# Compatible con bash 3.2 (macOS default).

set -eo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
PLAN="$SCRIPT_DIR/PLAN.md"
WIDTH=40        # ancho de la barra de progreso total
PHASE_WIDTH=25  # ancho de la barra por fase

if [[ ! -f "$PLAN" ]]; then
  echo "Error: $PLAN no existe" >&2
  exit 1
fi

# Pre-proceso: reemplazar em-dash (U+2014) y en-dash (U+2013) por guión normal.
# Esto evita issues de UTF-8 multi-byte en awk de macOS.
PLAN_NORMALIZED=$(sed 's/—/-/g; s/–/-/g' "$PLAN")

# Detectar nombre del proyecto desde el H1 del PLAN.md
PROJECT_NAME=$(echo "$PLAN_NORMALIZED" | grep -m1 '^# ' | sed 's/^# PLAN - //' | sed 's/^# //')

# Función para generar barra de progreso
bar() {
  local done=$1
  local total=$2
  local width=$3
  local filled=0
  if [[ $total -gt 0 ]]; then
    filled=$((done * width / total))
  fi
  local empty=$((width - filled))
  local b=""
  local i
  for ((i=0; i<filled; i++)); do b+="▓"; done
  for ((i=0; i<empty; i++)); do b+="░"; done
  echo "$b"
}

# Detectar fases buscando headers "## F<N> ..." (ya normalizados).
# Excluye sub-headers como "## Items decididos", "## Update protocol".
PHASES=$(echo "$PLAN_NORMALIZED" | awk '
  /^## F[0-9]+([[:space:]]|$)/ {
    # Extraer "F<N>"
    match($0, /F[0-9]+/)
    id = substr($0, RSTART, RLENGTH)
    # Nombre = línea sin el prefix "## F<N> " y sin separador inicial
    name = $0
    sub(/^## F[0-9]+[[:space:]]*/, "", name)
    sub(/^[-][[:space:]]*/, "", name)
    # Cortar al primer paréntesis o final (para "Setup (cerrada)" → "Setup")
    sub(/[[:space:]]*\(.*$/, "", name)
    # Tomar primeras 14 chars
    if (length(name) > 14) name = substr(name, 1, 14)
    print id "|" name
  }
' | awk '!seen[$0]++')  # dedupe por si el header aparece más de una vez

# Conteo total acumulado
TOTAL_ITEMS=0
TOTAL_DONE=0
RESULTS=""

# Iterar por cada fase detectada
while IFS='|' read -r fase name; do
  [[ -z "$fase" ]] && continue

  # Extraer la sección de esta fase: desde su header hasta el próximo
  # header de nivel 2 (cualquier "## ...").
  section=$(echo "$PLAN_NORMALIZED" | awk -v fase="$fase" '
    BEGIN { in_section=0 }
    $0 ~ ("^## " fase "([[:space:]]|$)") { in_section=1; next }
    /^## / {
      if (in_section) exit
    }
    in_section { print }
  ')

  total=$(echo "$section" | grep -c '^[[:space:]]*- \[' || true)
  done=$(echo "$section" | grep -c '^[[:space:]]*- \[x\]' || true)
  total=${total:-0}
  done=${done:-0}

  RESULTS+="$fase|$name|$done|$total"$'\n'
  TOTAL_ITEMS=$((TOTAL_ITEMS + total))
  TOTAL_DONE=$((TOTAL_DONE + done))
done <<< "$PHASES"

# Calcular % global
total_pct=0
if [[ $TOTAL_ITEMS -gt 0 ]]; then
  total_pct=$((TOTAL_DONE * 100 / TOTAL_ITEMS))
fi

# Detectar fase actual (primera fase con items pero no completada)
current_fase=""
while IFS='|' read -r fase name done total; do
  [[ -z "$fase" ]] && continue
  if [[ $done -lt $total ]]; then
    current_fase=$fase
    break
  fi
done <<< "$RESULTS"

# Si todas las fases están completas, marcar la última
if [[ -z "$current_fase" ]]; then
  current_fase=$(echo "$RESULTS" | tail -1 | cut -d'|' -f1)
fi

DATE=$(date +%Y-%m-%d)
TIMESTAMP=$(date +"%Y-%m-%d %H:%M")

# Generar el output
cat <<HEADER
# WBS — $PROJECT_NAME Progress

**Última actualización:** $TIMESTAMP
**Generado por:** \`scripts/wbs.sh\`

> Este archivo se regenera con \`bash scripts/wbs.sh > status/wbs.md\` al
> inicio y final de cada fase. NO editar manualmente.

\`\`\`
╔════════════════════════════════════════════════════════════════════════════╗
║              $PROJECT_NAME — WBS PROGRESS — $DATE
╠════════════════════════════════════════════════════════════════════════════╣
║                                                                            ║
HEADER

# Barra global
global_bar=$(bar $TOTAL_DONE $TOTAL_ITEMS $WIDTH)
printf "║  Total: %s  %d/%d (%d%%)\n" "$global_bar" "$TOTAL_DONE" "$TOTAL_ITEMS" "$total_pct"
echo "║"
echo "║  Por fase:"
echo "║"

# Barras por fase
while IFS='|' read -r fase name done total; do
  [[ -z "$fase" ]] && continue
  pct=0
  if [[ $total -gt 0 ]]; then
    pct=$((done * 100 / total))
  fi
  fase_bar=$(bar $done $total $PHASE_WIDTH)
  marker="  "
  if [[ "$fase" == "$current_fase" ]]; then
    marker="▶ "
  fi
  printf "║ %s%-3s %-14s %s  %2d/%-3d (%3d%%)\n" "$marker" "$fase" "$name" "$fase_bar" "$done" "$total" "$pct"
done <<< "$RESULTS"

cat <<FOOTER
║
║  Fase actual: $current_fase  (marcada con ▶)
║
╚════════════════════════════════════════════════════════════════════════════╝
\`\`\`

## Detalle de la fase actual

Ver [\`../PLAN.md\`](../PLAN.md) sección $current_fase.

## Referencias

- Plan maestro: [\`../PLAN.md\`](../PLAN.md)
- Fase actual: [\`current-phase.md\`](current-phase.md)
- Progress log: [\`progress-log.md\`](progress-log.md)
FOOTER
