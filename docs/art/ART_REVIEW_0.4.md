# Art Review 0.4 „Visual Identity" (Agent F)

Stand 23.10.2026 · Basis: Build 0.3.0 (Commit `625caf3`), sieben gerenderte Frames (720×1280) und `icon_512.png`,
Code: `echo_view.gd`, `echo_hud.gd`, `echo_game.gd`, `ui_theme.gd`, `night_sky.gdshader`, `assets/icon/*`.

**Messgrundlagen.** Alle Größen sind px auf dem 720-px-Basis-Viewport (Stretch `canvas_items`/`expand`). Auf einem
6,1–6,7"-Handy mit 1080 px Breite gilt: 1 px ≈ 0,096 mm ≈ 0,6 dp, also 48 dp ≈ 80 px. Die Kontraste nach WCAG stammen
aus Pixelproben der Frames. Farbabstände sind als CIEDE2000-ΔE angegeben; bei kleinen Marken ist ein ΔE unter 10 kaum
und ein ΔE unter 5 gar nicht unterscheidbar. Farbsehschwäche wurde nach Machado 2009 (Schweregrad 1,0) simuliert.
Herkunft jeder Aussage: **[gesehen]** = in den Frames sichtbar, **[gemessen]** = aus Pixeln oder Font berechnet,
**[Code]** = aus dem Quelltext abgeleitet, **[Annahme]** = nicht belegt.

| Frame | Inhalt [gesehen] |
|---|---|
| 60 | Welle 1, 1. Lauf: Starthinweis, Wellen-Banner, Geist erreicht die Laterne |
| 330 / 470 / 560 | Welle 3, Lauf 1 / 2 / 3: Zwillinge, Echo 1 und Echo 2, Hinweise zu Zwillingen, Kassieren und Durchkommen |
| 880 | Welle 4, 1. Lauf: Zwilling mit Countdown-Ring, die Dämmerung beginnt |
| 1240 / 1380 | Welle 5, Lauf 1 / 2: Panzer- und Normalgeister, Laternentreffer, dichtestes Bild |

## 1. Befund

### 1.1 Was auf dem Handy schon trägt
- **Laterne als Blickanker** [gesehen]: Der Körper ist 90×104 px groß und warm, der Halo hat einen Radius von ~260 px. In jedem Frame ist sie das hellste große Objekt. Sie hängt mittig (y≈550) und damit außerhalb der Daumenzone.
- **Tuschegeister** [gesehen]: schwarze Blobs von 44–50 px mit weißen Augen (8 px), die zur Laterne schauen. Der wabernde Saum macht sie lebendig, und ihre Silhouette lässt sich klar von den runden Lichtern trennen.
- **Zustände über Form** [gesehen]: Der Panzerring (6 Segmente, 4 px, r 32) und der weiße Countdown-Ring der Zwillinge (4 px, Frame 880) lesen sich ohne Farbe.
- **Text** [gemessen]: `TEXT` #f6f1e7 erreicht nachts 17,2:1 und in Welle 5 noch 10,7:1, `TEXT_DIM` 8,3 bzw. 5,2:1, `ACCENT` 10,9 bzw. 6,8:1. Der Score (58 px) und die Hinweise (27 px mit 8-px-Kontur) sind auf jedem Untergrund lesbar.
- **Dämmerung als Fortschritt** [gesehen]: Der Himmel geht oben von #0a0c1c nach #2d375d, der Horizont bis #805756. Die Skyline vor dem Pfirsich-Horizont (Frame 1240) ist das stärkste Stimmungsbild des Spiels.
- **Bereites Lauf-Licht** [gesehen]: Kern r 11, Glow und Trefferkreis r 38 (Frame 470) zeigen die Trefferzone ehrlich; das Licht liest sich wie eine Fackel.
- **Aufteilung** [Code/Annahme]: Lesestoff oben, Spiel in der Mitte, Daumen unten – das passt zur Einhand-Haltung.

### 1.2 Was nicht trägt
1. **Text im laufenden Spielfeld** [gesehen]. In Frame 60 stehen drei Textebenen im ersten Lauf: der Hinweis (y 170–240), das Wellen-Banner mit 46–62 px bei y≈710 direkt unter dem Lauf-Licht und dazu „+10". Das Banner läuft laut Code 2,2 s ab Rundenstart. In den Frames 470 und 560 bleiben „Kassieren: …" bzw. „Wer durchkommt …" 5 s mitten im nächsten Lauf stehen, obwohl gar kein Kassieren-Button zu sehen ist.
2. **Geisterränder verlieren bei Dämmerung Kontrast** [gemessen]. Rand gegen Himmel: Rosa #ff6b8a liegt nachts bei 6,9:1, direkt neben den Geistern in Welle 5 bei 3,4–4,5:1 und im unteren Feld (y 800–960) nur noch bei 2,3–2,6:1. Violett fällt von 7,6 auf 2,5–2,8:1, Orange von 9,4 auf 3,1–3,5:1. Der Tuschekörper hat nachts nur 1,1:1, die Form tragen also allein Rand und Augen. Ausgerechnet Welle 5 mit allen drei Typen ist am schlechtesten lesbar.
3. **Typen nur über Farbton** [gesehen/gemessen]. Normal und Zwilling unterscheiden sich im Feld nur durch den Randton und einen blassen Faden (2 px/35 %). In der Zeitleiste sind alle Ankünfte identische 10-px-Dreiecke. Rosa gegen Orange hat bei Deuteranopie nur ΔE 14,6, bei Tritanopie 10,9.
4. **Echo-Farben kollidieren** [gemessen]. Bei Normalsicht: E3 #ffe27a gegen Lauf-Licht #fff1b8 ΔE 9,2, E2 gegen E5 10,5, E1 gegen E6 12,6. Bei Deuteranopie: E3–E5 2,4, E2–Lauf-Licht 3,4 und **E4 #8fa8ff gegen Zwilling #c58bff 0,6, also identisch**. Der Code-Kommentar „stay clear of the ghost colours" stimmt hier nicht. Die Ziffer steht mit 18 px und 80 % neben dem Licht (Glyphe ≈ 13 px, Frame 560).
5. **Überladung in späten Läufen** [gesehen]. Frame 1380 zeigt ~10 Echo-Linienzüge, 6–8 gestrichelte Routen, 6 Schlagringe, Randanker, zwei Lichter und zwei Panzergeister. Die Echo-Pfade mit 13 % Deckkraft kommen nur auf 1,24–1,38:1 [gemessen]: Ihre Farbe ist verloren, sie wirken wie ein graues Sternbild.
6. **Tintenflecken sehen aus wie Geister** [gesehen]. In Frame 880 liegen vier dunkle, vierzackige Formen (laut Code ein 10-Punkt-Polygon in `INK` mit 22 %, 14 s lang). Sie haben dieselbe Farbe wie lebende Geister und sind auf dem helleren Himmel deutlich zu sehen.
7. **Eigenes Licht beim Nachladen blass** [gesehen]. In den Frames 60, 880 und 1240 hat der Kern nur 45 % Deckkraft [Code], dazu kommt ein 3-px-Bogen. Damit ist das eigene Licht schwächer als jedes Echo. Der Schweif zeigt Querbänder, weil sich die `draw_line`-Segmente (2–10 px) überlappen.
8. **Zeitleiste zu klein** [gesehen]. Die Marken sind 8–10 px groß (≈ 0,8–1 mm), der Balken 6 px. Der Laternenfaden (x 360) schneidet „Welle 3/5" und die Leiste. Der Wellenblock sitzt 40 px rechts der Mitte (cx = 400 [Code]).
9. **Flammen sind die Leben, aber winzig** [gesehen]. Die Flammen messen 10×18 px, und ein verlorenes Leben hinterlässt keine leere Stelle. „4 durch" (Frame 1380) ist ein rotes 34-px-Popup, das beim Ausblenden kaum lesbar ist und insgesamt nur 1,2 s steht.
10. **Das „Papier" fehlt** [gesehen]. Außer dem Himmelskorn ist alles Flachfarbe mit weichem Glow. Die Skyline besteht aus drei flachen Navy-Polygonen, und die Laternenrippen (2 px, 55 %) verschwinden auf Armlänge. Ohne Titel wirkt das wie generischer Neon-Vektor-Casual, nicht wie Papiertheater.
11. **Icon** [gemessen]. Der äußere Bogen der adaptiven Vordergrundebene reicht bis r ≈ 148–150 px (von 432; sichtbar sind r 144, die Safe Zone endet bei r 132). Runde Masken schneiden ihn deshalb an. In der kleinsten Darstellung (48 px, etwa in Einstellungen und Store-Listen) verschwimmen die drei 6-px-Bögen zu einem Farbfleck, und Faden und Sterne verschwinden.

**Was ein Erstspieler vermutlich falsch liest** [Annahme, aus den Frames abgeleitet]:
- Hohle Schlagringe (22–32 px) hält er für Ziele zum Einsammeln, weil sie dem Startring ähneln.
- Randanker (farbige Scheiben von 14–22 px mit weißem Punkt) hält er für Pickups.
- Tintenflecken hält er für weitere Geister.
- Das selbstständig fliegende Echo hält er für ein zweites steuerbares Licht oder einen Gegner.
- „×6" über sechs Punkten liest er als „6 Leben".
- Die Flammen in der Laterne hält er für Deko statt für Leben.
- Die Zeitleiste hält er für einen bloßen Fortschrittsbalken.

### 1.3 Nicht gesehen / Annahmen
- **Kassieren-Button, Ready-Zustand, Pause/Ergebnis und Menü** kommen in keinem Frame vor. Laut Code (Stand 0.3.0) ist der Button 560×96 px groß und sitzt bei y 1130, mit `ACCENT`-Fläche und 44-px-Text in #0d1028 (10,5:1). Gemessen mit Fredoka Bold ist „Kassieren +120  (−1 Flamme)" 550 px breit, mehr als die 524 px Innenbreite, also wächst der Button. „+1.250  (−2 Flammen)" misst 614 px und macht den Button 650 px breit. Die Kosten stehen in Klammern und in derselben Farbe wie der Gewinn.
- Im Arbeitsbaum stellt `ui_theme.gd` die Buttons gerade auf Papierkarten um (`_paper()`: dunklere Unterkante, flacht beim Drücken ab; noch nicht committet und nicht in den Frames). P1-9 baut darauf auf.
- Bewegung (Puls, Schwingen, Flackern, Hit-Stop) lässt sich auf Standbildern nicht beurteilen. Dass der Daumen einhändig etwa y > 850 verdeckt, ist eine Annahme.

## 2. Maßnahmen für 0.4 (priorisiert)

**Leitbild „Papiertheater bei Laternenlicht"** – drei Materialregeln, aus denen alle Punkte folgen:
- **Papier** (Laterne, Skyline, UI-Karten, Zettel): matt, mit 2-px-Schnittkante und hartem Versatzschatten (+5, +7) px in #05030c @ 35 %.
- **Licht** (Lauf-Licht, Echos, Flammen, Fenster): additive Glow-Textur ohne Kontur. *Warm steht für die Gegenwart* (Lauf-Licht, Flammen), *kühl für die Vergangenheit* (Echos als „Mondlicht").
- **Tusche** (nur Geister): #0a0613, immer mit Farbrand und Tusche-Außenkontur. Der Typ wird über die Form gezeigt, die Farbe ist nur Zweitkanal.

P0 = Lesbarkeit (Pflicht für 0.4) · P1 = Identität · P2 = Feinschliff. Die Code-Orte stehen in Klammern.

### P0-1 Geistertypen über Form, Tusche-Kontur (`echo_view.gd: _draw_enemies`)
- **Problem:** 1.2 Nr. 2 und 3.
- **Änderung:** Zuerst `draw_polyline(body_closed, INK, 7.0, true)` zeichnen, dann den Farbrand mit 3,5 px (statt 2,5). Damit hat der Rand gegen seine eigene Kontur 7,4:1 (Rosa), 8,1:1 (Violett) und 10,1:1 (Orange), egal auf welchem Himmel. Typ-Form:
  - **Normal** behält 2 Augen.
  - **Zwilling** bekommt *ein* großes Auge (Weiß r 6,5, Pupille r 3); das Paar hat zusammen ein Gesicht. Der Faden wird 3 px @ 60 % auf einer 5-px-Tusche-Unterlage (statt 2 px @ 35 %).
  - **Panzer** behält den Plattenring, die Platten bekommen eine 1,5-px-Tusche-Kontur.
  - Die Farben #ff6b8a / #c58bff / #ffa25c bleiben.
- **Warum:** Die Augen sind das kontraststärkste Detail (Weiß auf Schwarz). Ein Auge gegen zwei ist für jeden Farbsehtyp und in Graustufen sofort lesbar, und die Kontur macht den Rand unabhängig von der Dämmerung.

### P0-2 Ich und Echo über Form, Identität über Ziffer, kühle Echo-Palette (`_draw_echo_lights`, `ECHO_COLS`)
- **Problem:** 1.2 Nr. 4.
- **Änderung:** Das Echo wird zur **Ziffern-Marke**: eine gefüllte Scheibe r 13 in Echofarbe mit der Ziffer *in* der Scheibe (Fredoka Bold 20 px, `INK`, ≥ 9,3:1 auf allen neuen Farben). Das Alter zeigen Glow (0,55 → 0,2) und Größe (r 13 → 11). Die Scheibe bleibt deckend (≥ 0,85), damit die Ziffer lesbar bleibt. Das Lauf-Licht trägt nie eine Ziffer. Neue Palette „Mondlicht": Alle Echos sind kühl, warm ist nur das Lauf-Licht.
  `ECHO_COLS = [#a6f0ff, #29ccb1, #a6cbff, #47c1cc, #a6ffe1]`. Im Lauf gibt es höchstens 5 Echos, weil bei 6 Lichtern automatisch kassiert wird [Code]; ein 6. Eintrag nimmt die Farbe von E1.

  | min. ΔE2000 | IST | NEU |
  |---|---|---|
  | Echo vs. Lauf-Licht – Normal / Protan / Deutan / Tritan | 9,2 / 5,6 / 3,4 / 7,2 | 23,3 / 10,2 / 15,3 / 31,0 |
  | Echo vs. Geisterrand – Normal / Protan / Deutan / Tritan | 16,6 / 4,7 / 0,6 / 17,7 | 21,8 / 14,1 / 10,2 / 38,7 |
  | Echo vs. Echo – Normal / Deutan / Tritan | 10,5 / 2,4 / 6,5 | 13,7 / 9,0 / 2,8 |
- **Warum:** Neben Warmweiß, Rosa, Violett und Orange gibt es keine fünf gut trennbaren Farbtöne mehr. Eine Suche über ~70 zulässige kühle Kandidaten ergab als bestes Echo-Echo-Minimum 13,7 bei 5 Farben und 11,8 bei 6. Die Farbe trennt deshalb nur „ich / Vergangenheit / Gegner" robust; welches Echo es ist, sagt die Ziffer.

### P0-3 Ein Textkanal: Lehrtexte nur zwischen Läufen (`echo_hud.gd`, `echo_onboarding.gd`)
- **Problem:** 1.2 Nr. 1.
- **Änderung:**
  - `show_hint` puffert, solange `sim.state == "running"`, und zeigt erst in `ready`/`between`.
  - Darstellung als **Zettel** (siehe P1-9), zentriert über dem Startring: höchstens 600 px breit, Unterkante bei y ≈ 770 (24 px über dem Ring), höchstens 2 Zeilen à 26 px.
  - Das Wellen-Banner erscheint nur im Ready-Zustand der neuen Welle, an derselben Stelle, und blendet beim Lauf-Start in 0,15 s aus.
  - Im Lauf gibt es nur objektgebundene Kurzlabels (≤ 3 Wörter, 24 px, 1,5 s): „Dein Echo" an Echo 1 (ersetzt den Hinweis `echo`), „lädt …" am Licht (ersetzt `recharge`) und „Zwillinge!" zwischen dem Paar.
- **Warum:** In 8 s zieht jeder Text im Feld den Blick vom Ziel weg. Erklärt wird, wenn die Welt steht, und dort, wo das Objekt ist.

### P0-4 Spielfeld entrümpeln (`_draw_echo_trails`, `_draw_routes`, `_draw_stains`)
- **Problem:** 1.2 Nr. 5 und 6 sowie die Fehllesungen oben.
- **Änderung:**
  - **Echo-Pfad:** statt des ganzen Pfads nur die **nächste 1,0 s** vor jedem Echo als Punktspur (alle 6 Ticks ein Punkt, r 3 → 1,5 px, Deckkraft 0,55 → 0). Zwischen den Läufen nur den Pfad des neuesten Echos, 2 px @ 25 %.
  - **Schlagringe:** im Lauf nur Schläge der nächsten 2,0 s; Ring r 16, 3 px, mit der Echo-Ziffer (14 px, Echofarbe) in der Mitte. Das „bald"-Wachstum bleibt. Zwischen den Läufen alle Ringe @ 50 %.
  - **Routen:** im Lauf nur für Geister, die in ≤ 2 s erscheinen (Deckkraft steigt von 0,13 auf 0,30); zwischen den Läufen alle @ 0,18.
  - **Randanker:** das Typ-Symbol aus P0-6 (▲ / ▲▲ / ■, 16 px, 2-px-Tusche-Kontur), zur Laterne gedreht. So liest es sich als „kommt von hier", nicht als Pickup.
  - **Tintenflecken:** rund (Radius ±10 % statt Zacken) mit 2–3 Spritzern r 2–4 px, Deckkraft 0,12 (statt 0,22), Lebensdauer 4 s (statt 14 s).
- **Warum:** Zum Planen braucht man „wo und wann schlägt welches Echo" und „wer kommt woher", nicht die Geschichte jedes Laufs. Ziel für Welle 5: höchstens 15 Hilfsmarken gleichzeitig statt ~30.

### P0-5 Das eigene Licht ist immer das klarste (`_draw_live_lights`)
- **Problem:** 1.2 Nr. 7.
- **Änderung:** Der Kern hat r 12 und ist immer 100 % `LIVE_COL`. Der Glow ist #ffcf7a, beim Laden 48 px @ 0,45, wenn bereit 72 px @ 0,8. Den Ladezustand zeigt nur der Ring (r 22, 4 px): eine Spur @ 20 % und ein Füllbogen @ 90 %. Beim Vollwerden pulst der Ring einmal (×1,3 in 0,15 s), danach erscheint wie bisher der Trefferkreis r 38 @ 20 %. Der Schweif wird ein einziger Zug: `draw_polyline_colors(trail, colors, 8.0, true)` mit Alpha von 0 bis 0,5.
- **Warum:** Bei relativer Steuerung („Zieh irgendwo") liegt das Licht nicht unter dem Daumen, das Auge muss es ohne Suchen finden. Außerdem verschwinden so die Querbänder.

### P0-6 HUD-Kopf: lesbare Zeitleiste, ruhiges Raster (`echo_hud.gd: _draw`, `_draw_timeline`)
- **Problem:** 1.2 Nr. 3 und 8.
- **Änderung:**
  - **Raster:** Der Score bleibt links (x 28). Der Wellenblock wird exakt auf x 360 zentriert („Welle 3/5" 24 px, Punkte 10/14 px, Abstand 22). Der Multiplikator steht rechtsbündig bis x 596 (44 px). Die Lichtpunkte werden 12 px groß im Abstand 17; freie Plätze erscheinen als 1,5-px-Umriss @ 35 %, benutzte gefüllt. Pause ist 88×88 bei (612, 18).
  - **Zeitleiste** bei y 134: Balken 8 px mit runden Enden, Spur #ffffff @ 12 %, Füllung `LIVE_COL` @ 85 % und ein Abspielkopf von 4×22 px in `LIVE_COL` mit Glow. Die Ankünfte stehen unten als **Typ-Symbole mit 14 px**: ▲ normal, ▲▲ Zwillingspaar (ein Symbol pro Paar), ■ Panzer, jeweils mit 2-px-Tusche-Kontur; die Typfarben bleiben. Echo-Schläge stehen oben als Rauten mit 12 px, Lauf-Schläge als Striche von 3×14 px.
  - **Laternenfaden:** Er beginnt an der Arena-Oberkante (y 150) mit einem Knoten r 4 in #8a7f99, nicht am Bildschirmrand (`_draw_lantern`).
- **Warum:** Weil Feld (Randanker) und Leiste dieselben Symbole nutzen, ist die Leiste ohne Legende lernbar. 14 px (≈ 1,35 mm) erkennt man als Form, 8 px nicht.

### P1-7 Laterne: Held und Lebensanzeige (`_draw_lantern`)
- **Problem:** 1.2 Nr. 9 und 10.
- **Änderung:**
  - **Papier-Schattierung:** die rechte Körperhälfte als zweites Polygon in `paper.darkened(0.12)`; ein Innenglühen (Ellipse 0,62 r × 0,75 r um die Flammen) in #fff3cf @ 55 % × warm; Rippen 2,5 px #c98a45 @ 80 % (statt 55 %); Kappen #3a2b3f mit 2-px-Oberlicht #6b5570.
  - **Flammen** werden 16×28 px groß (Halbbreite 0,18 r, Höhe 0,64 r) und sitzen in festen Slots. Ein verlorenes Leben lässt einen Docht von 4×8 px in #3a2b3f stehen.
  - **Flammen in Gefahr** (zwischen Läufen, wenn `last_run.leaked > 0`): Die rechten N Flammen flackern mit 3 Hz zwischen #ff9a3c und #ff5d5d, darüber sitzt ein Tintentropfen r 4.
  - „N durch" wird ein 40-px-Popup mit 8-px-Tusche-Kontur, steht 1,8 s und erscheint seitlich der Laterne statt auf dem Faden.
- **Warum:** Der Blick liegt ohnehin auf der Laterne. Dort muss stehen, was das Kassieren kostet, bevor der Spieler drückt.

### P1-8 Papier-Bühne: Schnittkante und harter Schatten (`_draw_skyline`, `art_kit.gd`)
- **Problem:** 1.2 Nr. 10.
- **Änderung:**
  - Jede Skyline-Ebene wird zuerst um (+5, +7) versetzt in #05030c @ 35 % gezeichnet (`draw_set_transform`), dann die Fläche, dann eine 2-px-Schnittkante auf der Oberkontur (`poly[1 .. n-2]`) in #2b2756 / #221f47 / #17143a. Bei Dämmerung färbt sich die hinterste Kante Richtung #ff9d6b (× dawn × 0,6).
  - Die Ecken der Skyline werden deterministisch um ±1,5 px verrauscht, damit sie handgeschnitten wirken; die Fenster bekommen ein 2-px-Fensterkreuz.
  - Geister bekommen einen Versatzschatten (+4, +6) in `INK` @ 25 %. Nachts ist er unsichtbar, ab Welle 4 gibt er Tiefe.
  - Das Himmelskorn `grain` steigt von 0,035 auf 0,05.
- **Warum:** Harter Schatten und Schnittkante sind das billigste starke Papiersignal: ein Polygon mehr pro Objekt, keine Textur, tauglich für GL Compatibility.

### P1-9 UI-Stil „Laternenpapier" (`ui_theme.gd`, `_update_bank_button`; nur `StyleBoxFlat`)
- **Problem:** Die UI besteht aus generischen flachen Navy-Rechtecken, der Pause-Knopf ist ein Text „II". Der Kassieren-Text läuft über, und die Kosten gehen unter (1.3).
- **Änderung:**

| Element | Werte |
|---|---|
| Primär (Kassieren, Nochmal, Weiter, Spielen) | Wie im Arbeitsstand `_paper(PAPER, PAPER_EDGE, 30, 8)`: bg #ffd58a (Laternenpapier), Unterkante 8 px #c98a3c, Text `INK` #2a1f2e Bold 44 px (11,3:1). **Ergänzen:** `shadow_color` #ff9a3c @ 35 %, `shadow_size` 18, Offset 0, damit die Karte wie die Laterne glüht; gedrückt `shadow_size` 8 |
| Sekundär | Wie im Arbeitsstand: `PANEL_LIGHT` #232a5c, Unterkante 6 px `NIGHT_EDGE` #141838, Text `TEXT` 32 px (12,0:1); kein Glühen |
| Panel (Pause, Ergebnis) | bg #141735 @ 95 %. Statt der kühlen Kante #2c3470 ein Rand 2 px #ffd58a @ 30 % (von der Laterne angestrahlte Papierkante). Radius 28; Schatten #000 @ 40 %, Größe 14, Offset (0, 8); Innenabstand 32; Titel `ACCENT`, Text `TEXT_DIM` 26 px (7,5:1) |
| Zettel (nur Lehrtexte, P0-3) | Nachtpapier: bg #141735 @ 94 %, `border_width_left` 6 in #ffd58a (Lichtkante); Radius 14; Schatten #05030c @ 45 %, Größe 3, Offset (5, 7); Text `TEXT` Medium 26 px (15,5:1) |
| Pause-Knopf | 88×88; bg #ffffff @ 10 %, Rand 2 px @ 18 %, Radius 44; Symbol als zwei gezeichnete Balken 8×28 px statt Text „II" |
| Kassieren | Primär-Stil, 560×104 px, Unterkante 56 px über dem Rand (Gestenleiste); Text nur „Kassieren +120" (288 px bei 44 px). Kosten als eigenes Etikett 12 px darüber im Panel-Stil: gezeichnete Flamme und „kostet 1 Flamme" 24 px in `DANGER` #ff5d5d (5,8:1) |

- **Warum:** Nur Aktionen sind helles, glühendes Laternenpapier. Informationen und Lehrtexte liegen auf dunklem „Nachtpapier", also gibt es pro Bildschirm genau eine helle Fläche, und das Auge findet den Knopf sofort. Die Papierdicke (Unterkante) aus dem Arbeitsstand passt zur Materialregel „Papier" und bleibt. Alle Texte haben ≥ 5,8:1, alle Ziele ≥ 88 px (≈ 53 dp).

### P1-10 Dämmerung ohne Kontrastverlust (`night_sky.gdshader`, `night_progress`)
- **Problem:** 1.2 Nr. 2.
- **Änderung:** Der Morgenverlauf wechselt von `pow(uv.y, 1.6)` zu `pow(uv.y, 2.8)`, damit die Wärme am Horizont hinter der Skyline sitzt. `dawn` wird in den Wellen mit 0,87 skaliert (Welle 5 ≈ 0,75 statt 0,86). Die volle 1,0 kommt erst als Belohnung beim Morgengrauen-Ergebnis.
- **Warum (Modellrechnung für die Bildmitte, Welle 5):** Der rosa Rand hat gegen den Himmel bei y 550 / 800 / 950 heute 3,0 / 2,3 / 1,9:1, neu 4,5 / 3,9 / 3,3:1. Zusammen mit der Kontur aus P0-1 ist das robust, und oben wird der Himmel weiterhin sichtbar heller.

### P2-11 Launcher-Icon (`assets/icon/*`)
- **Problem:** 1.2 Nr. 11.
- **Änderung:** Zwei Bögen statt drei, mit 20 px Strich (auf 432) und den Radien 90 und 118. Die Außenkante liegt damit bei 128, also innerhalb der Safe Zone (r 132). Die Farben kommen aus der Mondlicht-Palette (#a6f0ff innen, #29ccb1 außen), damit die Laterne das einzig Warme bleibt. Die Laterne bleibt ~110 px breit. Die Sterne fallen weg oder es bleiben höchstens 5 große (≥ 6 px). Die Mono-Ebene funktioniert bereits.
- **Warum:** Bei 48 dp müssen Laterne und „Nachhall-Ringe" als zwei klare Formen stehen, und runde Masken dürfen nichts anschneiden.

### P2-12 Farbsehschwäche-Abnahme in der Engine (neuer Debug-Shader)
- **Problem:** Die Farbsicherheit wurde bisher nur behauptet (Kommentar in `echo_view.gd`), nicht geprüft; E4 kollidiert bei Deuteranopie mit dem Zwilling.
- **Änderung:** Ein Debug-`CanvasLayer` (Ebene 100) mit Vollbild-`ColorRect` und einem `hint_screen_texture`-Shader (funktioniert im 2D-Compatibility-Renderer). Modi: Protan / Deutan / Tritan (Machado-Matrizen in linearem RGB) und Graustufen; der Schalter sitzt neben „Touch-Debug". **Abnahmeregel 0.4:** In Graustufen und bei Deutan müssen unterscheidbar bleiben: Lauf-Licht und Echo, die drei Geistertypen (im Feld und in der Zeitleiste), Flamme und leerer Slot.
- **Warum:** So wird die Regel aus STYLE_GUIDE.md („Farbe allein trägt nie Information") im Spiel testbar, statt nur im Kopf geprüft zu werden.

## 3. Nicht ändern (funktioniert)
- **Laterne als zentraler Held:** Position (Arena-y 0,36), Größe (r 44), warmer Halo, Schwingen am Faden.
- **Grundform der Tuschegeister:** wabernder Körper mit gezacktem Saum, weiße Augen mit Blick zur Laterne, Wachsen beim Erscheinen, Tintenschweif.
- **Formbasierte Zustände:** Panzer-Plattenring und weißer Zwillings-Countdown-Ring.
- **Nacht → Morgengrauen über fünf Wellen** und die Scherenschnitt-Skyline; nur das Spielfeld wird geschützt (P1-10).
- **Fredoka:** Bold für Zahlen und Buttons, Medium für Text; Score 58 px, Hinweise ≥ 26 px mit Kontur. `TEXT`, `TEXT_DIM` und `ACCENT` bestehen alle Kontrastproben.
- **Orange #ffb347** als Farbe der Punkte-Wirtschaft (Multiplikator, einfliegende Punkte, erledigte Wellen).
- **Bedienung:** Lesestoff oben, Startring mit rotierenden Segmenten und Zug-Feedback, Trefferkreis r 38 am bereiten Licht.
- **Lichter:** die Grundidee „warmes Lauf-Licht gegen farbige Echos" und dass ältere Echos zurücktreten.
- **Alles prozedural** (eine Glow-Textur, ein Himmels-Shader): kleine APK, einheitlicher Look, die Effektstufen bleiben steuerbar.

Nach der Abnahme sollen Materialregeln, Echo-Palette und UI-Tabelle in `STYLE_GUIDE.md` übernommen werden; diese Datei ist hier bewusst unverändert.
