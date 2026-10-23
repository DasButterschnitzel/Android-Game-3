# Art Direction „Papiertheater bei Laternenlicht“ (Agent F)

Stand 0.4 · Grundlage: `ART_REVIEW_0.4.md` (Messungen an echten Frames). Die erste Fassung („Papiernacht“, für das
LUNTE-Feuerwerk) ist in der Git-Historie; ihr Prinzip bleibt: **Lesbarkeit vor Effekt, Gameplay-Objekte haben immer
den stärksten Kontrast, der Hintergrund bleibt dunkel und ruhig.**

## Drei Materialien
| Material | Wofür | Regel |
|---|---|---|
| **Papier** | Laterne, Skyline, UI-Karten, Lehr-Zettel | matt, 2-px-Schnittkante, harter Versatzschatten (+5, +7) px in #05030c @ 35 % |
| **Licht** | Lauf-Licht, Echos, Flammen, Fenster | additive Glow-Textur ohne Kontur. **Warm = Gegenwart** (Lauf-Licht, Flammen), **kühl = Vergangenheit** (Echos, „Mondlicht“) |
| **Tusche** | nur Geister | #0a0613, Farbrand 3,5 px über einer 7-px-Tuschekontur; Typ über **Form**, Farbe nur Zweitkanal |

## Formsprache = Regel (Farbe trägt nie allein Information)
- **Normal:** zwei Augen · Symbol ▲ · Rand #ff6b8a
- **Zwilling:** *ein* großes Auge (das Paar teilt sich ein Gesicht), Tusche-Faden zum Partner, Countdown-Ring · Symbol ▲▲ · #c58bff
- **Gepanzert:** Plattenring (6 Segmente, nach dem ersten Treffer halb) · Symbol ■ · #ffa25c
- **Echo:** gefüllte Scheibe mit **Ziffer** (welches Echo), kühle Farbe (Vergangenheit), ältere kleiner und mit weniger Glühen
- **Lauf-Licht:** immer voll deckender warmer Kern r 12; der Ladezustand steht nur im Ring (r 22), einmaliger Puls bei „bereit“
- Dieselben Typ-Symbole stehen am Rand (Herkunft) und in der Zeitleiste (Ankunft) → ohne Legende lernbar.

## Paletten
| Rolle | Farben |
|---|---|
| Echos („Mondlicht“) | #a6f0ff, #29ccb1, #a6cbff, #47c1cc, #a6ffe1 (max. 5 gleichzeitig; 6. Licht kassiert automatisch) |
| Lauf-Licht / Glühen | #fff1b8 / #ffcf7a |
| Geisterränder | #ff6b8a, #c58bff, #ffa25c |
| Tusche | #0a0613 |
| Laterne (klassisch) | Papier #ffd58a, Rippen #e0a656 (kosmetische Papiere: `Progression.PAPERS`) |
| Skyline (hinten → vorne) | #1a1838, #131130, #0b0a22; Schnittkanten #2b2756, #221f47, #17143a; hintere Kante wird bei Dämmerung → #ff9d6b |
| Text / gedämpft / Akzent / Gefahr / gut | #f6f1e7 / #a9a7c4 / #ffb347 / #ff5d5d / #7ce0b0 |

## Lesbarkeit
- **Ein Textkanal:** Lehrtexte erscheinen nie während eines Laufs, sondern zwischen den Läufen als heller Zettel über
  dem Startring. Im Lauf nur objektgebundene Kurzlabels (≤ 3 Wörter): „Dein Echo“, „lädt …“, „Zwillinge!“.
- **Entrümpelt:** Echo-Weg nur 1 s voraus (Punktspur), Echo-Schläge nur 2 s voraus (Ring mit Ziffer), Routen im Lauf
  nur für Geister, die in ≤ 2 s erscheinen. Tintenflecken rund, 12 %, 4 s.
- **Dämmerung** bleibt im Spielfeld gedämpft (Shader-Exponent 2,8, Wellen-Dämmerung ×0,87); das volle Morgenlicht ist
  die Belohnung auf dem Ergebnis-Bildschirm.
- **HUD-Raster:** Punkte links, Welle exakt mittig, Multiplikator rechtsbündig neben dem Pause-Knopf (88×88).
  Zeitleiste 8 px mit Abspielkopf; Symbole 14 px.
- Kontraste: Texte ≥ 5,2:1 auf jedem Himmel (gemessen); Geisterränder durch die Tuschekontur ≥ 7:1.

## UI „Laternenpapier“ (nur `StyleBoxFlat`, `scripts/ui/ui_theme.gd`)
| Element | Werte |
|---|---|
| Primär (Spielen, Kassieren, Nochmal, Weiter) | #ffb347, Unterkante 6 px #b8621c, Radius 26, warmes Glühen (#ff9a3c @ 35 %, 18 px), Text #2a1426; gedrückt: #f0a03a, Kante 2 px, Text 6 px tiefer |
| Sekundär | #1c1f45, Unterkante 5 px #0e1030, Radius 20, Text #f6f1e7 |
| Karte (Pause, Ergebnis) | #141735 @ 95 %, Rand 2 px #ffd58a @ 30 %, Radius 28, Schatten 45 % / 28 px / (0, 10), Innenabstand 32 |
| Zettel (nur Lehrtexte) | #f3e6cc, Text #22162e 26 px, Radius 14, Unterkante 4 px #cbb48c, Schatten (5, 7) |
| Pause-Knopf | 88×88, Weiß @ 10 %, Rand @ 18 %, zwei gezeichnete Balken |
| Kassieren | 560×104, 56 px über dem unteren Rand + Safe Area; Kosten als eigenes rotes Etikett mit Flamme darüber |

## Typografie
Fredoka (SIL OFL 1.1): Bold für Zahlen und Buttons, Medium für Fließtext. Score 58 px, Hinweise ≥ 26 px. Zeichen, die
die Schrift nicht hat (z. B. ★ →), werden gezeichnet; ein Test prüft alle UI-Texte gegen die Schrift.

## Effekt-Budget (Performance & Barrierefreiheit)
- Eine Glow-Textur, additive Partikel (max. 900), keine Post-Processing-Pässe.
- „Effekte reduziert“: weniger Partikel, schwächeres Wackeln, kürzerer Hit-Stop. „Minimal“: nur funktionale Effekte.
- Farbsehschwäche-Prüfung: Debug-Einstellung „Farbsicht-Test“ (Protan/Deutan/Tritan nach Machado 2009, Graustufen).
  Abnahme: in Graustufen und Deutan unterscheidbar bleiben Lauf-Licht vs. Echo, die drei Geistertypen (Feld und
  Zeitleiste), Flamme vs. leerer Slot.

## Icon
Laterne (~110 px auf 432) mit zwei Echo-Bögen (r 90 / 118, Strich 20) in Mondlicht-Farben, alles innerhalb der
Safe Zone (r 132); monochrome Ebene für Android 13+. Erzeugt von `tools/art/make_icon.py`.
