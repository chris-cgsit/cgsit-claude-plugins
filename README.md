# cgs-training — Plugin-Katalog der CGS-Claude-Code-Schulung

Öffentlicher Plugin-Katalog für die Claude-Code-Schulung von CGS IT Solutions.
Er enthält derzeit **ein** Plugin: `cgs-demo`, das Beispiel, an dem im Kurs
Plugin-Entwicklung gezeigt wird.

Kursunterlagen: <https://cgsit-train-claude.cgs.at>

---

## Installieren

**Remote, aus diesem Repository:**

```
/plugin marketplace add chris-cgsit/cgsit-claude-plugins
/plugin install cgs-demo@cgs-training
```

Nicht-interaktiv geht der erste Schritt auch als
`claude plugin marketplace add chris-cgsit/cgsit-claude-plugins`.

**Lokal, aus einer Kopie** — der Weg für einen Kursraum ohne verlässliches Netz:

```bash
git clone https://github.com/chris-cgsit/cgsit-claude-plugins.git
```

```
/plugin marketplace add ./cgsit-claude-plugins
/plugin install cgs-demo@cgs-training
```

Beide Wege führen zum selben Ergebnis. Im Kurs ist der lokale Weg der Standard, weil er
ohne Netz, ohne Konto und ohne Rate-Limits funktioniert.

> **Noch nicht durchgespielt.** Die Manifeste bestehen `claude plugin validate --strict`,
> der Installationsablauf selbst ist zum Zeitpunkt dieses Commits **ungetestet**. Was danach
> zu erwarten ist, steht unten — beim ersten Durchlauf abgleichen.

---

## Was das Plugin mitbringt

| Art | Name | Was es zeigt |
|---|---|---|
| Skill | `checking-links` | Skill mit Begleitskript, freigegeben über `allowed-tools` mit `${CLAUDE_PLUGIN_ROOT}` — läuft ohne Freigabedialog |
| Command | `plugin-info` | flache `.md` unter `commands/`. Funktional dasselbe Primitiv wie ein Skill, nur ohne eigenes Verzeichnis |
| Subagent | `link-reviewer` | Werkzeugliste ohne `Edit` und `Write` — er kann nichts ändern |
| Hook | `PostToolUse` auf `Edit\|Write` | schreibt eine Zeile pro Änderung nach `${CLAUDE_PLUGIN_DATA}/edits.log` |
| MCP | `seminar` | ein Server-Eintrag, siehe Einschränkung unten |

Nach der Installation zu erwarten:

1. `/cgs-demo:checking-links` und `/cgs-demo:plugin-info` sind aufrufbar
2. `/plugin` listet **CGS Demo** mit Version `0.1.0`
3. nach einer Datei-Änderung steht eine Zeile in `edits.log` unter dem Plugin-Datenverzeichnis
4. der Subagent `link-reviewer` erscheint in der Agentenliste
5. der MCP-Server `seminar` erscheint, verbindet aber nur unter der Bedingung unten

## Die Nutzlast

Ein **Markdown-Link-Prüfer** ohne Abhängigkeiten: er prüft, ob relative Links in
`.md`-Dateien ins Leere zeigen. Externe Adressen werden bewusst nicht abgerufen — das ist
ein Selbsttest der Doku, kein Link-Crawler.

```bash
python3 cgs-demo/scripts/check-links.py <verzeichnis>
```

Klein, nützlich in jedem Repository, und damit trägt das Beispiel sein eigenes Argument:
**ein Plugin lohnt ab dem zweiten Repository, nicht ab der zweiten Datei.**

## Zwei Einschränkungen, absichtlich sichtbar

**Der Subagent setzt kein `permissionMode`, kein `mcpServers` und keine `hooks`.** Diese
drei Felder werden bei Plugin-Subagenten ignoriert — laut Doku ausdrücklich „for security
reasons". Bei einem Projekt-Subagenten unter `.claude/agents/` wirken sie. Das ist der
Unterschied, der im Kurs gezeigt wird: ein Plugin verteilt **Fähigkeiten**, aber es kann
sich nicht selbst Rechte oder einen Lebenszyklus mitgeben.

**Der MCP-Eintrag zeigt auf ein Projekt außerhalb des Plugins.** `.mcp.json` verweist auf
`${CLAUDE_PROJECT_DIR}/examples/seminar-mcp/…` — das existiert nur in den Kursunterlagen und
muss dort erst gebaut werden. Ohne das schlägt der Serverstart fehl. **Das ist erwartet und
kein Fehler des Plugins:** Ein erfundener, immer erreichbarer Server wäre eine Attrappe;
ein Verweis auf ein echtes Projekt ist prüfbar falsch, wenn etwas fehlt.

---

## Prüfen

```bash
bash verify.sh
```

Statische Prüfung ohne Netz: alle JSON-Dateien parsen, Pflichtfelder sind da, jede genannte
Datei existiert, nur `plugin.json` liegt in `.claude-plugin/`, Skripte sind ausführbar,
keine Windows-Pfade. Dazu die eingebaute Prüfung von Claude Code:

```bash
claude plugin validate cgs-demo --strict
claude plugin validate . --strict
```

Beide sind **nicht interaktiv** und gehören in jede Prüfkette. `--strict` macht Warnungen zu
Fehlern — unbekannte Manifest-Felder fallen damit auf, die die Laufzeit stillschweigend
ignoriert.

---

## Aufbau

```
.claude-plugin/
  marketplace.json      der Katalog -- MUSS im Wurzelverzeichnis liegen
cgs-demo/               das Plugin, als "./cgs-demo" im Katalog eingetragen
  .claude-plugin/
    plugin.json         das Manifest -- und die EINZIGE Datei hier drin
  skills/checking-links/
  commands/plugin-info.md
  agents/link-reviewer.md
  hooks/hooks.json
  scripts/
  .mcp.json
verify.sh
```

Zwei Regeln, die man je einmal falsch macht:

1. **`.claude-plugin/marketplace.json` gehört ins Repository-Wurzelverzeichnis.** Liegt der
   Katalog in einem Unterverzeichnis, findet ihn `/plugin marketplace add owner/repo` nicht.
2. **In `.claude-plugin/` liegt nur `plugin.json`.** Alle Komponentenverzeichnisse liegen
   daneben, im Plugin-Wurzelverzeichnis. `verify.sh` prüft das.

---

## Lizenz

Bislang **keine** Lizenz erklärt — damit gilt das gesetzliche Urheberrecht, alle Rechte
vorbehalten. Wer den Link-Prüfer weiterverwenden möchte, fragt bei CGS IT Solutions an.

© CGS IT Solutions GmbH
