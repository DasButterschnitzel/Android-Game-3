# Kritik-Review Phase 2 – Konzepte K01–K12

Autor: Agent D (Gameplay Critic / Devil's Advocate) · Stand: 2026-10-22
Grundlage: `CONCEPTS.md`, `00_INNOVATION_MAP.md`, `01_mobile_market.md`, `02_indie_experimental.md`,
`03_touch_and_sentiment.md`, die vorhandene LUNTE-Bot-Simulation (auf einer Kopie ausgeführt) und eine kleine Prior-Art-Prüfung im Web.

**Kennzeichnung:**
- **[B]**: Quelle selbst geöffnet.
- **[S]**: Nur als Suchtreffer gesehen.
- **[A]**: Allgemeinwissen, in dieser Sitzung **nicht** verifiziert.
- **[Sim]**: Bot-Simulation, also **keine Menschen**.
- **[E]**: meine Einschätzung.

Alle Aussagen zu Spaß und Wiederspielwert sind **Hypothesen, keine Playtest-Ergebnisse**.

**Grenzen dieser Review:**
- **Websuche:** Nach vier Suchen war das mit anderen Agenten geteilte Suchbudget der Sitzung erschöpft. Weiter wurde nicht gesucht. Vier Treffer habe ich danach direkt geöffnet und geprüft. Für K03, K04 und K07–K12 stützt sich die Prior Art deshalb nur auf Feld L der Konzepte, die Recherche und Allgemeinwissen. „Nicht gefunden“ heißt nicht „existiert nicht“.
- **Simulation:** Sie lief auf einer Kopie im Scratchpad. Das Repository ist unverändert, ich habe keine andere Datei angefasst.

---

## 0. Urteil auf einer Seite

- **Keines der zwölf Konzepte ist in der vorliegenden Form gut genug.** Zwei sind prototypwürdig, und zwar **als Hypothesentest**. Voraussetzung sind die Umbauten aus Abschnitt 5 und Abbruchkriterien, die vorher schriftlich festgelegt werden.
- **Prototypen:** **K01 LUNTE** (umgebaut) und **K06 ECHO** (umgebaut). Sie testen gegensätzliche Hypothesen: Risiko in Echtzeit beim Zeichnen gegen Planung über Mikro-Durchläufe.
- **Sofort streichen:** K03, K04, K05, K07, K08, K09, K12.
- **Parken:** K02, K10, K11. Einzelteile davon sind verwertbar.
- **Neustart:** Einen Totalneustart fordere ich jetzt **nicht**. Pflicht ist aber eine eng geführte Nachideation mit harten Leitplanken (Abschnitt 6). Reißen beide Prototypen ihre Abbruchkriterien, folgt **automatisch** ein vollständiger Neustart.
- **Härtester Einzelbefund:** In der aktuellen LUNTE-Fassung entscheidet das **Zeichentempo** über Überleben und Punkte, nicht die Entscheidungen des Spielers. Gier kostet praktisch nichts, und das Rundenende ist eine versteckte Uhr [Sim, Abschnitt 2].

| Rang | Konzept | Gewichtet (0–10) |
|---|---|---|
| 1 | K01 LUNTE | 6,35 |
| 2 | K06 ECHO | 5,95 |
| 3 | K10 WELLENGANG | 5,30 |
| 4 | K11 ZEITBLASE | 5,20 |
| 5 | K02 SCHWARM | 5,15 |
| 6= | K03 PENDEL | 4,85 |
| 6= | K05 FINGERSONNE | 4,85 |
| 8 | K08 SPANNUNG | 4,65 |
| 9 | K12 SPIEGELSTURM | 4,45 |
| 10= | K04 LASSO | 4,35 |
| 10= | K09 ZWEILEINER | 4,35 |
| 12 | K07 PRALLFINGER | 3,90 |

Mein Maßstab:
- **≥ 7,0:** ohne Umbau prototypen.
- **6,0 bis unter 7,0:** nur mit Umbauten.
- **5,5 bis unter 6,0:** nur als Gegenhypothese, mit Umbauten.
- **< 5,5:** nicht weiterverfolgen.

**Kein Konzept erreicht 7.**

---

## 1. Systemische Kritik am Konzeptfeld

Diese Muster wiegen schwerer als jede Einzelkritik.

### 1. Verdeckung durch die Hand ist der blinde Fleck des ganzen Felds

In neun von zwölf Konzepten (K01–K07, K11, K12) liegt das gesteuerte Objekt oder die entscheidende Information unter oder direkt hinter dem Finger:

| Konzept | Was der Finger verdeckt |
|---|---|
| K01 | Lunten-Kopf, Funke |
| K02 | Schwarm am Lockpunkt |
| K03 | Kugel, die *unter* dem Finger hängt, also in der Hand |
| K04 | Glühwürmchen, die vor der Fingerspitze fliehen |
| K05 | Umlaufbahn um die Fingerkuppe |
| K06 | Lichtpunkt |
| K07 | Kugel im Moment des Abpralls |
| K11 | Eingefrorene Brücke unter dem Haltefinger |
| K12 | Spiegel unter dem Drehfinger |

Die eigene Recherche empfiehlt ausdrücklich das Gegenteil:
- Objekte nicht unter den Daumen legen und relative Eingabe nutzen (Prinzip „irgendwo berühren“), siehe 03 §3.4 Punkt 5 und §5 Punkt 3 sowie 00 §4.
- Der Beleg ist dort zitiert. Hundreds: „bumping into circles that your hand is blocking is a problem“ (03 §2.2.5).

**Kein einziges Ein-Finger-Konzept nutzt relative Eingabe.** Eine Eingabe, bei der der Finger nicht auf dem Zielobjekt liegt, haben nur K08 und K09 (beide zweihändig erzwungen) und mit Abstrichen K10.

### 2. Multitouch ist überwiegend angeklebt

- **Neun Konzepte haben den zweiten Finger als Zusatz:** Doppelzünder, Teilen, Umlenkhaken, Laterne, zweite Sonne, Mehrfach-Bumper, Interferenz-Doppeltipp, drei Blasen, zwei Spiegel (K01–K05, K07, K10–K12).
- **Zwei erzwingen beide Hände** (K08, K09).
- **Eines hat gar keinen** (K06).

Bei keinem ist plausibel begründet, warum ein Spieler den zweiten Finger *freiwillig* nutzen sollte. Die Leitlinie aus 00 §4 lautet „Kern mit 1 Finger, 2. Finger = Bonus mit echtem Nutzen, nie Pflicht“. Kein Konzept erfüllt sie überzeugend.

### 3. Das Feld ist einseitig

Alle zwölf Konzepte sind Echtzeit-Arcade mit dem Finger als Werkzeug. Drei Ansätze, die die eigene Recherche als touch-freundlich oder unterbesetzt ausweist, fehlen praktisch komplett. Nur ECHO hat mit seinen sechs Läufen ansatzweise ein Budget.
- **„Zielen ohne Zeitdruck, Festlegen beim Loslassen“** (Holedown, Desert Golfing). Fehleingabe-Risiko laut 03 §3.2 „gering“.
- **Aktionsbudget statt Uhr** (02 §3, Baustein 16).
- **Räumliches 1-aus-3-Drafting** (02 H1).

Dazu kommt die Marktlage: Puzzle bringt **53 %** des Werbeumsatzes, Arcade **13 %** (01 §5.1). Arcade „testet seine Untergrenze“ (01 §5.2). Die Innovation Map wählt bewusst das kleinere Segment (00 §6). Dann müssten die Konzepte dieses Segment wenigstens perfekt treffen, und das tun sie nicht.

### 4. Ungleiche Ausarbeitung verzerrt jede Bewertung

K01 hat ausformulierte Regeln, einen Ablauf der ersten 30 Sekunden und einen Technikplan. K03–K12 sind Skizzen mit Einzeilern in den Feldern G–L. Ein Vergleich misst damit teils den Ausarbeitungsfleiß und nicht die Qualität der Idee. Ich habe die Skizzen deshalb wohlwollend zu Ende gedacht und gegen K01 bewusst die stärkste vorhandene Evidenz eingesetzt, die Simulation.

### 5. Anker-Gefahr

Im Arbeitsverzeichnis existiert bereits ein LUNTE-Prototyp mit Bot-Simulation:
- `game/prototypes/lunte/`
- `game/scripts/gameplay/fuse/`
- `game/tests/simulation/sim_lunte.gd`

Er wurde **während** dieser Review weiterentwickelt: `lunte.json` und `fuse_sim.gd` wurden um 21:42 UTC geändert. Wer schon baut, bevor die Kritik vorliegt, findet später Gründe weiterzubauen. Deshalb müssen die Abbruchkriterien **vor** dem nächsten Test schriftlich feststehen (Abschnitt 5).

### 6. Prior-Art-Behauptungen sind teils zu optimistisch

- **K02:** 00 §3 nennt für den Schwarm „kein Multitouch-Vorbild gefunden“. *Swarm Multitouch* (iOS, 2016) teilt jedoch einen Schwarm auf mehrere Finger auf, in bis zu neun Gruppen [B].
- **K05:** Den Kern „Finger = Masse, die Bahnen biegt“ gibt es auf Android als *Gravity Force* [B].
- **K06:** Der Kern ist ein Dauerbrenner auf Game Jams [B/S].

---

## 2. Evidenz: Was die vorhandene LUNTE-Simulation verrät [Sim]

### Methode

- **Code-Stand:** Kopie vom 22.10.2026, 21:47 UTC.
- **Lauf:** `sim_lunte.gd` mit 40 Seeds pro Profil.
- **Bots:** Sie haben perfekte Information, keine Verdeckung und kein Zögern.
- **Entkopplung:** Die mitgelieferten Bot-Profile vermischen zwei Größen, nämlich wie nah man den Funken herankommen lässt und wie schnell gezeichnet wird. „Vorsichtig“ heißt 2,2 s Abstand bei 230 px/s, „gierig“ heißt 0,75 s bei 360 px/s. In der Kopie habe ich deshalb fünf entkoppelte Profile ergänzt.
- **Lesehilfe:** Der Abstand ist in Sekunden angegeben, die der Funke bis zum Lunten-Kopf braucht. Hitze ×3 gilt unter 0,8 s, ×2 unter 1,6 s.

### Ergebnisse

| Abstand / Zeichentempo | Rundendauer Median (p10–p90) | Score Median | Zeitanteil ×3 | Tode durch Funke / Böller / Kreuzung (von 40) |
|---|---|---|---|---|
| 2,2 s / 300 px/s | 96,5 s (46–101) | 1.875 | 5 % | 21 / 14 / 5 |
| 1,3 s / 300 px/s | 92,8 s (28–98) | 1.868 | 6 % | 16 / 17 / 7 |
| 0,75 s / 300 px/s | 93,5 s (54–95) | 2.781 | 8 % | 26 / 12 / 2 |
| 1,3 s / 230 px/s | 75,6 s (33–77) | 1.030 | 7 % | 23 / 15 / 2 |
| 1,3 s / 400 px/s | 114,7 s (43–121) | 3.295 | 5 % | 16 / 18 / 6 |

Ein früherer Lauf auf dem Stand vor dem 21:42-Update (noch ohne die neuen Elemente „splitter“ und „finale“) zeigte dasselbe Bild. Knapper Abstand brachte dort +34 % Punkte bei −2 % Überlebenszeit.

### Befunde

1. **Gier ist gratis.** Bei gleichem Zeichentempo bringt ein Abstand von 0,75 s **+48 % Punkte bei −3 % Überlebenszeit** gegenüber 2,2 s.
   - Das Kernversprechen aus K01-H, „der Spieler wählt aktiv das Risiko“, existiert damit für einen präzisen Spieler nicht.
   - Ein Risiko entsteht bei Menschen höchstens durch Ungenauigkeit und Verdeckung, also durch unfaire statt gestaltete Gefahren.
2. **Die eigentliche Fähigkeit ist das Zeichentempo.**

   | Zeichentempo (bei 1,3 s Abstand) | 230 px/s | 300 px/s | 400 px/s |
   |---|---|---|---|
   | Überleben (Median) | 76 s | 93 s | 115 s |
   | Punkte (Median) | 1.030 | 1.868 | 3.295 (×3,2) |

3. **Das Rundenende ist eine versteckte Uhr.**
   - Median und p90 der Rundendauer liegen nur **1,3–6,6 s** auseinander.
   - Fast alle Runden enden in dem Moment, in dem der zeitabhängig beschleunigende Funke das Zeichentempo überholt.
   - Das Ende kommt also aus der Motorik, nicht aus einer Entscheidung.
4. **×3 ist ein Messerrücken.** Selbst das Profil mit 0,75 s Zielabstand bei einer ×3-Schwelle von 0,8 s verbringt nur 5–8 % der Zeit auf ×3. Ein Mensch, der den Funken unter der eigenen Hand nicht sieht, schafft das noch seltener.
5. **30–45 % aller Tode entstehen durch Böller-Explosionen**, die die eigene Lunte *vor* dem Funken zünden.
   - Im Konzept taucht diese Regel nur als Mastery-Fußnote auf (K01-G: „Funkenflug“).
   - Für Menschen ist das der klassische „Warum bin ich jetzt tot?“-Moment.
6. **Die Kreuzung ist überwiegend Strafe.** Aufgefädelte Körper verpuffen, und der Funke springt näher heran. Ihr Nutzen (Platz schaffen, Hitze erhöhen) ist kaum lesbar. In der Simulation verursacht sie 5–18 % der Tode, und die Bots meiden sie per Kostenfunktion.
7. **Der Rundenanfang ist zäh.**
   - Der Funke startet mit 95 px/s und erreicht nach 30 s erst etwa 140–150 px/s (Formel in `fuse_sim.gd`, Werte aus `lunte.json`).
   - Bei Runden von 75–115 s läuft damit etwa das erste Drittel mit gedrosseltem Tempo.
   - Für ein Spiel, das schon in 30-Sekunden-Sessions tragen soll, ist das zu viel Anlauf. Wer nur 30 s hat, erlebt nur die langsame Phase.

### Einschränkung

Bots beweisen nichts über Spaß. Sie zeigen aber: **Das Regelwerk belohnt in der aktuellen Fassung Motorik statt Entscheidungen.** Das ist ein Designbefund, kein Balancing-Detail.

### Lob, das die Prüfung übersteht

Dass es diese Simulation gibt, ist das Beste am bisherigen Prozess. Sie hat in Minuten sichtbar gemacht, wofür sonst eine Playtest-Runde nötig gewesen wäre.

---

## 3. Einzelkritik (Teil A)

### K01 · LUNTE – Urteil: prototypen, aber umbauen

- **Wirklich neu?** Teilweise.
  - Verwandte: Snake und Tron (eigene Spur als Gefahr) [A], Paper.io (Spur als Verwundbarkeit) [A], Flight Control (Pfad live zeichnen, 03 §2.3), Fuse Runner und Burn the Rope (Feld L).
  - Meine Suche nach „Funke jagt den zeichnenden Finger“ ergab nur Seiten zur Feuerwerkssicherheit, kein Spiel. Eine Suche ist aber kein Beweis.
  - Die Verbindung „dein Schweif ist der Timer, der Ketten zündet“ ist das stärkste Originalitätsargument im ganzen Feld.
- **Nach 20 Runden:** Hier ist das Risiko groß.
  - Laut Simulation entscheiden weder Route noch Risiko über den Erfolg, sondern das Zeichentempo.
  - Langweilig sind die ersten rund 30 s jeder Runde, Phasen ohne erreichbaren Feuerwerkskörper und das immer gleiche Ende: Der Funke überholt dich.
  - Die Routenwahl schrumpft oft auf „nimm den nächsten Körper“. Genau mit dieser Heuristik spielt der Bot gut.
- **Können oder Glück?** Überwiegend Können: Der Funke ist deterministisch, die Spawns hängen an Seeds. Unfair wirken werden die Böller-Tode (30–45 % in der Simulation) und der Sprung an Kreuzungen, solange beides nicht vorab sichtbar ist.
- **Touch:** Hier liegt das Kernproblem.
  - Wer nach oben zieht, verdeckt mit der Hand den Funken, also genau die Information für den Hitze-Bonus. Wer nach unten zieht, verdeckt den Weg.
  - Durchgehend über das ganze Hochformat zu ziehen geht mit dem Daumen einer Hand kaum (oberes Drittel, gegenüberliegende Ecke). Die Folge sind Umgreifen, Abheben und Wiederansetzen unter Zeitdruck, während der Funke weiterläuft.
  - Der Start „unten mittig“ (K01-D) liegt nahe der Home-Geste. Ein Wisch vom unteren Rand nach oben ist genau diese nicht abschaltbare Geste (03 §3.1).
  - Positiv: Das Playtest-Protokoll sieht bereits einen A/B-Test direkte gegen relative Steuerung vor (`docs/playtests/PLAYTEST_PROTOCOL.md`). Das ist richtig.
- **Ohne Progression? Installieren und morgen wieder?** Installieren: ja. Morgen wieder: ja, für einige Tage. Feuerwerk plus Verfolgung lässt sich in einem 5-Sekunden-Clip erklären. Nach einer Woche nur noch, wenn Entscheidungen den Score tragen und nicht das Fingertempo.
- **Machbarkeit:** Sehr hoch, das meiste ist schon gebaut.
- **Größtes Risiko:** Aus „plane riskant“ wird „zeichne schnell durch Punkte“.
- **Billigster Test (1 Tag):** Vorhandenen Build auf echten Phones spielen lassen, 5 Personen × 10 Runden, mit Telemetrie zu Zeichentempo, Abstandsverlauf und Todesursache. Abbruchkriterien stehen in Abschnitt 5.1.

### K02 · SCHWARM – Urteil: parken

- **Wirklich neu?** Weniger als behauptet.
  - *Swarm Multitouch* (iOS 2016): Der Schwarm folgt dem Finger. Bei mehreren Fingern „the swarm will break up and a portion of the swarm will track each finger“, bis zu neun Gruppen. Ein Spielzeug ohne Ziele oder Gegner [B].
  - Weitere Verwandte: Koi [LD56] und Flock! (Feld L), Swarm (Hothead, 2011), LocoRoco (Teilen und Vereinen), Crowd City (Gruppe führen und vergrößern) [A].
  - Neu ist nur die Kombination mit Räubern und bewusstem Opfern.
- **Nach 20 Runden:**
  - Das Konzept nennt selbst „wenige Entscheidungsarten“.
  - Zwischen den Räuberangriffen herrscht Leerlauf: Plankton einsammeln heißt hinterherziehen.
  - Geteilt wird nur dort, wo das Level es erzwingt (zwei Wolken links und rechts). Dann ist es ein Tutorial-Trick, kein Taktikwerkzeug.
- **Können oder Glück?** Boids sind bewusst unscharf. Verlorene Nachzügler fühlen sich wie Zufall an („warum ist der da hingeschwommen?“). Der Hecht mit Vorwarnung ist fair, Quallen-Treffer am Schwarmrand sind kaum vorhersehbar.
- **Touch:**
  - Der Schwarm sammelt sich am Lockpunkt, also unter der Fingerkuppe.
  - Der Finger liegt die ganze Runde auf dem Display. Das bedeutet Ermüdung und Fehlberührungen durch den Handballen, die vor Android 13 nicht zuverlässig erkennbar sind (03 §3.1).
  - Teilen braucht zwei gehaltene Finger. Das heißt zwei Hände, und das halbe Display ist verdeckt.
- **Ohne Progression? Morgen wieder?** Als Entspannungs-Spielzeug vielleicht, als „noch eine Runde“-Spiel eher nicht. Es gibt wenige Druckpunkte, und der Score „Licht × Größe“ ist abstrakt.
- **Machbarkeit:** Mittel bis hoch. 150 Boids mit räumlichem Hash sind in GDScript machbar, auf Billiggeräten muss man messen.
- **Größtes Risiko:** Fehlendes Kontrollgefühl plus Verdeckung.
- **Billigster Test (½–1 Tag):** Graubox mit Boids und zwei Räubern, keine Erklärung zum Teilen. Abbruch, wenn weniger als 3 von 5 Testern den Schwarm verlässlich um Räuber führen oder niemand ungefragt teilt.

### K03 · PENDEL – Urteil: streichen

- **Wirklich neu?** Gering.
  - Physik-Werkzeug als Steuerung kennt man aus Getting Over It (Feld L).
  - Abrissbirnen- und Flegel-Physik ist ein verbreitetes Motiv. Feld L sagt selbst „nicht verifiziert“ [A]. Eine eigene Suche war wegen des Budgets nicht möglich.
- **Nach 20 Runden:** Wildes Herumschleudern dominiert, das räumt K03-H selbst ein. Das einzige Gegengewicht ist der Seilriss, und genau der ist der unfairste Teil.
- **Können oder Glück?** Gefühlt Glück [E].
  - Die Seilspannung hängt an der Fingergeschwindigkeit.
  - Touch-Abtastung (60–120 Hz) und Latenz erzeugen bei schnellen Wischern Geschwindigkeitsspitzen.
  - Das führt zu Rissen, die niemand vorhersehen kann.
- **Touch:** Im Hochformat strukturell kaputt.
  - Die Kugel *hängt unter* dem Finger, also genau dort, wo Daumen und Hand liegen.
  - Schwung nach oben verlangt Daumenwege in die schwer erreichbare obere Hälfte.
  - Der Umlenkhaken braucht die zweite Hand.
- **Ohne Progression? Morgen wieder?** Nein. 30 Sekunden Zerstörungsspaß, danach Leerlauf.
- **Machbarkeit:** Ein Verlet-Seil ist ok. Das Wickeln um bewegte Haken ist laut Konzept selbst anspruchsvoll.
- **Größtes Risiko:** Verdeckung.
- **Billigster Test (2 Std.):** Kugel am Finger, fünf Kristalle, Bildschirmaufnahme mit Touch-Overlay. Gemessen wird der Zeitanteil, in dem die Kugel unter Hand oder Daumen liegt. Ich erwarte mehr als 40 % [E].

### K04 · LASSO – Urteil: streichen

- **Wirklich neu?** Nein.
  - Sparky trifft das Konzept laut Feld L „sehr nah“.
  - Pokémon Ranger mit seinen Fangkreisen ist bekannt.
  - Der Reiz hängt an Farbsortierung, also an genau der Oberfläche, die 00 §7 abwertet.
- **Nach 20 Runden:** Warten auf Cluster ist der Kern (K04-H). Warten ist das Gegenteil eines Toilettenspiels.
- **Können oder Glück?** Die Cluster entstehen zufällig. Weil die Glühwürmchen vor der Fingerspitze fliehen, wird das Schließen der Schleife zum Gefummel.
- **Touch:** Schleifen am Rand lösen die Zurück-Geste aus. Die Ziele fliehen genau aus dem Bereich, den der eigene Finger verdeckt. Die Laterne braucht eine zweite Hand.
- **Ohne Progression? Morgen wieder?** Nein.
- **Machbarkeit:** Hoch, aber das ist kein Argument.
- **Größtes Risiko:** Das Spiel existiert schon.
- **Billigster Test:** Sparky spielen.

### K05 · FINGERSONNE – Urteil: streichen

- **Wirklich neu?** Nein.
  - *Gravity Force* (Android): Eine Berührung erzeugt eine Masse, dargestellt als Schwarzes Loch, die Asteroidenbahnen biegt. Ziel ist, Asteroiden mit der Schwerkraft des Fingers ins Bild zu lenken [B].
  - Dazu *Orbit*: Planeten per Wisch in Umlaufbahnen um Schwarze Löcher schicken [S].
  - *Save the Comet*: Planeten verschieben, um einen Kometen umzulenken [S].
  - Osmos und Angry Birds Space (Feld L).
- **Nach 20 Runden:**
  - Mit Orbit-Assistenz wird das Einfangen trivial, ohne sie chaotisch.
  - Übrig bleibt der Loslass-Moment, also ein Timing-Tap. Das ist die übernutzteste Mechanik überhaupt (03 §3.2).
- **Können oder Glück?** Der tangentiale Abflug ist physikalisch korrekt, aber kontraintuitiv. Spieler erwarten, dass der Komet dorthin fliegt, wohin sie wischen. Bis man das verinnerlicht hat, wirken Treffer zufällig.
- **Touch:** Halten ist gut. Aber die Hälfte jeder Umlaufbahn liegt unter Finger und Hand, sodass der richtige Loslass-Winkel oft gerade verdeckt ist. Zwei Sonnen brauchen zwei Hände.
- **Ohne Progression? Morgen wieder?** Nein, das ist ein Spielzeug.
- **Machbarkeit:** Hoch.
- **Größtes Risiko:** Prior Art und unlesbare Bahnen.
- **Billigster Test (2 Std.):** Trifft ein Neuling nach zehn Versuchen einen Planeten deutlich öfter, als es mit Zufall zu erwarten wäre?

### K06 · ECHO – Urteil: prototypen, aber umbauen

- **Wirklich neu?** Der Kern nicht.
  - Feld L: Cursor*10 (2008) und The Company of Myself (2009).
  - Dazu eine ganze Jam-Tradition:
    - *Layers of Time* (Ludum Dare 47): Kooperatives Puzzle, in jeder Schleife spielt ein Geist die Eingaben früherer Schleifen ab [B].
    - *Echo Loop* (GMTK 2025): Top-down-Shooter, in dem der vorige Lauf als Geist mitkämpft. In der Jam-Fassung war nur ein Geist stabil, mehr Geister brachten Freezes und Desyncs [B].
    - Weitere Treffer [S].
  - Eigenständig ist nur die Verpackung: 8-Sekunden-Mikroläufe, Kernverteidigung, Touch und ein deterministischer Tagesseed. Der Rahmen „Kern verteidigen“ ähnelt Missile Command und ist austauschbar. Sobald es funktioniert, ist das Klonrisiko hoch.
- **Nach 20 Runden:**
  - Es droht eine Rezeptlösung: Lauf 1 links, Lauf 2 rechts und so weiter, also eine Aufteilung in Tortenstücke.
  - Die ersten ein bis zwei Läufe jeder Runde sind fast leer und reines Polster.
  - Wenn Gegner echte Koordination verlangen, etwa gleichzeitige Treffer, trägt das Konzept. Sonst ist es nach einer Stunde gelöst.
- **Können oder Glück?** Das beste Profil im Feld: deterministisch, jeder Fehler ist sichtbar und reproduzierbar, Scheitern ist nachvollziehbar.
- **Touch:**
  - Ein Finger, kurze Züge, keine Wischgesten vom Rand.
  - Der Lichtpunkt liegt unter der Fingerkuppe. Das lässt sich mit Versatz oder relativer Steuerung lösen.
  - Multitouch fehlt, aber das ist hier ein Vorteil. Mehrere Akteure koordiniert man *nacheinander*, also einhändig und barrierearm. Die Game Accessibility Guidelines raten, keine gleichzeitigen Aktionen zu erzwingen (03 §3.1).
- **Ohne Progression? Installieren und morgen wieder?** Installieren: ja. Morgen wieder: ja, wenn es einen Tagesseed gibt (gleiche Welle für alle, teilbares Ergebnis). Ohne Tagesseed bleibt es ein Rätselhappen.
- **Machbarkeit:** Hoch. Eingabeaufzeichnung plus eigene deterministische Simulation, nicht über Godot-Physik.
- **Größtes Risiko:** Verständnis und Rezeptlösung.
- **Billigster Test (1–2 Tage):** Graubox mit drei Läufen à 8 s, zwei Gegnertypen, kein Text. Abbruchkriterien stehen in Abschnitt 5.2.

### K07 · PRALLFINGER – Urteil: streichen

- **Wirklich neu?** Nein. Pachinko und Peggle, Air-Hockey-Apps und Sortierspiele stehen schon in Feld L. Farbsortierung ist eine übersättigte Oberfläche (00 §1).
- **Nach 20 Runden:** Das Konzept erwartet selbst geringen Wiederspielwert.
- **Können oder Glück?** Die Fingerkuppe als Bumper ist nur auf einige Millimeter genau. Damit sind die Abprallwinkel praktisch zufällig. Das Konzept benennt dieses Risiko selbst.
- **Touch:** Im Kontaktmoment ist die Kugel unter dem Finger verdeckt. Mehrere Bumper heißt mehrere Finger, also zwei Hände.
- **Ohne Progression? Morgen wieder?** Nein.
- **Machbarkeit:** Hoch.
- **Größtes Risiko:** Gefühlte Unfairness bei einer übersättigten Oberfläche.
- **Billigster Test:** Unnötig, die Prior Art reicht als Beleg.

### K08 · SPANNUNG – Urteil: streichen

- **Wirklich neu?** Gering. Das Schläger-Prinzip (Breakout, Pong) plus Schleuder. Die Gummiband-Steuerung mit zwei Daumen ist als Eingabe frisch [E].
- **Nach 20 Runden:** Fangen, Zielen und Schießen auf feste Sternbilder. Die Winkel lernt man schnell, danach bleibt Wiederholung.
- **Können oder Glück?** Können, eine faire Physik ist möglich.
- **Touch:**
  - Eigentlich ist das das ergonomisch sauberste Multitouch-Konzept: Die Daumen liegen unten, das Spielfeld darüber ist frei.
  - Aber beide Hände sind Pflicht. Die Ein-Finger-Variante ist laut Konzept „schwächer“.
  - Schlimmer: „Schnelles Hochziehen = Schuss“ mit den Daumen am unteren Rand ist dieselbe Bewegung wie die nicht abschaltbare Home-Geste (03 §3.1).
- **Ohne Progression? Morgen wieder?** Nein.
- **Machbarkeit:** Hoch.
- **Größtes Risiko:** Zu flach, plus Konflikt mit Systemgesten.
- **Billigster Test (2 Std.):** Auf Phones mit Gestennavigation zählen, wie oft beim Schuss versehentlich die Home-Geste ausgelöst wird.
- **Verwertbar:** Der Gedanke des Akkords (beide Daumen ergeben eine dritte Aktion, vgl. Data Wing in 03) für die Nachideation.

### K09 · ZWEILEINER – Urteil: streichen

- **Wirklich neu?** Auf Mobile ungewöhnlich, als Vorbild nennt Feld L Ice Cold Beer. Prior Art habe ich nicht geprüft.
- **Nach 20 Runden:** Ringe und Loopings auf einem Kurs. Das liegt nahe am verbotenen Startpunkt „Runner“, nur mit Trick-Zusatz.
- **Können oder Glück?** Können. Aber die Differenzialsteuerung über zwei analoge Leinen hat eine steile, frustrierende Lernkurve und erinnert an QWOP [E].
- **Touch:**
  - Zweihändig zwingend. Das widerspricht direkt dem Briefing, und das Konzept räumt es selbst ein.
  - Daumen nahe den Seitenrändern mit Ziehbewegungen nach innen lösen die Zurück-Geste aus.
  - Ausnahmebereiche für Gesten sind auf 200 dp begrenzt (03 §3.1).
- **Ohne Progression? Morgen wieder?** Nein.
- **Machbarkeit:** Mittel, wegen des Aerodynamik-Tunings.
- **Größtes Risiko:** Die Lernkurve.
- **Billigster Test:** Zeit bis zum ersten Ring bei Neulingen messen. Das lohnt nicht, das Konzept verletzt das Briefing ohnehin.

### K10 · WELLENGANG – Urteil: parken

- **Wirklich neu?** Unklar, eine Suche war wegen des Budgets nicht mehr möglich. Indirekte Steuerung über Wellen als Kern eines Arcade-Spiels kenne ich nicht. Verwandte sind Boomshine (Ringe) und Osmos (Rückstoß) [A].
- **Nach 20 Runden:** Ein Schieberätsel ohne Druck. Das Konzept warnt selbst vor „schwammiger Kontrolle“. Interferenz durch zwei gleichzeitige Taps ist physikalisch hübsch, für Spieler aber unlesbar.
- **Können oder Glück?** Deterministisch und fair, aber mit niedriger Präzisionsdecke.
- **Touch:** Das beste Eingabeprofil im Feld.
  - Man tippt *hinter* das Objekt. Dadurch gibt es keine Verdeckung, und es geht einhändig.
  - Taps am Rand sind unkritisch (03 §3.4 Punkt 1).
  - Nur der Doppeltipp braucht ein Zeitfenster für „gleichzeitig“ und wird Fehlbedienungen erzeugen.
- **Ohne Progression? Morgen wieder?** Als Zen-Modus vielleicht. Für die Zielhypothese „Spannung“ aus 00 §6 ist es zu spannungsarm.
- **Machbarkeit:** Hoch.
- **Größtes Risiko:** Das Gefühl „ich steuere nichts“.
- **Billigster Test (2 Std.):** Drei Laternen, eine Bucht, 30 s. Danach das Kontrollgefühl auf einer Skala von 1–5 abfragen.
- **Verwertbar:** Das Eingabeprinzip „Wirkung hinter dem Ziel auslösen“.

### K11 · ZEITBLASE – Urteil: parken

- **Wirklich neu?** Teilweise.
  - Zeitstopp ist bekannt (Braid, Superhot).
  - Eine autonome Figur, deren Umgebung man formt, ebenfalls (Lemmings; GMTK-2024-Sieger „Panda“, 02 §2.8).
  - Fallende Trümmer einzufrieren, um daraus Brücken zu bauen, wirkt als Kombination frisch [E]. Prior Art habe ich nicht geprüft.
- **Nach 20 Runden:**
  - Das Konzept spricht selbst von „Levelcharakter“, also einer Content-Tretmühle.
  - Prozedural erzeugte Trümmerfälle, die garantiert lösbar sind, sind schwer zu bauen.
  - Ohne Garantie entsteht Frust über „unmögliche Level“. Spieler hassen das nachweislich (01 §5.3 Punkt 5). „Every puzzle has a solution“ wird gelobt (01 H4).
- **Können oder Glück?** Mit handgebauten Leveln fair, prozedural riskant.
- **Touch:**
  - Der Haltefinger liegt genau auf der Brücke, die man sehen muss.
  - Die Kugel rollt unten durchs Bild, also unter der Hand.
  - Bis zu drei Finger gleichzeitig sprengen das Pointer-Budget (Basis 2, 03 §3.4 Punkt 6) und die Einhandigkeit.
- **Ohne Progression? Morgen wieder?** Einmal ja, für den Aha-Moment. Danach ist der Inhalt verbraucht.
- **Machbarkeit:** Mittel. Die Physik ist einfach, ein Generator mit Lösbarkeitsgarantie ist schwer.
- **Größtes Risiko:** Content-Hunger plus Verdeckung.
- **Billigster Test:** Fünf handgebaute Szenen. Ein Bot prüft, welcher Anteil zufälliger Varianten lösbar ist.

### K12 · SPIEGELSTURM – Urteil: streichen

- **Wirklich neu?** Nein. Spiegel- und Laser-Puzzles sind ein eigenes Genre. „Bedrohung läuft auf einen Kern zu“ ist das Grundmuster von Tower Defense und liegt damit nah am verbotenen Standard-TD.
- **Nach 20 Runden:** Spiegel drehen heißt Geschütz ausrichten. Kettenreflexionen sind schön, lassen sich unter Zeitdruck am Phone aber kaum planen.
- **Können oder Glück?** Können, Raycasts sind exakt.
- **Touch:** Eine Kreisgeste auf kleinen Spiegeln ist langsam und ungenau. Der Finger verdeckt Spiegel und Strahlursprung. Zwei Spiegel brauchen zwei Hände.
- **Ohne Progression? Morgen wieder?** Nein.
- **Machbarkeit:** Hoch.
- **Größtes Risiko:** Eine Kreisgeste unter Zeitdruck.
- **Billigster Test (2 Std.):** Dreh-Präzision und Zeitbedarf messen. Das lohnt aber nicht, das Konzept ist TD-nah.

---

## 4. Bewertung (Teil B)

**Formel:** Gesamt = Σ (Punkte × Gewicht), Gewichte in Prozent. Alle Punkte sind **Hypothesen** und meine unabhängige Einschätzung, keine Playtest-Ergebnisse. Die Summen sind per Skript nachgerechnet.

**Spaltenkürzel:**
- **Spaß:** Tatsächlicher Spielspaß (25 %)
- **Eigen:** Eigenständigkeit (20 %)
- **Wieder:** Wiederspielwert (20 %)
- **Mobile:** Mobile-Steuerung (10 %)
- **Verst.:** Schnelle Verständlichkeit (10 %)
- **Tech:** Technische Realisierbarkeit (5 %)
- **AV:** Audiovisuelle Möglichkeiten (5 %)
- **Monet.:** Faire Monetarisierbarkeit (5 %)

| # | Konzept | Spaß | Eigen | Wieder | Mobile | Verst. | Tech | AV | Monet. | **Gesamt** |
|---|---|---|---|---|---|---|---|---|---|---|
| 1 | K01 LUNTE | 6 | 7 | 5 | 5 | 7 | 9 | 9 | 7 | **6,35** |
| 2 | K06 ECHO | 6 | 5 | 6 | 6 | 5 | 8 | 8 | 7 | **5,95** |
| 3 | K10 WELLENGANG | 4 | 5 | 4 | 7 | 7 | 8 | 8 | 6 | **5,30** |
| 4 | K11 ZEITBLASE | 5 | 6 | 4 | 3 | 7 | 6 | 7 | 6 | **5,20** |
| 5 | K02 SCHWARM | 5 | 4 | 4 | 4 | 8 | 7 | 9 | 6 | **5,15** |
| 6= | K03 PENDEL | 5 | 4 | 4 | 3 | 7 | 6 | 8 | 6 | **4,85** |
| 6= | K05 FINGERSONNE | 5 | 3 | 4 | 5 | 6 | 8 | 8 | 6 | **4,85** |
| 8 | K08 SPANNUNG | 4 | 4 | 3 | 5 | 7 | 8 | 7 | 6 | **4,65** |
| 9 | K12 SPIEGELSTURM | 4 | 3 | 4 | 3 | 7 | 8 | 7 | 6 | **4,45** |
| 10= | K04 LASSO | 4 | 2 | 3 | 5 | 8 | 8 | 7 | 6 | **4,35** |
| 10= | K09 ZWEILEINER | 4 | 5 | 3 | 4 | 4 | 6 | 7 | 6 | **4,35** |
| 12 | K07 PRALLFINGER | 3 | 2 | 3 | 3 | 8 | 9 | 6 | 6 | **3,90** |

**Begründung in je einer Zeile:**
- **K01:** Stärkster Hook und beste AV-Chance im Feld. Laut Simulation belohnt die aktuelle Fassung aber Zeichentempo statt Entscheidungen, und die Hand verdeckt Funken oder Weg.
- **K06:** Fairstes Konzept, einhändig, mit echtem Aha-Moment. Der Kern ist ein Jam-Dauerbrenner, Verständnis und Rezeptlösung sind offen.
- **K10:** Bestes Eingabeprofil (Tippen hinter das Ziel, keine Verdeckung), aber spannungsarm und schwammig.
- **K11:** Frische Kombination der Verben, aber hungrig nach Leveln, der Haltefinger verdeckt die Brücke, bis zu drei Finger.
- **K02:** Schönste Atmosphäre, aber der Schwarm liegt unter dem Finger, die Kontrolle ist indirekt, und das Teilen existiert schon als Spielzeug.
- **K03:** Das Gewichtsgefühl reizt, aber die Kugel hängt in der Hand und der Seilriss wirkt willkürlich.
- **K05:** Der Kern existiert schon (Gravity Force). Übrig bleibt ein Timing-Tap mit verdecktem Loslass-Winkel.
- **K08:** Ergonomisch sauber, aber zweihändig erzwungen, mit Home-Gesten-Konflikt und als Schlägerspiel zu flach.
- **K12:** TD-Grundmuster mit einer langsamen, verdeckten Kreisgeste.
- **K04:** Fast identische Prior Art (Sparky), Farbsortierung, Warten als Kern.
- **K09:** Zweihändig erzwungen, Kursflug nahe am Runner, steile Lernkurve.
- **K07:** Sortier-Oberfläche plus Zufallsphysik am Finger.

**Hinweis zu den Monetarisierungspunkten:** Bewertet ist unter der Vorgabe des Briefings, also werbefinanziert ohne IAP. Runden von 1–2 Minuten mit natürlichem Ende (K01, K06) passen besser zu Werbung nach dem Score-Screen als Mikro-Runden. Bei Runden von 30 s wäre Werbung nach jeder Runde ein extremes Verhältnis von Werbung zu Spielzeit (03 §4.2 T1).

---

## 5. Empfehlung (Teil C)

### 5.1 Prototyp 1: K01 LUNTE (umgebaut)

**Hypothese A:** Pfadzeichnen in Echtzeit mit unmittelbaren Folgen trägt 20 und mehr Runden, wenn *Entscheidungen* über den Score bestimmen (Route, Risiko, Schleifen) und nicht das Zeichentempo.

Ich empfehle LUNTE **nicht**, weil es schon angefangen ist, sondern **obwohl** es schon angefangen ist. Es hat den stärksten Hook im Feld, und seine Schwächen lassen sich mit der vorhandenen Simulation billig testen.

**Umbauten vor dem nächsten Test:**

1. **Die Uhr an Entscheidungen koppeln statt an die Zeit.**
   - Das Funkentempo steigt nicht mehr mit der Zeit, sondern pro Zündung: Erfolg beschleunigt die Jagd.
   - Zündet man nichts, sinkt es langsam.
   - Die Obergrenze liegt deutlich unter dem gemessenen bequemen Zeichentempo echter Spieler.
   - Dann entscheidet die Frage „nehme ich diesen Körper noch mit?“ über das Rundenende, nicht die Motorik.
   - Alternative: eine sichtbare „Luntenrolle“ mit begrenzter Länge als Sessionuhr, also ein Aktionsbudget statt einer Uhr (02 §3, Baustein 16).
2. **Gier muss etwas kosten.**
   - Hitze nährt das Feuer: Bei ×2 und ×3 brennt die Lunte schneller, Richtwert +15 % bzw. +30 %.
   - Abnahme im Bot-Test: Bei gleichem Zeichentempo muss das Profil mit 0,75 s Abstand deutlich kürzer überleben als das mit 2,2 s. Sonst bleibt das Risiko gratis.
3. **Die Kreuzung vom Unfall zum Werkzeug machen.**
   - Eine geschlossene Schleife über der eigenen unverbrannten Lunte wird zum „Kurzschluss“: Alle aufgefädelten Körper *innerhalb* der Schleife zünden gleichzeitig, das ergibt eine große Kette.
   - Dafür springt das Feuer zur Kreuzung, und der Abstand schrumpft.
   - Das ist lesbar, riskant und lohnend. Gleichzeitig übernimmt es das einzige gute Element aus K04.
4. **Keine unsichtbaren Todesursachen.**
   - Böller zeigen ihren Explosionsradius, sobald sie aufgefädelt sind. Lunten-Stücke im Radius glühen rot.
   - Alternative: Böller zünden nur Feuerwerk, nie die Lunte.
   - Ziele: In der Simulation unter 15 % Tode durch Böller (heute 30–45 %). Bei Menschen unter 10 % Tode, die sie selbst nicht erklären können.
5. **Gegen Verdeckung und für saubere Android-Gesten.**
   - Der Lunten-Kopf sitzt mit Versatz über der Fingerkuppe, oder es gibt einen relativen Modus. Der A/B-Test dazu steht schon im Playtest-Protokoll.
   - Den Abstand zusätzlich über die Tonhöhe des Knisterns, einen Haptik-Puls und eine Leiste am **oberen** Rand anzeigen.
   - Die Zündkerze startet im mittleren Drittel statt „unten mittig“.
   - Toleranz beim Umgreifen: Der Funke wird 0,5 s langsamer, solange kein Finger auf dem Display liegt.
6. **Umfang:** Den Doppelzünder (zweiter Finger) aus dem Prototyp streichen. LUNTE ist ein Ein-Finger-Spiel. Multitouch nur wegen des Kriteriums anzukleben, wäre genau der Gimmick, den das Briefing verbietet.

**Abbruchkriterien (vor dem Test fixieren):**

Getestet wird mit 5 Personen × 10 Runden auf echten Phones, mit Telemetrie und `PLAYTEST_PROTOCOL.md`.

- Erklärt das mittlere Zeichentempo mehr als die Hälfte der Score-Streuung (R² > 0,5), wird das Konzept gestoppt oder neu entworfen.
- Können Spieler mehr als 20 % der Tode nicht korrekt erklären, und ist das auch nach Umbau 4 so, wird das Konzept gestoppt.
- Starten weniger als 3 von 5 nach Runde 10 ungefragt eine weitere Runde, wird das Konzept gestoppt.
- Überlebt im Bot-Test das gierige Profil nicht kürzer als das vorsichtige, ist die Risiko-Mechanik gescheitert.

### 5.2 Prototyp 2: K06 ECHO (umgebaut)

**Hypothese B:** Planung über 8-Sekunden-Mikroläufe, also Kooperation mit den eigenen Echos, erzeugt „noch eine Runde“ ohne Reflexdruck. Gleichzeitig liefert sie die Koordination mehrerer Akteure, die man sonst von Multitouch kennt, einhändig und nacheinander.

**Umbauten:**

1. **Verständnis durch erzwungenes Scheitern.**
   - In Runde 1 kommen Gegner gleichzeitig von zwei Seiten. Allein kann man nur eine Seite halten.
   - Lauf 2 zeigt dann sofort das Echo.
   - Die erste Runde hat höchstens drei Läufe, vier bis sechs erst später.
2. **Gegner, die echte Choreografie erzwingen** (gegen die Tortenstück-Lösung):
   - „Zwillinge“ sterben nur bei zwei Treffern innerhalb von 0,3 s.
   - „Panzer“ sterben nur bei Treffern aus zwei Richtungen.
   - Eine „Kette“ aus zwei per Strahl verbundenen Gegnern stirbt nur, wenn beide Enden gleichzeitig berührt werden.
3. **Push-your-luck statt Absitzen.**
   - Nach jedem Lauf darf man werten („Bank“).
   - Weniger Läufe bedeuten einen höheren Multiplikator, etwa ×6 bei Lösung im ersten Lauf bis ×1 im sechsten.
   - Damit wird jeder Lauf zur Entscheidung: noch ein Echo, oder jetzt kassieren?
4. **Planung sichtbar und hörbar machen.**
   - Vor jedem Lauf erscheinen die Bahnen aller Echos als blasse Linien, dazu oben eine Zeitleiste über 8 s.
   - Jedes Echo singt eine Stimme des Kanons (K06-J), sodass Timing hörbar wird.
   - Gegner kündigen sich 1 s vorher am Rand an.
5. **Gegen Verdeckung:**
   - Lichtpunkt mit Versatz über der Fingerkuppe oder relative Steuerung.
   - Kern im oberen Mittelfeld.
   - Keine Gegner vom unteren Rand, denn dort liegt die Hand.
6. **Multitouch mit echtem Nutzen, aber optional, plus Tagesseed.**
   - Ein zweiter Finger nimmt in *einem* Lauf zwei Echos auf. Das spart einen Lauf und bringt einen höheren Multiplikator. Eine Experten-Option, nie Pflicht.
   - Ein Tagesseed: gleiche deterministische Welle für alle, teilbares Ergebnis wie „gelöst mit 3 Echos“ (01 H2/H8). LinkedIn meldet für sein Tagesrätsel 86 % Rückkehr am Folgetag (01 B3).

**Abbruchkriterien:**
- Weniger als 4 von 5 Testern erklären die Echo-Regel nach Runde 1 richtig (t2 im Playtest-Protokoll).
- Die Zeit bis zur ersten *absichtlichen* Nutzung eines Echos liegt im Median über 20 s.
- Nach 5 Runden spielen alle dasselbe Rezept, es ist also höchstens eine Strategie zu beobachten.
- Weniger als 3 von 5 spielen ungefragt mindestens 3 weitere Runden.

### 5.3 Warum genau diese zwei

| | K01 LUNTE | K06 ECHO |
|---|---|---|
| Kernreiz | Verfolgung, Risiko, Kettenreaktion | Planung, Koordination, Aha-Moment |
| Eingabe | durchgehendes Ziehen | kurze Züge in 8-s-Fenstern |
| Wahrscheinlichste Fehlerquelle | Motorik und Verdeckung | Verständnis |
| Session-Rhythmus | eine durchgehende Runde von 1–2 min | 3–6 Häppchen à 8 s |
| Antwort auf „Multitouch“ | bewusst keins | zeitlich, plus optionaler 2. Finger |
| Marktbezug | Spannungs-Arcade (00 §6) | puzzle-nah, Tagesseed (01 H2) |

Scheitern **beide**, liegt das Problem nicht am Einzelkonzept, sondern am Suchraum. Dann folgt der Neustart aus Abschnitt 6.

**Ausdrücklich nicht empfohlen ist K02, obwohl die Innovation Map es lobt.** Ihr Argument „kein Multitouch-Vorbild“ ist widerlegt, siehe Swarm Multitouch. Außerdem testet K02 dieselbe Hypothese „Finger als Avatar in Echtzeit“ wie K01, nur mit schlechterer Kontrolle.

### 5.4 Streichliste und Parkplatz

**Sofort streichen:**
- **K04 LASSO:** Nahezu identische Prior Art (Sparky). Der Reiz ist Farbsortierung, der Kern ist Warten.
- **K07 PRALLFINGER:** Sortier-Oberfläche, Zufallsphysik am Finger, im Kontaktmoment verdeckt.
- **K03 PENDEL:** Die Kugel hängt in der Hand, ein strukturelles Verdeckungsproblem. Der Seilriss wirkt willkürlich, Schleudern dominiert.
- **K05 FINGERSONNE:** Der Kern existiert bereits (Gravity Force und Verwandte). Übrig bleibt ein Timing-Tap mit verdecktem Loslass-Winkel.
- **K12 SPIEGELSTURM:** TD-Grundmuster mit langsamer, verdeckter Kreisgeste.
- **K09 ZWEILEINER:** Zweihändig erzwungen, gegen das Briefing. Kursflug nahe am Runner, steile Lernkurve.
- **K08 SPANNUNG:** Schlägerspiel mit erzwungenen zwei Händen und Konflikt mit der Home-Geste, zu flach.

**Parken** (nicht prototypen, aber Teile verwerten):
- **K10:** Das Prinzip „Wirkung hinter dem Ziel auslösen, nichts verdecken“ geht in die Nachideation.
- **K11:** Die Zeitstopp-Blase als mögliches Verb in einem deterministischen Puzzle-Arcade. Nur mit Generator, der Lösbarkeit garantiert.
- **K02:** Schwarmverhalten als Verhalten von *Gegnern* oder *Ressourcen*, zum Beispiel in ECHO, nicht als Steuerung.

---

## 6. Neustart? (Teil D)

**Klare Antwort:** Keines der zwölf Konzepte ist in der vorliegenden Form gut genug. Einen Totalneustart fordere ich **jetzt trotzdem nicht**:
- Zwei Konzepte haben einen klaren, billig testbaren Kern.
- LUNTE ist zur Hälfte gebaut.
- Zwei kurze Hypothesentests sind günstiger als ein Neustart ins Blaue.

**Ich fordere aber zweierlei:**
1. **Pflicht-Nachideation, parallel und eng geführt.** Ein Durchgang mit 6–8 Konzepten in gleicher Ausarbeitungstiefe, gebunden an die Leitplanken unten. Das Feld ist zu einseitig, um daraus „das“ Spiel zu wählen.
2. **Automatischer Totalneustart**, wenn beide Prototypen ihre Abbruchkriterien reißen. Dann gilt nicht „wir nehmen den Drittplatzierten“. K10, K11 und K02 liegen alle unter meiner Schwelle von 5,5.

**Leitplanken für Nachideation bzw. Neustart:**

1. **Der Finger ist nicht der Avatar.**
   - Erlaubte Kern-Eingaben:
     - relativ (irgendwo ziehen, Desert-Golfing-Prinzip),
     - Festlegen beim Loslassen (Holedown),
     - Tippen *neben* oder *hinter* das Ziel (K10-Prinzip),
     - zwei große Daumenzonen mit Akkord (Data Wing, 03 §2.2.3).
   - Jedes Konzept braucht eine Pflichtskizze: Wo liegt die Hand, und was ist darunter?
2. **Entscheidungsdichte vor Motorik.**
   - Alle 2–5 s eine lesbare Entscheidung.
   - Ein Bot mit perfekter Motorik darf **nicht** automatisch Bestwerte holen.
   - Mit der vorhandenen Simulationspipeline ist das prüfbar. Deshalb muss jedes Konzept so beschrieben sein, dass ein Bot es spielen kann.
3. **Deterministisch und seedbar.** Tagesseed, gleicher Inhalt für alle, teilbares Ergebnis (01 H2/H4/H8).
4. **Session-Ende über Aktionsbudget oder Ziel, nicht über eine versteckte Beschleunigungs-Uhr.** Vorbilder sind 02 §3 Baustein 16 und der Sonnenuntergang in Tiny Wings (03 §2.2.10).
5. **Mindestens ein Drittel der Konzepte im größeren Segment „ruhig, aber entscheidungsdicht“.** Puzzle hat 53 % des Werbeumsatzes, Arcade 13 % (01 §5.1). Gefordert ist ein **neues Verb**, keine neue Oberfläche.
6. **Ungenutzte Bausteine aus der eigenen Recherche aufgreifen:**
   - Zielen-und-Loslassen-Kaskade mit Statik (Holedown, 02 §2.10)
   - räumliches 1-aus-3-Drafting in 90 s (Blue Prince, 02 H1)
   - Push-your-luck-Extraktion in 60 s (Bore Blasters, 02 H7)
   - Arena-Rand als Ressource plus Pinch (Windowkill und Stretchmancer, 02 §6)
7. **Multitouch nur, wenn ein Test zeigt, dass Spieler ihn freiwillig nutzen.** Sonst lieber „zeitliches Multitouch“ wie bei ECHO oder einen Akkord als einen angeklebten zweiten Finger.
8. **Prozess:**
   - Prior-Art-Suche **vor** der Bewertung.
   - Keine Statisten mit Einzeilern.
   - Jedes Konzept beantwortet selbst die Frage „Welche Strategie dominiert, und was kostet sie?“.

---

## 7. Quellen

### Intern
- `docs/concepts/CONCEPTS.md`
- `docs/research/00_INNOVATION_MAP.md`
- `docs/research/01_mobile_market.md`
- `docs/research/02_indie_experimental.md`
- `docs/research/03_touch_and_sentiment.md`
- `docs/playtests/PLAYTEST_PROTOCOL.md`
- `game/data/balance/lunte.json`
- `game/scripts/gameplay/fuse/fuse_sim.gd`
- `game/scripts/gameplay/fuse/lunte_bot.gd`
- `game/tests/simulation/sim_lunte.gd`

### Simulation reproduzieren
1. Projektkopie anlegen.
2. `godot --headless --path <kopie>/game --script res://tests/simulation/sim_lunte.gd -- 40` ausführen.
3. In der Kopie in `lunte_bot.gd` die Profile `{gap 2.2/1.3/0.75 s, speed 300}` und `{gap 1.3 s, speed 230/400}` ergänzen und in `sim_lunte.gd` in die Profil-Schleife eintragen.

Die Rohdaten lagen nur im Session-Scratchpad und sind nicht eingecheckt.

### Web, selbst geöffnet [B]
- **Swarm Multitouch** (Brett Aukburg, iOS, v1.0 vom 21.10.2016): Ein Finger lässt den Schwarm folgen, mehrere Finger teilen ihn, bis zu neun Gruppen; keine Ziele, keine Gegner. https://apps.apple.com/app/id1166671935
- **Echo Loop** (GMTK Game Jam 2025, Devlog 04.08.2025): Top-down-Shooter, der vorige Lauf kämpft als Geist mit; nur ein Geist stabil. https://randomgamecoder.itch.io/echo-loop/devlog/1001709/echo-loop-devlog-01-game-jam
- **Layers of Time** (Ludum Dare 47): In jeder Schleife spielt ein Geist frühere Eingaben ab, Kooperation mit vergangenen Ichs. https://kaldrin.itch.io/ld47
- **Gravity Force** (`com.gravityplay`, Android/F-Droid, v1.1.7 von 2023): Die Berührung wird zu einer Masse, die Asteroidenbahnen biegt. https://f-droid.org/es/packages/com.gravityplay/

### Web, nur als Suchtreffer gesehen [S]
- Orbit: https://chetansurpur.itch.io/orbit
- Save the Comet: https://www.moddb.com/games/save-the-comet/articles
- Timeloop (2009): https://toucharcade.com/2009/08/13/timeloop-a-time-traveling-puzzler/
- The Time Loop Labyrinth: https://www.pyxelstudio.net/vslzk349
- Finger Forest: https://experiments.withgoogle.com/finger-forest
- TouchArcade-Forum „Innovative multitouch games“: https://toucharcade.com/community/threads/innovative-multitouch-games.17162/

### Erfolglose bzw. abgebrochene Suchen
- **Erfolglos (K01):** Die Suche nach einem Spiel, in dem man eine Lunte zeichnet und der Funke den Finger jagt, lieferte nur Seiten zur Feuerwerkssicherheit.
- **Wegen des erschöpften Suchbudgets nicht ausgeführt:** Zweitsuche zu K01 sowie Suchen zu K10, K11 und K03.

### Allgemeinwissen, nicht verifiziert [A]
Swarm (Hothead Games, 2011), LocoRoco, Crowd City, Paper.io, Snake/Tron, Getting Over It, Superhot, Braid, Lemmings, Pong/Breakout, Peggle, QWOP, Missile Command.
