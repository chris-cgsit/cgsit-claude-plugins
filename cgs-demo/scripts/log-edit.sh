#!/usr/bin/env bash
#
# PostToolUse-Hook des cgs-demo-Plugins.
#
# Schreibt eine Zeile pro Datei-Aenderung in ein Log unterhalb von
# ${CLAUDE_PLUGIN_DATA}. Der Zweck ist rein didaktisch: im Kurs soll sichtbar
# werden, dass ein Plugin-Hook wirklich feuert.
#
# Bewusst "fail open": jeder unerwartete Zustand endet mit Exit 0. Ein Hook, der
# den Ablauf wegen seines eigenen Fehlers anhaelt, ist schlimmer als ein Hook,
# der eine Zeile verliert.
set -uo pipefail

ZIEL="${CLAUDE_PLUGIN_DATA:-}"
[ -z "$ZIEL" ] && exit 0
mkdir -p "$ZIEL" 2>/dev/null || exit 0

EINGABE="$(cat 2>/dev/null || true)"

# Ohne jq den Dateipfad grob herausziehen. Schlaegt das fehl, bleibt das Feld leer.
PFAD="$(printf '%s' "$EINGABE" \
        | tr ',' '\n' \
        | grep -m1 '"file_path"' \
        | sed 's/.*"file_path"[[:space:]]*:[[:space:]]*"//; s/".*//' 2>/dev/null || true)"

printf '%s  %s\n' "$(date -u '+%Y-%m-%dT%H:%M:%SZ')" "${PFAD:-unbekannt}" \
    >> "$ZIEL/edits.log" 2>/dev/null || true

exit 0
