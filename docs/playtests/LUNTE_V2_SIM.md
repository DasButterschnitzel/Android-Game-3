# LUNTE v2 – Simulationsprotokoll (Bot-Abnahme B1–B4)

Stand 2026-10-22 · Agent H (QA) / Agent E · **Bots sind keine Menschen.** Sie spielen mit perfekter Information,
ohne Verdeckung und ohne Zögern. Die Werte prüfen das *Regelwerk*, nicht den Spielspaß.

Reproduzieren: `godot --headless --path game --script res://tests/simulation/sim_lunte.gd -- 40`
(40 Seeds je Profil, 5 entkoppelte Profile „g<Abstand s>_s<Zeichentempo px/s>“, Kriterien siehe ADR 0001).

## Verlauf der Design-Iteration

| Iteration | Änderung | B1 (gierig/vorsichtig, Median Zeit) | B2 (Score 400/230) | B3 (Böller-Tode) | B4 (Median-Zeiten) |
|---|---|---|---|---|---|
| v1 (Kritiker-Messung) | zeitabhängige Beschleunigung | 0,97 ✗ | 3,2 ✗ | 30–45 % ✗ | – |
| v2.0 | Luntenrolle, Rückerstattung bei Zündung, Tempo pro Zündung, Hitze +15/30 % | 1,14 ✗ | 0,83 ✓ | 11,5 % ✓ | 39–52 s ✗ |
| v2.1 | Hitze-Tempo +20/55 %, Morgengrauen 150 s, mehr Startlunte, exakte Kreuzungsprüfung im Bot | 0,37 ✓ | 3,52 ✗ | 17 % ✗ | 55–150 s ✗ |
| v2.2 | Funken-Obergrenze 190 px/s, nur **aufgefädelte** Böller entzünden Lunte, Nacht 140 s | 1,00 ✗ | 1,08 ✓ | 12 % ✓ | 140 s ✓ |
| v2.3 | Zündung schleudert Feuer 64 px vor | 0,24 ✓ | 7,1 ✗ | 5,5 % ✓ | 25–140 s ✗ |
| v2.4 | Sprungweite nach Hitze (0/32/96 px), Obergrenze 175 px/s | 1,00 ✗ | 1,03 ✓ | 18,5 % ✗ | 140 s ✓ |
| v2.5 | Bot prüft Böller-Radius vor dem Einfädeln; heißer Sprung 128 px | 0,88 ✗ | 1,02 ✓ | 20 % ✗ | 124–140 s ✓ |
| v2.6 | Böller-Ausnahme geometrisch: gesamte eigene Durchfahrt durch den Kreis ist sicher, nur Wiedereinfahrt zündet | 1,00 ✗ | 1,05 ✓ | 9 % ✓ | 140 s ✓ |
| **v2.7** | Hitzestufen neu: Punkte ×1/×1,5/×3, Sprung 0/48/128 px, Tempo +0/15/30 % | **0,83 ✓** | **1,05 ✓** | **8 % ✓** | **116–140 s ✓** |

## Wichtige Einsichten

1. **Ein perfekter Spieler braucht keinen Sicherheitsabstand, solange alles gleichmäßig ist.** Erst der Hitze-abhängige
   Funkensprung bei Zündungen erzeugt ein planbares, sichtbares Risiko für dichtes Hinterherziehen.
2. **Jede „Muss schneller zeichnen“-Situation macht Motorik dominant** (v2.1, v2.3). Strafen müssen *Gier* treffen
   (Hitze), nicht langsames Zeichnen.
3. **Pfadlängen-Regeln fühlen sich unfair an, geometrische nicht** (v2.5 → v2.6): Die Ausnahme „deine eigene
   Durchfahrt durch den Kreis“ ist für Menschen sofort verständlich.
4. **Das Morgengrauen zensiert den Median** (v2.2–v2.6): Viele Runden erreichen die 140-s-Grenze. B1 wurde trotzdem
   unverändert angewendet; zusätzlich protokolliert: Anteil ohne Morgengrauen.

## Endstand v2.7 (40 Seeds je Profil)

| Profil | Median-Zeit | Median-Score | Morgengrauen erreicht | Todesursachen |
|---|---|---|---|---|
| g2.2_s300 (vorsichtig) | 140 s | 1.285 | 31/40 | Rolle leer 8, Kreuzung 1 |
| g1.3_s230 (langsam) | 140 s | 1.288 | 27/40 | Böller 6, Rolle leer 7 |
| g1.3_s300 | 140 s | 1.326 | 31/40 | Böller 3, Rolle leer 6 |
| g1.3_s400 (schnell) | 140 s | 1.355 | 36/40 | Böller 2, Rolle leer 2 |
| g0.75_s300 (gierig) | 116,5 s | 2.768 | 14/40 | Verfolgung 16, Böller 5, Rolle 4, Kreuzung 1 |

**Bewertung (Hypothese):** Das Regelwerk belohnt jetzt Entscheidungen (Abstand, Route, Böller-Platzierung) statt
Zeichentempo. Gier ist der Weg zu Bestwerten, scheitert aber oft – ein Push-your-luck-Profil. Ob sich das für Menschen
spannend statt stressig anfühlt, kann nur der Gerätetest (`PLAYTEST_PROTOCOL.md`) zeigen.

## Offene Punkte
- Bots nutzen die Kurzschluss-Schleife nicht gezielt; ihr Wert ist simulativ noch nicht gemessen.
- Die menschlichen Abbruchkriterien (R², unerklärte Tode, freiwillige Runden) sind **nicht** geprüft.
