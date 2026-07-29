---
name: checking-links
description: Prueft, ob die relativen Links in Markdown-Dateien eines Repositories ins Leere zeigen. Zu benutzen vor einem Commit an der Dokumentation, bei Aufraeumarbeiten oder wenn nach kaputten Links gefragt wird.
allowed-tools: Bash(${CLAUDE_PLUGIN_ROOT}/scripts/check-links.py *)
argument-hint: "[verzeichnis]"
arguments: verzeichnis
---

# Markdown-Links pruefen

Fuehre das mitgelieferte Skript aus:

```bash
python3 ${CLAUDE_PLUGIN_ROOT}/scripts/check-links.py $verzeichnis
```

Ohne Argument das aktuelle Verzeichnis pruefen.

Gib die Ausgabe unveraendert weiter. Meldet das Skript kaputte Links, schlage fuer jeden
das wahrscheinliche Ziel vor -- suche dazu nach Dateien mit aehnlichem Namen.

Repariere nichts, ohne dass darum gebeten wurde.
