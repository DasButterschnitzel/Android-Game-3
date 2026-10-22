# Gewichtete Bewertungsmatrix (Phase 2)

Stand 2026-10-22 · Alle Werte sind **Hypothesen**, keine Playtest-Ergebnisse.

Gewichte: Spielspaß 25 %, Eigenständigkeit 20 %, Wiederspielwert 20 %, Mobile-Steuerung 10 %, Verständlichkeit 10 %, Technik 5 %, AV 5 %, Monetarisierbarkeit 5 %. Summen per Skript berechnet.

- **Director (erst):** erste Einschätzung von Agent A/C vor Kritik und Prior-Art-Funden.
- **Director (revidiert):** nach Prior-Art-Funden (Sparky → K04, Swarm Multitouch → K02, Gravity Force → K05) und nach der LUNTE-v1-Simulation (Motorik dominiert).
- **Kritiker:** unabhängige Werte von Agent D (`CRITIC_REVIEW.md` §4).
- **Entscheidungswert:** Mittel aus Director (revidiert) und Kritiker.

| Rang | Konzept | Director (erst) | Director (revidiert) | Kritiker | **Entscheidungswert** |
|---|---|---|---|---|---|
| 1 | K01 LUNTE | 8.05 | 7.45 | 6.35 | **6.90** |
| 2 | K06 ECHO | 6.80 | 6.50 | 5.95 | **6.22** |
| 3 | K02 SCHWARM | 7.65 | 6.20 | 5.15 | **5.68** |
| 4 | K10 WELLENGANG | 6.20 | 6.05 | 5.30 | **5.68** |
| 5 | K11 ZEITBLASE | 6.45 | 5.95 | 5.20 | **5.58** |
| 6 | K03 PENDEL | 7.20 | 6.20 | 4.85 | **5.53** |
| 7 | K05 FINGERSONNE | 6.60 | 5.65 | 4.85 | **5.25** |
| 8 | K09 ZWEILEINER | 6.60 | 5.80 | 4.35 | **5.08** |
| 9 | K04 LASSO | 7.35 | 5.75 | 4.35 | **5.05** |
| 10 | K12 SPIEGELSTURM | 6.40 | 5.60 | 4.45 | **5.03** |
| 11 | K08 SPANNUNG | 6.10 | 5.30 | 4.65 | **4.97** |
| 12 | K07 PRALLFINGER | 6.45 | 5.55 | 3.90 | **4.72** |

## Einzelwerte Director (revidiert)

| Konzept | Spaß | Eigen | Wieder | Mobile | Verst. | Tech | AV | Monet. |
|---|---|---|---|---|---|---|---|---|
| K01 LUNTE | 7 | 8 | 7 | 6 | 8 | 9 | 9 | 8 |
| K02 SCHWARM | 7 | 4 | 6 | 5 | 8 | 7 | 9 | 7 |
| K03 PENDEL | 7 | 5 | 5 | 5 | 9 | 6 | 8 | 7 |
| K04 LASSO | 6 | 3 | 5 | 6 | 9 | 8 | 8 | 7 |
| K05 FINGERSONNE | 6 | 4 | 5 | 6 | 6 | 7 | 9 | 7 |
| K06 ECHO | 7 | 5 | 7 | 7 | 5 | 8 | 7 | 8 |
| K07 PRALLFINGER | 5 | 5 | 4 | 5 | 9 | 8 | 7 | 7 |
| K08 SPANNUNG | 5 | 5 | 4 | 4 | 8 | 7 | 7 | 7 |
| K09 ZWEILEINER | 6 | 6 | 5 | 4 | 6 | 7 | 8 | 7 |
| K10 WELLENGANG | 5 | 6 | 5 | 8 | 7 | 7 | 8 | 7 |
| K11 ZEITBLASE | 6 | 6 | 5 | 5 | 7 | 7 | 7 | 7 |
| K12 SPIEGELSTURM | 5 | 5 | 5 | 5 | 7 | 8 | 8 | 7 |

Kritiker-Einzelwerte und Begründungen: siehe `CRITIC_REVIEW.md` §4.

## Ergebnis

Die beiden höchsten Entscheidungswerte haben **K01 LUNTE** und **K06 ECHO** – identisch mit der Empfehlung des Kritikers.
Kein Konzept erreicht in der kritischen Einzelwertung 7/10; beide werden deshalb nur **umgebaut** und mit **vorab fixierten
Abbruchkriterien** prototypisiert. Begründung der Auswahl und Umbauten: `docs/decisions/0001-prototype-selection.md`.
