#!/usr/bin/env python3
"""Prueft relative Links in Markdown-Dateien.

Ohne Abhaengigkeiten, ohne Netz: externe Links werden bewusst nicht abgerufen,
sondern uebersprungen. Der Zweck ist ein schneller Selbsttest der Doku, kein
Link-Crawler.

Exit-Code 0 = alle Links loesen auf, 1 = kaputte Links, 2 = Aufruffehler.
"""
import re
import sys
from pathlib import Path

LINK = re.compile(r"\[[^\]]*\]\(([^)\s]+)")
# Was nicht auf eine Datei im Repository zeigt und daher uebersprungen wird.
EXTERN = ("http://", "https://", "mailto:", "#", "tel:")


def check(md, root):
    kaputt = []
    for lineno, line in enumerate(md.read_text(encoding="utf-8",
                                               errors="replace").splitlines(), 1):
        for ziel in LINK.findall(line):
            if ziel.startswith(EXTERN):
                continue
            pfad = ziel.split("#", 1)[0]
            if not pfad:
                continue
            if (md.parent / pfad).exists():
                continue
            kaputt.append(f"FEHL  {md.relative_to(root)}:{lineno}  Link '{ziel}' "
                          f"zeigt ins Leere")
    return kaputt


def main(argv):
    root = Path(argv[1] if len(argv) > 1 else ".")
    if not root.is_dir():
        # Fehler hier loesen, nicht an das Modell weiterreichen.
        print(f"FEHL  {root} ist kein Verzeichnis", file=sys.stderr)
        return 2

    dateien = [p for p in sorted(root.rglob("*.md"))
               if ".git" not in p.parts and "node_modules" not in p.parts]
    if not dateien:
        print(f"Keine Markdown-Dateien unter {root} gefunden.")
        return 0

    kaputt = []
    for md in dateien:
        kaputt.extend(check(md, root))

    for k in kaputt:
        print(k)
    wort = "kaputter Link" if len(kaputt) == 1 else "kaputte Links"
    print(f"{len(dateien)} Dateien geprueft, {len(kaputt)} {wort}")
    return 1 if kaputt else 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
