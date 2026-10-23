# Changelog

Alle Builds sind Debug-APKs (Debug-Zertifikat), nicht für den Store bestimmt. „Getestet“ heißt hier immer:
automatische Tests, Bot-Simulationen und Linux-Smoke-Test des exportierten Builds. **Kein Build wurde bisher auf
einem echten Android-Gerät oder Emulator gestartet** (keine KVM-Virtualisierung, kein Gerät in dieser Umgebung).

## 0.2.0 – „Mechanics“ (2026-10-23) · NACHHALL

Erstes APK des eigentlichen Spiels. Paket `io.github.dasbutterschnitzel.nachhall`, Anzeigename „Nachhall“.

### Neu
- **NACHHALL** (Produktionsfassung von ECHO): Schatten laufen auf die Papierlaterne zu; jeder Lauf (max. 8 s) wird
  ein Echo, das Weg *und* Treffer exakt wiederholt. Fünf Wellen pro Nacht, drei Flammen, Morgengrauen-Bonus.
- **Nachglühen** (1 s nach jedem Treffer), Treffer erfasst alle Schatten im Radius (ADR 0003).
- **Lehr-Welle**: zwei Schatten, die ein einzelnes Licht beweisbar nicht beide schafft.
- **Zwillinge** (ab Welle 3, 0,6 s Fenster, Countdown-Ring am Partner) und **Gepanzerte** (ab Welle 4).
- **Multiplikator zählt Lichter**: ×6/×4/×3/×2/×1,5/×1; ein zweiter Finger entzündet nach bewusstem Zug (≥ 40 px)
  ein zweites Licht und kostet wie ein weiterer Lauf. Abschaltbar in den Einstellungen.
- **Startring**: Ein Lauf beginnt nur, wenn das Licht bewusst aus dem Ring gezogen wird; Finger, die beim Laufende
  noch liegen, sind verbraucht. **Kassieren** ist ein eigener Button; perfekte Läufe werden automatisch kassiert.
- Relative Steuerung mit Ziel-Nachführung: Schnelle Wischer lassen das Licht kurz nachlaufen, aber nie abdriften.
- Darstellung „Papiernacht“: hängende Papierlaterne mit Flammen als Leben, Tuschegeister mit Augen, Panzer-Ringe,
  Zwillingsfaden, Echo-Spuren mit angekündigten Treffer-Ringen, ältere Echos blasser, Himmel wird zum Morgen hell.
- HUD oben: Punkte, Welle, Multiplikator mit Licht-Punkten, Zeitleiste mit Ankunft der Schatten und Echo-Treffern.
- Hinweise im Spiel (je einmal, gespeichert), Wellen-Banner mit Ankündigung neuer Typen.
- Ton: jedes Licht singt eine eigene Note (Kanon), Leck-, Kassier- und Morgengrauen-Klänge (Klänge aus 0.1 wiederverwendet).
- Hauptmenü mit laufender Bot-Partie im Hintergrund, Tagesnacht mit eigenem Tagesbestwert.
- Eigenes App-Icon (adaptiv, mit Monochrom-Ebene für Android 13+), prozedural erzeugt (`tools/art/make_icon.py`).
- Speicherstand Schema v2 (Statistiken von NACHHALL; LUNTE-Werte aus 0.1 werden nicht übernommen).

### Geändert
- LUNTE (inkl. Produktionsszene) und SCHWARM sind nur noch im Debug-Prototyp-Labor erreichbar.
- Tests, Aufnahmen und Smoke-Test nutzen eigene Speicherdateien und verändern keinen echten Spielstand.

### Tests
- 76 automatische Tests grün (u. a. Beweis der Lehr-Welle, Monotonie der Echos, Startring, ruhender Finger,
  zweiter Finger, Pause, Ergebnis/Neustart über die echte Touch-Pipeline).
- Bot-Simulation: alle Abnahmekriterien E1, C1, T1, T2, L1 (und das schwache E2) bestanden – siehe `docs/playtests/ECHO_SIM.md`.
- Smoke-Test des exportierten Linux-Builds: komplette Nacht ohne Engine-Fehler.

### Bekannte Einschränkungen
- Nicht auf einem Gerät getestet (siehe oben). Touch-Gefühl, Lesbarkeit auf 6"-Displays und Lautstärken sind ungeprüft.
- Klänge stammen noch aus LUNTE; eigener Kanon-Klangsatz folgt in 0.3.
- Keine Werbung, keine Einwilligungsabfrage (folgt als Vorschau in 0.6).

## 0.1.0 – „Proof of Fun“ (2026-10-22) · Prototyp-Labor

- Prototypen LUNTE (v2) und ECHO, Referenz-Spike SCHWARM im Labor wählbar.
- Mehrfinger-Kern (`PointerTracker`) mit Touch-Debug-Anzeige.
- Paket `io.github.dasbutterschnitzel.pocketlab` (Labor, wird nicht weitergeführt).
