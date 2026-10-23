# ECHO / NACHHALL – Simulationsprotokoll

> **Zwei Regelstände.** Teil A beschreibt den Prototyp (Commit `d45960c`, Regeln ohne Nachglühen) und bleibt als
> Entscheidungsgrundlage für ADR 0002 unverändert stehen. Teil B misst die Produktionsregeln nach ADR 0003.
> Zum Nachstellen von Teil A muss Commit `d45960c` ausgecheckt werden; die heutigen Skripte messen Teil B.

## Teil A – Prototyp (Bot-Abnahme E1/E2)

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


## Teil B – Produktionsregeln (ADR 0003)

Stand 2026-10-23 · Bots sind keine Menschen: Sie sehen alles, zögern nie und bewegen sich exakt.

Reproduzieren:
`godot --headless --path game --script res://tests/simulation/sim_echo.gd -- 40 7000 600 | python3 tools/sim/summarize_echo.py`
(Argumente: Runden je Strategie, Seed-Basis, Bot-Tempo in px/s, optional JSON-Overrides für Parameter-Sweeps.)

### Strategien
- **solo** – plant einen Lauf und kassiert sofort; nutzt nie Echos.
- **perfect** – spielt vor jedem Lauf die Echos durch und jagt, was sie verfehlen; kassiert nur ohne Leck.
- **early** – wie perfect, kassiert aber schon mit höchstens einem Leck.
- **sector** – Rezept: Lauf k jagt nur Schatten von einer festen Seite.
- **chaser** – reaktiv, ohne Vorausschau: jagt immer den Schatten, der der Laterne am nächsten ist, ignoriert Echos.

### Ergebnisse (40 Seeds je Strategie, Median; Rundenlänge inkl. 2 s Entscheidung je Pause)

| Seeds / Tempo | perfect | early | sector | solo | chaser | Rundenlänge Planer | Zwillinge zerstört |
|---|---|---|---|---|---|---|---|
| 3000–3039 / 600 px/s | 1.445 | 1.315 | 640 | 540 | 340 | 77–85 s | 97 % |
| 7000–7039 / 400 px/s | 1.380 | 1.260 | 650 | 540 | 340 | 80–92 s | 96 % |
| 7000–7039 / 600 px/s | 1.445 | 1.280 | 680 | 540 | 340 | 75–89 s | 94–95 % |
| 7000–7039 / 900 px/s | 1.410 | 1.280 | 680 | 540 | 340 | 75–89 s | 92–93 % |

### Abnahme (automatisch geprüft, alle bestanden)
- **E1** allein ≤ 40 % des Planers: 0,37–0,39.
- **C1** reaktiv ≤ 50 % des Planers: 0,23–0,25. Planung schlägt Reaktion deutlich.
- **T1** Lehr-Welle für ein Licht in 100 % der Seeds verloren (zusätzlich bewiesen im Unit-Test).
- **T2** Planer zerstören ≥ 80 % der Zwillingspaare: 92–97 %. Keine Klippe für planvolles Spiel; ob Menschen das
  Timing lesen können, bleibt Gerätefrage.
- **L1** Rundenlänge der Planer 60–180 s: 75–92 s.
- **E2** (schwach, wie in Teil A): perfect und early liegen ≥ 80 % des Besten; sector (Tortenstück-Rezept) nur 44–47 %.

### Einschätzung (Hypothesen)
- `solo` und `chaser` liefern in jedem Seed exakt denselben Wert: Normale Schatten schafft ein Licht allein immer,
  Zwillinge und Gepanzerte nie. Das ist gewollt – diese Typen *erzwingen* Echos –, macht die Solo-Kurve aber flach.
- Mit Flammen als knapper Ressource liegt **perfect jetzt leicht vor early** (≈ 9 %), dafür ist early schneller.
  Bei Menschen mit Fehlern dürfte frühes Kassieren attraktiver sein; Gerätetest beobachten.
- Das Bot-Tempo wirkt kaum (± 5 %): Die Erholzeit, nicht die Motorik, begrenzt ein einzelnes Licht.
