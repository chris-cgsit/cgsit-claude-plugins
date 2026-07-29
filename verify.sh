#!/usr/bin/env bash
#
# Statische Pruefung von Marketplace und Plugin. Laeuft ohne Netz.
#
# Was hier NICHT geprueft wird: die Installation selbst. `/plugin marketplace add`
# und `/plugin install` sind interaktive Claude-Code-Befehle -- die Anleitung dazu
# steht in README.md und muss von einem Menschen ausgefuehrt werden.
#
set -uo pipefail
cd "$(dirname "$0")"

P=cgs-demo
fehl=0
ok()   { printf 'OK    %s\n' "$1"; }
nok()  { printf 'FEHL  %s\n' "$1"; fehl=1; }

echo "=== 1. JSON parst ==="
for f in .claude-plugin/marketplace.json \
         $P/.claude-plugin/plugin.json \
         $P/hooks/hooks.json \
         $P/.mcp.json; do
    if python3 -m json.tool "$f" >/dev/null 2>&1; then ok "$f"; else nok "$f parst nicht"; fi
done

echo
echo "=== 2. Pflichtfelder ==="
python3 - <<'PY'
import json
import sys

fehl = 0

m = json.load(open(".claude-plugin/marketplace.json"))
for feld in ("name", "owner", "plugins"):
    if feld in m:
        print(f"OK    marketplace.json: {feld} vorhanden")
    else:
        print(f"FEHL  marketplace.json: {feld} fehlt (Pflichtfeld)")
        fehl = 1
if "name" not in m.get("owner", {}):
    print("FEHL  marketplace.json: owner.name fehlt (Pflichtfeld)")
    fehl = 1

for e in m.get("plugins", []):
    for feld in ("name", "source"):
        if feld not in e:
            print(f"FEHL  plugins[]: {feld} fehlt")
            fehl = 1
    src = e.get("source", "")
    if isinstance(src, str):
        if not src.startswith("./"):
            print(f"FEHL  plugins[].source '{src}' muss mit ./ beginnen")
            fehl = 1
        else:
            import os
            if os.path.isdir(src.lstrip("./")):
                print(f"OK    plugins[].source {src} existiert")
            else:
                print(f"FEHL  plugins[].source {src} existiert nicht")
                fehl = 1

p = json.load(open("cgs-demo/.claude-plugin/plugin.json"))
if "name" in p:
    print("OK    plugin.json: name vorhanden (einziges Pflichtfeld)")
else:
    print("FEHL  plugin.json: name fehlt")
    fehl = 1
if not isinstance(p.get("keywords", []), list):
    print("FEHL  plugin.json: keywords muss ein Array sein -- falscher Typ ist ein Ladefehler")
    fehl = 1

sys.exit(fehl)
PY
[ $? -ne 0 ] && fehl=1

echo
echo "=== 3. Nur plugin.json liegt in .claude-plugin ==="
# Harte Regel der Doku: alle uebrigen Komponentenverzeichnisse liegen im Plugin-Root.
extra=$(find $P/.claude-plugin -type f ! -name plugin.json | wc -l)
[ "$extra" -eq 0 ] && ok "$P/.claude-plugin enthaelt nur plugin.json" \
                   || nok "$P/.claude-plugin enthaelt $extra weitere Datei(en)"

echo
echo "=== 4. Komponenten vorhanden ==="
for f in $P/skills/checking-links/SKILL.md \
         $P/commands/plugin-info.md \
         $P/agents/link-reviewer.md \
         $P/hooks/hooks.json \
         $P/.mcp.json; do
    [ -f "$f" ] && ok "$f" || nok "$f fehlt"
done

echo
echo "=== 5. Skripte ==="
for s in $P/scripts/check-links.py $P/scripts/log-edit.sh; do
    [ -x "$s" ] && ok "$s ist ausfuehrbar" || nok "$s ist nicht ausfuehrbar (chmod +x)"
done
python3 $P/scripts/check-links.py . >/dev/null 2>&1
rc=$?
[ $rc -le 1 ] && ok "check-links.py laeuft (Exit $rc)" || nok "check-links.py bricht ab (Exit $rc)"

echo
echo "=== 6. Keine Windows-Pfade ==="
if grep -rlE '\]\([^)]*\\' $P --include="*.md" 2>/dev/null | grep -q .; then
    nok "Windows-Pfad in einem Markdown-Verweis"
else
    ok "alle Verweise mit Schraegstrich"
fi

echo
echo "=== 7. Manifest-Validierung durch Claude Code ==="
if command -v claude >/dev/null 2>&1; then
    claude plugin validate $P --strict >/dev/null 2>&1 \
        && ok "claude plugin validate $P --strict" \
        || nok "claude plugin validate $P --strict schlaegt an"
    claude plugin validate . --strict >/dev/null 2>&1 \
        && ok "claude plugin validate . --strict (Marketplace)" \
        || nok "claude plugin validate . --strict schlaegt an"
else
    echo "uebersprungen  claude nicht im PATH"
fi

echo
if [ $fehl -eq 0 ]; then
    echo "Alle statischen Pruefungen bestanden."
    echo "Die Installation selbst ist NICHT geprueft -- siehe README.md."
else
    echo "Mindestens eine Pruefung ist fehlgeschlagen."
fi
exit $fehl
