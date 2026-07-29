---
description: Zeigt, welche Komponenten das cgs-demo-Plugin mitbringt und wo sie liegen.
---

# cgs-demo

Nenne die Komponenten dieses Plugins, je eine Zeile mit Art, Name und Aufruf:

- Skill `checking-links`, aufrufbar als `/cgs-demo:checking-links`
- Command `plugin-info` (diese Datei), aufrufbar als `/cgs-demo:plugin-info`
- Subagent `link-reviewer`
- Hook auf `PostToolUse` fuer `Edit` und `Write`
- MCP-Eintrag `seminar`, siehe `.mcp.json` im Plugin

Erklaere anschliessend in einem Satz, warum diese Datei ein **Command** ist und kein
Skill: sie liegt als flache `.md`-Datei unter `commands/` und hat kein eigenes
Verzeichnis fuer Begleitdateien. Funktional sind beide inzwischen dasselbe Primitiv.
