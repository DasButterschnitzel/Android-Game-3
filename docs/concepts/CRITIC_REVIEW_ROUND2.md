# Kritik-Review Runde 2 – Konzepte K13–K19

Autor: Agent D (Gameplay Critic / Devil's Advocate) · Stand: 2026-10-22

**Grundlage:**
- `CONCEPTS_ROUND2.md` (Agent C2)
- `CRITIC_REVIEW.md` §4 (gleiche Bewertungsskala) und §6 (Leitplanken)
- ADR 0001 und ADR 0002
- `docs/playtests/PROTOTYPE_COMPARISON_CRITIC.md` (Prototyp-Evidenz zu ECHO)

**Kennzeichnung:**
- **[B]**: Quelle in dieser Sitzung geöffnet. [B, C2] heißt: von C2 geöffnet, von mir nicht erneut geöffnet.
- **[R]**: aus unseren Recherche-Dokumenten.
- **[A]**: Allgemeinwissen, nicht verifiziert.
- **[E]**: meine Einschätzung.

Alle Aussagen über Spaß sind **Hypothesen**. Keines der sieben Konzepte wurde gebaut oder simuliert.

**Grenzen:**
- **Websuche:** Auch meine Websuchen wurden abgewiesen, weil das geteilte Suchbudget erschöpft war. Ich habe es nicht umgangen. Stattdessen habe ich drei Wikipedia-Artikel bekannter Verwandter direkt geöffnet: Loop Hero, Captain Sonar und Flame Over.
- **Folge für Prior Art:** Für alle sieben Konzepte ist sie nur gegen *bekannte* Verwandte geprüft. „Nicht gefunden“ heißt hier „nicht suchbar“.
- **Pflicht vor jedem Prototyp:** die von C2 in Feld L genannten Suchen nachholen.

---

## 0. Urteil auf einen Blick

- **Ersetzt ein Konzept aus Runde 2 ECHO jetzt? – Nein.** Keines ist *klar* stärker.
  - Die beiden besten, K18 GEGENFEUER (6,45) und K15 ECHOLOT (6,40), liegen nur 0,10–0,15 Punkte über ECHO in der umgebauten Fassung (6,30). Das ist weit innerhalb der Unschärfe hypothetischer Wertungen.
  - Beide sind Papier, ECHO ist ein Prototyp mit ehrlich bestandener Bot-Abnahme.
  - Zur Erinnerung: LUNTE war auf Papier die Nummer 1 (6,35) und ist an seinen Kriterien gescheitert, sobald es gebaut war.
- **Stark (Kandidaten fürs nächste Projekt bzw. erster Ersatz, falls ECHO am Gerät scheitert):**
  - **K18 GEGENFEUER:** bestes Spaßpotenzial, einziges Konzept mit fairer, telegrafierter Spannung.
  - **K15 ECHOLOT:** originellstes Verb: Beobachten heißt Stören.
- **Parken:** K13 RÜCKWEG, K16 LICHTUNG.
- **Streichen:** K14 KIPPMOMENT, K17 FÄHRMANN, K19 WINDSPIEL.
- **Kein späterer ECHO-Modus:** Die Fantasien passen nicht zusammen, und für einen Solo-Techniker wäre das Umfangsausweitung. GEGENFEUER und ECHOLOT sind eigene Spiele.

---

## 1. Systemisch: Was Runde 2 besser macht – und was nicht

**Lob, das der Prüfung standhält:**
- C2 hat die Leitplanken ernst genommen: kein Finger als Avatar, nur Tippen neben das Ziel, relative Züge oder Zonen.
- Alles ist deterministisch und mit Tagesseed spielbar.
- Jedes Konzept hat ein sichtbares Budget statt einer versteckten Uhr.
- Jedes Konzept beantwortet die Frage nach der dominanten Strategie.
- Jedes Konzept hat eine vorab fixierbare Bot-Abnahme.
- Die fehlende Websuche ist offen benannt.
- Die Ausarbeitungstiefe ist gleichmäßig. Das war in Runde 1 ein Hauptkritikpunkt.

**Kritik:**

1. **Denksport-Monokultur.**
   - Vier der sieben Konzepte sind zugbasiert, zwei sind ruhige Echtzeit.
   - Nur K18 trifft noch das ursprüngliche Ziel der Innovation Map, „Spannung im Sekundentakt“.
   - Die Leitplanken haben die alten Fehler verhindert, aber das Feld in Richtung „Rechnen in Ruhe“ gekippt.
   - Leitplanke 5 forderte *mindestens* ein Drittel ruhige Konzepte, nicht fast alle.
2. **Tabellengefühl.** Mehrere Konzepte tragen ihre Spannung über Zahlen statt über Bilder:
   - K13 rechnet mit Puffer und Lastschwellen.
   - K16 mit einer Fläche als Summe von Speichenquadraten.
   - K18 mit Hitzewerten je Gelände.

   C2 benennt das Risiko selbst (§4). Es ist aber nicht gelöst.
3. **Regelmenge.** Typisch sind 6–10 Regeln pro Konzept, bei K13 eher mehr. Für Sessions von 60–120 s ist das viel. LUNTE v2 hat gezeigt, wohin Regelanhäufung führt.
4. **Gleichförmiger Rahmen.** Fünf von sieben Konzepten enden mit Sonnenuntergang, Morgengrauen oder einem Tageslicht-Budget, ebenso LUNTE. Als Motiv ist das verbraucht und taugt nicht als Alleinstellung.
5. **Bot-Abnahmen nach der LUNTE-Lehre härten.**
   - Nenner explizit definieren („je Tod“ oder „je Runde“).
   - Bot und Messcode gemeinsam mit den Kriterien einfrieren.
   - Das Profilraster muss die vermutete dominante Strategie *enthalten*.
   - Kriterien sind Vetos, keine Optimierungsziele.

   Die Abnahmen in Feld O sind gut formuliert, aber noch nicht in diesem Sinn gehärtet.
6. **Multitouch ist praktisch verschwunden** (nur optionales Spreizen in K16 und ein optionaler Akkord in K17). Das ist ehrlicher als angeklebtes Multitouch. Das Briefing-Ziel „sinnvolles Multitouch“ erfüllt aber keines der Konzepte.

---

## 2. Einzelurteile

### K13 · RÜCKWEG – parken

- **Prior Art:**
  - Blue Prince: 1-aus-3-Drafting; am Tagesende verliert man Gesammeltes [B, C2].
  - Deep Sea Adventure: Beute macht den Rückweg teurer [B, C2].
  - Incan Gold [B, C2].
  - **Loop Hero** [B, eigener Abruf]: Karten legen Gelände an den Weg; nach jeder Runde ist der Rückzug ins Lager möglich, Ressourcen bleiben erhalten; bei einer Niederlage gehen 70 % verloren; seit 30.04.2024 auf Android und iOS.
  - Folge: Extraktion mit Push-your-luck und gelegten Karten existiert bereits auf Mobile. Eigenständig ist nur die Kopplung „der Hinweg baut den Rückweg“ mit dem Lastmultiplikator.
- **Nach 20 Runden [H]:**
  - Die exakte Puffer-Anzeige verwandelt Push-your-luck in Buchhaltung. Der Rückweg führt über *bereits gebaute* Felder, seine Kosten sind also bekannt.
  - Unbekannt ist nur der Preis des nächsten Angebots, höchstens 2 h.
  - Spieler lernen schnell: „Puffer ≥ 2 h halten.“ Danach gibt es kein Risiko mehr, nur noch Optimierung.
  - Der Hook („jeder Schritt hinauf ist ein Schritt zurück“) wird zur Rechenaufgabe.
  - Dazu kommen rund zehn Regeln (acht Kartentypen, drei Laststufen, Depot, Abseilen, Schneebrücke, Gipfelbonus, mehrere Touren, Notbiwak) für 60–120 s Spielzeit.
- **Touch:** sehr gut. Kartenleiste unten, zugbasiert, keine Verdeckung.
- **Größtes Risiko:** Tabellengefühl ohne echte Gier-Spannung.
- **Billigster Test:** C2s Papierprototyp, plus eine Messung, wie oft Menschen ins Notbiwak geraten. Gerät nie jemand hinein, gibt es keine Spannung.
- **Falls es wiederbelebt wird:** Unsicherheit in den Rückweg bringen, etwa angekündigte Wetterwechsel, statt exakter Rechnung. Und die Regeln halbieren.

### K14 · KIPPMOMENT – streichen (als Hauptspiel)

- **Prior Art:**
  - Cut the Rope [B, C2]. Dass man dort Seile per Wisch durchtrennt und die Schwerkraft den Rest erledigt, ist [A].
  - Dazu die bekannte 3-Sterne-Levelstruktur [A] sowie Holedown-Statik [R] und Turing Tumble [B, C2].
  - Das Verb „Faden schneiden, die Schwerkraft rechnet“ gehört Cut the Rope. Die Gleichgewichts-Variante ändert daran im Store nichts.
  - Das Briefing verbietet ausdrücklich „known puzzle mechanics with new skins“.
- **Nach 20 Runden [H]:**
  - Vier Tagesmobiles sind endliche Rätsel.
  - Die Kaskade wird absichtlich nicht vorhergesagt. Ohne Wiederholungsversuch heißt das Ausprobieren (vgl. die Kritik an *Is This Seat Taken?*, 01 §B5), mit Wiederholung ist es ein klassisches Levelrätsel.
  - Die Qualität hängt vollständig am Generator: eine Content-Tretmühle in Verkleidung.
- **Verwertbar für ECHO:** „Par vom Löser“. Der Planer-Bot kennt die minimale Zahl an Läufen pro Welle. Als Tagesziel („Par: 2 Läufe“) ist das billig und motivierend.

### K15 · ECHOLOT – stark (originellstes Verb der Runde)

- **Prior Art (streng):**
  - Distanz-Deduktion im Raster ist rund 50 Jahre alt: Hurkle und Mugwump, Hunt the Wumpus [B, C2].
  - Black Box und Scotland Yard [B, C2].
  - **Captain Sonar** (2016) [B, eigener Abruf]: Teams orten die verborgene Position des gegnerischen U-Boots, das sich Feld für Feld bewegt.
  - Minesweeper und Schiffe versenken [A].
  - **Neu ist, unverifiziert,** nur die Kopplung: Sondieren *schiebt* das Ziel deterministisch weg, Beobachten heißt also Stören. Dazu kommen Möglichkeitswolken, die das Spiel selbst führt. Im verfügbaren Wissen kenne ich kein Spiel mit genau dieser Kopplung [E]. Ohne Suche bleibt das eine Behauptung.
- **Nach 20 Runden [H]:**
  - Stark ist: Man formt sichtbare Wolken von Möglichkeiten, jedes Meer ist ein neues Rätsel, und jeder Ping ist eine echte Abwägung zwischen Information und Schub.
  - Schwach ist:
    - Es ist reiner, langsamer Denksport ohne kinetische Freude.
    - Es droht eine Rezeptlösung („von der Netzseite pingen, dann nah“). E1 und E5 müssen zeigen, dass der Planer die Heuristiken klar schlägt.
    - Wenn ein Wal mit unsicherer Position im Netz landet, wirkt das wie Pech, obwohl alles deterministisch ist (E3 begrenzt das).
    - Die Schreckregel (2 oder 1 Feld je nach Entfernung, Ausweichen im Uhrzeigersinn) ist ohne Vorschau Ausprobieren.
- **Touch:** sehr gut. Fadenkreuz 12 mm über der Kuppe, Einrasten, Ergebnis erst nach dem Loslassen.
- **Auflagen vor einem Prototyp:**
  - Vor dem Loslassen zeigen, wohin jeder Kandidatenpunkt flieht.
  - Mit zwei Walen einsteigen.
  - Ton ist Information (Echo-Verzögerung). Deshalb braucht jede Ton-Information eine sichtbare Entsprechung, denn viele spielen stumm.
- **Billigster Test:** C2s Papiertest (eine Person spielt „das Meer“) und danach eine 1–2-tägige Graubox mit den Bot-Profilen aus Feld O.

### K16 · LICHTUNG – parken

- **Prior Art:**
  - Don't Starve: Licht als Überlebensbedingung [B, C2].
  - Windowkill und Stretchmancer [R].
  - Kingdom (Licht gegen Nachtwesen) und Missile Command [A].
  - Flächenerhaltendes Formen als einziges Verb wirkt frisch [E].
- **Nach 20 Runden [H]:**
  - Die Bedrohung ist sehr einfach: Wichte rücken einen Ring pro Zug vor und fliehen vor Licht.
  - Nach wenigen Nächten droht die Routine „Augen anleuchten, sonst ernten“ (L4 prüft das).
  - 55 Aktionen pro Zug ergeben eine abstrakte Flächenverteilung mit Tabellengefühl.
  - Die zähe „Teig“-Geste ist schön, trägt aber kein ganzes Spiel.
- **Touch:** sehr gut, relativ ziehen und loslassen.
- **Größtes Risiko:** Nach einer Stunde gelöst.
- **Verwertbar:** die flächenerhaltende Formgeste als Eingabeidee für später.

### K17 · FÄHRMANN – streichen

- **Prior Art:**
  - Abholen und Abliefern unter Zeitdruck ist ein ausgetretenes Genre (Crazy Taxi [A]).
  - Trägheit als Planung: Racetrack [B, C2].
  - Zonen mit Akkord: Data Wing [R].
  - Ungewöhnlich ist nur das Rudern im Takt.
- **Nach 20 Runden [H]:**
  - 45 Takte, alle 2 s eine Eingabe: Das ist Fleißarbeit, wie C2 selbst als Risiko nennt.
  - Drehungen um 60° mit Trägheit sind umständlich, ohne Können zu belohnen.
  - Die Routenebene (Kapazität 2, Strömung) ist ein kleines Rundreiseproblem, interessant für etwa fünf Runden.
  - Der Mittelstreifen macht den Akkord bedeutungslos. Das Multitouch ist Dekoration.
- **Bestes Element:** Die Ergonomie ist die beste im Feld (nur Tippen, keine Verdeckung). Allein trägt sie kein Spiel.

### K18 · GEGENFEUER – stark (bestes Spaßpotenzial der Runde)

- **Prior Art (streng):**
  - Into the Breach: telegrafierte Bedrohung [B, C2].
  - Forest-fire model und das reale Gegenfeuer („back burning“) [B, C2].
  - **Flame Over** (Laughing Jackal, 2015, Windows und PS Vita) [B, eigener Abruf]: Der Artikel belegt nur, dass es existiert. Dass es ein Feuerwehrspiel ist, ist [A].
  - Flash Point: Fire Rescue, ein kooperatives Feuerwehr-Brettspiel [A].
  - Eindämmungsspiele mit sich ausbreitendem Feuer gibt es also. Das *geankerte Gegenfeuer* als Kernverb wirkt frisch, ist aber unverifiziert.
- **Nach 20 Runden [H]:**
  - Das Konzept hat die beste Mischung im Feld.
  - Eine sichtbare, vollständig angekündigte Bedrohung trifft auf einen Windfahrplan und drei Werkzeuge mit verschiedenen Zeitprofilen:
    - Schneise: sofort wirksam.
    - Gegenfeuer: kriecht langsam.
    - Löschflug: kommt verzögert.
  - Das ergibt räumlich-zeitliche Planung *mit Drama* und Spektakel: Rauch, Löschflugzeug, Hütten, deren Fenster angehen.
  - Das Eigentor (das eigene Gegenfeuer als zweite Front) ist ein sichtbares, selbst gewähltes Risiko.
  - Es ist das einzige Konzept aus Runde 2, das die ursprüngliche Spannungs-Hypothese fair bedient.
- **Risiken:**
  1. **Rezept:** etwa „Schneise quer, Gegenfeuer davor“. G1 und G5 müssen Vielfalt zeigen.
  2. **Passive Zuschau-Phasen:** Der Brand „frisst sich aus“. Ein Zeitraffer ist nötig, sonst besteht womöglich die halbe Session aus Zusehen.
  3. **Schleichender Echtzeitdruck:** Der Fokus-Vorrat ist auf 12 s begrenzt. C2 nennt dafür den Rückfall „Ticks nur ohne Finger“; den würde ich gleich testen.
  4. **Thema:** Reale Waldbrände sind sensibel. Der Ton muss vorsichtig sein: Hütten retten, keine Opfer zeigen.
- **Touch:** sehr gut. Versatz-Fadenkreuz, Einrasten, Zeitlupe beim Zielen, Werkzeugleiste unten.
- **Billigster Test:** zwei Tage Graubox mit dem zellularen Automaten und den Bot-Profilen aus Feld O. Am Menschen: Setzen Testende das geankerte Gegenfeuer ohne Hinweis ein zweites Mal ein (C2)?

### K19 · WINDSPIEL – streichen

- **Prior Art:**
  - Flower: Wind und Blütenblätter [B, C2].
  - Eine Eingabe, die alles zugleich bewegt: Neige-Labyrinthe und die Schiebe-Mechanik von 2048 und Threes [A].
- **Nach 20 Runden [H]:**
  - Es ist derselbe Fehler wie bei K10 (in Runde 1 geparkt): indirekte, schwammige Kontrolle.
  - Samen fliegen gefächert, Wolken treiben mit 35 % der Windgeschwindigkeit. Zwischen den 14 Windwechseln schaut man überwiegend zu.
  - Die Regel „die neue Wolke kommt von der Windseite“ ist undurchsichtig.
  - Das Kontrollgefühl ist das Hauptrisiko, und C2 nennt es selbst.
- **Verwertbar:** Wind als Klangspiel, als Audio-Idee.

---

## 3. Bewertung (gleiche Skala wie `CRITIC_REVIEW.md` §4)

**Formel:** Gesamt = Σ (Punkte × Gewicht), per Skript nachgerechnet. Alle Werte sind **Hypothesen**. Die Kalibrierung entspricht Runde 1: Kein Papierkonzept bekommt beim Spaß mehr als 6, solange nichts davon gespielt wurde.

**Spaltenkürzel:**
- **Spaß:** Tatsächlicher Spielspaß (25 %)
- **Eigen:** Eigenständigkeit (20 %)
- **Wieder:** Wiederspielwert (20 %)
- **Mobile:** Mobile-Steuerung (10 %)
- **Verst.:** Schnelle Verständlichkeit (10 %)
- **Tech:** Technische Realisierbarkeit (5 %)
- **AV:** Audiovisuelle Möglichkeiten (5 %)
- **Monet.:** Faire Monetarisierbarkeit (5 %)

| # | Konzept | Spaß | Eigen | Wieder | Mobile | Verst. | Tech | AV | Monet. | **Gesamt** | Urteil |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | K18 GEGENFEUER | 6 | 6 | 6 | 8 | 6 | 8 | 8 | 7 | **6,45** | stark |
| 2 | K15 ECHOLOT | 5 | 7 | 6 | 8 | 6 | 8 | 8 | 7 | **6,40** | stark |
| – | *ECHO, umgebaut (mit Prototyp-Evidenz)* | 6 | 5 | 7 | 7 | 5 | 9 | 8 | 7 | ***6,30*** | *gewählt (ADR 0002)* |
| 3 | K16 LICHTUNG | 5 | 6 | 5 | 8 | 6 | 8 | 8 | 7 | **6,00** | parken |
| 4 | K13 RÜCKWEG | 5 | 5 | 6 | 8 | 4 | 8 | 6 | 7 | **5,70** | parken |
| 5 | K14 KIPPMOMENT | 6 | 3 | 5 | 8 | 6 | 6 | 7 | 6 | **5,45** | streichen |
| 6 | K19 WINDSPIEL | 4 | 5 | 4 | 8 | 6 | 7 | 8 | 7 | **5,30** | streichen |
| 7 | K17 FÄHRMANN | 4 | 4 | 4 | 8 | 6 | 8 | 7 | 7 | **5,10** | streichen |

**Begründung in je einer Zeile:**
- **K18:** Faire, telegrafierte Spannung mit Spektakel und einem frischen Kernverb. Risiken sind Rezept, Zuschau-Phasen und das Thema.
- **K15:** Das originellste Verb („Beobachten heißt Stören“). Es ist aber reiner Denksport, und die Schreckregel braucht eine Vorschau.
- **ECHO:** Bot-geprüfte Planungstiefe (Wiederspielwert +1), Relativsteuerung gebaut (Mobile +1), Technik steht (+1). Das Verständnis bleibt das Hauptrisiko.
- **K16:** Schöne Formgeste, aber eine zu einfache Bedrohung und Tabellengefühl.
- **K13:** Die Puffer-Buchhaltung tötet das Push-your-luck. Loop Hero besetzt die Extraktion auf Mobile, und die Regeln sind zu viele.
- **K14:** Das Verb von Cut the Rope, also vom Briefing ausgeschlossen. Endliche Tagesrätsel.
- **K19:** Wiederholt die K10-Schwäche: indirekt, schwammig, überwiegend Zuschauen.
- **K17:** Taktfleiß statt Entscheidung, ein ausgetretenes Lieferspiel-Genre, Akkord ohne Bedeutung.

**Zur ECHO-Zeile:** Gegenüber der Runde-1-Wertung (5,95) habe ich nur dort angehoben, wo die Prototyp-Evidenz es trägt:
- **Wiederspielwert 6 → 7:** Planung ist nötig; die Rezeptlösung „sector“ bringt nur 43–45 %; die Kassier-Entscheidung ist echtes Push-your-luck.
- **Mobile 6 → 7:** Die Relativsteuerung ist gebaut. Die Eingabefalle muss laut ADR 0002 ohnehin behoben werden.
- **Technik 8 → 9:** Prototyp und Bots existieren.

Spaß und Verständlichkeit bleiben unverändert, denn dazu gibt es noch keine Menschen-Daten.

---

## 4. Kernfrage: Ersetzt ein Konzept aus Runde 2 ECHO?

**Ersetzen jetzt: Nein.**

1. **Keines ist klar stärker.**
   - Der Vorsprung von K18 (+0,15) und K15 (+0,10) liegt weit innerhalb der Unschärfe meiner Hypothesenwertung. Ein Punkt Unterschied in einem einzigen Kriterium bewegt die Gesamtnote um 0,05–0,25.
2. **Papier gegen Prototyp.**
   - ECHO ist das einzige Konzept, dessen Kern durch eine ehrliche, nachgemessene Bot-Abnahme gestützt ist.
   - Papierwertungen sind systematisch zu optimistisch. LUNTE war auf Papier vorn und ist gebaut an seinen Kriterien gescheitert.
   - Wer jetzt wechselt, tauscht Evidenz gegen Begeisterung. Das ist derselbe Anker-Fehler wie bei LUNTE, nur mit umgekehrtem Vorzeichen: Neuheit statt investierter Arbeit.
3. **Kosten.**
   - Der Wechsel würde den laufenden Gerätetest, die wiederverwendete Spiel-Hülle und die ECHO-Auflagen entwerten.
   - Er würde mindestens zwei Wochen Graubox, Bots und Kalibrierung für ein unverifiziertes Konzept kosten.

**Späterer Modus? Nein.** ECHO (Laternen, Schatten, Kanon) hat mit Feuer oder Walen keine gemeinsame Fantasie. Ein zweites Regelwerk im selben Spiel verdoppelt Tutorial, Balancing und Test für einen Solo-Techniker.

**Nächstes Projekt bzw. Ersatzreihenfolge: Ja.**

1. **K18 GEGENFEUER als Kandidat Nr. 1.** Es kommt der ursprünglichen Marktlücke am nächsten: Spannung, Ketten, Risiko, aber fair telegrafiert. Und es bietet das stärkste Spektakel.
2. **K15 ECHOLOT als Nr. 2.** Es hat die größte Eigenständigkeit, aber die engere Zielgruppe (Denksport).

**Was meine Meinung ändern würde:** ECHO reißt am Gerät die menschlichen Abbruchkriterien aus ADR 0002, zum Beispiel weniger als 4 von 5 Testern verstehen die Echos. Dann gilt:
- K18 und K15 werden *vor* jeder neuen Ideationsrunde als Graubox gebaut, mit Bot-first und den Abnahmen aus Feld O.
- Die Abnahmen werden vorher gehärtet: Nenner definieren, Profilraster inklusive der dominanten Strategie, Bot einfrieren.
- Vorher werden die 2–3 von C2 genannten Prior-Art-Suchen je Konzept nachgeholt.

**Für ECHO aus Runde 2 mitnehmen** (billig und optional): ein Tagesziel „Par“ aus dem Planer-Bot (aus K14).

---

## 5. Quellen

**Selbst geöffnet [B]** (22.10.2026, Direktabruf, keine Suche):
- **Loop Hero:** Karten legen Gelände; Rückzug ins Lager nach jeder Runde, Ressourcen bleiben; bei einer Niederlage gehen 70 % verloren; Android und iOS seit 30.04.2024. https://en.wikipedia.org/wiki/Loop_Hero
- **Captain Sonar:** 2016, Matagot. Teams orten die Koordinaten des gegnerischen U-Boots, das sich Feld für Feld bewegt. Die Funker-Mechanik beschreibt der Artikel nicht. https://en.wikipedia.org/wiki/Captain_Sonar
- **Flame Over:** Laughing Jackal, 2015, Windows und PS Vita. Der Artikel belegt nur die Existenz, keine Mechanik. https://en.wikipedia.org/wiki/Flame_Over (leitet auf den Artikel zu Laughing Jackal weiter)

**Von C2 geöffnet [B, C2]:** Die Quellenliste steht in `CONCEPTS_ROUND2.md` §5. Ich habe sie nicht erneut geöffnet.

**Abgewiesen:** drei Websuchen (Suchbudget der Sitzung erschöpft), zu Waldbrand-Eindämmungsspielen, Sonar-Herding-Rätseln und Kletter-Extraktions-Roguelites.

**Allgemeinwissen [A]:** Cut the Rope (Schneidegeste), 3-Sterne-Level, Hurkle und Mugwump (über C2s Wumpus-Quelle), Minesweeper, Schiffe versenken, Kingdom, Missile Command, Crazy Taxi, Flash Point: Fire Rescue, 2048 und Threes, Neige-Labyrinthe.
