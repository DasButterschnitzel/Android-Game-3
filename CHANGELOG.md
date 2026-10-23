# Changelog

Alle Builds sind Debug-APKs (Debug-Zertifikat), nicht für den Store bestimmt. „Getestet“ heißt hier immer:
automatische Tests, Bot-Simulationen und Linux-Smoke-Test des exportierten Builds. **Kein Build wurde bisher auf
einem echten Android-Gerät oder Emulator gestartet** (keine KVM-Virtualisierung, kein Gerät in dieser Umgebung).

## 0.4.0 – „Visual Identity“ (2026-10-23)

Grundlage: unabhängiges Art-Gutachten `docs/art/ART_REVIEW_0.4.md` (Messungen an echten Frames: Kontrast,
CIEDE2000, Farbsehschwäche-Simulation). Leitbild „Papiertheater bei Laternenlicht“ (`docs/art/STYLE_GUIDE.md`).

### Neu / geändert
- **Geistertypen über Form:** Zwillinge haben ein einzelnes großes Auge, Gepanzerte einen Plattenring; 7-px-Tuschekontur
  unter dem Farbrand (Randkontrast in Welle 5 vorher bis 2,3:1). Typ-Symbole ▲ / ▲▲ / ■ am Rand und in der Zeitleiste.
- **Echos als nummerierte Scheiben** in kühler „Mondlicht“-Palette; warm ist nur das eigene Licht (vorher war Echo 4 bei
  Deuteranopie nicht von Zwillingen zu unterscheiden).
- **Ein Textkanal:** Lehrtexte nur zwischen den Läufen als Zettel über dem Startring; im Lauf nur kurze Labels am Objekt.
- **Entrümpelt:** Echo-Wege nur 1 s voraus, Echo-Schläge nur 2 s voraus (Ring mit Ziffer), Routen nur für bald
  erscheinende Geister, Tintenflecken klein und kurz.
- **Eigenes Licht immer am klarsten** (voller Kern, Ladering, Puls bei „bereit“, glatter Schweif).
- **Laterne:** Papierschattierung, Innenglühen, größere Flammen in festen Slots mit Docht für verlorene Leben,
  gefährdete Flammen flackern vor dem Kassieren; Faden beginnt am Spielfeldrand.
- **Papier-Bühne:** Skyline mit Schnittkante, hartem Versatzschatten und Fensterkreuzen; Geister werfen Schatten.
- **UI „Laternenpapier“:** Aktionen glühen orange, Infos auf Nachtpapier-Karten, Lehrtexte auf hellem Zettel,
  gezeichneter Pause-Knopf, Kassieren-Kosten als eigenes rotes Etikett (Text lief vorher über); wenn Kassieren die
  letzten Flammen kostet, sagt das Etikett es: „– die Laterne erlischt“.
- **Lehr-Zettel:** In jeder Pause gewinnt der neueste Hinweis (veraltete wie „So startest du“ fallen weg); ein Zettel
  gilt erst nach 1 s Sichtbarkeit als gelesen, sonst kommt er in der nächsten Pause wieder.
- **Hauptmenü:** Titel oben, die echte Laterne mit tanzenden Echos als Emblem, Aktionen im Daumenbereich.
- **Dämmerung** im Spielfeld gedämpft; volles Morgenlicht als Belohnung auf dem Ergebnis.
- **Icon:** zwei Echo-Bögen in der Safe Zone, lesbar bei 48 px; Store-Feature-Grafik.
- **Debug:** Farbsicht-Test (Protan/Deutan/Tritan/Grau) als Einstellung; `tools/art/cvd_sheet.py` für Aufnahmen.

### Bekannt
- Die neue Grafik braucht ≈ 70–80 % mehr Draw-Calls als 0.3.0 (Median bis 308, Spitze 394 je Frame; gemessen im
  Software-Renderer, `TEST_REPORT.md`). Batching-Optimierung folgt in 0.5; Bildrate auf echten Geräten ungeprüft.

### Neu (aus 0.5/0.6 vorgezogen)
- **Sternbilder:** 10 Achievements (z. B. erstes Echo, Morgengrauen, Morgengrauen mit allen Flammen, 25 perfekte
  Wellen, Duo mit zwei Fingern) schalten **rein kosmetische** Laternenpapiere frei (5 Stück, kein Spielvorteil).
  Seite „Sternbilder“ mit Statistik (Nächte, Morgengrauen, perfekte Wellen, Spielzeit).
- **Vollmond:** schwerere Variante (schnellere Schatten, engeres Zwillingsfenster, größere Wellen), freigeschaltet durch
  das erste Morgengrauen; eigene Bestwerte je Modus. Simulation: alle Abnahmekriterien bestanden (`docs/playtests/ECHO_SIM.md`).
- **Tagesnacht mit Nummer** (#1 = 22.10.2026) und Tagesbestwert im Menü.
- **Werbe-Grundgerüst für 0.6, in diesem Build nicht aktiv** (keine Werbung, kein Netzwerk): `AdService` mit
  Mock-Adapter, Einwilligung erst nach der zweiten Nacht statt beim ersten Start, neue Spieler haben fünf werbefreie Nächte.
- Glyphen-Test: Jedes Zeichen aller UI-Texte muss in der mitgelieferten Schrift vorhanden sein (fand einen Pfeil, der
  als Kästchen erschienen wäre).

### Behoben
- **Schwerer Fehler in 0.2.0 und 0.3.0:** Einstellungen, Credits und Datenschutz-Seite waren unsichtbar bzw. nicht
  bedienbar (Panels behielten Größe 0, weil der Anker-Preset im laufenden Baum gesetzt wurde). Gefunden erst durch eine
  gerenderte Aufnahme des Menüs; jetzt mit Regressionstests abgesichert.
- Android-Zurück-Taste/-Geste beendete das Spiel sofort (Godot-Standard). Jetzt: Pause im Spiel, Overlays schließen,
  nur im Hauptmenü wird die App verlassen.
- HUD/Pausen-Knopf konnten unter Kamera-Aussparungen liegen, Kassieren-Button unter der Gestenleiste → sicherer
  Bildschirmbereich wird berücksichtigt.
- Kassieren-Button zeigte seit 0.2.0 die Godot-Standardschrift statt Fredoka (er liegt auf einer CanvasLayer, die kein
  Theme erbt). Ein Test prüft jetzt alle Texte in Spiel, Pause-Karte, Menü und Overlays auf die Spielschrift.
- Kurzlabel „Dein Echo“ blieb am Startpunkt stehen, während das Echo weiterzog; Labels am Objekt („Dein Echo“,
  „lädt …“) fahren jetzt mit ihrem Licht mit.
- Ein neuer Lehr-Zettel konnte für einen Frame als leerer Papierstreifen erscheinen (Text noch nicht gesetzt) – Zettel
  blenden jetzt ein.

## 0.3.0 – „Game Feel“ (2026-10-23)

### Neu
- **Eigener Klangsatz für NACHHALL** (30 Dateien, prozedural, `tools/audio/make_nachhall_audio.py`):
  Jedes Licht hat eine Stimme der D-Dur-Pentatonik – das lebende Licht als klare Glasglocke, sein Echo als verhallte
  Erinnerung desselben Tons (Kanon). Tusche-Zerstäuben, Panzer-Riss, Zwillings-Ping und -Klang, Leck, erlöschende
  Flamme, Lauf-Start, „Licht bereit“, leiser Sekundentakt als hörbare Zeitleiste, Wellen-Glocke, Perfekt, Morgengrauen,
  Erlöschen der Laterne. Beim Kassieren klingen die Töne aller benutzten Lichter nacheinander.
- **Animationen und Effekte:** Geister wachsen beim Erscheinen und wippen beim Gehen, zerplatzen in einen Tusche-Ring
  und hinterlassen verblassende Flecken; Zwillinge verbindet beim Treffen ein Lichtstrahl; Panzerplatten fliegen ab;
  die Laterne pendelt und schwingt bei Treffern; Lichter ziehen Schweife, Echos kurze Spuren; Startring zieht sich
  beim Ziehen zusammen; Wellenstart als Glockenschlag-Welle; Punkte fliegen beim Kassieren zur Anzeige;
  Multiplikator „springt“ bei Änderung; Ergebnis zählt hoch; Konfetti bei perfekten Läufen.
- **Hit-Stop:** kurzer Mini-Freeze bei Treffern des lebenden Lichts (skaliert mit der Effekt-Einstellung, bei
  „minimal“ aus). Die Simulation wartet nur – Echos bleiben exakt.
- **Empfindlichkeit** der Steuerung einstellbar (niedrig/normal/hoch).
- Erste Lehr-Welle: Kassieren wird erst angeboten, nachdem man einmal ein Echo gesehen hat.

### Behoben
- Klicks am Ende von Glockenklängen (auch im LUNTE-Satz aus 0.1): Hüllkurven enden jetzt bei null; der
  Audio-Analysator erkennt isolierte Klicks (neue Regel, kalibriert).
- Datenschutz-Text im Spiel behauptete Platzhalter-Werbung; korrigiert (diese Version enthält keine Werbung).
  Der Einwilligungs-Button erscheint erst, wenn es einen Werbedienst gibt.
- CI: Downloads der Toolchain mit Wiederholung und HTTP/1.1-Rückfall (Lauf #6 scheiterte an einem Netzabbruch).

### Dokumente
- `GAME_DESIGN.md`, `ARCHITECTURE.md`, `README.md`, `ROADMAP.md`, Compliance-Entwürfe in `docs/compliance/`.

## 0.2.0 – „Mechanics“ (2026-10-23) · NACHHALL

Erstes APK des eigentlichen Spiels. Paket `io.github.dasbutterschnitzel.nachhall`, Anzeigename „Nachhall“.

### Neu
- **NACHHALL** (Produktionsfassung von ECHO): Schatten laufen auf die Papierlaterne zu; jeder Lauf (max. 8 s) wird
  ein Echo, das Weg *und* Treffer exakt wiederholt. Fünf Wellen pro Nacht, drei Flammen, Morgengrauen-Bonus.
- **Nachglühen** (1 s nach jedem Treffer), Treffer erfasst alle Schatten im Radius (ADR 0003).
- **Lehr-Welle**: zwei Schatten, die ein einzelnes Licht beweisbar nicht beide schafft.
- **Zwillinge** (ab Welle 3, 0,6 s Fenster, Countdown-Ring am Partner) und **Gepanzerte** (ab Welle 4).
- **Multiplikator zählt Lichter**: ×6/×4/×3/×2/×1,5/×1; ein zweiter Finger entzündet nach bewusstem Zug (≥ 40 px)
  ein zweites Licht und kostet wie ein weiterer Lauf. Abschaltbar in den Einstellungen.
- **Startring**: Ein Lauf beginnt nur, wenn das Licht bewusst aus dem Ring gezogen wird; Finger, die beim Laufende
  noch liegen, sind verbraucht. **Kassieren** ist ein eigener Button; perfekte Läufe werden automatisch kassiert.
- Relative Steuerung mit Ziel-Nachführung: Schnelle Wischer lassen das Licht kurz nachlaufen, aber nie abdriften.
- Darstellung „Papiernacht“: hängende Papierlaterne mit Flammen als Leben, Tuschegeister mit Augen, Panzer-Ringe,
  Zwillingsfaden, Echo-Spuren mit angekündigten Treffer-Ringen, ältere Echos blasser, Himmel wird zum Morgen hell.
- HUD oben: Punkte, Welle, Multiplikator mit Licht-Punkten, Zeitleiste mit Ankunft der Schatten und Echo-Treffern.
- Hinweise im Spiel (je einmal, gespeichert), Wellen-Banner mit Ankündigung neuer Typen.
- Ton: jedes Licht singt eine eigene Note (Kanon), Leck-, Kassier- und Morgengrauen-Klänge (Klänge aus 0.1 wiederverwendet).
- Hauptmenü mit laufender Bot-Partie im Hintergrund, Tagesnacht mit eigenem Tagesbestwert.
- Eigenes App-Icon (adaptiv, mit Monochrom-Ebene für Android 13+), prozedural erzeugt (`tools/art/make_icon.py`).
- Speicherstand Schema v2 (Statistiken von NACHHALL; LUNTE-Werte aus 0.1 werden nicht übernommen).

### Geändert
- LUNTE (inkl. Produktionsszene) und SCHWARM sind nur noch im Debug-Prototyp-Labor erreichbar.
- Tests, Aufnahmen und Smoke-Test nutzen eigene Speicherdateien und verändern keinen echten Spielstand.

### Tests
- 76 automatische Tests grün (u. a. Beweis der Lehr-Welle, Monotonie der Echos, Startring, ruhender Finger,
  zweiter Finger, Pause, Ergebnis/Neustart über die echte Touch-Pipeline).
- Bot-Simulation: alle Abnahmekriterien E1, C1, T1, T2, L1 (und das schwache E2) bestanden – siehe `docs/playtests/ECHO_SIM.md`.
- Smoke-Test des exportierten Linux-Builds: komplette Nacht ohne Engine-Fehler.

### Bekannte Einschränkungen
- Nicht auf einem Gerät getestet (siehe oben). Touch-Gefühl, Lesbarkeit auf 6"-Displays und Lautstärken sind ungeprüft.
- Klänge stammen noch aus LUNTE; eigener Kanon-Klangsatz folgt in 0.3.
- Keine Werbung, keine Einwilligungsabfrage (folgt als Vorschau in 0.6).

## 0.1.0 – „Proof of Fun“ (2026-10-22) · Prototyp-Labor

- Prototypen LUNTE (v2) und ECHO, Referenz-Spike SCHWARM im Labor wählbar.
- Mehrfinger-Kern (`PointerTracker`) mit Touch-Debug-Anzeige.
- Paket `io.github.dasbutterschnitzel.pocketlab` (Labor, wird nicht weitergeführt).
