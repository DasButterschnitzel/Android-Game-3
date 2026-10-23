# ADR 0005 – Wellen-Formationen und Tagesnacht mit Leitmotiv

Status: entschieden · 2026-10-23 · Entscheider: Agent A (Game Director), Umsetzung Agent C/E
Grundlagen: Meilenstein 0.5 „Replayability“, `docs/playtests/ECHO_SIM.md` Teil C. (ADR 0004 ist für die Wahl des
Werbe-SDK reserviert.)

## Problem
Nach 0.4 unterscheiden sich Nächte nur im Zufall der Startpunkte und Ankunftszeiten. Für „eine Runde noch“ fehlt
Abwechslung mit **Bedeutung**: Situationen, die eine andere Planung verlangen, ohne neue Regeln, neue Geistertypen
oder neue Lehrtexte für Anfänger.

## Entscheidung
1. **Vier Formationen** für die normalen Schatten einer Welle (Zwillinge und Gepanzerte bleiben, wie sie sind):
   Streuung, Kette, Zange, Regen. Gewichtet ausgelost, deterministisch je Seed und Welle.
2. **Kette** nutzt eine bestehende Regel (ein Schlag trifft alle Schatten im Radius): Abstand 46 px < 2 × 38 px,
   ein Schlag zwischen zwei Gliedern trifft beide. Ein einmaliger Zettel erklärt das beim ersten Auftreten.
3. **Die erste Nacht eines Spielers ist immer Streuung** – das Onboarding (Lehr-Welle, Zwillinge, Gepanzerte) bleibt
   ungestört.
4. **Tagesnacht mit Leitmotiv:** täglich reihum Ketten, Zangen, Regen (Gewicht ×6), für alle gleich, im Menü
   angezeigt („Tagesnacht #2 · Zangen“). Kein Streak, keine Strafe fürs Auslassen.
5. Das Wellenbanner nennt die Formation in einer Zeile („Kette – ein Schlag kann zwei treffen“).

## Verworfen
- **Neue Geistertypen** (z. B. „Spiegel“): mehr Lehrbedarf, neue Kunst und Klänge – nach 0.8 erneut prüfen.
- **Zufällige Modifikatoren** (schneller, Nebel): ändern Regeln statt Situationen; Nebel schadet der Lesbarkeit.
- **Streak-Belohnungen** für Tagesnächte: Dark Pattern nach Vorgabe.

## Belege und Grenzen
Bot-Simulation (40 Seeds × 5 Strategien × 5 Einstellungen): alle Abnahmekriterien bestanden; Ketten erhöhen die
Streuung der Ergebnisse, nicht den Mittelwert. Unit-Tests sichern Ankunft vor Laufende, Kettenabstand, Doppeltreffer,
Spiegelung der Zangen, eigene Bahnen im Regen, Determinismus, erste Nacht und Tagesnacht-Gewichtung.
Nicht belegt: ob Menschen Ketten als „Trick“ entdecken und genießen – Gerätetest.
