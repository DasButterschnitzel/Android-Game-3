# Spielkonzepte – Phase 2

Autor: Agent C (Experimental Gameplay Designer) · Stand: 2026-10-22
Grundlage: Recherche in `docs/research/` und gezielte Prior-Art-Suchen (siehe jeweils Feld L).

Alle Konzepte sind für **Hochformat**, **Runden von 30 s – 3 min**, **ohne Netz** und **werbefinanziert ohne IAP**
gedacht. Bewertung erfolgt getrennt (`SCORING.md`), Kritik durch Agent D (`CRITIC_REVIEW.md`).

Legende Feld L: „belegt“ = per Websuche/Quelle geprüft; „bekannt“ = allgemein bekannter Klassiker;
„nicht verifiziert“ = Vermutung, nicht als Fakt verwenden.

---

## K01 · LUNTE

**A. Arbeitstitel** – LUNTE

**B. Elevator Pitch** – Du ziehst mit dem Finger eine Zündschnur über den Nachthimmel, und der Funke brennt
dir hinterher. Fädle Feuerwerk auf, bevor er dich einholt – hinter deinem Finger explodiert der Himmel.

**C. Kernmechanik** – Ein Finger zieht eine durchgehende Linie (die Lunte). Ein Funke läuft mit langsam
steigender Geschwindigkeit *entlang genau dieser Linie* hinterher. Feuerwerkskörper, durch die die Lunte
führt, sind „aufgefädelt“ und zünden, sobald der Funke sie erreicht. Abheben ist erlaubt: Man setzt den
Finger wieder auf das Luntenende und zieht weiter – der Funke läuft währenddessen weiter. Kreuzt man die
eigene, noch unverbrannte Lunte, entsteht eine **Abkürzung**: Der Funke springt an der Kreuzung über,
der übersprungene Abschnitt (samt Feuerwerk) verpufft. Die Runde endet, wenn der Funke das Luntenende
erreicht. Punkte pro Zündung werden mit einem **Hitze-Multiplikator** verrechnet: Je knapper der Funke
hinter dir ist, desto mehr zählt jede Zündung (×1 / ×2 / ×3).

**D. Die ersten 30 Sekunden**
- 0 s: Dunkler Himmel, unten mittig glimmt eine Zündkerze, ein pulsierender Pfeil: „Zieh!“.
- 1–3 s: Finger auf die Kerze, ziehen – eine glühende Lunte entsteht, leises Knistern unter dem Finger.
- 3 s: Der Funke springt über und folgt gemächlich. Drei Feuerwerkskörper liegen genau im natürlichen Zugweg.
- 6 s: Erster Körper aufgefädelt (Klick, er leuchtet auf). Funke erreicht ihn → erste Explosion, Ton, Punkte.
- 12 s: Eine Rakete erscheint. Aufgefädelt fliegt sie bei Zündung los und zündet unterwegs ein zweites
  Feuerwerk → erste Kettenreaktion ohne eigenes Zutun.
- 20–30 s: Der Funke wird spürbar schneller, der Bildschirm füllt sich mit der eigenen Lunte. Der Spieler
  merkt: Nah am Funken = ×3. Erster „Puh, knapp!“-Moment.

**E. Core Gameplay Loop** – Feuerwerk erscheint → Route planen → auffädeln → Funke zündet hinter dir →
Punkte/Kette → Tempo steigt → Platz wird knapp → neue Routenentscheidung. Spaß entsteht aus drei
gleichzeitigen Spannungen: Verfolgung (Tempo), Raum (die eigene Lunte blockiert) und Gier (Hitze-Bonus).

**F. Hook** – Dein Schwanz ist eine brennende Zündschnur. Du baust die Kettenreaktion im Laufen – und sie jagt dich.

**G. Mastery** – effiziente Routen; Abstand zum Funken bewusst klein halten; Raketen und Böller für
Fernzündungen nutzen; Explosionen von der eigenen Lunte fernhalten (Funkenflug kann sie vorne entzünden);
Raum managen, ohne sich einzukesseln; für Experten: **Doppelzünder** spaltet den Funken – mit einem
zweiten Finger zieht man eine zweite Lunte parallel.

**H. Wiederspielwert** – prozedural verteilte Feuerwerkstypen (reproduzierbare Seeds), emergente Ketten,
Highscore-Jagd, Varianten („Ein Atemzug“: Absetzen verboten; „Sturm“: Wind verbiegt die Lunte),
freischaltbare Himmelspaletten und Feuerwerksfarben. Die 50. Runde ist interessant, weil Raum und
Kettenpotenzial jede Runde anders verteilt sind und der Spieler aktiv das Risiko wählt.

**I. Technische Machbarkeit** – Polyline mit Bogenlängen-Parametrisierung; Funke = Position auf der Bogenlänge;
Selbstschnitt-Erkennung (Segment-Tests mit Raster-Beschleunigung); Partikelsysteme; Spawn-Logik mit
Fairness-Validierung; reine 2D-Logik, gut testbar und simulierbar. Hoch machbar.

**J. Audiovisuelle Vision** – Nachthimmel in Tinte und Papier (leichtes Korn, Vignette); die Lunte als
glühende, minimal zitternde Linie mit Glutpartikeln; Feuerwerk als stilisierte Papierkörper mit Mustern;
Explosionen additiv mit Nachglühen und langsam sinkendem Rauch. Audio: Knistern, dessen Tonhöhe der
Funkengeschwindigkeit folgt; jede Zündung spielt einen Ton einer Pentatonik, Ketten bauen Akkorde.

**K. Werbetauglichkeit** – Natürlicher Bruch nach jeder Runde (Funke hat dich eingeholt). Optionales
Rewarded: einmalige „Ersatzlunte“ pro Runde (Score separat markiert) oder kosmetische Palette testen.

**L. Vergleichbare Spiele**
- Snake / Slither.io (bekannt): wachsender Körper, Selbstkollision – aber dort ist der Körper Futter-abhängig, nicht Tempo-abhängig.
- Flight Control (bekannt, 2009): Pfade in Echtzeit zeichnen.
- Fuse Runner (belegt, Jam-Prototyp, HTML5): Lunte zur Bombe zeichnen, bevor sie abbrennt; levelbasiert,
  ohne Verfolgung entlang der eigenen Linie, ohne Ketten. https://astrogamestudios.itch.io/fuse-runner
- Burn the Rope (belegt, Big Blue Bubble): Flamme wandert an Seilen, Steuerung durch Neigen.
- Boomshine (bekannt): Kettenreaktionen durch expandierende Explosionen.

---

## K02 · SCHWARM

**A. Arbeitstitel** – SCHWARM

**B. Elevator Pitch** – Du bist kein Fisch, du bist vierzig. Führe einen leuchtenden Schwarm mit dem Finger
durch ein dunkles Riff voller Räuber – mit zwei Fingern teilst du ihn.

**C. Kernmechanik** – Finger halten/ziehen setzt einen Lockpunkt, der Schwarm folgt mit Flocking-Verhalten.
Ein zweiter Finger teilt den Schwarm nach Nähe in zwei Gruppen; hebt man einen Finger, vereinen sie sich.
Planktonwolken einsammeln → neue Fische schließen sich an. Räuber (Hecht: Sturmangriff mit Vorwarnung,
Qualle: treibt, nesselt bei Berührung, Anemone: lokale Falle) fressen Nachzügler. Runde endet, wenn kein
Fisch mehr übrig ist. Score = gesammeltes Licht × Schwarmgröße.

**D. Die ersten 30 Sekunden** – 12 leuchtende Fische um eine Lichtquelle, Hinweis „Berühren und führen“.
Spieler zieht, der Schwarm fließt hinterher (sofort befriedigend). 5 s: Planktonwolke → +3 Fische, satter
Klang. 12 s: Schatten kündigt einen Hecht an; Ausweichen, 1–2 Nachzügler gehen verloren (klares Feedback).
20 s: zwei Wolken links und rechts, Zwei-Finger-Symbol → Schwarm teilen, beide einsammeln.

**E. Core Loop** – sammeln → wachsen → größerer Schwarm ist träger und auffälliger → teilen/vereinen → überleben.

**F. Hook** – Multitouch teilt einen lebendigen Schwarm. Köder-Taktik: eine kleine Gruppe opfern, um den Räuber wegzulocken.

**G. Mastery** – Schwarmform über Tempo steuern (schnell = langgezogen), Timing beim Teilen und Vereinen,
Räubermuster lesen, bewusstes Opfern.

**H. Wiederspielwert** – Räuber-Kombinationen, prozedurale Riffe/Strömungen, emergentes Schwarmverhalten.
Risiko: wenige *Entscheidungsarten*; Variation entsteht vor allem durch Gegnermix.

**I. Technische Machbarkeit** – Boids (40–150 Agenten) mit räumlichem Hash, einfache Räuber-KI,
Strömungsfeld. Machbar; Performance auf schwachen Geräten muss gemessen werden.

**J. Audiovisuelle Vision** – Biolumineszenz in tiefem Blau, Fische als leuchtende Kommaformen mit Schweif,
Räuber als dunkle Silhouetten mit leuchtenden Augen. Ambient-Musik, deren Schichten mit der Schwarmgröße wachsen.

**K. Werbetauglichkeit** – Nach Rundenende. Rewarded: kosmetische Schwarmfarbe.

**L. Vergleichbare Spiele**
- Koi [LD56] (belegt, Jam): Schwarm boid-artiger Fische per Maus führen, Futter fressen, Räubern ausweichen. https://a-priori-games.itch.io/koi
- Flock! (bekannt, 2009): Schafe per UFO-Traktorstrahl hüten.
- flOw / Osmos (bekannt): organisches Wachstum.
- Crowd-Runner wie Count Masters (bekannt): Gruppengröße als Lebensbalken – aber linear, ohne Flocking.

---

## K03 · PENDEL

**A. Arbeitstitel** – PENDEL

**B. Elevator Pitch** – An deiner Fingerspitze hängt eine schwere Kugel an einem Seil. Hol Schwung,
zertrümmere Kristalle – aber übertreib es nicht, sonst reißt das Seil.

**C. Kernmechanik** – Der Finger ist der Aufhängepunkt; die Kugel pendelt physikalisch (Verlet-Seil).
Schaden ∝ Aufprallgeschwindigkeit. Zu hohe Seilspannung lässt das Seil rot glühen und reißen
(Runde vorbei). Ziele: Kristalle (unterschiedlich hart), Laternen (nicht treffen), bewegte Ziele.
Ein zweiter Finger wird zum Umlenkhaken, um den sich das Seil wickelt → Peitschenschläge um Ecken.

**D. Die ersten 30 Sekunden** – Kugel hängt am Finger, „Schwing!“. Erstes Pendeln fühlt sich schwer und
satt an. 4 s: erster Kristall zerplatzt in Splitter. 10 s: eine Laterne erzwingt präzises Vorbeischwingen.
18 s: harter Kristall braucht Anlauf, das Seil glüht als Warnung. 25 s: erste Kombo.

**E. Core Loop** – Schwung aufbauen → zielen → treffen → Wellen von Zielen → Spannung managen.

**F. Hook** – echtes Gewichtsgefühl am Finger, Risiko durch Seilriss, Zwei-Finger-Umlenkung.

**G. Mastery** – Schwung präzise dosieren, Umlenkhaken, Mehrfachtreffer in einem Schwung, Grenzspannung.

**H. Wiederspielwert** – Wellengenerator, Zieltypen, Physik-Emergenz. Risiko: wildes Herumschleudern als Dominanzstrategie.

**I. Technische Machbarkeit** – Verlet-Seil mit Kollision, vorgebrochene Splitter, Seilwicklung um bewegte Punkte (anspruchsvoll).

**J. Audiovisuelle Vision** – Kristallhöhle, schweres „Wuuusch“, helles Klirren, Splitterpartikel.

**K. Werbetauglichkeit** – Nach Runde.

**L. Vergleichbare Spiele** – Getting Over It (bekannt: Physikwerkzeug als Steuerung); Abrissbirnen-Hypercasual-Titel (nicht verifiziert); Angry Birds (bekannt: Zerstörungsphysik).

---

## K04 · LASSO

**A. Arbeitstitel** – LASSO

**B. Elevator Pitch** – Zieh Schleifen um Schwärme gleichfarbiger Glühwürmchen. Je größer und reiner der Fang, desto heller dein Glas.

**C. Kernmechanik** – Linie zeichnen; schließt sie sich, werden alle Glühwürmchen innen gefangen. Nur eine
Farbe im Fang = n² Punkte, gemischt = Kette bricht. Glühwürmchen fliehen vor der Fingerspitze. Motten
durchtrennen offene Linien. Zweiter Finger = Laterne, die alle (auch Motten) anlockt.

**D. Die ersten 30 Sekunden** – Wiese bei Nacht, drei Farbcluster schweben. Hinweis „Umkreisen“. Erste Schleife
fängt 4 blaue → helles Glas, Glockenklang. 15 s: Motte durchtrennt eine Linie. 25 s: Laterne lockt, großer Fang.

**E. Core Loop** – Cluster beobachten → warten oder sofort fangen → Schleife → Kombo → neue Cluster.

**F. Hook** – Flocking erzeugt Farbcluster, die man „erntet“; Laterne + Lasso mit zwei Händen.

**G. Mastery** – Cluster lesen, große reine Schleifen, Motten-Timing.

**H. Wiederspielwert** – mittel; Gefahr von Wartephasen.

**I. Technische Machbarkeit** – Boids, Punkt-in-Polygon, Linienschnitt; hoch machbar.

**J. Audiovisuelle Vision** – Nachtwiese, Leuchtpunkte, Glasglocken.

**K. Werbetauglichkeit** – Nach Runde.

**L. Vergleichbare Spiele**
- Pokémon Ranger (bekannt, 2006): Fangkreise um Pokémon.
- Sparky (belegt, TouchArcade-Forum): Schleifen um gleichfarbige Funken – **sehr nah an diesem Konzept**.
  https://toucharcade.com/community/threads/sparky-a-fireworks-themed-game.288780/
- Paper.io (bekannt): Schleifen als Territorium.

---

## K05 · FINGERSONNE

**A. Arbeitstitel** – FINGERSONNE

**B. Elevator Pitch** – Jeder Finger ist eine Sonne. Fang Kometen in deine Umlaufbahn und schleudere sie im
richtigen Moment in ihre Planeten.

**C. Kernmechanik** – Halten erzeugt eine Gravitationsquelle; vorbeifliegende Kometen werden abgelenkt oder
(mit Orbit-Assistenz) eingefangen. Loslassen: Kometen fliegen tangential weiter. Zwei Finger: Übergabe
zwischen zwei Sonnen, Achterbahnen. Farbige Planeten als Ziele, Schwarze Löcher als Gefahr.

**D. Die ersten 30 Sekunden** – Ein Komet fliegt quer; Hinweis „Halten“. Er biegt sich zum Finger, kreist.
Loslassen → er fliegt davon, trifft (assistiert) einen Planeten. 15 s: zwei Kometen gleichzeitig; 25 s: erster Doppeltreffer.

**E. Core Loop** – einfangen → Orbits stapeln (Risiko: Kollision) → im richtigen Winkel loslassen → Treffer/Kombo.

**F. Hook** – Gravitation unter der Fingerspitze, Multitouch-Jonglage zwischen Sonnen.

**G. Mastery** – Freigabewinkel, Mehrfach-Orbits, Übergaben.

**H. Wiederspielwert** – mittel; Gefahr, dass Bahnen schwer lesbar sind.

**I. Technische Machbarkeit** – N-Körper light, Bahnvorhersage; machbar.

**J. Audiovisuelle Vision** – Weltraum, leuchtende Schweife, harmonische Töne pro Orbit.

**K. Werbetauglichkeit** – Nach Runde.

**L. Vergleichbare Spiele** – Orbit-/Gravitations-Sandboxes für Mobile (nicht verifiziert im Detail);
Angry Birds Space (bekannt: Gravitationsfelder); Osmos (bekannt: Orbit-Level).

---

## K06 · ECHO

**A. Arbeitstitel** – ECHO

**B. Elevator Pitch** – Jede Runde dauert acht Sekunden, und alle deine vorherigen Versuche spielen mit.
Verteidige den Kern als Team aus deinen eigenen Echos.

**C. Kernmechanik** – Finger führt einen Leuchtpunkt 8 s lang; Gegner, die er berührt, zerfallen. Danach
Reset: Alle vorherigen Durchläufe laufen als Echos synchron mit, die Gegnerwelle ist deterministisch. Man
plant, welche Lücke man in diesem Durchlauf abdeckt. Sechs Durchläufe = eine Runde.

**D. Die ersten 30 Sekunden** – Durchlauf 1: wenige Gegner, leicht. Durchlauf 2: „Dein Echo hilft dir“ –
sichtbar die Spur von eben. Durchlauf 3: Gegner von zwei Seiten, nur mit Echo lösbar → Aha-Moment.

**E. Core Loop** – beobachten → Rolle für diesen Durchlauf wählen → ausführen → Teamwirkung sehen.

**F. Hook** – Kooperation mit der eigenen Vergangenheit, in Kurzzeit-Runden verpackt.

**G. Mastery** – Arbeitsteilung über Durchläufe planen, präzise Wiederholbarkeit.

**H. Wiederspielwert** – hoch für Planer, geringer für Gelegenheitsspieler; Verständnis braucht 15–20 s.

**I. Technische Machbarkeit** – Eingabeaufzeichnung + deterministische Simulation; machbar.

**J. Audiovisuelle Vision** – Geisterhafte Spuren, jedes Echo eine eigene Stimme eines Kanons.

**K. Werbetauglichkeit** – Nach sechs Durchläufen.

**L. Vergleichbare Spiele** – Cursor*10 (bekannt, Nekogames 2008); The Company of Myself (bekannt, 2009); Braid (bekannt).

---

## K07 · PRALLFINGER

**A. Arbeitstitel** – PRALLFINGER

**B. Elevator Pitch** – Kugeln regnen herab, und deine Fingerspitzen sind die Bumper. Lenke jede Farbe in ihr Fach.

**C. Kernmechanik** – Jede Berührung ist ein runder, physischer Bumper; bewegt man ihn, überträgt er Impuls.
Unten wechselnde farbige Fächer. Mehrere Finger = mehrere Bumper.

**D. Die ersten 30 Sekunden** – Eine rote Kugel fällt, rotes Fach links; Finger hinhalten → Abpraller → Treffer.
15 s: zwei Farben gleichzeitig; 25 s: erster Zwei-Finger-Doppeltreffer.

**E. Core Loop** – Kugeln lesen → Finger platzieren/schlagen → einsortieren → Kombo.

**F. Hook** – Du bist das Pachinko-Brett.

**G. Mastery** – Abprallwinkel, Schläge, Jonglage.

**H. Wiederspielwert** – eher gering; Gefahr, dass Physik-Zufall unfair wirkt (Fingerkontakt ungenau, Verdeckung).

**I. Technische Machbarkeit** – einfache Starrkörperphysik; hoch machbar.

**J. Audiovisuelle Vision** – Flipper-Ästhetik, Glas und Neon.

**K. Werbetauglichkeit** – Nach Runde.

**L. Vergleichbare Spiele** – Pachinko/Peggle (bekannt), Air-Hockey-Apps (bekannt: Schläger unter dem Finger), Sortierspiele (bekannt).

---

## K08 · SPANNUNG

**A. Arbeitstitel** – SPANNUNG

**B. Elevator Pitch** – Zwischen deinen beiden Daumen spannt sich ein Gummiband. Fang fallende Sterne und
katapultiere sie zurück in ihre Sternbilder.

**C. Kernmechanik** – Zwei Touchpunkte definieren ein elastisches Band; weiter auseinander = straffer;
schnelles Hochziehen = Schuss. Ein Finger allein: Band hängt einseitig an der Wand (schwächer).

**D. Die ersten 30 Sekunden** – Stern fällt, zwei Daumen-Symbole; Band fängt ihn federnd, Stern prallt zurück
ins Sternbild. 20 s: zwei Sterne, man lernt Winkel.

**E. Core Loop** – fangen → zielen → schießen → Sternbild vervollständigen.

**F. Hook** – Das Band existiert nur zwischen deinen Fingern.

**G. Mastery** – Winkel, Spannung, Timing.

**H. Wiederspielwert** – mittel bis gering.

**I. Technische Machbarkeit** – Feder-Band, Ballphysik; hoch machbar.

**J. Audiovisuelle Vision** – Sternenhimmel, gezupfte Saitenklänge, deren Tonhöhe der Spannung folgt.

**K. Werbetauglichkeit** – Nach Sternbild.

**L. Vergleichbare Spiele** – Breakout/Pong (bekannt: Schläger), Trampolin-Spiele (nicht verifiziert).

---

## K09 · ZWEILEINER

**A. Arbeitstitel** – ZWEILEINER

**B. Elevator Pitch** – Steuere einen Lenkdrachen an zwei Leinen: linker Daumen, rechter Daumen. Flieg
Loopings durch Wolkenringe, ohne abzustürzen.

**C. Kernmechanik** – Zwei unabhängige Leinen-Zonen; Ziehen verkürzt eine Leine, der Drachen dreht.
Windphysik, Ringe, Loopings als Tricks.

**D. Die ersten 30 Sekunden** – Drachen steht im Wind; beide Daumen auf die Zonen. Leichtes Ziehen links →
Kurve. 15 s: erster Ring, 25 s: erster Looping (Trick-Sound).

**E. Core Loop** – Wind lesen → Kurs fliegen → Ringe/Tricks → Absturz vermeiden.

**F. Hook** – zweihändige, unabhängige Analogsteuerung, die echte Lenkdrachen nachempfindet.

**G. Mastery** – feines Gegenlenken, Trick-Ketten.

**H. Wiederspielwert** – mittel; zweihändig zwingend (widerspricht „eine Hand“).

**I. Technische Machbarkeit** – vereinfachte Drachenaerodynamik; mittel.

**J. Audiovisuelle Vision** – Strand, Wind, flatternder Stoff.

**K. Werbetauglichkeit** – Nach Absturz.

**L. Vergleichbare Spiele** – Ice Cold Beer (bekannt, Taito 1983: zwei unabhängige Hebel); Drachen-Simulatoren (nicht verifiziert).

---

## K10 · WELLENGANG

**A. Arbeitstitel** – WELLENGANG

**B. Elevator Pitch** – Ein Teich voller Laternen, deine Finger sind Regentropfen. Schieb mit Wellen alle
Laternen in die Bucht – Interferenz ist deine Geheimwaffe.

**C. Kernmechanik** – Tippen erzeugt Ringwellen, die schwimmende Objekte radial schieben. Zwei gleichzeitige
Taps erzeugen Interferenzlinien mit doppelter Kraft. Strudel und Treibholz als Hindernisse.

**D. Die ersten 30 Sekunden** – Eine Laterne treibt, Tipp → Welle → sie schwimmt ins Ziel. 15 s: drei
Laternen, Strudel. 25 s: Doppeltipp-Interferenz.

**E. Core Loop** – Lage lesen → Impulse setzen → Laternen einsammeln.

**F. Hook** – indirekte Steuerung durch Wellenphysik.

**G. Mastery** – Interferenzpunkte präzise setzen.

**H. Wiederspielwert** – mittel; Risiko schwammiger Kontrolle.

**I. Technische Machbarkeit** – vereinfachte Wellenringe; hoch machbar.

**J. Audiovisuelle Vision** – Tuschmalerei-Teich, Regentropfenklänge.

**K. Werbetauglichkeit** – Nach Teich.

**L. Vergleichbare Spiele** – Boomshine (bekannt: Ringe), Teich-Entspannungs-Apps (nicht verifiziert).

---

## K11 · ZEITBLASE

**A. Arbeitstitel** – ZEITBLASE

**B. Elevator Pitch** – Wo dein Finger liegt, steht die Zeit still. Halte herabstürzende Trümmer an und baue
daraus Brücken für eine rollende Kugel.

**C. Kernmechanik** – Halten erzeugt eine Blase, in der alles einfriert (wird statisch); Loslassen lässt die
Objekte mit gespeichertem Impuls weiterfallen. Eine Kugel rollt autonom; sie muss sicher ins Ziel. Max. drei Finger.

**D. Die ersten 30 Sekunden** – Kugel rollt auf eine Lücke zu, Trümmer fallen; Halten friert einen Balken als
Brücke ein. 15 s: zwei Brücken nötig; 25 s: Trümmer frieren, die sonst die Kugel getroffen hätten.

**E. Core Loop** – Bedrohung/Lücke erkennen → einfrieren → loslassen im richtigen Moment.

**F. Hook** – Zeit-Stopp unter dem Finger als Bauwerkzeug.

**G. Mastery** – Timing, Mehrfachhalten, Impuls-Speicher nutzen.

**H. Wiederspielwert** – mittel (Levelcharakter).

**I. Technische Machbarkeit** – Physik mit Einfrieren; machbar.

**J. Audiovisuelle Vision** – Zeitlupen-Ästhetik, gedehnte Klänge in der Blase.

**K. Werbetauglichkeit** – Nach Abschnitt.

**L. Vergleichbare Spiele** – Superhot, Braid (bekannt: Zeitmanipulation); Lemmings (bekannt: autonome Figur unterstützen).

---

## K12 · SPIEGELSTURM

**A. Arbeitstitel** – SPIEGELSTURM

**B. Elevator Pitch** – Lichtstrahlen, drehbare Spiegel, anrückende Schatten. Dreh die Spiegel so, dass das
Licht jeden Schatten erwischt, bevor er den Leuchtturm erreicht.

**C. Kernmechanik** – Spiegel per Kreisgeste drehen; Strahlen reflektieren in Echtzeit; Schatten bewegen sich
auf den Kern zu. Zwei Spiegel gleichzeitig mit zwei Fingern.

**D. Die ersten 30 Sekunden** – Ein Spiegel, ein Schatten; drehen → Strahl trifft → Schatten zerfällt. 20 s:
zwei Schatten aus zwei Richtungen, zweiter Spiegel.

**E. Core Loop** – Bedrohung erkennen → Spiegel ausrichten → Kettenreflexionen.

**F. Hook** – Echtzeit-Reflexions-Puzzle unter Druck.

**G. Mastery** – Mehrfachreflexionen, Vorausrichten.

**H. Wiederspielwert** – mittel.

**I. Technische Machbarkeit** – Raycasts; hoch machbar.

**J. Audiovisuelle Vision** – Leuchtturm, Nebel, Lichtkegel.

**K. Werbetauglichkeit** – Nach Welle.

**L. Vergleichbare Spiele** – Laser-/Spiegel-Puzzles (bekannt als Genre); Tower Defense (bekannt: Bedrohung auf einen Kern).
