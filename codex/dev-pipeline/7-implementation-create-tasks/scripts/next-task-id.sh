#!/bin/sh
# next-task-id.sh - calcula o próximo ID hierárquico dentro de uma fase ou tarefa em um arquivo tasks.md.
#
# Uso:
#   scripts/next-task-id.sh FASE tasks.md      # próxima tarefa na fase, ex.: 1.3
#   scripts/next-task-id.sh TAREFA tasks.md    # próxima subtarefa na tarefa, ex.: 1.2.4
#
# Se o prefixo não existe, retorna {prefix}.1.

set -eu

if [ $# -lt 2 ]; then
  cat <<'USAGE' >&2
Uso: next-task-id.sh PREFIX tasks.md

Exemplos:
  next-task-id.sh 1 tasks.md
  next-task-id.sh 1.2 tasks.md
  next-task-id.sh 3.5 tasks.md
USAGE
  exit 2
fi

PREFIX="$1"
FILE="$2"

if [ ! -f "$FILE" ]; then
  printf 'Arquivo não encontrado: %s\n' "$FILE" >&2
  exit 1
fi

ESC_PREFIX=$(printf '%s' "$PREFIX" | sed 's/\./\\./g')

MAX=$(grep -oE "(^### |\- \[[ x~!]\] )${ESC_PREFIX}\.[0-9]+" "$FILE" 2>/dev/null \
  | sed -E "s/^(### |- \[[ x~!]\] )//" \
  | sed -E "s/^${ESC_PREFIX}\.//" \
  | sort -n \
  | tail -n 1 || printf '0')

MAX=${MAX:-0}
NEXT=$((MAX + 1))

printf '%s.%d\n' "$PREFIX" "$NEXT"
