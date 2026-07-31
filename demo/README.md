# Demo-Datei für den Link-Prüfer

Übungsmaterial für `cgs-demo:checking-links`. Sie enthält **absichtlich vier kaputte
Links** neben mehreren funktionierenden. Wer sie repariert, macht das Beispiel kaputt —
dafür gibt es `verify.sh` im Wurzelverzeichnis, das die gepflanzten Fehler prüft.

Aufruf:

```
/cgs-demo:checking-links demo
```

oder direkt:

```bash
python3 cgs-demo/scripts/check-links.py demo
```

---

## Diese Links lösen auf

- [Eine vorhandene Datei](vorhanden.md)
- [Dieselbe Datei mit Anker](vorhanden.md#abschnitt-mit-anker) — geprüft wird nur der Pfad davor
- [Eine Datei im Unterordner](unterordner/tief.md)
- [Der Katalog des Marketplace](../.claude-plugin/marketplace.json) — auch nicht-Markdown wird geprüft

## Diese werden übersprungen

Sie zeigen nicht auf Dateien im Repository, also prüft der Prüfer sie bewusst **nicht** —
er ist ein Selbsttest der Doku, kein Link-Crawler:

- [Externe Adresse](https://cgsit-train-claude.cgs.at)
- [Sprungmarke auf dieser Seite](#diese-links-lösen-auf)
- [Mailadresse](mailto:office@cgs.at)

## Diese sind kaputt — sie sollen gefunden werden

1. [Tippfehler im Dateinamen](vorhandne.md) — Buchstabendreher, der beim Lesen nicht auffällt
2. [Datei wurde verschoben](tief.md) — liegt in Wirklichkeit in `unterordner/`
3. [Windows-Pfad](unterordner\tief.md) — mit Backslash, funktioniert auf keinem Unix-System
4. [Ordner statt Datei](unterordner/) — zeigt auf ein Verzeichnis, nicht auf ein Dokument

---

## Was der Prüfer meldet

```
FEHL  README.md:39  Link 'vorhandne.md' zeigt ins Leere
FEHL  README.md:40  Link 'tief.md' zeigt ins Leere
FEHL  README.md:41  Link 'unterordner\tief.md' zeigt ins Leere
3 Dateien geprueft, 3 kaputte Links
```

Vier gepflanzte Fehler, **drei** Meldungen — das ist der Lehrmoment dieser Datei.
Fall 4 zeigt auf `unterordner/`, und dieses Verzeichnis **existiert**. Der Prüfer fragt
nur, ob der Pfad da ist, nicht ob er ein Dokument ist.

Das ist keine Schlamperei, sondern eine bewusste Grenze: Ein Werkzeug, das man im Kurs
zeigt, soll erklärbar sein. Wer diese Lücke schließen will, braucht eine Zeile mehr im
Skript — und genau darüber lässt sich im Kurs reden, statt über eine perfekte Prüfung, die
niemand nachvollziehen kann.
