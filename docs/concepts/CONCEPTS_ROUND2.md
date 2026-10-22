# Spielkonzepte – Runde 2 (Nachideation unter Leitplanken)

Autor: Agent C2 (Experimental Gameplay Designer, Runde 2) · Stand: 2026-10-22
Grundlage: `CRITIC_REVIEW.md` (§1 systemische Kritik, §6 Leitplanken – verbindlich), `CONCEPTS.md` (Runde 1, nicht wiederholt),
`00_INNOVATION_MAP.md`, `02_indie_experimental.md` (§2–§4), `03_touch_and_sentiment.md` (§3), Format der Bot-Abnahme aus
`docs/decisions/0001-prototype-selection.md`.

Rahmen wie Runde 1: **Hochformat**, **Runden von 30 s – 3 min**, **offline**, **werbefinanziert ohne IAP**, Godot 4 (2D),
prozedurale Grafik und prozedurales Audio, ein Solo-Techniker. Dieses Dokument **bewertet nicht**; das übernimmt der Kritiker.

**Kennzeichnung (wie in `CRITIC_REVIEW.md`):**
- **[B]** Quelle in dieser Sitzung selbst geöffnet (Direktabruf), Zitate wörtlich.
- **[R]** aus unseren Recherche-Dokumenten übernommen (dort belegt), von mir nicht erneut geöffnet.
- **[A]** Allgemeinwissen, in dieser Sitzung **nicht** verifiziert.
- **[E]** meine Einschätzung.

Alle Aussagen über Spaß, Dauer und Balance sind **Hypothesen**. Alle Zahlen in den Regeln sind **Startwerte für die
Bot-Kalibrierung**, keine Ergebnisse. Die Konzepte sind fortlaufend nummeriert (K13–K19), damit sie sich nicht mit Runde 1 überschneiden.

---

## 0. Prior-Art-Prozess und seine Grenzen

- **WebSearch war gesperrt.** Schon meine erste Suchanfrage wurde abgewiesen, weil das mit anderen Agenten geteilte
  Suchbudget dieser Sitzung aufgebraucht war. Umgehungen (Suchmaschinen per curl, Proxys, Reader-Dienste) habe ich bewusst
  nicht genutzt. **In dieser Runde gab es also keine einzige Websuche.**
- **Ersatz:** 17 gezielte Direktabrufe bekannter Referenzseiten, alle **vor** dem Ausformulieren der Konzepte. 15 lieferten
  Inhalt, 2 ergaben HTTP 404 (Wikipedia „Firefighter problem“, „Dark Echo“) und werden nicht als belegt zitiert.
- **Konsequenz:** Direktabrufe bestätigen nur Verwandte, die ich schon kenne. Unbekannte Nahverwandte, vor allem kleine
  Mobile- und Jam-Titel, kann ich ohne Suche nicht finden. **„Nicht gefunden“ heißt hier „nicht suchbar gewesen“**, nicht
  „existiert nicht“. Feld L nennt deshalb je Konzept die Suchbegriffe, die vor einem Prototyp nachgeholt werden sollten
  (2–3 Suchen je Kandidat).

---

## 1. Überblick

| # | Titel | Kurz-Pitch | Kern-Eingabe | Tempo | Session-Ende | Multitouch |
|---|---|---|---|---|---|---|
| K13 | RÜCKWEG | Route auf den Berg aus je 3 Karten draften, mit Beute wieder hinunter | Wischen irgendwo + 1 von 3 Karten tippen | ruhig, zugbasiert | 36 h Tageslicht, Rückkehr zur Hütte | keins |
| K14 | KIPPMOMENT | Ein Schnitt durch ein Gleichgewichts-Mobile, dann rechnet die Schwerkraft | relativ ziehen (Drehregler), Loslassen schneidet | ruhig, zugbasiert | 3 Schnitte × 4 Mobiles | keins |
| K15 | ECHOLOT | Jeder Sonar-Ping zeigt die unsichtbaren Wale – und treibt sie weg | hinter das Ziel tippen (Versatz-Fadenkreuz, Loslassen) | ruhig, zugbasiert | 14 Pings oder alle Wale entschieden | keins |
| K16 | LICHTUNG | Lagerfeuerlicht mit fester Fläche formen, bis der Morgen kommt | relativ ziehen + Loslassen | ruhig, zugbasiert | 24 Züge bis Sonnenaufgang oder Glut aus | optional, gleichwertig |
| K17 | FÄHRMANN | Im Takt rudern (links/rechts/beide), Fahrgäste vor Sonnenuntergang | zwei Daumenzonen + Akkord oder Mittelstreifen | Takt 2 s | 45 Ruderschläge bis Sonnenuntergang | Akkord optional, gleichwertig |
| K18 | GEGENFEUER | Waldbrand mit Schneisen, Löschflug und geankertem Gegenfeuer bändigen | Versatz-Fadenkreuz, Loslassen setzt | Echtzeit-Ticks, Zeitlupe beim Zielen | Brand erlischt; Werkzeuge 4/3/2 | keins |
| K19 | WINDSPIEL | Ein Wind für alles: Samen säen und Regenwolken treiben | Wischen irgendwo (Richtung) | ruhige Echtzeit | 14 Windwechsel, Sonnenuntergang nach 90 s | keins |

**Feldbalance:** Vier Konzepte (K13–K16) liegen im Segment „ruhig, aber entscheidungsdicht“ (Leitplanke 5 verlangt mindestens
ein Drittel). Drei (K17–K19) laufen in Echtzeit oder im Takt, aber ohne Präzisions- oder Tempovorteil.

**Was aus Runde 1 verwertet wurde (nur „Parken“-Teile):**
- K10 „Wirkung hinter dem Ziel auslösen“ → K15 (Ping hinter dem Wal).
- K11 „Zeitstopp-Blase“ → K18 (Zeitlupe nur beim Zielen, als sichtbarer Vorrat).
- K02 „Schwarmverhalten als Verhalten von Ressourcen“ → K15 (deterministisches Fluchtverhalten), K16 (Variante Glühwürmchen), K19 (Samenfächer).

**Nicht wiederholt:** Pfad zeichnen mit Verfolger (K01), Finger als Lockpunkt (K02), Objekt am oder unter dem Finger (K03–K07, K11, K12),
erzwungene zwei Hände (K08, K09), Eingabe-Aufzeichnung als Kern (K06).

---

## 2. Leitplanken-Matrix

| Leitplanke (`CRITIC_REVIEW.md` §6) | K13 | K14 | K15 | K16 | K17 | K18 | K19 |
|---|---|---|---|---|---|---|---|
| 1 Finger ≠ Avatar | Wischen + Kartenleiste | relativ + Loslassen | hinter das Ziel, Loslassen | relativ + Loslassen | 2 Zonen + Akkord | Versatz-Fadenkreuz, Loslassen | Wischen |
| 2 Entscheidung alle 2–5 s; Motorik ohne Vorteil | 1,5–3 s, keine Motorik | 3–6 s, Einrasten | 3–6 s, keine Motorik | 2–4 s, keine Motorik | 2 s Takt, breite Fenster | 2–5 s, Zeitlupe + Feldraster | 2–5 s, 8 Richtungen |
| 3 Deterministisch, Tagesseed, teilbar | ja | ja | ja | ja | ja | ja | ja |
| 4 Ende über sichtbares Budget/Ziel | Tageslicht | Schnitte | Pings | Morgen / Glut | Sonnenuntergang | Brand erlischt | Hauche + Sonne |
| 5 Ruhig mit neuem Verb | umkehren (Draften auf Rückweg-Rechnung) | schneiden (Gleichgewicht stören) | anpingen (sehen = stören) | Licht formen (flächenerhaltend) | – | – | – |
| 6 Ungenutzter Baustein | 1-aus-3-Drafting (Blue Prince) + Extraktion (Bore Blasters) | Zielen-Loslassen + Statik (Holedown) | K10-Prinzip, K02-Verhalten | Arena-Rand + Dehnen (Windowkill, Stretchmancer) | Akkord (Data Wing), Trägheit | K11-Zeitblase, Telegrafie (Into the Breach) | Tiny-Wings-Sonne, K02 |
| 7 Multitouch ehrlich | keins | keins | keins | Spreizen = Ein-Finger-Geste | Akkord = Mittelstreifen | keins | keins |
| 8 Dominanz beantwortet | Feld N | Feld N | Feld N | Feld N | Feld N | Feld N | Feld N |

---

## 3. Gemeinsame Annahmen für alle Konzepte

- **Tagesseed** aus dem lokalen Datum, kein Server. Gleiche Inhalte für alle; Ergebnis als kurzer Text plus kleines
  Symbolraster oder Bild über das Android-Teilen-Menü. Zusätzlich ein freier Übungsmodus mit beliebigen Seeds.
- **Kein-Frust-Vertrag:** keine Leben, keine Energie, kein Tod mit Sperre. Neustart in unter 1 s, Zustand nach jeder Aktion
  gespeichert (Unterbrechung jederzeit).
- **Werbung** nur nach dem Ergebnisbildschirm, nie zu Rundenbeginn (Play-Richtlinie, 03 §4.2 T1). **Rewarded** nur im Übungsmodus,
  nie im Tagesmodus, damit Tagesergebnisse vergleichbar bleiben.
- **Android-Hygiene (03 §3.4):** keine spielrelevanten Wische, die am Seiten- oder Unterrand beginnen; *immersive sticky*
  während der Runde; Ziele ≥ 48 dp; Pointer-Abbrüche (`ACTION_CANCEL`) sauber behandeln.
- **Barrierefreiheit:** Farbe nie allein (immer Form oder Symbol dazu), Screenshake und Haptik abschaltbar, alles einhändig
  spielbar, nirgends Halten oder gleichzeitige Eingaben als Pflicht.
- **Bot-Pipeline:** Spiel und Bot nutzen dieselbe deterministische Sim-Klasse (Muster `FuseSim` / `sim_lunte.gd`), ≥ 200 Seeds
  pro Profil, JSON-Zusammenfassung mit Median, p10 und p90. Die Abnahmekriterien in Feld O sind so formuliert, dass sie
  **vor** dem ersten Lauf fixiert werden können (Regel aus ADR 0001).
- **Leitplanke 2 bei zugbasierten Konzepten:** Ohne motorische Komponente hat jeder Bot automatisch „perfekte Motorik“. Geprüft
  wird dort die Spreizung zwischen Entscheidungsprofilen: Zufall, Gier und Planung müssen weit auseinanderliegen.

---

## K13 · RÜCKWEG

*Ruhig, zugbasiert · Kern-Eingabe: Wischen irgendwo, Tippen auf eine von drei großen Karten · Bausteine: räumliches
1-aus-3-Drafting (Blue Prince), Push-your-luck-Extraktion (Bore Blasters) · Multitouch: keins*

**A. Arbeitstitel** – RÜCKWEG

**B. Elevator Pitch** – Du baust die Route auf den Kristallberg Feld für Feld aus je drei Karten – und musst sie mit deiner
Beute vor Sonnenuntergang wieder hinunter. Jeder Schritt nach oben ist auch ein Schritt zurück.

**C. Kernmechanik**
- **Spielfeld:** Berghang als Raster aus 5 × 8 Feldern, anfangs leer. Unten in der Mitte die Hütte (Start und Ziel). Oben
  läuft die Sonne über einen sichtbaren Bogen: **36 Stunden Tageslicht**.
- **Draften:** Wischt der Spieler irgendwo in eine Richtung, geht der Kletterer durch den passenden Ausgang seines Felds.
  Liegt dort noch kein Feld, erscheinen unten drei Routenkarten; er tippt eine, sie wird gelegt und betreten. Jede Karte hat
  eine Tür zur Herkunftsseite. Mindestens eine der drei führt weiter (Fairness-Garantie). Ein aufgedecktes Angebot muss
  gewählt werden. Nachbarfelder sind nur verbunden, wenn beide eine Tür zueinander haben.
- **Kartentypen (Startsatz):**
  - Pfad (1 h, zwei Ausgänge), Band (1 h, quer), Grat (2 h, drei Ausgänge).
  - Kluft (1 h, Sackgasse, enthält Kristalle: Zeilen 1–3 je 1–3 zu 1 Punkt, Zeilen 4–6 je 2–3 zu 2 Punkten, Zeilen 7–8 je 2–3 zu 3 Punkten).
  - Biwak (1 h): Depot, Kristalle kostenlos ablegen oder aufnehmen.
  - Schneebrücke (0 h): bricht nach dem ersten Überqueren ein.
  - Abseilstelle: abwärts zwei Zeilen auf einmal für 1 h, wenn darunter schon ein verbundenes Feld liegt.
  - Gipfel: steht im mittleren Feld der Zeile 8 immer im Angebot. Wer ihn erreicht und heimkehrt, bekommt ×1,5 auf alle an diesem Tag abgelieferten Kristalle.
- **Last:** In einer Kluft wählt der Spieler, wie viele Kristalle er mitnimmt (Tasten 1 / 2 / 3 an Stelle der Karten). Die Last
  multipliziert jede Bewegung: 0–2 Kristalle ×1, 3–5 ×2, ab 6 ×3.
- **Puffer (der Kern):** Neben dem Kletterer steht immer *Tageslicht minus Kosten des günstigsten Rückwegs mit aktueller Last*.
  Jede Karte und jede Mengentaste zeigt „Puffer danach“. Gier ist damit nie versteckt, nur riskant.
- **Laufen auf gebauten Feldern:** Tippen auf ein Feld zeigt beim Aufsetzen den günstigsten Weg mit Kosten, Loslassen läuft
  ihn ab (Wegziehen bricht ab). So ist auch der Abstieg eine einzige Geste.
- **Abliefern und mehrere Touren:** In der Hütte zählen die mitgebrachten Kristalle. Mit dem restlichen Licht darf man erneut
  aufsteigen; die gebaute Route bleibt.
- **Ende:** Bei 0 h übersteht man die Nacht im Notbiwak, verliert aber alles, was man trägt oder im Depot hat. Kein Tod, nur verlorene Beute.
- **Determinismus:** Das Angebot jedes Felds (Kartentypen, Inhalte) ist eine feste Funktion aus Tagesseed und Koordinate; die
  Türen richten sich nach der Eintrittsseite. Wer am selben Tag dasselbe Feld öffnet, sieht dieselben drei Karten.

**D. Die ersten 30 Sekunden** (Tutorialtag mit 12 h)
- 0 s: Hütte, ein leeres Feld darüber, Morgensonne. Ein Daumensymbol wischt nach oben.
- 2 s: Wisch → drei Karten: Pfad, Band, Kluft (1 Kristall). Ein Pfeil zeigt auf „Pfad“.
- 5 s: Der Kletterer steigt, die Sonne rückt sichtbar weiter: „Puffer 10 h“.
- 8 s: Nächster Wisch, im Angebot eine Kluft mit 3 Kristallen. Gewählt → „Wie viele?“ Bei 3 zeigt die Taste „Last ×2 · Puffer 2 h“ in Orange. Erste echte Gier-Entscheidung.
- 15 s: Der Puffer wird knapp, die Figur keucht, die Hütte blinkt.
- 18 s: Tippen auf die Hütte → „Abstieg 6 h“, Loslassen → schneller Abstieg entlang der roten Routenschnur.
- 22 s: Kristalle klirren in die Kiste, Hüttenglocke, Punkte.
- 25–30 s: Ergebnisbild mit der gebauten Route: „Morgen neuer Berg · Übungsberg jetzt“.

**E. Core Gameplay Loop** – Puffer lesen → Richtung wählen → 1 aus 3 draften → in der Kluft Menge wählen → Puffer neu lesen →
weiter oder umkehren → abliefern → mit Restlicht noch einmal? Der Reiz entsteht aus zwei gekoppelten Spannungen: Was liegt
hinter dem nächsten Feld (Erkundung), und was kostet es, es wieder hinunterzutragen (Last × Weg).

**F. Hook** – Der Weg hinein ist der Weg hinaus. Jede Karte, die du oben legst, bezahlst du unten noch einmal – mit schwerem Rucksack.

**G. Mastery**
- Lastschwellen ausreizen: lieber 2 als 3 Kristalle, bis man oben ist; das Depot nutzen, um leicht zu steigen.
- Rückwege vorbauen: Querverbindungen und Abseilstellen so legen, dass der Abstieg kürzer wird als der Aufstieg.
- Schneebrücken als Einbahnstraße: schnell hinauf, aber nur, wenn ein zweiter Weg zurückführt.
- Gipfel-Timing: erst Gipfel mit leichtem Gepäck, dann ernten (×1,5 gilt für den ganzen Tag) – oder umgekehrt.
- Angebote lesen: Die Kartenverteilung je Höhenstufe ist bekannt; Profis wissen, in welchen Zeilen Klüfte wahrscheinlich sind.

**H. Wiederspielwert**
- Tagesberg mit gleichen Angeboten je Feld für alle, teilbares Ergebnis; unbegrenzte Übungsberge.
- Varianten: „Wettersturz“ (24 h), „Steinschlag“ (Rinne: schnell, aber mit ≥ 4 Kristallen fällt einer heraus), „Zwei Hütten“ (Abstieg links oder rechts).
- Die 50. Runde ist interessant, weil jede Wahl drei Dinge zugleich festlegt: den Weg nach oben, den Weg nach unten und
  die Anschlüsse der Nachbarfelder. Vorab lösen lässt sich der Tag nicht, weil Angebote erst beim Öffnen sichtbar werden.

**I. Technische Machbarkeit**
- Raster mit Kartendaten (JSON); Angebot = Hash(Seed, x, y) → drei Karten aus der Tabelle der Höhenstufe, mit Prüfung der Fairness-Garantie.
- Weg- und Rückwegkosten per Dijkstra auf höchstens 40 Feldern, nach jeder Aktion neu.
- Keine Physik, keine Echtzeit; Zustand nach jeder Aktion speicherbar.
- Eine Sim-Klasse für Spiel und Headless-Bot. Graubox in 1–2 Tagen; der Hauptaufwand ist das Balancing der Kartentabelle, und das übernimmt der Bot.

**J. Audiovisuelle Vision** – Topografische Karte statt Landschaftsbild: Felder erscheinen als Kartenausschnitte mit
Höhenlinien, die Route als rote Schnur, die den Rückweg immer zeigt. Das Tageslicht färbt die ganze Karte: kühler Morgen,
goldener Nachmittag, blaue Dämmerung. Unter 3 h Puffer pulsiert die Schnur. Audio: Der Wind wird mit der Höhe lauter, die
Schritte schwerer mit der Last, jeder Kristall klirrt im Rucksack mit, beim Abliefern läutet die Hüttenglocke. Kacheln aus
Höhenlinien-Rauschen, Töne aus wenigen Synthesizer-Patches – vollständig prozedural.

**K. Werbetauglichkeit** – Natürliche Pause nach jedem Tag (Ergebnisbild, 60–120 s Spielzeit). Interstitial höchstens nach
jedem zweiten Übungsberg. Rewarded nur im Übungsmodus, z. B. „Fernglas“: die Angebote von drei Feldern vorab sehen.

**L. Vergleichbare Spiele**
- **Blue Prince** (Dogubomb/Raw Fury, 2025) [B]: Beim Öffnen einer Tür wird ein Raum gedraftet, „by choosing one of three
  randomly selected floor plans“; „The player begins each day with 50 steps“; am Tagesende muss man das Haus verlassen und
  „abandon all objects they have collected“. Der Artikel nennt keine Mobile-Fassung. https://en.wikipedia.org/wiki/Blue_Prince_(video_game)
  – Abgrenzung: Dort gibt es keinen Rückweg, das Tagesende ist ein harter Schnitt. Hier ist der Rückweg der Kern: Die
  gedraftete Karte ist zugleich die Rechnung.
- **Deep Sea Adventure** (Oink Games) [B]: geteilter Sauerstofftank; wer viele Schätze nimmt, verbraucht ihn schneller; offen
  ist, ob man es zurück zum U-Boot schafft. Laut Verlagsseite gibt es eine Digitalfassung in „Let's Play! Oink Games“.
  https://oinkgames.com/en/games/analog/deep-sea-adventure/ – Nächster Verwandter für „Beute macht den Rückweg teurer“; dort
  fester Pfad, Würfel, Mehrspieler, kein Drafting.
- **Incan Gold / Diamant** (Moon & Faidutti, 2005) [B]: Wer weitergeht, kann „risk losing the treasure they have accumulated“,
  wer geht, behält. https://en.wikipedia.org/wiki/Incan_Gold – Push-your-luck ohne Raum.
- **Bore Blasters** [R]: Treibstoff-Timer, Beute bleibt bei Abbruch (02 §2.5). **Dorfromantik** [R]: Kachelstapel als Timer ohne Uhr (02 §2.4).
- **Nicht suchbar gewesen** (§0): Mobile-Titel mit „Drafting beim Hinweg, Kosten beim Rückweg“. Nachzuholen:
  „draft rooms return journey push your luck mobile“, „roguelite climb descend carry weight time budget“.

**M. Hand & Verdeckung**

**Wo liegt die Hand, und was ist darunter?** – Der Daumen liegt im unteren Fünftel auf der Kartenleiste; darunter liegen nur die
drei Karten, die er gerade wählt. Der Berg wächst nach oben vom Daumen weg. Beim Wischen verdeckt die Hand höchstens kurz die
Hütte und die untersten, längst bekannten Felder. Der Abstieg ist Tippen und Loslassen, also kein Dauerkontakt.

```
+------------------------+
| Sonne ---o---  Puffer 6h|   Status oben
|  .   .   .   .   .     |
|  .   .   ^   .   .     |   Berg 5 x 8,
|  .   .   |   .   .     |   wächst nach oben
|  .   K---+   .   .     |   K = Kletterer
|          H             |   H = Hütte
| [Karte] [Karte] [Karte]|   <- Daumen
+------------------------+
```
- Wische zählen erst ab 24 dp Abstand zum Seitenrand und nie aus der unteren Gestenleiste; während des Tages *immersive sticky*.

**N. Dominante Strategie & ihre Kosten** – Welche Strategie dominiert, und was kostet sie?
- **„Immer die Kluft“:** Klüfte sind Sackgassen. Wer jede nimmt, baut ein Geäst aus Stichwegen, muss ständig zurück und
  überschreitet früh die Lastschwelle ×2. Kosten: Man kommt kaum über Zeile 4 und erntet fast nur 1-Punkt-Kristalle.
- **„Erst Autobahn, dann ernten“:** nur weiterführende Karten bis oben. Kosten: unterwegs keine Punkte; oben hängt alles daran,
  ob die drei Angebote dort Klüfte enthalten. Hohe Varianz, die man nicht beeinflusst.
- **„Puffer bis null“:** Kosten: Ein Grat (2 h) oder eine eingestürzte Schneebrücke macht den Rückweg teurer als geplant →
  Notbiwak, alles weg. Die Kosten sind sichtbar, treffen aber jeden, der keine Reserve lässt.
- **Erwartung [E]:** Am stärksten ist eine Mischung: früh 1–2 Klüfte, Depot im Mittelteil, leicht nach oben, dort 3 Kristalle, abseilen.
- **Restrisiko:** Ist der Gipfelbonus zu stark, wird „Gipfel zuerst“ zur Pflicht-Eröffnung. Das prüft R4.

**O. Bot-Spielbarkeit**
- **Zustand:** gebaute Felder (Typ, Türen, Restinhalt), Position, Last, Depot, Tageslicht, Gipfel erreicht ja/nein, abgelieferte Punkte.
- **Aktionen (alle diskret):** bewegen (≤ 4), Karte wählen (3), Menge in der Kluft (1–3), Depot ablegen/aufnehmen, „zur Hütte“, Tag beenden.
- **Motorik:** keine. Jeder Bot hat automatisch perfekte Motorik; Unterschiede entstehen nur aus Entscheidungen.
- **Profile:**
  - `zufall`: zufällige gültige Aktion.
  - `gierig_m0`, `gierig_m2`, `gierig_m4`: immer die kristallreichste Karte und die Maximalmenge; Umkehr bei Puffer ≤ m.
  - `autobahn`: nur weiterführende Karten bis Zeile 7, dann ernten.
  - `gipfel`: erst Gipfel mit leerem Rucksack, dann ernten.
  - `planer`: Beam-Suche (Breite 20, Tiefe 4); ungeöffnete Felder gehen mit der Verteilung ihrer Höhenstufe als Erwartungswert ein (der Bot weiß nicht mehr als ein Mensch).
  - `orakel`: wie `planer`, kennt aber alle Angebote (obere Schranke).
- **Messgrößen:** Median, p10, p90 der Punkte; Anteil Notbiwak; Aktionen und Touren pro Tag; Depot- und Gipfelquote.
- **Abnahmekriterien (vor dem Test fixieren):**
  - R1: `planer` ≥ 1,4 × `gierig_m2` (Median).
  - R2: `gierig_m0` landet in ≥ 25 % der Seeds im Notbiwak und liegt im Median unter `gierig_m2`. Sonst kostet Gier nichts.
  - R3: `zufall` ≤ 30 % von `planer`.
  - R4: Mindestens zwei stilistisch verschiedene Profile (z. B. `planer`, `gipfel`) liegen ≤ 10 % unter dem besten Median. Sonst gibt es ein Rezept.
  - R5: `orakel` ≤ 1,3 × `planer`. Sonst entscheidet Glück beim Aufdecken zu viel.
  - R6: 15–40 Aktionen pro Tag, also 45–150 s bei angenommenen 3 s pro Aktion.
- **Billigster Menschentest:** Papierprototyp mit Kartenstapeln je Höhenstufe und Würfel-freiem Seed-Blatt, 5 Personen × 3 Tage; gefragt wird, ob die Umkehr-Entscheidung „wehtut“.

**P. Session-Budget** – Ein Tag = 36 h Tageslicht als Sonnenbogen; jede Bewegung kostet sichtbare Stunden. Ende: „Feierabend“
in der Hütte oder 0 h. Erwartete Dauer 60–120 s (Tutorialtag 30 s). Tagesberg aus dem Datum. Teilbar: „RÜCKWEG · 22.10. ·
17 Kristalle · Gipfel ja · 2 h Puffer“ plus ein 5 × 8-Symbolraster der eigenen Route (zeigt den Weg, nicht die Angebote).

---

## K14 · KIPPMOMENT

*Ruhig, zugbasiert · Kern-Eingabe: relativ ziehen (Drehregler), Loslassen schneidet · Baustein: Zielen–Loslassen–Kaskade mit
Statik (Holedown) · Multitouch: keins*

**A. Arbeitstitel** – KIPPMOMENT

**B. Elevator Pitch** – Über drei Schalen hängt ein Mobile aus Wippen, Kugeln und Fäden. Du hast drei Schnitte: Zieh die
Schnittlinie, lass los – und sieh zu, wie das Gleichgewicht kippt und deine Kugeln in die Schalen rollen.

**C. Kernmechanik** – Fünf zählbare Regeln:
1. **Schnitt:** Die Schere sitzt unten mittig. Die Schnittlinie ist eine Gerade von der Schere nach oben und trennt **alle**
   Fäden, die sie kreuzt. Was an einem getrennten Faden hing, fällt senkrecht herunter; Wippen zerfallen dabei, ihre Gegenstände fallen einzeln.
2. **Kippen:** Jede Wippe vergleicht das Gewicht links und rechts ihres Drehpunkts – Gegenstände auf ihr plus alles, was an ihren
   Enden hängt. Ist eine Seite schwerer, kippt die Wippe dorthin. Gezählt wird nur Gewicht, nicht Hebelarm.
3. **Rollen:** Kippt eine Wippe, rollt alles, was auf ihr liegt, über das tiefe Ende und fällt senkrecht. Eine gekippte Wippe
   bleibt schräg und leitet alles, was später auf sie fällt, zum tiefen Ende weiter (Rampe).
4. **Reißen:** Jeder Faden trägt höchstens so viel Gewicht, wie er Knoten hat (1–4). Landet mehr darauf, reißt er – wie ein
   Schnitt, nur verzögert.
5. **Schalen:** Unten hängen drei Schalen (×1, ×2, ×3). Gegenstände: Kugel (Gewicht 1, 1 Punkt), Bleikugel (Gewicht 2, 0 Punkte,
   reines Gegengewicht), Glasvogel (Gewicht 1, 3 Punkte; zerbricht, wenn er außerhalb einer Schale landet: −3).
- **Ablauf:** Pro Mobile drei Schnitte; danach oder per „Fertig“ wird gewertet. Ein Tagesset = vier Mobiles steigender
  Schwierigkeit. „Par“ = beste Punktzahl, die der Löser findet; Sterne bei 50 / 80 / 100 % von Par.
- **Vorschau:** Beim Zielen leuchten die Fäden, die getrennt würden, und gestrichelte Falllinien zeigen, wo das direkt Fallende
  landet. Die Kaskade danach (Kippen, Rollen, Reißen) wird **nicht** vorhergesagt – das ist das Rätsel. Nach jedem Schnitt gibt
  es auf Wunsch eine Zeitlupen-Wiederholung, in der jede Ursache aufleuchtet (Regeltransparenz, vgl. Draftula-Kritik in 02 §2.9).
- **Determinismus:** Ereignisse laufen in fester Reihenfolge (nach Fallhöhe, dann x). Leichtes Schaukeln im Wind ist rein kosmetisch und beim Zielen eingefroren.

**D. Die ersten 30 Sekunden**
- 0 s: Mini-Mobile: eine Wippe mit je einer Kugel links und rechts, an beiden Enden hängt zusätzlich eine Bleikugel; unter dem
  rechten Ende eine Schale. Die Geste wird animiert: seitlich ziehen = zielen, nach oben ziehen = Schere öffnen, loslassen = schneiden.
- 4 s: Schnitt durch den Faden der linken Bleikugel → sie fällt ins Leere, die Wippe kippt nach rechts, beide Kugeln rollen in
  die Schale: „pling, pling ×1“.
- 10 s: Zwei Etagen. Ein Schnitt lässt eine Kugel auf die untere Wippe fallen; die kippt und rollt sie in die ×2-Schale. Erste Kaskade.
- 18 s: Zwei Gegengewichte an beiden Enden, darunter zwei Schalen: Eine schräge Linie trennt beide Fäden zugleich, die Wippe
  bleibt waagerecht, beide Gewichte fallen in Schalen. Aha: ein Schnitt, zwei Fäden.
- 25–30 s: Mini-Ergebnis mit Sternen, dann das erste Tagesmobile.

**E. Core Gameplay Loop** – Gewichte zählen → Kippfolgen durchdenken → Linie wählen → schneiden → Kaskade zusehen
(1–3 s „Hoffen“) → neue Lage lesen (gekippte Wippen sind jetzt Rampen) → nächster Schnitt. Die Spannung liegt in der
Reihenfolge: Der erste Schnitt baut oft die Rampe für den dritten.

**F. Hook** – Ein Schnitt, dann übernimmt die Schwerkraft. Ein guter Schnitt räumt ein ganzes Mobile ab, Kugel für Kugel in die ×3-Schale.

**G. Mastery**
- Bilanzen über mehrere Etagen vorausrechnen.
- Wippen gezielt als Rampen vorkippen, bevor die wertvollen Kugeln fallen.
- Doppelschnitte, die eine Wippe im Gleichgewicht halten, während ihre Gehänge fallen.
- Überlast als verzögerten Zünder nutzen: erst Gewicht auf einen schwachen Faden lenken, dann reißt er von selbst.
- Glasvögel zuletzt und nur über Rampen bewegen; Par mit weniger als drei Schnitten erreichen.

**H. Wiederspielwert**
- Tagesset aus Seed (4 Mobiles), unendlicher Übungsmodus aus dem Generator; der Generator behält nur Mobiles, deren beste Lösung eine Kaskade braucht.
- Varianten: „Ein Schnitt“ (eine Linie, maximale Punkte), „Glashaus“ (viele Glasvögel), „Wandhaken“ (feste Drehpunkte, die kippen, aber nicht fallen).
- Die 50. Runde ist interessant, weil wenige Bauteile (Faden, Wippe, Gewicht, Schale) sich zu immer neuen Ketten kombinieren;
  Tiefe, Knotenzahlen und Schalenlage variieren pro Seed.

**I. Technische Machbarkeit**
- Diskrete Ereignissimulation statt Physik-Engine; Schnitt = Test „Gerade gegen senkrechte Fadenstrecke“.
- Aktionen = Winkelintervalle mit gleicher Fadenmenge: bei N Fäden höchstens 2N + 1, typisch 10–25.
- Löser = vollständige Suche über drei Schnitte (≤ 25³ ≈ 16.000 kleine Simulationen, Bruchteile einer Sekunde).
- Generator verwirft Mobiles, bei denen der Topschnitt ≥ 50 % Par bringt oder Gier schon Par erreicht. Tagessets können vorab für ein Jahr erzeugt und als kleine JSON-Datei mitgeliefert werden.
- Darstellung: Linien, Kreise, Polygone, Tweens für Fallen und Rollen. Graubox 2–3 Tage; Generator und Löser sind der Hauptteil.

**J. Audiovisuelle Vision** – Scherenschnitt auf warmem Papier: schwarze Silhouetten (Vögel, Monde, Fische), dazu wenige
kräftige Farben für Kugeln und Schalen. Fäden als feine Linien, Knoten als kleine Punkte, damit Tragkraft lesbar ist. Beim
Zielen dunkelt das Papier leicht ab, die Schnittlinie leuchtet. Audio: Schnipp, hölzernes „tok“ beim Kippen, Rollgeräusch,
Schalen klingen nach Faktor (×3 am höchsten), Glas klirrt. Kaskaden spielen eine aufsteigende Pentatonik – je länger die Kette, desto höher der Ton.

**K. Werbetauglichkeit** – Pause nach dem Tagesset (vier Mobiles) und im Übungsmodus nach jedem dritten Mobile. Rewarded nur
im Übungsmodus: „ganze Kaskade vorab zeigen“ als Lernhilfe.

**L. Vergleichbare Spiele**
- **Cut the Rope** (ZeptoLab, 2010; u. a. iOS und Android) [B]: „The objective of the Cut the Rope games is to feed candy to a
  little green creature named Om Nom while collecting stars.“ https://en.wikipedia.org/wiki/Cut_the_Rope – Dass man dort Seile
  per Wisch durchtrennt und die Süßigkeit pendelt, ist [A] (im Artikel nicht beschrieben). Nächster Verwandter.
  Abgrenzung: kein Pendeln, keine Echtzeit, keine Wischpräzision; eine Gerade trennt mehrere Fäden zugleich; Kern sind
  Gewichtsbilanz und Kaskade, gewertet gegen Par.
- **Holedown** [R]: Zielen, Loslassen, Blöcke fallen, wenn ihre Stützen fehlen (02 §2.10). Übernommen sind Geste und
  Statik-Idee, bewusst nicht Bälle mit Trefferzahlen (die übersättigte Ballz-Oberfläche).
- **Turing Tumble** (2017) [B]: Kugeln fallen durch Bauteile; ein „bit“ ändert seine Richtung, „such that the next ball goes to
  the other side“. https://en.wikipedia.org/wiki/Turing_Tumble – Verwandt: zustandsbehaftete Weichen in einer Kugelkaskade (unsere gekippten Wippen als Rampen).
- **Jenga** [A] (Statik als Spannung); die Mobiles von Alexander Calder [A] (Ästhetik).
- **Nicht suchbar gewesen:** Mobile-Rätsel mit Gleichgewichts-Mobiles und Schnittlinie. Nachzuholen: „cut thread balance mobile puzzle game“, „seesaw cascade puzzle mobile“.

**M. Hand & Verdeckung**

**Wo liegt die Hand, und was ist darunter?** – Der Daumen liegt im unteren Viertel auf einer reinen Wischfläche (Werkbank),
die nichts Spielrelevantes zeigt. Die Schere sitzt darüber, die Schnittlinie läuft vom Daumen weg nach oben und ist immer ganz
sichtbar. Die Schalen liegen bei etwa 70 % Bildhöhe, also über der Hand. Während der Kaskade ist der Finger schon gehoben.

```
+------------------------+
|  ====o=====  (Haken)   |
|     |     |            |   Mobile im
|  o==+==o  |            |   oberen Teil
|        o==+==o         |
|   [x1]   [x2]   [x3]   |   Schalen bei ~70 %
|            ^ Schere    |
|   ~~ Wischfläche ~~    |   <- Daumen
+------------------------+
```
- Geste: seitlich ziehen dreht die Linie (1 cm ≈ 8°) mit Einrasten in die Mitte jedes Winkelbereichs gleicher Fadenmenge;
  mindestens 1 cm nach oben öffnet die Schere; Loslassen bei offener Schere schneidet; zurück nach unten schließt sie wieder (Abbruch ohne Kosten).

**N. Dominante Strategie & ihre Kosten** – Welche Strategie dominiert, und was kostet sie?
- **„Topschnitt“** (obersten Faden kappen, alles fällt): Kosten: Alles fällt senkrecht dorthin, wo es hängt; die Schalen
  liegen absichtlich nicht unter den großen Lasten. Punkte bringt nur seitlicher Versatz durch Kippen und Rollen. Glas
  zerbricht. Der Generator verwirft Mobiles, bei denen der Topschnitt ≥ 50 % Par erreicht.
- **„Maximale Fäden“** (immer die Linie mit den meisten Fäden): Kosten: unkontrolliert wie der Topschnitt, und die Schnitte sind schnell weg.
- **„Kleinschnitte“** (nur unterste Fäden, je ein Gegenstand sicher in eine Schale): Kosten: höchstens drei Treffer pro Mobile, klar unter Par.
- **„Gierig pro Schnitt“** (immer die meisten Sofortpunkte): Kosten: verbraucht Gewichte, die später als Gegengewicht für die
  große Kaskade fehlen. M1 prüft, dass das spürbar ist.
- **Restrisiko [E]:** Erfahrene Spieler könnten ein festes Muster finden („immer zuerst das tiefste Gegengewicht“). M5 prüft die Vielfalt guter Eröffnungen.

**O. Bot-Spielbarkeit**
- **Zustand:** Fäden (Anker, Knoten, Last), Wippen (Drehpunkt, Neigung, Gegenstände je Seite), Gegenstände, Schalen, verbleibende Schnitte.
- **Aktionen:** Winkel von −75° bis +75° in 0,1°-Schritten, zusammengefasst zu Intervallen gleicher Fadenmenge (typisch 10–25), plus „Fertig“.
- **Profile:** `zufall` (gleichverteilt über Intervalle), `topschnitt`, `maxfaden`, `gierig` (max. Sofortpunkte), `planer`
  (vollständige Suche über alle verbleibenden Schnitte = Par), `planer_rauschen` (Planer mit Zielfehler σ = 3° ohne Einrasten),
  `planer_snap` (derselbe Fehler mit Einrasten).
- **Messgrößen:** Punkte/Par pro Mobile, Kaskadentiefe (Folgeereignisse je Schnitt), Anteil der Par-Lösungen mit ≥ 2 Kaskadenstufen,
  Zahl verschiedener erster Schnitte mit ≥ 90 % Par.
- **Abnahmekriterien (vor dem Test fixieren):**
  - M1: `gierig` ≤ 70 % von Par (Median). Sonst ist es kein Planungsspiel.
  - M2: `zufall` ≤ 35 % und `topschnitt` ≤ 50 % von Par.
  - M3: `planer_snap` ≥ 97 % von Par – Motorik spielt dann keine Rolle. `planer_rauschen` wird berichtet; liegt es unter 85 %, ist Einrasten Pflicht.
  - M4: In ≥ 60 % der Tagesmobiles enthält die Par-Lösung mindestens einen Schnitt mit ≥ 2 Kaskadenstufen.
  - M5: In ≥ 40 % der Mobiles erreichen mindestens zwei verschiedene erste Schnitte ≥ 90 % von Par.
  - M6: Zwölf Schnitte pro Tagesset bei 3–6 s inklusive Kaskade (Taktung am oberen Rand der Leitplanke, bewusst: jeder Schnitt wiegt schwer).
- **Billigster Menschentest:** fünf handgebaute Mobiles als Klickprototyp; gemessen wird, ob Testende den Ausgang eines Schnitts vorher richtig ansagen (Ziel ≥ 60 % nach dem Tutorial).

**P. Session-Budget** – Drei Schnitte pro Mobile (sichtbar als drei Scheren), vier Mobiles pro Tagesset. Ende: alle Schnitte
verbraucht oder „Fertig“. Erwartete Dauer 60–120 s inklusive Lesen. Tagesset aus dem Datum. Teilbar als Sternreihe:
„KIPPMOMENT · 22.10. · ★★★ ★★☆ ★★★ ★☆☆ · 41/48“.

---

## K15 · ECHOLOT

*Ruhig, zugbasiert · Kern-Eingabe: hinter das Ziel tippen (Versatz-Fadenkreuz, Loslassen setzt) · Bausteine: K10-Prinzip
„Wirkung hinter dem Ziel“, K02-Verhalten als Ressource, Aktionsbudget · Multitouch: keins*

**A. Arbeitstitel** – ECHOLOT

**B. Elevator Pitch** – Drei Wale irren im dunklen Meer zwischen Fischernetzen. Du siehst sie nicht: Jeder Sonar-Ping verrät,
wie weit sie entfernt sind, und schreckt sie zugleich auf – treib sie mit Schall in die sichere Bucht.

**C. Kernmechanik**
- **Spielfeld:** Sechseck-Raster 7 × 10. Oben eine Schutzbucht (3 Felder), der übrige obere Rand ist Riff. Sichtbar sind Netze
  (3–5 Felder) und Felsen. Unsichtbar sind drei Wale (A, B, C), jeder mit eigener Stimme, Farbe und Form seiner Spur.
- **Ping** (14 pro Meer, sichtbar als Batterie): Eine Sonarboje wird auf ein Feld gesetzt. Dann geschieht in fester Reihenfolge:
  1. **Echo:** Jeder Wal im Umkreis von 3 Feldern antwortet; für ihn erscheint ein Ring in seiner Farbe genau in seiner
     Entfernung (1, 2 oder 3). Wer nicht antwortet, ist weiter als 3 entfernt – auch das ist Information.
  2. **Schreck:** Jeder antwortende Wal schwimmt geradeaus vom Ping weg: 2 Felder bei Entfernung 1–2, 1 Feld bei Entfernung 3.
     Liegt er genau zwischen zwei Richtungen, weicht er im Uhrzeigersinn aus.
  3. **Hindernisse:** Felsen, Rand und andere Wale stoppen ihn davor. Ein Netz fängt ihn (verloren). Erreicht er die Bucht,
     ist er gerettet und taucht sichtbar auf.
- **Echospuren:** Das Spiel führt für jeden Wal die Menge aller Felder, auf denen er nach allen bisherigen Echos noch sein kann,
  und zeigt sie als glimmende Punkte. Jeder Schreck verschiebt diese Punkte nach derselben Regel wie den echten Wal. Die
  Buchführung übernimmt das Spiel, die Entscheidung trifft der Spieler: Wo pinge ich, damit möglichst alle möglichen Positionen
  eines Wals Richtung Bucht und keine ins Netz geschoben werden?
- **Ende:** alle Wale gerettet oder verloren, oder Batterie leer.
- **Wertung:** gerettet +100, im Netz −50; übrige Pings +10 je Ping, aber nur, wenn alle drei gerettet wurden.
- **Determinismus:** Nach dem Seed gibt es keinen Zufall. Startlagen, Netze und Felsen sind für alle Spieler eines Tages gleich.

**D. Die ersten 30 Sekunden**
- 0 s: Dunkles Wasser, oben die Bucht, ein Wal ausnahmsweise sichtbar. Hinweis: „Ping hinter den Wal“.
- 3 s: Der Finger setzt unten auf, das Fadenkreuz schwebt über der Kuppe; Loslassen unter dem Wal → Ringwelle, Walgesang, der Wal schwimmt zwei Felder nach oben.
- 8 s: Zweiter Ping → der Wal erreicht die Bucht, bläst eine Fontäne, ein Akkord erklingt, +100.
- 12 s: Ein zweiter Wal, diesmal unsichtbar, nur fernes Singen. Ping in der Mitte → ein grüner Ring, Punkte glimmen auf dem
  Ring und rücken danach sichtbar ein Feld nach außen: „Er ist geflohen – irgendwo hier.“
- 18 s: Ping von der Seite → der neue Ring schneidet die Punktwolke, es bleiben zwei Kandidaten. Links davon liegt ein Netz.
- 24 s: Ping von links unten schiebt beide Kandidaten nach rechts oben, weg vom Netz → der Wal taucht in der Bucht auf.
- 30 s: Das erste richtige Meer: drei Wale, 14 Pings.

**E. Core Gameplay Loop** – Echospuren lesen → abwägen: Information (fern pingen, sanft schieben) oder Treiben (nah pingen,
stark schieben) → Ping → Echo und Flucht beobachten → Spuren schrumpfen oder wandern → nächster Ping. Spannung: Jede
Information kostet Bewegung, und Bewegung unter Unsicherheit kann einen Wal ins Netz treiben.

**F. Hook** – Jeder Ping zeigt dir die Wale – und treibt sie weg. Du rettest sie nur mit Schall.

**G. Mastery**
- Von der Gefahrenseite pingen: Das schiebt alle Kandidaten vom Netz weg, auch ohne genaue Position.
- Felsen als Trichter: Schiebt man eine Punktwolke gegen eine Felsreihe, bleiben alle Kandidaten dort hängen – die Unsicherheit fällt in sich zusammen.
- Zwei Wale mit einem Ping so treffen, dass beide geradeaus Richtung Bucht fliehen.
- Stille nutzen: Ein Ping ohne Antwort löscht bis zu 37 Felder (am Rand weniger) aus allen Spuren.
- Ping-Ökonomie: früh weit pingen (1 Feld Schub, viel Information), spät nah (2 Felder Schub, wenn die Spur ≤ 2 Felder umfasst).
- Profi-Modus ohne Spuranzeige für Spieler, die selbst Buch führen wollen.

**H. Wiederspielwert**
- Tagesmeer (gleich für alle), unbegrenzte Übungsmeere.
- Varianten: „Strömung“ (Pfeilfelder versetzen Wale nach jedem Ping um 1), „Kalb“ (Mutter und Kalb fliehen gemeinsam),
  „Schiffsroute“ (ein Frachter kreuzt nach Fahrplan und schreckt selbst auf).
- Die 50. Runde ist interessant, weil Netze, Felsen und Startlagen jede Eröffnung verändern und es keine sichere
  Standarderöffnung gibt: Ein Ping in der Mitte liefert die meiste Information, schiebt aber alles zu Rand und Netzen.

**I. Technische Machbarkeit**
- Sechseck-Mathematik in Würfelkoordinaten; Entfernung und Schritt „geradeaus weg“ sind deterministische Formeln.
- Spuren als Bitmenge über 70 Felder pro Wal: Jedes Echo filtert, jeder Schreck transformiert die Menge.
- Keine Physik, keine Echtzeit, Zustand pro Ping speicherbar.
- Generator: Startlagen und Netze erzeugen, mit dem `planer`-Bot prüfen und verwerfen, wenn er im Median nicht alle drei Wale rettet.
- Graubox in 1–2 Tagen.

**J. Audiovisuelle Vision** – Tiefblauer Verlauf; der Ping als heller Ring mit Wasserverzerrung (Shader); Echospuren als
Leuchtplankton in Walfarbe und -form; Netze als dunkle Maschen-Silhouetten. Audio ist hier Spielinformation: Die
Echoverzögerung entspricht der Entfernung, jeder Wal singt in seiner Tonlage (prozedurale FM-Glissandi), mit Kopfhörern
links/rechts gepannt. Jede Rettung ergänzt einen Akkord, der mit drei Walen vollständig ist.

**K. Werbetauglichkeit** – Pause nach jedem Meer (40–90 s). Rewarded nur im Übungsmodus (z. B. „zusätzlicher Ping“), nie im Tagesmeer.

**L. Vergleichbare Spiele**
- **Hunt the Wumpus** (Gregory Yob, 1973) [B]: Höhlen in völliger Dunkelheit, Hinweise auf Gefahren in Nachbarhöhlen; ein
  aufgeschreckter Wumpus kann sich bewegen. Der Artikel nennt ältere Raster-Versteckspiele: „there were multiple games,
  including Hurkle and Mugwump, that had the player 'hide and seek' in a 10 by 10 grid.“ https://en.wikipedia.org/wiki/Hunt_the_Wumpus
  – Nächster Verwandter für „Sondieren kann das Ziel bewegen“; dort ist die Bewegung Zufall und Bedrohung, hier deterministisch und das eigentliche Werkzeug.
- **Black Box** (Eric Solomon, 1970er) [B]: Strahlen in ein Raster schicken, versteckte Atome aus „hit“, „reflection“ und
  „detour“ ableiten. https://en.wikipedia.org/wiki/Black_Box_(game)
- **Scotland Yard** (Ravensburger, 1983) [B]: versteckte Bewegung; die Position wird „at five specific times“ aufgedeckt.
  https://en.wikipedia.org/wiki/Scotland_Yard_(board_game)
- **Minesweeper, Schiffe versenken** [A]: Deduktion über Hinweise. **Dark Echo** (RAC7) [A, nicht verifiziert; Abruf ergab 404]: sichtbar gemachte Schallwellen, nur optisch verwandt.
- **Nicht suchbar gewesen:** Spiele, in denen Sondieren zugleich Information und deterministisches Treiben ist. Nachzuholen:
  „sonar ping puzzle push hidden whales“, „herding hidden targets deduction game“.

**M. Hand & Verdeckung**

**Wo liegt die Hand, und was ist darunter?** – Der Finger liegt unterhalb des Fadenkreuzes, also auf dem Wasser hinter dem
Ping – dort ist das, wovon man die Wale gerade wegtreibt, meist leeres Wasser. Die Wale fliehen nach oben in den sichtbaren
Bereich. Ringe und Spuren erscheinen erst nach dem Loslassen, wenn die Hand weg ist.

```
+------------------------+
| Pings oooooooooooooo   |
|    [ Bucht ]   Riff    |
|  .  .  .  .  .  .  .   |   Wale fliehen
|   .  .  o  o  .  .     |   vom Ping (+)
|  .  .  .  +  .  .  .   |   nach oben
|   .  .  .  |  .  .     |   Fadenkreuz 12 mm
|  .  .  ( Finger )  .   |   über der Kuppe
+------------------------+
```
- Felder etwa 9 mm, das Fadenkreuz rastet auf die Feldmitte; Loslassen außerhalb des Meeres bricht ab. Nur Tippen und kurzes Ziehen, keine Randwische.

**N. Dominante Strategie & ihre Kosten** – Welche Strategie dominiert, und was kostet sie?
- **„Besen“** (immer ganz unten unter der Spurwolke pingen und alles nach oben kehren): Kosten: Nur Wale genau über dem Ping
  fliehen gerade nach oben, alle anderen schräg – zu den Seitenrändern und in Netze, die der Generator genau dorthin legt. Aus
  den oberen Riff-Ecken kommen sie nur mit seitlichen Pings heraus, und dafür braucht man ihre Position.
- **„Erst scannen“** (Meer mit weit gestreuten Pings vermessen, dann treiben): Kosten: Jeder Scan-Ping schreckt auf, die Wale
  werden in unbekannte Richtungen verstreut, und die Batterie ist halb leer, bevor das Treiben beginnt.
- **„Nahschuss“** (immer direkt hinter den wahrscheinlichsten Ort): Kosten: Bei breiter Spur schiebt der Zwei-Felder-Schub die
  falschen Kandidaten quer, oft ins Netz.
- **Erwartung [E]:** Gut ist ein Wechsel aus fernem Ping von der Gefahrenseite und nahem Ping, sobald die Spur klein ist. E1–E5 prüfen das.
- **Restrisiko:** Ist das Ping-Budget zu großzügig, wird geduldiges Scannen risikolos. E6 kalibriert das Budget.

**O. Bot-Spielbarkeit**
- **Zustand:** wahre Walpositionen (nur für Simulation und `orakel`), Spurmengen je Wal (wie der Spieler sie sieht), Netze, Felsen, Bucht, Pings.
- **Aktionen:** Ping auf jedes freie Feld (≤ 70).
- **Motorik:** keine im engeren Sinn. Robustheit prüft `planer_fehltipp`: 5 % der Pings landen auf einem zufälligen Nachbarfeld.
- **Profile:** `zufall`, `besen`, `scanner` (größte erwartete Verkleinerung der Spuren), `treiber` (Nahschuss hinter die
  wahrscheinlichste Position des buchtnächsten Wals), `planer` (Erwartungswert über die Spurmengen, Suchtiefe 2), `orakel`
  (kennt die Positionen, obere Schranke), `planer_fehltipp`.
- **Messgrößen:** gerettete Wale, Netzverluste, verbrauchte Pings, Punkte, Informationswert (`orakel` minus `planer`).
- **Abnahmekriterien (vor dem Test fixieren):**
  - E1: `planer` ≥ 1,5 × `besen` und ≥ 1,3 × `treiber` (Median).
  - E2: `zufall` rettet im Median höchstens 1 Wal.
  - E3: `orakel` liegt 15–50 % über `planer`. Darunter ist Information egal, darüber ist das Spiel Raten.
  - E4: `planer_fehltipp` verliert ≤ 10 % gegenüber `planer`.
  - E5: Mindestens zwei verschiedene Eröffnungsfelder liegen ≤ 10 % unter der besten Eröffnung (keine Pflicht-Eröffnung).
  - E6: Budget so kalibrieren, dass `planer` im Median alle drei Wale mit 2–4 Pings Rest rettet; 8–14 Entscheidungen bei 3–6 s.
- **Billigster Menschentest:** Papier-Sechseckraster, eine Person spielt „das Meer“ nach Regelblatt; nach drei Meeren erklären die Testenden die Schreckregel in eigenen Worten (t2 aus dem Playtest-Protokoll).

**P. Session-Budget** – 14 Pings als sichtbare Batterie. Ende: alle Wale entschieden oder Batterie leer. Erwartete Dauer
40–90 s. Tagesmeer aus dem Datum. Teilbar: „ECHOLOT · 22.10. · 3/3 gerettet · 3 Pings übrig · 0 im Netz“ plus ein
7 × 10-Raster der eigenen Ping-Punkte (verrät keine Walpositionen).

---

## K16 · LICHTUNG

*Ruhig, zugbasiert · Kern-Eingabe: relativ ziehen (Richtung und Stärke), Loslassen legt fest · Bausteine: Arena-Rand als
Ressource (Windowkill), Dehnen als einziges Verb (Stretchmancer) · Multitouch: optional, gleichwertig zur Ein-Finger-Geste*

**A. Arbeitstitel** – LICHTUNG

**B. Elevator Pitch** – Dein Lagerfeuer wirft einen Lichtkreis mit fester Fläche in den Nachtwald. Zieh ihn wie Teig dorthin,
wo Pilze, Holz oder neugierige Schattenwichte sind – auf der anderen Seite wird es dafür dunkel. Halte durch bis zum Morgen.

**C. Kernmechanik**
- **Spielfeld:** Draufsicht, das Feuer bei etwa 40 % Bildhöhe, ein Waldkreis mit Radius 9 Ringen. Das Licht ist eine weiche
  Form aus 12 Speichen (alle 30°), jede mit Länge 1–7 Ringen.
- **Flächenregel:** Die Lichtfläche (Summe der Speichenquadrate) entspricht der Glut des Feuers. Start: alle Speichen 3, Fläche 108.
- **Ein Zug = eine Geste:** irgendwo aufsetzen, in eine Richtung ziehen (12 Richtungen, 3 Stärken je nach Zuglänge),
  loslassen. Die Speiche in Zugrichtung wächst um die Stärke, bei Stärke 2–3 ihre Nachbarn um 1. Dieselbe Fläche wird auf der
  Gegenseite abgezogen; ist dort nichts mehr zu holen (Länge 1), von den nächstliegenden Speichen. Beim Ziehen zeigt ein Umriss
  die neue Form. Kurzes Tippen = „halten“ (Zug ohne Formänderung).
- **Nach jedem Zug**, in dieser Reihenfolge:
  1. **Ernte:** Was im Licht liegt, wird eingesammelt: Holz (+15 Fläche, gleichmäßig verteilt), Pilze und Beeren (1–3 Punkte, je weiter draußen, desto mehr).
  2. **Schattenwichte:** Sie kommen in Wellen nach festem Fahrplan; ihre leuchtenden Augen sind immer sichtbar, auch im
     Dunkeln. Jeder rückt pro Zug einen Ring auf das Feuer zu. Steht er im Licht, quiekt er, springt drei Ringe zurück und
     schmollt einen Zug. Erreicht er das Feuer, stiehlt er Glut (−10 Fläche) und verschwindet.
  3. **Herunterbrennen:** −3 Fläche pro Zug, gleichmäßig über alle Speichen.
- **Sicht:** Gegenstände bis 2 Ringe außerhalb des Lichts sind als Schemen sichtbar (Dämmerzone), weiter draußen nicht. Ein
  Kompassring ums Feuer zeigt, aus welchen Richtungen Augen kommen.
- **Ende:** Morgengrauen nach 24 Zügen (Himmel und Sonnenrand zeigen den Fortschritt) oder die Glut sinkt unter 12, also unter die Fläche von zwölf Speichen der Länge 1 (Feuer aus).
- **Wertung:** gesammelte Punkte; Restglut / 10 als Gleichstandsbrecher.
- **Optionales Spreizen:** Zwei Finger auseinander = symmetrischer Zug in zwei Gegenrichtungen (Ellipse). Dieselbe Aktion gibt
  es einhändig per Doppeltipp und Ziehen (wie der Ein-Finger-Zoom in Kartenapps). Zwei Hände bringen keinen Vorteil.

**D. Die ersten 30 Sekunden** (Tutorialnacht mit 8 Zügen)
- 0 s: Nacht, Knistern, ein runder Lichtkreis. Knapp außerhalb glimmt ein Pilz-Schemen; eine Geisterhand zieht in seine Richtung.
- 3 s: Der Spieler zieht → der Umriss dehnt sich zum Pilz, die Gegenseite zieht sich sichtbar zurück. Loslassen → „plopp“, +1.
- 8 s: Links tauchen zwei Augen auf und rücken näher. Hinweis: „Licht vertreibt“.
- 12 s: Zug nach links → der Wicht quiekt und springt zurück.
- 17 s: Rechts oben ein Holzstapel. Zug dorthin → das Feuer lodert auf, der ganze Kreis wächst.
- 22 s: Jetzt gleichzeitig: Beeren rechts, ein Wicht links unten. Die erste echte Abwägung.
- 28–30 s: Morgenrot, Vögel, Ergebnis mit Punkten und Restglut.

**E. Core Gameplay Loop** – Augen und Schemen lesen → Richtung und Stärke wählen → Vorschau prüfen (was wird dunkel?) →
loslassen → Ernte, Schreck, Herunterbrennen → neue Lage. Spannung: Das Licht reicht nie für alles; jede Ausdehnung reißt woanders eine Lücke.

**F. Hook** – Dein Licht ist dein Spielfeld – und es reicht nie für alles. Zieh es dorthin, wo du es brauchst; woanders wird es dunkel.

**G. Mastery**
- Flächeneffizienz: Nachbarspeichen mitziehen, um ganze Gruppen auf einmal zu ernten.
- Doppelzüge: ein Zug, der zugleich erntet und einen Wicht verscheucht.
- Schmollzüge der Wichte als Fenster für weite Ausflüge nutzen.
- Holz vor einer Welle holen, nicht danach; die Dämmerzone gezielt aufdecken, um Holz zu finden.
- Das Herunterbrennen einplanen: Späte Züge haben weniger Fläche, also früh weit, spät dicht.

**H. Wiederspielwert**
- Tageswald (Holz, Pilze, Wichtel-Fahrplan aus dem Seed), unbegrenzte Übungswälder.
- Varianten: „Neumond“ (keine Dämmerzone), „Sturmnacht“ (−5 pro Zug), „Glühwürmchen“ (ein Schwarm, der vom Licht angezogen wird
  und dort, wo er schwebt, die Fläche um 10 % erhöht – K02-Verhalten als Ressource).
- Die 50. Nacht ist interessant, weil Fahrplan und Lage der Ressourcen jedes Mal andere Zielkonflikte erzeugen.

**I. Technische Machbarkeit**
- Zwölf Speichen und der Flächenausgleich sind wenige Zeilen Code; die Form ist ein geglätteter Polygonzug (Catmull-Rom) mit Radialverlauf-Shader.
- Wichte und Gegenstände sitzen auf Polarkoordinaten (Ring × Speiche); „im Licht“ ist ein Vergleich Ring ≤ Speichenlänge.
- Zugbasiert, keine Physik-Engine, Zustand pro Zug speicherbar. Graubox in 1–2 Tagen.

**J. Audiovisuelle Vision** – Nachtwald aus prozeduralen Baumsilhouetten, warmes Licht mit weichem Rand. Beim Ziehen verformt
sich das Licht zäh wie Honig (Shader). Die Wichte sind rundliche Rußwesen mit großen Augen, die im Licht „pfft“ machen. Audio:
Knistern, dessen Lautstärke der Glut folgt, Eulen und Grillen, Holzglocken bei der Ernte, im Morgengrauen ein Vogelchor.

**K. Werbetauglichkeit** – Pause nach jeder Nacht (50–100 s). Rewarded nur im Übungsmodus (z. B. „ein Extra-Holzscheit“).

**L. Vergleichbare Spiele**
- **Windowkill** [R]: Das Fenster schrumpft, man schießt die Ränder zurück; „Arena als Lebensbalken“ (02 §2.7). Abgrenzung:
  Hier wird der Rand nicht zurückgedrängt, sondern bei fester Fläche umgeformt; die Arena ist zugleich Ressource, Abwehr und Sicht.
- **Stretchmancer** [R]: Welt dehnen und stauchen als einziges Verb (02 §2.6).
- **Don't Starve** (Klei, 2013; Android 2016) [B]: „A player must have a light source or night vision to prevent Charlie from
  attacking.“ https://en.wikipedia.org/wiki/Don%27t_Starve – verwandt im Motiv „Licht als Überlebensbedingung“, dort Survival über Stunden.
- **Missile Command** [A]: Verteidigung gegen Bedrohungen aus mehreren Richtungen.
- **Nicht suchbar gewesen:** Spiele mit flächenerhaltendem Formen der Arena als einzigem Verb. Nachzuholen:
  „area conserving arena shape game“, „campfire light radius defense puzzle“.

**M. Hand & Verdeckung**

**Wo liegt die Hand, und was ist darunter?** – Der Daumen setzt im unteren Drittel auf dem Waldboden an, der außerhalb des
Spielkreises liegt; die Zugbewegung ist relativ und kurz (1–3 cm). Feuer, Licht und der ganze Waldrand liegen darüber. Unter
der Hand ist nur Dekoration; der Kompassring ums Feuer zeigt zusätzlich alle anrückenden Augen.

```
+------------------------+
| Zug 7/24   Glut ||||   |
|    .  . o o  .  .      |   o o = Augen
|   .  (~~~~~~~)  .      |
|   . (   FEUER   ) .    |   Lichtform
|   .  (~~~~~~~~~)       |
|    .  .  .  .  .       |   Waldrand bei ~62 %
|   ~~ Waldboden ~~      |   <- Daumen zieht hier
+------------------------+
```
- Züge, die näher als 48 dp am Unterrand beginnen, werden ignoriert (Home-Geste); kein Wisch vom Seitenrand nötig.

**N. Dominante Strategie & ihre Kosten** – Welche Strategie dominiert, und was kostet sie?
- **„Kreis halten“** (nie ziehen): Kosten: keine Ernte; ohne Holz sinkt die Glut in 24 Zügen auf rund ein Drittel; Punkte nahe null.
- **„Gierstrecke“** (immer maximal zum wertvollsten Pilz): Kosten: Die Gegenseite fällt auf Länge 1; zwei Wichte erreichen
  nacheinander das Feuer (−20 Fläche), die Nacht endet früh im Dunkeln.
- **„Holz zuerst“:** Kosten: Züge; Holz liegt (Generator) oft auf Wichtel-Routen, und frühe Glut brennt ohnehin wieder herunter.
- **„Verteidiger“** (immer zum nächsten Wicht): Kosten: kaum Punkte; verscheuchte Wichte kommen nach dem Schmollen wieder.
- **Erwartung [E]:** Doppelzüge (Ernte plus Schreck) schlagen jede Einzelregel; dadurch entsteht ständig Abwägung statt einer Formel.
- **Restrisiko:** Wenn ein Wicht-Fahrplan zu regelmäßig ist, lernt man ihn auswendig. L4 prüft, ob eine Heuristik reicht.

**O. Bot-Spielbarkeit**
- **Zustand:** Speichenlängen, Fläche, Gegenstände (Polarposition, sichtbar ja/nein), Wichte (Position, Schmollen), Zugnummer, sichtbarer Teil des Fahrplans.
- **Aktionen:** 12 Richtungen × 3 Stärken + 6 Achsen × 3 Stärken (symmetrisch) + halten = 55.
- **Motorik:** keine; Richtungen und Stärken rasten ein. Unterschiede entstehen nur aus Entscheidungen.
- **Profile:** `halten`, `zufall`, `gierig` (max. Sofortpunkte), `holz` (Fläche zuerst), `verteidiger`, `planer` (Beam-Suche Tiefe 3 über das Sichtbare), `orakel` (sieht alle Gegenstände).
- **Messgrößen:** Punkte, Diebstähle, Anteil „Feuer aus vor dem Morgen“, Restglut, Anteil Doppelzüge.
- **Abnahmekriterien (vor dem Test fixieren):**
  - L1: `planer` ≥ 1,4 × das beste Einzelheuristik-Profil (Median).
  - L2: `gierig` verliert in ≥ 30 % der Nächte das Feuer vor dem Morgen oder liegt ≥ 30 % unter `planer`.
  - L3: `halten` ≤ 10 % von `planer`.
  - L4: Die zwei besten Einzelheuristiken liegen ≤ 15 % auseinander (keine Heuristik dominiert).
  - L5: `orakel` ≤ 1,25 × `planer` (Dunkelheit soll Spannung erzeugen, keine Lotterie).
  - L6: 24 Züge bei 2–4 s → 50–100 s.
- **Billigster Menschentest:** Graubox mit Kreis, Augen und Pilzen ohne Grafik; gemessen wird, ob Testende vor dem Loslassen vorhersagen, welcher Wicht durchkommt.

**P. Session-Budget** – 24 Züge bis zum Morgengrauen, sichtbar als Himmelsfarbe und Zugzähler; die Glut ist die zweite
sichtbare Grenze (Feuer aus). Erwartete Dauer 50–100 s. Tageswald aus dem Datum. Teilbar: „LICHTUNG · 22.10. · 34 Punkte ·
Feuer bis zum Morgen · 2 Diebe“.

---

## K17 · FÄHRMANN

*Takt 2 s · Kern-Eingabe: zwei große Daumenzonen mit Akkord, einhändig per Mittelstreifen · Bausteine: Zonen + Akkord (Data Wing),
Trägheit als Planungsproblem (Racetrack), Sonnenuntergang als Grenze (Tiny Wings) · Multitouch: Akkord optional, gleichwertig*

**A. Arbeitstitel** – FÄHRMANN

**B. Elevator Pitch** – Ein Ruderboot, zwei Ruder, ein Sonnenuntergang. Im Takt entscheidest du links, rechts oder beide – und
bringst so viele Fahrgäste wie möglich über den See, bevor es dunkel wird.

**C. Kernmechanik**
- **See:** Sechseck-Raster 8 × 12 im oberen Bildteil, sechs Anleger am Ufer, Inseln und Felsen, ein sichtbares Strömungsband vom Zulauf zum Abfluss.
- **Takt:** Alle 2,0 s ein Ruderschlag (pulsierender Ring, Plätschern). Es zählt die letzte Eingabe im laufenden Takt; ein
  Pfeil am Boot zeigt die vorgemerkte Wahl schon vor dem Schlag.
  - Linke Zone: Boot dreht 60° nach links, Tempo wird 1.
  - Rechte Zone: 60° nach rechts, Tempo wird 1.
  - Beide Zonen gleichzeitig (Akkord) oder Mittelstreifen: Kraftschlag geradeaus, Tempo +1 (höchstens 2).
  - Keine Eingabe: gleiten, Tempo −1 (bei 0 steht das Boot).
- **Bewegung pro Takt:** so viele Felder wie das Tempo in Fahrtrichtung, danach versetzt die Strömung um ein Feld. Felsen stoppen (Tempo 0).
- **Fahrgäste:** erscheinen nach festem Fahrplan an Anlegern, mit einem Fähnchen in Farbe und Form ihres Ziels und einem
  Münzstapel. Einsteigen: den Takt neben dem Anleger mit Tempo 0 beenden; Platz für zwei. Abliefern genauso am Ziel. Der
  Münzstapel schrumpft alle drei Takte um eine Münze, solange der Gast wartet oder an Bord ist.
- **Ende:** Sonnenuntergang nach 45 Takten (90 s, sichtbar sinkende Sonne, konstantes Tempo). Wer dann noch an Bord ist, zahlt nicht.
- **Wertung:** Summe der Fahrpreise.
- **Einhändig:** Der Mittelstreifen ersetzt den Akkord vollständig. Der Akkord ist nur die natürlichere Geste für Zweihänder
  („mit beiden Armen ziehen“), keine Mehrleistung.

**D. Die ersten 30 Sekunden**
- 0 s: Das Boot liegt am Anleger, gegenüber wartet ein Gast mit rotem Fähnchen am roten Steg. Zwei Daumensymbole und der Mittelstreifen leuchten im Takt.
- 2 s: Tippen in die Mitte → Kraftschlag, das Boot gleitet los, Plätschern auf dem Takt.
- 6 s: Links tippen → das Boot schwenkt; der Pfeil zeigt die Wahl, bevor der Schlag kommt.
- 10 s: Nahe am Steg: Hinweis „Nichts tun = ausgleiten“. Ein Takt ohne Eingabe → das Boot steht, der Gast steigt ein, Glocke.
- 16 s: Auf dem Rückweg erfasst das Strömungsband das Boot und trägt es ein Feld weiter. Aha: gratis Fahrt.
- 22 s: Abliefern → Münzen klimpern, die erste Instrumentalspur des Abendlieds setzt ein.
- 26–30 s: Zwei neue Gäste an verschiedenen Stegen; erste Routenentscheidung.

**E. Core Gameplay Loop** – Fahrplan lesen → Route wählen (welche Gäste, welche Reihenfolge, welche Strömung) → im Takt
steuern und rechtzeitig ausgleiten → einsteigen, abliefern → Münzen, neue Gäste → Route neu planen. Zwei Ebenen: alle 2 s ein
Schlag, alle 10–15 s eine Routenentscheidung.

**F. Hook** – Du ruderst nicht schneller, sondern klüger: Jeder Schlag ist eine Entscheidung, und der Sonnenuntergang wartet nicht.

**G. Mastery**
- Bremsweg planen: bei Tempo 2 zwei Takte vorher ausgleiten.
- Das Strömungsband als Förderband nutzen, gegen den Strom nur mit Kraftschlägen.
- Zwei Gäste kombinieren, deren Ziele auf einer Linie liegen.
- Drehungen dorthin legen, wo der Tempoverlust nicht schadet.
- Den Fahrplan vorausdenken: Wer erscheint in fünf Takten wo?

**H. Wiederspielwert**
- Tagessee (Karte und Fahrplan aus dem Seed), unbegrenzte Übungsseen.
- Varianten: „Nebel“ (Anleger erst aus der Nähe sichtbar), „Hochwasser“ (Strömung versetzt um 2), „Markttag“ (viele Gäste, wenig Platz).
- Die 50. Fahrt ist interessant, weil Fahrplan und Strömung jedes Mal eine andere Tour verlangen – ein kleines Rundreiseproblem
  mit Kapazität 2 und Trägheit.

**I. Technische Machbarkeit**
- Sechseck-Raster und eine Zustandsmaschine pro Takt (Feld, Richtung, Tempo); Fahrplan aus Seed.
- Bot = A* im Zustandsraum (96 Felder × 6 Richtungen × 3 Tempi) plus Tourplanung über wenige Gäste.
- Eingabe: zwei Zonen plus Mittelstreifen, Akkord = beide Zonen im selben Moment berührt (Toleranz 150 ms); Pointer-Abbrüche behandeln (03 §3.4 Punkt 6).
- Graubox in 2 Tagen.

**J. Audiovisuelle Vision** – See in Gouache-Farben; der Himmel verläuft vom Nachmittag ins Abendrot, an den Stegen gehen
nach und nach Laternen an. Die Ruder sind unten im Bild als große Griffe zu sehen und bewegen sich mit dem Daumen
(Verkörperung ohne Verdeckung). Audio: Der Takt ist Musik – Plätschern auf der Eins, Knarzen auf der Drei; jeder abgelieferte
Gast fügt dem Abendlied ein Instrument hinzu (Akkordeon, Gitarre, Pfeife). Haptik: kurzer Puls auf jedem Schlag.

**K. Werbetauglichkeit** – Pause nach Sonnenuntergang (90 s). Rewarded nur im Übungsmodus (z. B. „längerer Abend“), im Tagessee keine Vorteile.

**L. Vergleichbare Spiele**
- **Data Wing** [R]: links/rechts halten lenkt, beide halten bremst (03 §2.2.3) – Vorbild für Zonen plus Akkord als dritte Aktion.
- **Racetrack** (Papier und Bleistift, 1973 von Martin Gardner veröffentlicht) [B]: „the eight neighbour rule allows changing each
  coordinate of the vector by ±1“; der Artikel nennt Triplanetary mit ähnlichen Regeln auf Sechseckfeldern.
  https://en.wikipedia.org/wiki/Racetrack_(game) – Vorbild für Trägheit als Planungsaufgabe statt Reflex.
- **Crazy Taxi** [A]: Abholen und Abliefern unter Zeitdruck. **Mini Metro** [R]: Routen als ruhige Echtzeitentscheidung (03 §2.2.14).
- **Nicht suchbar gewesen:** Ruder- oder Fährspiele auf Mobile mit Taktsteuerung. Nachzuholen: „rowing boat game left right oar tap mobile“,
  „ferry passenger delivery boat game“.

**M. Hand & Verdeckung**

**Wo liegt die Hand, und was ist darunter?** – Die Daumen liegen in den beiden großen Ruderzonen im unteren Drittel; darunter
sind nur die gezeichneten Rudergriffe. Der ganze See liegt darüber, das Boot kann nie unter die Hand fahren. Einhändig tippt
ein Daumen links, rechts oder in den Mittelstreifen.

```
+------------------------+
|  Sonne -----o-----     |
|  [A]   ~~~~~~   [B]    |   See 8 x 12
|      .   b   .  [C]    |   b = Boot
|  [D]   ~~~~~~   .      |   ~ = Strömung
|  [E]          [F]      |
|------------------------|
| LINKS | MITTE | RECHTS |   <- Daumen
+------------------------+
```
- Nur Tippen, keine Wische → keine Konflikte mit Zurück- oder Home-Geste; die Zonen beginnen 16 dp über der Gestenleiste.

**N. Dominante Strategie & ihre Kosten** – Welche Strategie dominiert, und was kostet sie?
- **„Immer Kraftschlag“:** Kosten: Bei Tempo 2 braucht man zwei Takte zum Ausgleiten und überfährt Stege; jede Drehung setzt
  das Tempo auf 1; Felsstöße kosten einen Takt.
- **„Nächster Gast zuerst“:** Kosten: ignoriert Strömung und Fahrplan; zwei Gäste mit entgegengesetzten Zielen blockieren den Platz, die Münzstapel schrumpfen.
- **„Nur mit der Strömung“:** Kosten: Das Band führt nur in eine Richtung; Gäste am anderen Ufer bleiben stehen.
- **„Vorsichtig“** (nie schneller als 1): Kosten: zu langsam für mehr als 5–6 Fahrten.
- **Erwartung [E]:** Die Tourplanung (Reihenfolge, Paare, Strömung) schlägt jede reine Fahrweise. F1 und F4 prüfen das.
- **Restrisiko:** Der Schlag-Takt kann sich wie Fleißarbeit anfühlen. Wenn Testende die Routenebene nicht bemerken, ist das Konzept gescheitert (Menschentest unten).

**O. Bot-Spielbarkeit**
- **Zustand:** Boot (Feld, Richtung, Tempo), Gäste (Ort, Ziel, Münzen), Fahrplan, Takt.
- **Aktionen:** vier pro Takt (links, rechts, Kraftschlag, gleiten).
- **Motorik und Reaktion:** keine Präzision; jede Eingabe hat ein Fenster von 2 s. `planer_spaet` entscheidet erst in den letzten
  0,4 s des Takts und zeigt, dass Reaktionszeit keine Rolle spielt; `planer_fehler` gibt in 5 % der Takte die falsche Eingabe.
- **Profile:** `zufall`, `gierig` (nächstes Ziel, kürzester A*-Weg), `vollgas`, `vorsichtig`, `planer` (Tourplanung über die
  nächsten drei Ziele, A* mit Strömung und Bremsweg), `planer_spaet`, `planer_fehler`.
- **Messgrößen:** Münzen, Fahrten, Leertakte, Felsstöße, Anteil gepaarter Fahrten.
- **Abnahmekriterien (vor dem Test fixieren):**
  - F1: `planer` ≥ 1,5 × `gierig` (Median).
  - F2: `zufall` ≤ 15 % von `planer`.
  - F3: `planer_fehler` ≥ 85 % von `planer`; `planer_spaet` liegt innerhalb ± 2 % von `planer`.
  - F4: Ein Planer mit Höchsttempo 1 und einer mit Höchsttempo 2 liegen ≤ 15 % auseinander – Tempo ist Stilfrage, nicht Pflicht.
  - F5: 6–12 Fahrten pro Abend bei `planer`.
- **Billigster Menschentest:** Graubox, 5 Personen × 3 Abende; nach jedem Abend fragen „Warum hast du diesen Gast zuerst geholt?“ – Ziel: ≥ 3 von 5 nennen einen Routengrund.

**P. Session-Budget** – 45 Takte bis Sonnenuntergang: 90 s mit festem Takt, sichtbarer Sonne und ohne Beschleunigung. Ende =
Sonnenuntergang. Tagessee aus dem Datum. Teilbar: „FÄHRMANN · 22.10. · 9 Fahrten · 128 Taler“.

---

## K18 · GEGENFEUER

*Echtzeit mit Ticks, Zeitlupe beim Zielen · Kern-Eingabe: Versatz-Fadenkreuz, Loslassen setzt · Bausteine: K11-Zeitblase (als
Zielhilfe), vollständig telegrafierte Bedrohung (Into the Breach, Hoplite), Werkzeugbudget · Multitouch: keins*

**A. Arbeitstitel** – GEGENFEUER

**B. Elevator Pitch** – Ein Blitz, ein Funke, Wind von Norden – unten im Tal stehen sechs Hütten. Mit ein paar Schneisen, einem
Löschflug und dem riskantesten Werkzeug der Feuerwehr bändigst du den Brand: Feuer gegen Feuer.

**C. Kernmechanik**
- **Tal:** Raster 8 × 12. Felder: Gras (zündet bei Hitze 1, brennt 1 Tick), Busch (2 / 2), Wald (3 / 3), Hütte (2 / 2; brennt ab =
  verloren), Fels, Wasser und Weg brennen nicht.
- **Ausbreitung (deterministisch, Tick = 1,0 s):** Jedes brennende Feld gibt seinen vier Nachbarn +1 Hitze, dem Nachbarn in
  Windrichtung +1 zusätzlich. Ohne brennenden Nachbarn sinkt Hitze um 1 pro Tick. Bei Starkwind gibt Wald zusätzlich +1 an das
  Feld zwei Schritte in Windrichtung (Funkenflug: einspurige Schneisen werden übersprungen).
- **Telegrafie:** Felder, die im nächsten Tick zünden, glühen orange; Hitze färbt Felder warm. Oben zeigt ein Windfahrplan
  angekündigte Drehungen („Ost in 6 Ticks“). Nichts passiert ohne Vorwarnung.
- **Werkzeuge** (Budget pro Brand, unten in der Leiste):
  - **Schneise ×4:** 1 × 3 Felder werden zu Weg; die Ausrichtung folgt der Hauptrichtung der Ziehbewegung (waagerecht/senkrecht).
  - **Gegenfeuer ×3:** 1 × 3 Felder brennen sofort an und folgen den normalen Regeln. Angelegt an Schneise oder Weg kann es nur
    gegen den Wind kriechen und frisst dem Hauptfeuer das Futter weg. Frei gelegt läuft es mit dem Wind – womöglich auf die Hütten zu.
  - **Löschflug ×2:** 3 × 3 Felder sind 8 Ticks lang nass (keine Hitze, Brände erlöschen). Das Flugzeug kommt mit 2 Ticks Verzögerung, sein Schatten zeigt das Ziel.
- **Fokus (K11-Zeitblase als Zielhilfe):** Solange der Finger zielt, läuft die Zeit mit 25 %. Fokus ist ein sichtbarer Vorrat von
  12 s pro Brand; ist er leer, läuft die Zeit beim Zielen normal.
- **Ende:** Der Brand erlischt, wenn nichts mehr brennt – er frisst sich immer aus. Doppeltippen = Zeitraffer, wenn nichts mehr zu tun ist.
- **Wertung:** gerettete Hütten × 100 + unverbrannte Wald- und Buschfelder × 2.

**D. Die ersten 30 Sekunden** (Tutorialtal)
- 0 s: Kleines Tal, oben schlägt ein Blitz ein, Gras fängt Feuer; Wind nach Süden; quer durch die Mitte ein Weg, darunter eine Hütte.
- 3 s: Hinweis „Ziehen, zielen, loslassen“. Der Spieler legt eine Schneise zwischen Feuer und Hütte → die Glutvorschau endet an der Schneise.
- 9 s: Der Windfahrplan kündigt Ost an; die Vorschau zeigt, dass das Feuer um das Schneisenende herumlaufen wird.
- 13 s: Hinweis „Gegenfeuer an den Weg legen“ → drei Felder oberhalb des Wegs brennen. Über den Weg können sie nicht, also
  kriechen sie dem Hauptfeuer entgegen; ein schwarzer Streifen entsteht.
- 20 s: Die Hauptfront erreicht den Streifen, findet nichts mehr zu brennen und erlischt dort. Großer Aha-Moment, die Musik öffnet sich.
- 25 s: Ein Glutnest springt über die Schneise; Löschflug, Schatten, Wasser.
- 30 s: Brand aus, die Hütte steht, ihr Fenster leuchtet auf.

**E. Core Gameplay Loop** – Front, Glutvorschau und Windfahrplan lesen → Werkzeug wählen → zielen (Zeitlupe) → loslassen →
Front reagiert → neu lesen. Spannung aus drei Quellen: wenige Werkzeuge, die vorrückende Front und das Risiko, dass das eigene Gegenfeuer zur zweiten Front wird.

**F. Hook** – Feuer mit Feuer bekämpfen: Der beste Löscher ist ein zweites Feuer am richtigen Ort.

**G. Mastery**
- Gegenfeuer an Wegen, Bächen und eigenen Schneisen ankern.
- Windwechsel vorausnehmen: Schneisen dorthin, wo die Front nach der Drehung hinläuft.
- Funkenflug mit zweispurigen Schneisen kontern.
- Den Löschflug wegen seiner Verzögerung vorhalten statt hinterherwerfen.
- Hüttengruppen priorisieren, wenn nicht alle zu retten sind; Fokus für die kritischen Sekunden sparen.

**H. Wiederspielwert**
- Tagestal (Gelände, Blitzort, Windfahrplan aus dem Seed), unbegrenzte Übungstäler.
- Varianten: „Trockenzeit“ (Busch zündet bei 1), „Sturmtag“ (durchgehend Starkwind), „Zwei Blitze“.
- Die 50. Runde ist interessant, weil jeder Windfahrplan das Gegenfeuer anders riskant macht und das Gelände (Wege, Bäche) die
  möglichen Ankerpunkte bestimmt.

**I. Technische Machbarkeit**
- Zellularer Automat auf 96 Feldern (trivial), Werkzeuge als Feldänderungen, Zeitskala für den Fokus.
- Darstellung: Kacheln und Partikel; Rauch, der mit dem Wind treibt, zeigt den Wind auch ohne Pfeil.
- Bot: Rollout-Suche bis zum Brandende (deterministisch, ein ganzer Brand < 120 Ticks) – schnell genug für viele Kandidaten.
- Graubox in 2 Tagen.

**J. Audiovisuelle Vision** – Flache, warme Landschaftskacheln (Grüntöne je Brennstoff), Feuer als animiertes Rauschen mit
Funken, verbrannte Felder dunkel mit verglimmender Glut. Beim Zielen wird das Bild entsättigt und langsamer (Fokus). Audio:
Wind, Knistern, dessen Dichte der Zahl brennender Felder folgt, Propellerbrummen beim Löschflug. Erlischt das Feuer, spielt ein
ruhiges Klavier, und die Fenster der geretteten Hütten gehen an.

**K. Werbetauglichkeit** – Pause nach jedem Brand (45–120 s). Rewarded nur im Übungsmodus (z. B. „zusätzlicher Löschflug“), nie im Tagestal.

**L. Vergleichbare Spiele**
- **Into the Breach** (Subset Games, 2018; iOS und Android 2022 über Netflix) [B]: „The player is shown the direction of the Vek
  unit's intended attack.“ Schieben ist ein Hauptwerkzeug. https://en.wikipedia.org/wiki/Into_the_Breach – Vorbild für vollständig
  telegrafierte, deterministische Bedrohung (unsere Glutvorschau); dort rundenbasierte Taktik mit Einheiten.
- **Forest-fire model** (Drossel & Schwabl, 1992) [B]: zellularer Automat, „A tree will burn if at least one neighbor is
  burning“, dort mit Zufallswahrscheinlichkeiten, hier ohne. https://en.wikipedia.org/wiki/Forest-fire_model
- **Gegenfeuer in der Praxis** [B]: „Back burning or backfiring is also done to stop a wildfire that is already in progress“;
  es heißt, Vegetation so anzuzünden, „that it has to burn against the prevailing wind“; „Firebreaks are also used as an anchor
  point to start a line of fires“. https://en.wikipedia.org/wiki/Controlled_burn – Die Kernregel des Verbs stammt aus der echten Brandbekämpfung.
- **„Firefighter problem“** der Graphentheorie [A; Abruf unter diesem Titel ergab 404]: Feuer breitet sich pro Schritt aus, man
  schützt pro Schritt Knoten – die rundenbasierte Mathematik-Variante der Eindämmung.
- **Nicht suchbar gewesen:** Waldbrand-Strategiespiele auf Mobile (vermutlich gibt es Hypercasual-„Löschen“-Spiele [E]).
  Nachzuholen: „wildfire containment strategy mobile backfire firebreak“, „forest fire puzzle game wind cellular“.

**M. Hand & Verdeckung**

**Wo liegt die Hand, und was ist darunter?** – Der Finger liegt unter dem Fadenkreuz, also auf der Werkzeugleiste bzw. über den
Hütten im unteren Drittel – auf dem, was man schützt und was sich nicht bewegt. Die Front kommt von oben und liegt über dem
Fadenkreuz im Blick. Beim Zielen läuft die Zeit mit 25 %, damit auch kurzes Verdecken nichts kostet.

```
+------------------------+
| Wind v   [Ost in 6]    |
|  ^^^^ FEUER ^^^^       |   Front kommt von oben
|  ,,, Gras ,,,  TTT     |
|      [+] Fadenkreuz    |   12 mm über der Kuppe
|  ======= Weg =======   |
|   h    h     h    h    |   Hütten (statisch)
| [Schn] [Gegen] [Wasser]|   <- Daumen
+------------------------+
```
- Werkzeug antippen, dann irgendwo aufsetzen und ziehen; das Fadenkreuz folgt relativ und rastet auf Feldmitten; Loslassen über der Leiste bricht ab.

**N. Dominante Strategie & ihre Kosten** – Welche Strategie dominiert, und was kostet sie?
- **„Hütten einmauern“:** Kosten: Vier Schneisen reichen nicht für drei Hüttengruppen, Funkenflug überspringt einspurige Ringe, und der Wald brennt komplett ab (Punkte).
- **„Früh alles gegenfeuern“:** Kosten: Ungeankerte Gegenfeuer laufen mit dem Wind auf die Hütten zu; dreht der Wind, wird das eigene Feuer zur zweiten Front.
- **„Wasser auf die Front“:** Kosten: zwei Flüge, 8 Ticks Wirkung, 2 Ticks Verzögerung – danach brennt es weiter.
- **„Schnell sein“:** Nutzen klein: Fokus-Zeitlupe und 1-s-Ticks nehmen Reaktionszeit als Hauptfaktor heraus (G3 prüft das).
- **Erwartung [E]:** Stark ist „Schneise als Anker, Gegenfeuer kurz vor der Front, Löschflug als Reserve gegen Funkenflug“ – eine Lese- und Planungsaufgabe.
- **Restrisiko:** Bleibt Echtzeitdruck trotz Fokus spürbar, gewinnen schnelle Spieler doch. Fallback: Ticks nur, solange kein Finger liegt (vollständig zugbasiert).

**O. Bot-Spielbarkeit**
- **Zustand:** Feldtypen, Hitze, Brennzeiten, Windfahrplan, Werkzeuge, Fokus, Tick.
- **Aktionen pro Tick:** nichts oder Werkzeug × Feld × Ausrichtung (≤ 3 × 96 × 2), vorgefiltert auf Felder ≤ 4 von der Front.
- **Profile:** `passiv`, `zufall` (alle 5 Ticks ein zufälliges Werkzeug nahe der Front), `mauer`, `wasser`, `gegenfeuer_frei`
  (Gegenfeuer ohne Anker), `planer` (Rollouts bis Brandende für die besten 20 Kandidaten je Entscheidung), `planer_langsam`
  (entscheidet erst 1,5 s nach jeder Lageänderung und nur alle 3 Ticks), `planer_ungenau` (10 % der Werkzeuge um 1 Feld versetzt).
- **Messgrößen:** gerettete Hütten, unverbrannte Felder, Branddauer, Werkzeugnutzung, „Eigentore“ (Hütten, die durch eigenes Gegenfeuer verbrennen).
- **Abnahmekriterien (vor dem Test fixieren):**
  - G1: `planer` ≥ 1,5 × `mauer` (Median).
  - G2: `passiv` rettet im Median ≤ 30 % der Hütten.
  - G3: `planer_langsam` ≥ 85 % von `planer` – Reaktion zählt wenig.
  - G4: `planer_ungenau` ≥ 90 % von `planer` – Präzision zählt wenig.
  - G5: In ≥ 50 % der Täler nutzt die beste gefundene Lösung mindestens ein geankertes Gegenfeuer, und `gegenfeuer_frei` verliert
    in ≥ 50 % der Täler mindestens eine Hütte durch ein Eigentor (das Signaturverb ist nötig und riskant).
  - G6: Median-Branddauer 45–120 s.
- **Billigster Menschentest:** Graubox, ein Tutorialtal und drei Täler; gemessen wird, ob Testende das geankerte Gegenfeuer ohne Hinweis ein zweites Mal einsetzen.

**P. Session-Budget** – Ein Brand: Werkzeugleiste (4 / 3 / 2) und Fokusvorrat sichtbar; Ende, wenn das Feuer erloschen ist
(Ziel statt Uhr – es frisst sich immer aus). Erwartete Dauer 45–120 s, Zeitraffer für den Ausklang. Tagestal aus dem Datum.
Teilbar: „GEGENFEUER · 22.10. · Hütten 5/6 · Wald 31 · gebändigt nach 58 s“ plus eine 8 × 12-Brandkarte aus Symbolen.

---

## K19 · WINDSPIEL

*Ruhige Echtzeit · Kern-Eingabe: Wischen irgendwo (nur die Richtung zählt) · Bausteine: Sonnenuntergang als Grenze (Tiny Wings),
hartes Aktionsbudget (02 §3 Baustein 16), K02-Verhalten als Ressource (Samenfächer) · Multitouch: keins*

**A. Arbeitstitel** – WINDSPIEL (doppeldeutig: Spiel mit dem Wind und Windspiel als Klangspiel)

**B. Elevator Pitch** – Du bist der Wind über einer Frühlingswiese. Ein Wisch dreht ihn für alles zugleich – Pusteblumensamen und
Regenwolken: Säe, gieße und lass es blühen, bevor die Sonne untergeht.

**C. Kernmechanik**
- **Wiese:** Draufsicht, 9 × 14 Beete. Böden: fruchtbar (Same → Keimling), trocken (Keimling nur, wenn innerhalb von 8 s Regen
  darauf fällt, sonst vertrocknet er), Stein, Weg und Teich (Same verloren).
- **Pusteblumen** (3–5, fest): Jede bläst nach Fahrplan alle 8 s vier Samen ab; 2 s vorher leuchtet sie („reif“).
- **Samen:** fliegen 3 s mit dem Wind (plus kleine feste Fächerung, damit sie sich verteilen) und landen dann auf dem Beet
  darunter. Fliegen sie durch die markierte Zone des Spatzenschwarms (fester Rundkurs), werden sie gefressen.
- **Wolken:** zwei bis drei; sie treiben mit 35 % der Windgeschwindigkeit und regnen auf ihr Beet und die Nachbarbeete.
  Keimling plus Regen = Blüte. Alle 12 s zieht eine neue Wolke vom Rand herein, **aus dem der Wind gerade kommt** (Stelle am Rand
  aus dem Seed). Wer den Wind dreht, bestimmt also auch, woher der nächste Regen kommt.
- **Wind:** Ein Wisch irgendwo setzt Richtung (8) und Stärke (kurz = Brise, lang = Böe); kurzes Tippen = Flaute. Der Wind dreht
  weich über 0,5 s. Jeder Wechsel kostet einen von 14 „Hauchen“, sichtbar als Röhrchen eines Windspiels.
- **Ende:** Sonnenuntergang nach 90 s (sichtbare Sonne, konstantes Tempo). Sind alle Hauche verbraucht, lässt sich der Abend per Tippen im Zeitraffer abschließen.
- **Wertung:** Blüten × 3 + Keimlinge × 1 bei Sonnenuntergang.

**D. Die ersten 30 Sekunden**
- 0 s: Grüne Wiese, eine Pusteblume leuchtet „reif“, rechts davon ein dunkles, fruchtbares Beet. Eine Geisterhand wischt nach rechts.
- 2 s: Wisch → die Windfahne dreht, das Gras wogt, das Windspiel klingt. Die Samen fliegen nach rechts und landen: drei Keimlinge.
- 8 s: Links zieht eine Wolke herein. Hinweis: „Regen lässt Keimlinge blühen.“
- 12 s: Wisch nach links (Brise) → die Wolke schiebt sich über die Keimlinge, drei Blüten ploppen auf. Aha: ein Wind für zwei Dinge.
- 18 s: Zwei Pusteblumen werden zugleich reif, eine links, eine rechts; die Wolke steht gerade gut. Erster Zielkonflikt: säen oder Wolke halten?
- 25–30 s: Spatzen kreuzen, ein Samenfächer wird gefressen – sichtbar warum. Danach die erste echte Wiese.

**E. Core Gameplay Loop** – Reife Pusteblumen, Wolken und Spatzenroute lesen → wechseln oder halten (Hauch-Budget) → Wisch →
Samen landen, Regen fällt → Keimlinge, Blüten → neue Lage. Spannung: Ein einziger Wind muss mehreren Zielen dienen.

**F. Hook** – Ein Wind für alles: Jeder Wisch hilft hier und schadet dort. Am Abend steht eine Wiese, die es so nur einmal gibt.

**G. Mastery**
- Phasen bündeln: erst säen, dann mit einer Böe Wolken heranholen.
- Die Eintrittsregel der Wolken nutzen: den Wind rechtzeitig drehen, damit die nächste Wolke auf der richtigen Seite hereinkommt.
- Samenfächer um den Spatzen-Rundkurs herumlenken.
- Trockene Beete nur mit passendem Regen-Timing besäen.
- Hauche für die späten, dichten Phasen sparen.

**H. Wiederspielwert**
- Tageswiese (Böden, Pusteblumen, Wolken, Spatzen aus dem Seed), unbegrenzte Übungswiesen.
- Varianten: „Sommer“ (viele trockene Beete), „Sturm“ (nur Böen), „Bienen“ (Blüten bestäuben Nachbarbeete nur bei Flaute).
- Die 50. Wiese ist interessant, weil sich die Zielkonflikte aus der Geometrie jeder Wiese neu ergeben und das fertige Bild jedes Mal anders aussieht.

**I. Technische Machbarkeit**
- Feste Zeitschritte (30 Hz), keine Physik-Engine; höchstens etwa 30 Samen und 3 Wolken gleichzeitig; Beete als Raster; Wind als globaler Vektor mit Rampe.
- Bot: Rollout über 6 s für 17 Windoptionen plus „halten“ an Entscheidungspunkten (Reif-Signale, Wolkenereignisse).
- Graubox in 1–2 Tagen.

**J. Audiovisuelle Vision** – Helle, malerische Draufsicht; das Gras wogt in Windrichtung (Shader) und zeigt den Wind überall,
ohne Pfeil. Samen als weiße Federchen, Wolkenschatten auf dem Gras, Regenstreifen; Blüten ploppen in Farben, die je nach
Pusteblume variieren. Audio: Das Windspiel ist Programm – jeder Windwechsel spielt den Ton seiner Richtung, Blüten fügen leise
Töne hinzu, abends kommen Grillen. Geteilt wird ein Bild der fertigen Wiese.

**K. Werbetauglichkeit** – Pause nach Sonnenuntergang (90 s). Rewarded nur im Übungsmodus (z. B. „drei Extra-Hauche“).

**L. Vergleichbare Spiele**
- **Flower** (thatgamecompany, 2009; iOS 2017) [B]: „Changes in the pitch and roll of the floating petal are accomplished by tilting
  the PlayStation 3 controller“; „Pressing any button blows the wind harder“; Blumen erblühen, wenn man sich ihnen nähert.
  https://en.wikipedia.org/wiki/Flower_(video_game) – Nächster Verwandter im Motiv. Abgrenzung: Dort steuert man ein Band aus
  Blütenblättern wie einen Avatar durch eine 3D-Welt; hier ist der Wind ein globaler Schalter mit Budget, der mehrere Systeme
  zugleich bewegt (Zielkonflikt statt Flug).
- **Tiny Wings** [R]: Der Sonnenuntergang beendet den Lauf (03 §2.2.10).
- **Neige-Labyrinthe** [A]: eine Eingabe, die alles zugleich bewegt.
- **Nicht suchbar gewesen:** 2D-Rätsel mit globalem Wind für Samen und Wolken. Nachzuholen: „wind direction puzzle seeds clouds
  game“, „dandelion seed wind game mobile“.

**M. Hand & Verdeckung**

**Wo liegt die Hand, und was ist darunter?** – Gewischt wird irgendwo, empfohlen am Wiesenrand im unteren Fünftel; ein Wisch
dauert etwa 0,3 s, danach ist die Hand wieder weg. Unter der Hand liegt dauerhaft nichts, weil es kein Objekt gibt, das man
berühren muss – gesteuert wird nur eine Richtung.

```
+------------------------+
| Sonne --o--  Hauche 9  |
|  * Pusteblume    ##    |   ## = fruchtbar
|    ~ Wolke ~      ##   |
|  ..  Spatzenrunde  ..  |
|  ##    *      ~ Teich  |
|  ##        ##          |
|  ~~ Wiesenrand ~~      |   <- Wischfläche
+------------------------+
```
- Wische zählen erst ab 24 dp vom Seitenrand und nicht aus der Gestenleiste; die Richtung wird großzügig auf 8 Sektoren gerundet.

**N. Dominante Strategie & ihre Kosten** – Welche Strategie dominiert, und was kostet sie?
- **„Fester Wind“** (einmal zur größten fruchtbaren Fläche, dann halten): Kosten: Wolken ziehen aus dem Bild, neue kommen immer
  von derselben, meist falschen Seite; der Generator legt die Spatzenrunde bevorzugt auf den naheliegenden Korridor.
- **„Mikrosteuerung“** (jeder Samenfächer bekommt seinen Wind): Kosten: Nach etwa 40 s sind die Hauche weg; die dichtere zweite Hälfte bleibt ungesteuert.
- **„Wolkenhirte“** (Wolken über Keimlingen halten): Kosten: Brisen tragen Samen zu kurz, sie landen auf Wegen und im Teich.
- **Erwartung [E]:** Gut ist ein Phasenspiel, das die Eintrittsregel der Wolken vorausdenkt. P1 und P2 prüfen das.
- **Restrisiko:** Das Gefühl „ich steuere nichts“ (Kritik an K10). Gegenmittel: sofort sichtbarer, globaler Effekt jedes Wischs; der Menschentest fragt das Kontrollgefühl ab.

**O. Bot-Spielbarkeit**
- **Zustand:** Samen (Ort, Restflugzeit), Wolken, Beete (Boden, Keimling, Blüte, Trockenfrist), Spatzenposition, Wind (Ist und Soll), Hauche, Zeit.
- **Aktionen:** an Entscheidungspunkten (alle 0,25 s) halten oder einer von 17 Winden (8 Richtungen × 2 Stärken + Flaute).
- **Motorik und Reaktion:** keine Präzision; `planer_langsam` reagiert 0,8 s später und zeigt, ob Reaktionszeit zählt.
- **Profile:** `fest_best` (bester fester Wind, durch Ausprobieren aller 17 ermittelt), `zufall` (alle 6 s zufällig), `gierig`
  (max. Landungen des nächsten Fächers), `wolkenhirte`, `planer` (Rollout 6 s je Option an Ereignispunkten), `planer_langsam`.
- **Messgrößen:** Punkte, verbrauchte Hauche, gefressene Samen, Zeit ohne Hauche, Blüten je Wolke.
- **Abnahmekriterien (vor dem Test fixieren):**
  - P1: `planer` ≥ 1,5 × `fest_best` (Median).
  - P2: `gierig` ≤ 75 % von `planer`.
  - P3: `planer_langsam` ≥ 85 % von `planer`.
  - P4: `zufall` ≤ 40 % von `planer`.
  - P5: `planer` verbraucht im Median 9–14 Hauche (das Budget bindet, ist aber nicht absurd knapp).
  - P6: Zwei Planer-Varianten („erst säen“ und „erst gießen“) liegen ≤ 10 % auseinander.
- **Billigster Menschentest:** Graubox mit zwei Pusteblumen und einer Wolke; Kontrollgefühl auf einer Skala von 1–5 abfragen (Abbruch bei Median < 4, analog zum K10-Test).

**P. Session-Budget** – 90 s bis Sonnenuntergang (sichtbare Sonne, konstantes Tempo, keine Beschleunigung) und 14 Hauche als
sichtbares Aktionsbudget. Ende = Sonnenuntergang, bei leeren Hauchen per Zeitraffer. Tageswiese aus dem Datum. Teilbar als Bild
der Wiese plus „WINDSPIEL · 22.10. · 21 Blüten · 9 Keimlinge“.

---

## 4. Querschnitt: offene Risiken des Feldes (ohne Bewertung)

- **Tabellengefühl bei den ruhigen Konzepten (K13, K16):** Wenn die Zahlen (Puffer, Fläche) die Bilder verdrängen, fühlt es sich
  nach Rechnen an. Die Audio-Bild-Ebene (Sonnenlicht, Glut) muss die Zahlen tragen, nicht umgekehrt.
- **Kontrollgefühl bei indirekter Steuerung (K15, K19):** Das war der Hauptvorwurf an K10. Beide Konzepte setzen auf sofort
  sichtbare, deterministische Folgen jeder Eingabe; der Menschentest muss das Kontrollgefühl ausdrücklich abfragen.
- **Schleichende Motorik bei Takt und Echtzeit (K17, K18):** Beide haben einen Rückfall auf vollständig zugbasiert, falls die
  Bot-Kriterien F3 bzw. G3 halten, Menschen aber trotzdem Tempo als entscheidend erleben.
- **Prior Art:** Ohne Websuche (§0) ist die Eigenständigkeit aller sieben Konzepte nur gegen bekannte Verwandte geprüft. Am
  dringendsten nachzuholen sind die Suchen für K15 und K13 (stärkste Neuheitsbehauptung) und K14 (Nähe zu Cut the Rope).
- **Offline-Tagesseed:** Vergleich nur über geteilte Texte und Bilder, keine Bestenliste. Das ist gewollt (kein Server), begrenzt aber den sozialen Sog.

---

## 5. Quellen

### Direkt abgerufen [B] (alle am 22.10.2026, vor dem Ausformulieren)
- Blue Prince – https://en.wikipedia.org/wiki/Blue_Prince_(video_game) (K13)
- Deep Sea Adventure, Oink Games – https://oinkgames.com/en/games/analog/deep-sea-adventure/ (K13)
- Incan Gold – https://en.wikipedia.org/wiki/Incan_Gold (K13)
- Cut the Rope – https://en.wikipedia.org/wiki/Cut_the_Rope (K14)
- Turing Tumble – https://en.wikipedia.org/wiki/Turing_Tumble (K14)
- Hunt the Wumpus – https://en.wikipedia.org/wiki/Hunt_the_Wumpus (K15)
- Black Box (game) – https://en.wikipedia.org/wiki/Black_Box_(game) (K15)
- Scotland Yard (board game) – https://en.wikipedia.org/wiki/Scotland_Yard_(board_game) (K15)
- Don't Starve – https://en.wikipedia.org/wiki/Don%27t_Starve (K16)
- Racetrack (game) – https://en.wikipedia.org/wiki/Racetrack_(game) (K17)
- Into the Breach – https://en.wikipedia.org/wiki/Into_the_Breach (K18)
- Forest-fire model – https://en.wikipedia.org/wiki/Forest-fire_model (K18)
- Controlled burn – https://en.wikipedia.org/wiki/Controlled_burn (K18; nur die ersten 100.000 Zeichen der Seite gelesen)
- Flower (video game) – https://en.wikipedia.org/wiki/Flower_(video_game) (K19)

### Abgerufen ohne verwertbaren Befund
- BASIC Computer Games – https://en.wikipedia.org/wiki/BASIC_Computer_Games: nennt Hurkle und Mugwump nicht; nicht zitiert
  (die Erwähnung beider Spiele stammt aus dem Artikel zu Hunt the Wumpus).
- „Firefighter problem“ und „Dark Echo“ auf Wikipedia: HTTP 404; beide nur als [A] geführt.

### Aus der Recherche übernommen [R]
- `02_indie_experimental.md`: §2.4 Dorfromantik, §2.5 Bore Blasters, §2.6 Stretchmancer, §2.7 Windowkill, §2.9 Draftula, §2.10 Holedown, §3 Bausteine 1, 2, 5, 8, 9, 10, 16.
- `03_touch_and_sentiment.md`: §2.2.3 Data Wing, §2.2.10 Tiny Wings, §2.2.14 Mini Metro, §3.1–3.4 Ergonomie und Android-Grenzen, §4.2 T1 Werbung.

### Allgemeinwissen, nicht verifiziert [A]
Minesweeper, Schiffe versenken, Dark Echo (RAC7), Jenga, Mobiles von Alexander Calder, Missile Command, Crazy Taxi,
Neige-Labyrinthe, das „Firefighter problem“ der Graphentheorie, das Seilschneiden-Detail von Cut the Rope.

### Nicht durchgeführt
- Websuchen: keine einzige (Sitzungsbudget erschöpft, §0). Die nachzuholenden Suchbegriffe stehen in Feld L jedes Konzepts.
- Simulationen: bewusst keine. Spielzeug-Simulationen nur für einzelne Konzepte hätten die Ausarbeitung ungleich gemacht
  (Kritikpunkt §1.4 in `CRITIC_REVIEW.md`); stattdessen hat jedes Konzept eine gleich detaillierte Bot-Spezifikation in Feld O.
