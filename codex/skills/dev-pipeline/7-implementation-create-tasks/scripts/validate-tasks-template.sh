#!/bin/sh
# validate-tasks-template.sh - gate determinístico de fidelidade ao template da skill create-tasks.
#
# Uso:
#   validate-tasks-template.sh FILE [--phase-prefix PREFIX] [--config CONFIG_JSON]
#
# Saída:
#   FINDING|<severity>|<code>|<mensagem>
#   RESULT|<file>|critical=<N>|warning=<M>
#
# Exit: 0 conformante; 1 drift; 2 uso incorreto ou arquivo inexistente.

set -eu

FILE=""
PREFIX_OVERRIDE=""
CONFIG=""

usage() {
  cat <<'USAGE' >&2
Uso: validate-tasks-template.sh FILE [--phase-prefix PREFIX] [--config CONFIG_JSON]

Valida se FILE, um tasks.md, está conforme ao template canônico da skill.
Emite linhas FINDING|severity|code|msg e um RESULT final.
Exit: 0 conformante; 1 drift; 2 uso/arquivo.
USAGE
}

while [ $# -gt 0 ]; do
  case "$1" in
    --phase-prefix)
      [ $# -ge 2 ] || { usage; exit 2; }
      PREFIX_OVERRIDE="$2"; shift 2 ;;
    --phase-prefix=*)
      PREFIX_OVERRIDE="${1#--phase-prefix=}"; shift ;;
    --config)
      [ $# -ge 2 ] || { usage; exit 2; }
      CONFIG="$2"; shift 2 ;;
    --config=*)
      CONFIG="${1#--config=}"; shift ;;
    -h|--help)
      usage; exit 2 ;;
    --*)
      printf 'Opção desconhecida: %s\n' "$1" >&2; usage; exit 2 ;;
    *)
      if [ -z "$FILE" ]; then
        FILE="$1"; shift
      else
        printf 'Argumento extra: %s\n' "$1" >&2; usage; exit 2
      fi ;;
  esac
done

if [ -z "$FILE" ]; then
  usage; exit 2
fi
if [ ! -f "$FILE" ]; then
  printf 'Arquivo não encontrado: %s\n' "$FILE" >&2
  exit 2
fi

PREFIX="FASE"
if [ -n "$PREFIX_OVERRIDE" ]; then
  PREFIX="$PREFIX_OVERRIDE"
elif [ -n "$CONFIG" ] && [ -f "$CONFIG" ]; then
  _pp=$(grep -oE '"phase_prefix"[[:space:]]*:[[:space:]]*"[^"]*"' "$CONFIG" 2>/dev/null \
    | sed -E 's/.*"phase_prefix"[[:space:]]*:[[:space:]]*"([^"]*)".*/\1/' \
    | head -n 1 || printf '')
  [ -n "$_pp" ] && PREFIX="$_pp"
fi

ESC_PREFIX=$(printf '%s' "$PREFIX" | sed 's/[].[^$*\\/]/\\&/g')

CRIT=0
WARN=0

emit() {
  printf 'FINDING|%s|%s|%s\n' "$1" "$2" "$3"
  if [ "$1" = "critical" ]; then
    CRIT=$((CRIT + 1))
  else
    WARN=$((WARN + 1))
  fi
}

count() {
  _c=$(grep -cE "$1" "$FILE" 2>/dev/null) || _c=0
  printf '%s' "$_c"
}

if [ "$(count "^##[[:space:]]+${ESC_PREFIX}[[:space:]]")" -eq 0 ]; then
  emit critical no-phase "Nenhum heading de fase '## ${PREFIX} <N>' encontrado"
fi

if [ "$(count '^- \[[ x~!]\]')" -eq 0 ]; then
  emit critical no-checkbox "Nenhuma subtarefa em formato checkbox '- [ ]' encontrada"
fi

if [ "$(count '^###[[:space:]].*`\[[A-Z]+\]`')" -eq 0 ]; then
  emit critical no-criticality "Nenhuma tarefa com tag de criticidade '\`[C|A|M]\`' encontrada"
fi

has() {
  grep -qiE "$1" "$FILE" 2>/dev/null
}

has 'Legenda de status'      || emit warning no-status-legend     "Bloco 'Legenda de status' ausente"
has 'Legenda de criticidade' || emit warning no-crit-legend       "Bloco 'Legenda de criticidade' ausente"
has 'Matriz de Depend'       || emit warning no-dependency-matrix  "Seção 'Matriz de Dependências' ausente"
has 'Resumo Quantitativo'    || emit warning no-summary            "Seção 'Resumo Quantitativo' ausente"
has 'Escopo Coberto'         || emit warning no-scope-covered      "Seção 'Escopo Coberto' ausente"
has 'Escopo Exclu'           || emit warning no-scope-excluded     "Seção 'Escopo Excluído' ausente"

printf 'RESULT|%s|critical=%d|warning=%d\n' "$FILE" "$CRIT" "$WARN"

if [ "$CRIT" -gt 0 ] || [ "$WARN" -gt 0 ]; then
  exit 1
fi
exit 0
