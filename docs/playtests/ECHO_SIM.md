# ECHO – Simulationsprotokoll (Bot-Abnahme E1/E2)

Stand 2026-10-22 · **Bots sind keine Menschen.** Der Planer-Bot kennt die deterministische Welle vollständig,
simuliert jeden Lauf vorab mit allen Echos und plant perfekte Abfangrouten (Lichttempo 500 px/s). Er zeigt, ob das
Regelwerk Planung erzwingt – nicht, ob Menschen das Verstehen und Planen genießen.

Reproduzieren: `godot --headless --path game --script res://tests/simulation/sim_echo.gd -- 40`

## Strategien
- **solo**: kassiert nach dem ersten Lauf, nutzt nie Echos.
- **perfect**: plant für die Schatten, die die Echos verfehlen würden; kassiert erst bei 0 Lecks.
- **early**: wie perfect, kassiert aber schon bei ≤ 1 Leck (höherer Multiplikator).
- **sector**: „Rezept“: Lauf k jagt nur Schatten von einer festen Seite (links, rechts, oben).

## Ergebnisse (40 Seeds je Strategie, Median und p10–p90)

| Strategie | Score | Wellen gewertet | perfekte Wellen | Läufe/Welle | Lecks | reine Spielzeit |
|---|---|---|---|---|---|---|
| early | 2210 (1755–2440) | 5 | 4 | 2,00 | 2 | 60 s |
| perfect | 1930 (1395–2320) | 5 | 4 | 2,80 | 1 | 85 s |
| sector | 960 (805–1193) | 5 | 4 | 4,40 | 1 | 142 s |
| solo | 420 (240–720) | 3 | 1 | 1,00 | 8 | 17 s |

## Abnahme
- **E1 (Echos nötig): bestanden.** solo erreicht 19 % des besten Planers (Grenze ≤ 40 %).
- **E2 (keine Einzelrezeptur): bestanden.** Zwei Strategien (early, perfect) liegen ≥ 80 % des Bestwerts; die
  „Tortenstück“-Strategie (sector) erreicht nur 43 %.

## Einschätzung (Hypothesen)
- Die Bank-Entscheidung wirkt: Früh kassieren mit einem Leck schlägt Perfektion – ein echtes Push-your-luck.
- Der perfekte Planer braucht nur 2–3 Läufe pro Welle. Menschen werden mehr brauchen; ob die Planung Spaß macht oder
  überfordert (Kritiker-Risiko „Verständnis“), ist nur mit Menschen messbar.
- Reine Spielzeit 60–85 s plus Entscheidungspausen zwischen den Läufen → Sitzungen von ca. 1,5–3 min.
