# Prototyp-Vergleich LUNTE v2 vs. ECHO

Unabhängiges Kritiker-Gutachten · Autor: Agent D (Gameplay Critic / Devil's Advocate) · Stand: 2026-10-22, ca. 23:00 UTC

**Grundlage:**
- ADR 0001 (vorab fixierte Abbruchkriterien)
- Code-Stand von 22:47 UTC als Kopie
- Simulationsberichte `LUNTE_V2_SIM.md` und `ECHO_SIM.md`
- Bot-Captures `lunte_v2_sheet.png` und `echo_sheet.png`

**Methode:**
- Alle Simulationen liefen auf Kopien im Scratchpad. Zusätzliche Bots und Profile existieren nur dort.
- Im Repository ist außer dieser Datei nichts verändert.
- Die Schlussfolgerungen der Director-Dokumente habe ich nicht übernommen, sondern nachgemessen.

**Kennzeichnung:**
- **[Sim]:** Bot-Simulation, keine Menschen.
- **[Code]:** aus dem Quelltext abgeleitet.
- **[H]:** Hypothese.

Kein Mensch hat diese Prototypen in dieser Umgebung gespielt. **Alle Aussagen über Spaß sind Hypothesen.**

**Umrechnung (Richtwert):** 720 Basis-px entsprechen etwa 65–70 mm Displaybreite, also 1 px ≈ 0,1 mm.

---

## 0. Urteil auf einen Blick

1. **ECHO besteht seine Bot-Kriterien ehrlich**, sogar gegen einen strengeren Gegentest als vorgesehen.
   - Ein reaktiver Bot ohne Vorausplanung erreicht nur **15 %** des besten Scores und verliert den Kern in **100 %** der Runden, egal wie schnell er sich bewegt.
   - Planung ist dort wirklich das Tor, nicht Motorik.
2. **LUNTE v2 besteht seine Kriterien nur auf dem Papier.**
   - **B3 ist falsch gemessen:** Die Böller-Tode werden durch *Runden* statt durch *Tode* geteilt. Korrekt gerechnet liegen sie bei **26 %** (Original-Seeds) bzw. **23 %** (frische Seeds), bei einer Grenze von 15 %. → **B3 nicht bestanden.**
   - **B1 und B2 sind nur formal bestanden.** Die Profilauswahl verfehlt die dominante Strategie: Wer ruhig in Hitzestufe 2 bleibt, holt **+37 %** gegenüber „gierig“ und das **2,6-Fache** von „vorsichtig“. Das Morgengrauen erreicht dieses Profil in 85 % der Runden.
   - Gier hat damit wieder einen fast kostenlosen Sweet Spot. ×3 ist eine Todesfalle, kein Risiko.
3. **Empfehlung: ECHO, unter Bedingungen. LUNTE v2 nicht weiterentwickeln. Kein Totalneustart.**
4. **Die acht LUNTE-Iterationen sind ein Lehrbuchfall von Goodhart.**
   - Regeln wurden gegen einen perfekten Bot optimiert.
   - Dabei änderte sich das Messinstrument (der Bot) mit.
   - Ergebnis: etwa zwölf Regeln, von denen mehrere nur existieren, um einen perfekten Bot zu bestrafen.
5. **ECHO hat drei konkrete Mängel, die vor dem Gerätetest behoben werden müssen:**
   - Die Lehrwelle lehrt nicht: Eine einzelne Lichtquelle löst sie in 58–90 % der Seeds.
   - Zwillinge sind eine Schwierigkeitsklippe ab Welle 2.
   - Zwischen den Läufen startet jede Mikrobewegung des Fingers sofort den nächsten Lauf. Danach ist Kassieren unmöglich, obwohl der Button sichtbar bleibt.
6. **Prozess-Warnung:** Während dieses Vergleichs entsteht bereits Audio nur für LUNTE. Das verzerrt einen neu gebauten Gerätetest zugunsten von LUNTE, und es ist erneut eine Investition vor der Entscheidung (siehe Abschnitt 2, Testvalidität).

---

## 1. Bestehen die Prototypen ihre Bot-Kriterien ehrlich?

### 1.1 LUNTE v2

| Kriterium (ADR 0001) | Bericht | Mein Rerun, Seeds 1000–1039 (40/Profil) | Frische Seeds 5000–5059 (60/Profil) | Urteil |
|---|---|---|---|---|
| B1: gierig überlebt ≥ 15 % kürzer | 0,83 ✓ | 0,832 ✓ | 0,837 ✓ | formal bestanden, inhaltlich verfehlt (L2, L3) |
| B2: Score-Faktor 400/230 px/s ≤ 1,6 | 1,05 ✓ | 1,052 ✓ | 1,064 ✓ | im bedeutungslosen Regime gemessen (L4) |
| B3: < 15 % **der Tode** durch Böller | 8 % ✓ | 8 % je Runde, **26 % je Tod (16/61) ✗** | 6 % je Runde, **23 % je Tod (18/78) ✗** | **nicht bestanden** (L1) |
| B4: Median-Dauer 45–150 s | 116–140 s ✓ | 116,5–140 s ✓ | 117–140 s ✓ | durch die Konstruktion erfüllt (L6) |

**Positiv:** Die Werte reproduzieren exakt und halten auf frischen Seeds. Ein Overfitting auf die Seeds 1000–1039 liegt **nicht** vor.

#### L1 – B3 wird mit dem falschen Nenner gemessen [Code, Sim]

- `sim_lunte.gd::_acceptance` teilt die Böller-Tode durch **alle 200 Runden**.
- Darin stecken auch die rund 70 % der Runden, die das Morgengrauen erreichen und gar nicht sterben.
- ADR 0001 verlangt aber „unter 15 % der **Tode**“. Die v1-Vergleichswerte von 30–45 % waren ebenfalls Anteile an Toden, denn in v1 endete jede Runde mit einem Tod.
- Korrekt gerechnet ergibt sich 26 % bzw. 23 %. Das ist kein Interpretationsspielraum, sondern ein Messfehler, der aus einem Fail einen Pass gemacht hat.

#### L2 – Die Profilauswahl verfehlt die dominante Strategie [Sim]

Der Bot wartet, bis der Abstand unter „Zielabstand + 0,4 s“ fällt. Deshalb liegen die Profilnamen 0,35–0,4 s neben dem tatsächlich gespielten Abstand:
- „g1.3“ spielt im Mittel bei 1,70 s, also in Hitzestufe 1.
- „g0.75“ spielt bei 1,08 s.

Ich habe Zwischenprofile ergänzt (frische Seeds, 60 Runden je Profil):

| Profil (tatsächlicher Ø-Abstand) | Median-Score | Morgengrauen erreicht | Zündungen Stufe 1 / 2 / 3 (Median) | Häufigste Todesursache |
|---|---|---|---|---|
| g2.2 (2,60 s) | 1.327 | 52/60 | 102 / 0 / 0 | Rolle leer |
| g1.3 (1,70 s) | 1.301 | 47/60 | 102 / 0 / 0 | Rolle leer |
| **g1.0 (1,33 s)** | **3.425** | **51/60** | 1 / 142 / 0 | Böller (7) |
| g0.9 (1,23 s) | 3.150 | 39/60 | 1 / 136 / 0 | Böller (15) |
| g0.75 (1,08 s), „gierig“ | 2.503 | 26/60 | 1 / 98 / 1 | Feuersprung (24) |
| g0.5 (0,91 s) | 379 | 15/60 | 1 / 14 / 2 | Feuersprung (39) |

**Was das bedeutet:**
- Wer dauerhaft in Hitzestufe 2 bleibt, holt das **2,6-Fache** des vorsichtigen Scores und **+37 %** gegenüber dem „gierigen“ Profil. Die Überlebensrate ist dabei praktisch gleich.
- Die Risiko-Ertrags-Kurve hat **keinen Abwägungsbereich**. Es gibt eine sichere Hochebene (Stufe 2) und eine Klippe (Stufe 3).
- B1 besteht nur, weil das Gier-Profil gelegentlich über diese Klippe fällt.
- Für einen präzisen Spieler ist Gier damit wieder gratis. Das ist der v1-Befund, nur an anderer Stelle.

Bei Menschen entsteht das Risiko stattdessen aus Unschärfe: Sie müssen ein Band von etwa 13–27 mm hinter dem Lunten-Kopf halten, an der eigenen Fingerkuppe [H]. Das ist wieder eine Wahrnehmungs- und Motorikaufgabe, genau das, was der Umbau verhindern sollte.

#### L3 – Hitzestufe 3 ist eine Todesfalle, kein Risiko [Code, Sim]

- Stufe 3 gilt bei einem Abstand unter 0,8 s × Grundtempo. Bei einem Grundtempo von höchstens 175 px/s sind das höchstens 140 px.
- Der Zündsprung in Stufe 3 beträgt 128 px.
- Jede Zündung in Stufe 3 setzt das Feuer also 0–12 px (etwa 1 mm) vor den Kopf. Liegt das Grundtempo unter 160 px/s, ist der Tod sicher.
- Folgen in der Simulation:
  - Zündungen in Stufe 3: im Median 0–2 pro Runde.
  - „Feuersprung“ ist die häufigste Todesursache aller nahen Profile.
- ×3 ist ein Selbstmordbonus, keine Entscheidung.

#### L4 – B2 wurde im bedeutungslosen Regime gemessen [Sim]

- B2 vergleicht 230 und 400 px/s beim Profil g1.3, das tatsächlich in Stufe 1 spielt.
- Beide Tempi liegen über dem Funkendeckel von 175 px/s. Der Funke steht in allen tragfähigen Profilen am Rundenende auf genau diesem Deckel.
- Dort *kann* das Zeichentempo gar nichts entscheiden.
- Im punkterelevanten Regime nahe am Funken entscheidet es dagegen alles:

  | g0.75 mit … | Median-Überleben | Median-Score |
  |---|---|---|
  | 230 px/s | 15,7 s | 265 |
  | 400 px/s | Morgengrauen | 3.463 |

  Das ist ein Faktor 13.
- Für Menschen ist rohes Tempo kaum der Engpass, denn 230 px/s sind nur etwa 22 mm/s. Der Engpass ist die **Reaktion auf Feuersprünge**, die direkt an oder unter der Fingerkuppe passieren. Das kann kein Bot messen [H].

#### L5 – Das Messinstrument wurde während der Iteration verändert [Doku, Code]

- Laut Iterationsprotokoll bekam der Bot in v2.1 eine exakte Kreuzungsprüfung und in v2.5 eine Prüfung des Böller-Radius vor dem Einfädeln.
- Die Kriterien blieben fix, aber der Messbot wurde besser. Der Fortschritt bei B3 ist also teilweise Bot-Fortschritt.
- **Gegentest** mit einem „unachtsamen“ Bot, der die Böller-Ringe ignoriert und sonst identisch ist (Abstand 1,3 s):
  - 17 von 18 Toden durch Böller.
  - 28 % aller Runden enden durch einen Böller.

#### L6 – B4 ist durch die Konstruktion erfüllt [Code]

Das Morgengrauen beendet jede Runde bei 140 s (`night_length`). Die Obergrenze von 150 s kann also gar nicht verletzt werden. B4 misst damit einen Konfigurationswert, nicht das Spiel.

#### L7 – Ungeprüfte und wirkungslose Regeln [Sim]

- **Kurzschluss-Schleifen:** Die Bots bilden im Mittel 0–0,15 Schleifen pro Runde, weil sie Kreuzungen per Kostenfunktion meiden. Die Regel ist vollständig unvalidiert.
- **Finale im Morgengrauen:** Es bringt im Median 0 Punkte.
- **Funkentempo nach „Zündungsenergie“:** Es liegt am Rundenende in allen tragfähigen Profilen auf dem Deckel von 175 px/s. Faktisch ist das ein konstantes Tempo.

#### L8 – Die Oberfläche widerspricht der Regel [Code, Capture]

Die Punkte-Popups zeigen die Stufennummer als „×2“ bzw. „×3“ an (`" ×%d" % heat`). Das HUD zeigt dagegen „Hitze ×1.5“. Spieler sehen „×2“ und bekommen ×1,5. Auf dem LUNTE-Sheet ist das sichtbar.

#### Was die Prüfung übersteht

- Die Simulation ist reproduzierbar und auf frischen Seeds stabil.
- Das Iterationsprotokoll ist vorbildlich transparent. Erst dadurch ließen sich L2 bis L5 finden.
- Im vorsichtigen Regime ist die Motorik-Dominanz von v1 wirklich beseitigt.

### 1.2 ECHO

| Kriterium | Bericht | Mein Rerun, Seeds 3000–3039 | Frische Seeds 7000–7059 (60/Strategie) | Urteil |
|---|---|---|---|---|
| E1: ohne Echos ≤ 40 % des Planers | 19 % ✓ | 19 % ✓ | 21 % ✓ | **ehrlich bestanden**, durch strengeren Gegentest bestätigt |
| E2: ≥ 2 Strategien ≥ 80 % des Besten | early, perfect ✓ | ✓ | ✓ (perfect 85 %) | formal eine Technikalität, die Absicht ist aber erfüllt |

**Strenger Gegentest „chaser“** (nur in der Kopie):
- **Wie er spielt:** Er ist reaktiv, plant nicht voraus und kennt die Echo-Bahnen nicht. In jedem Lauf jagt er den Schatten, der dem Kern am nächsten ist, und kassiert bei höchstens einem Leck.
- **Ergebnis:**
  - 335 Punkte, also 15 % des besten Planers.
  - Der Kern wird in 100 % der Runden zerstört, im Median nach drei gewerteten Wellen.
- **Tempo spielt keine Rolle:** Bei 300, 500 und 900 px/s erreicht er 335, 335 und 345 Punkte. Das Scheitern ist strategisch, nicht motorisch.
- **Ursache:** Zwillinge müssen innerhalb von 0,35 s zweimal getroffen werden. Ohne geplantes Timing mit einem Echo ist das nicht lösbar.

**Planer bei unterschiedlichem Lichttempo** (Strategie „early“):

| Lichttempo | Median-Score |
|---|---|
| 300 px/s | 1.660 |
| 500 px/s | 2.260 |
| 900 px/s | 2.380 |

Tempo wirkt also moderat (Faktor 1,4). Planung entscheidet: Faktor 6,8 gegenüber dem „chaser“.

**Einschränkungen:**
- **E2 ist eine Technikalität [Code].**
  - „early“ und „perfect“ sind derselbe Planer mit unterschiedlicher Kassier-Schwelle: höchstens ein Leck gegenüber null Lecks.
  - Es gibt also *eine* dominante Politik: plane für das, was die Echos verfehlen, und kassiere bei höchstens einem Leck.
  - Das ist allerdings die beabsichtigte Kernfertigkeit und keine degenerierte Abkürzung. Das befürchtete Tortenstück-Rezept („sector“) erreicht nur 43–45 %.
- **Der Planer ist übermenschlich [Code].**
  - Vor jedem Lauf simuliert er exakt, welche Schatten die Echos verfehlen, und plant tick-genaue Abfangpunkte.
  - Ob Menschen diese Vorhersage leisten können, kann kein Bot zeigen.
  - Die Oberfläche zeigt Routen und Echo-Spuren, aber keine Vorhersage „dieser Schatten kommt durch“.
- **Die Lehrwelle lehrt nicht [Sim].**
  - Eine einzelne Lichtquelle löst Welle 1 ohne Leck in 23/40 Seeds (250 px/s), 33/40 (350 px/s) und 36/40 (500 px/s).
  - Das „erzwungene Scheitern“ findet also meist nicht statt.
  - Der erste echte Zwang zu Echos kommt erst mit den Zwillingen in Welle 2, und zwar als Klippe.
- **Eingabefalle zwischen den Läufen [Code, `echo_proto.gd`].**
  - Im Zustand `between` ruft jede Bewegung eines Fingers, der nicht auf dem Kassier-Button gelandet ist, sofort und ohne Schwelle `sim.next_run()` auf.
  - Danach ist Kassieren unmöglich. Der Button bleibt sichtbar, reagiert aber nicht mehr.
  - Ein ruhender Finger erzeugt auf echten Geräten Mikrobewegungen. Die wichtigste Entscheidung des Spiels kann so versehentlich verloren gehen.
  - Außerdem startet ein Lauf schon nach etwa 0,8 mm Fingerweg (12 px Schwelle bei Verstärkung 1,4).

**Was die Prüfung übersteht:**
- ECHO ist deterministisch und auf frischen Seeds robust.
- Planung schlägt Reaktion deutlich, Motorik dominiert nicht.
- Die Kassier-Entscheidung ist ein echtes Push-your-luck: „early“ schlägt „perfect“.

---

## 2. Welcher Prototyp macht nach 20 Runden wahrscheinlicher Spaß? (alles [H])

| Dimension | LUNTE v2 | ECHO | Vorteil |
|---|---|---|---|
| Verdeckung | Das punkterelevante Band (Stufe 2: 140–280 px, etwa 13–27 mm hinter dem Kopf) liegt an oder unter der Fingerkuppe. Der Versatz-Cursor hebt den Kopf nur 64 px (etwa 6 mm) an. Der Relativmodus löst die Verdeckung, erschwert aber das präzise Einfädeln (ungetestet). | Relativsteuerung ist Standard: Der Finger liegt irgendwo, die Aktion spielt in der oberen Bildhälfte. Wenig Verdeckung. | ECHO |
| Verständnis | Der Kern ist sofort klar („zieh, der Funke folgt“). Dahinter stehen rund zwölf Regeln, mehrere davon kontraintuitiv: Feuersprung, Wiedereinfahrt, verzögerte Rückerstattung, „×2“ statt ×1,5. Folge: Tode, die sich Spieler nicht erklären können. | 6–7 zusammenhängende Regeln, aber ein abstrakter Kern (Echos). Die Lehrwelle lehrt nicht, Zwillinge mit 0,35-s-Fenster bilden eine Klippe. | Unentschieden, verschiedene Risiken |
| Entscheidungsdichte | Viele kleine Routenentscheidungen. Die dominante Strategie lautet aber „im orangen Band bleiben“: eine Halteaufgabe, keine Abwägung. | Wenige, gewichtige Entscheidungen alle 8 s: welche Schatten, welches Timing mit den Echos, kassieren oder weiter. Laut chaser-Test sind sie nötig. | ECHO |
| Session-Rhythmus | 140 s Dauerzeichnen ohne natürliche Pause, feste Länge. Ein einhändiger Dauerzug ermüdet. Im Mittel kriecht der Kopf mit etwa 17–23 mm/s über das Display. | 8-s-Häppchen mit natürlichen Pausen, unterbrechungsfest. Menschen brauchen aber mehr Läufe pro Welle; geschätzt dauert eine Runde 3–4 min (Planer: 61–82 s Spielzeit plus Pausen). | ECHO, mit Längenrisiko |
| Wow-Momente | Stark und sofort: Explosionen, Raketenketten, Finale im Morgengrauen. | Kognitiv: „mein Echo rettet mich“, synchroner Zwillingstreffer, ×6 kassieren. Optisch bisher karg. | LUNTE in den ersten fünf Minuten |
| Fairness des Scheiterns | Tod durch Feuersprung (das Feuer teleportiert an den Finger, *weil* man Erfolg hat), durch Böller (23–26 % der Tode) oder durch eine leere Rolle. Oft nicht selbst erklärbar. | Deterministisch, Lecks sind sichtbar, fünf Kernleben bedeuten gestuftes Scheitern. Aber hoher Boden: Wer nicht plant, verliert den Kern in Welle 3. | ECHO, mit Einstiegsrisiko |
| Nach 20 Runden | Das Rezept (Stufe 2 halten) ist gefunden, der Rest ist Zufall der Spawns. Das Spektakel nutzt sich ab. | Prozedurale Wellen sind jedes Mal ein neues Mini-Puzzle. Risiko: Es fühlt sich nach Hausaufgabe an. | ECHO |

**Testvalidität:** Im geprüften Code-Stand (22:47 UTC) und im ausgelieferten Lab-APK 0.1.0 (gebaut 22:40 UTC) haben beide Prototypen **weder Ton noch Haptik** [Code].
- LUNTE fehlt damit die geplante Rückmeldung über den Abstand, also der Ausgleich für die Verdeckung.
- ECHO fehlt der Kanon als Timing-Hilfe.

Der Gerätetest prüft beide also unter ihren schlechtesten Bedingungen. Das sollte bei der Auswertung klar benannt werden.

**Achtung:** Während dieses Gutachtens (gegen 23:00 UTC) entstand parallel Audio nur für LUNTE: `scripts/gameplay/lunte/lunte_audio.gd` und über 30 Klänge unter `game/assets/audio/`. Für ECHO gibt es nichts.
- Wird die APK neu gebaut, testet der Gerätetest LUNTE mit Ton und ECHO ohne. Das ist ein verzerrter Vergleich.
- Außerdem ist es erneut eine Investition vor der Entscheidung.
- Deshalb: entweder beide mit Ton oder beide ohne.

**Fazit [H]:** LUNTE gewinnt die ersten fünf Minuten, ECHO die zwanzigste Runde.
- ECHOs Tiefe kommt aus Planung, belegt durch den chaser-Test, und sein Scheitern ist fair.
- LUNTEs Tiefe ist in v2 auf eine Halteaufgabe geschrumpft, sein Scheitern ist regelbedingt undurchsichtig.
- ECHOs größtes Risiko ist das Gegenteil: Der Aha-Moment kommt womöglich gar nicht. Ohne Aha gibt es kein Spiel, denn Nicht-Planer verlieren schnell.

---

## 3. Empfehlung: ECHO, unter Bedingungen – LUNTE v2 nicht weiterentwickeln

**Begründung:**
- ECHO besteht seine vorab fixierten Kriterien ehrlich.
- LUNTE v2 fällt bei korrekter Messung durch B3 und erfüllt B1 und B2 nur dem Wortlaut nach.
- Nach der Logik von ADR 0001 scheitern damit nicht beide. Ein Totalneustart ist also nicht angezeigt.
- LUNTE v2 sollte **nicht weiter gegen Bots getunt** werden. Weitere Iterationen würden nur weitere Bot-Regeln erzeugen.

**Was mit LUNTE geschehen soll:** Im Gerätetest höchstens als **Kontrollgruppe in einer Lite-Konfiguration** laufen lassen (siehe Abschnitt 4). Das braucht nur Konfigurationsschalter, kein neues Feature. Schneidet LUNTE Lite bei Menschen klar besser ab als ECHO, heißt das: Der Bot-Prozess hat die Regeln verdorben, nicht die Idee.

**Vor dem Gerätetest bei ECHO beheben** (je höchstens ein Tag):
1. **Eingabefalle.** Der nächste Lauf startet erst nach einer bewussten Geste, zum Beispiel einem Zug von mehr als 40 px aus einem sichtbaren Startring oder 0,3 s Halten. Bis dahin bleibt Kassieren möglich.
2. **Lehrwelle.** Sie muss für eine einzelne Lichtquelle wirklich unlösbar sein: zwei Schatten gleichzeitig dicht vor dem Kern, auf gegenüberliegenden Seiten. Abnahme per Bot: Eine Lichtquelle allein löst sie in weniger als 10 % der Seeds.
3. **Zwillinge entschärfen.**
   - Zum Einstieg ein Zeitfenster von etwa 0,6 s statt 0,35 s.
   - Zwillinge erst ab Welle 3.
   - Den Trefferzeitpunkt des Echos auf der Zeitleiste markieren („Echo trifft hier“).
4. **Ton als Funktion, nicht als Deko.** Mindestens ein hörbarer Klick pro Echo-Treffer und eine Timing-Spur, denn der Kanon ist Teil der Verständlichkeit.

**Die fünf wichtigsten Risiken für das volle Spiel (ECHO) und was zuerst auf Geräten zu testen ist:**

| # | Risiko [H] | Erster Gerätetest | Signal zum Umsteuern oder Abbrechen |
|---|---|---|---|
| 1 | Der Aha-Moment kommt nicht, Echos bleiben abstrakt. Nicht-Planer verlieren schnell (chaser-Test). | 5 Neulinge, keine Erklärung. Nach Runde 1 sollen sie die Regel in eigenen Worten erklären (t2 im Protokoll). | Weniger als 4 von 5 erklären Echos korrekt. |
| 2 | Zwillinge, also Synchronisation mit einem Echo im Zeitfenster, sind zu schwer oder unlesbar. Frust ab Welle 2. | Anteil getöteter Zwillingspaare; Zeit bis zum ersten *bewussten* Synchrontreffer. | Weniger als 50 % der Zwillinge nach 5 Runden, oder Spieler nennen es „unfair“. |
| 3 | Fehleingaben: Relativsteuerung, versehentliche Laufstarts, verlorene Kassier-Entscheidung. | Telemetrie: versehentliche Starts, ins Leere gehende Taps auf den Kassier-Button, Treffergenauigkeit. | Mehr als ein versehentlicher Start pro Runde. |
| 4 | Planung fühlt sich wie Hausaufgabe an, Runden werden zu lang. | Echte Rundenlänge, Läufe pro Welle, ungefragte Folgerunden nach Runde 10. | Median über 4 min pro Runde, oder weniger als 3 von 5 spielen weiter. |
| 5 | Lesbarkeit ab Lauf 4–6: Echo-Spuren, Routen und Lichter auf einem 6-Zoll-Display. | Vor Lauf 4 fragen: „Welche Schatten kommen durch?“ und die Vorhersage auswerten. | Weniger als 60 % richtige Vorhersagen. |

**Weiteres Risiko, auf Geräten nicht testbar:** Kooperation mit Echos ist ein Dauerbrenner auf Game Jams, etwa Echo Loop (GMTK 2025) und Layers of Time (LD47). Die Abgrenzung muss aus drei Dingen kommen: der Kassier-Entscheidung, einem Tagesseed und dem Kanon.

---

## 4. Ist LUNTE v2 ohne Tutorial zu komplex? – Ja.

| Regel | Was der Spieler wissen muss | Evidenz | Vorschlag |
|---|---|---|---|
| Zeichnen, der Funke folgt | trivial | Kern | **behalten** |
| Feuerwerk auffädeln; es zündet bei Funkenankunft; ungenutzt verfällt es nach 9–13 s | einfach, ein Ring zeigt die Restzeit | Kern | **behalten** |
| Raketen zünden, was sie treffen | sichtbar, erzeugt Ketten | Wow-Moment | **behalten** |
| Luntenrolle; Rückerstattung erst bei Zündung, plus Kettenbonus | eine zweite Ressource mit verzögerter Rückmeldung | Beendet 2–17 % der Runden, vor allem bei vorsichtigen Profilen. Doppelt sich mit dem Morgengrauen als Sessionbudget. | **streichen**, höchstens als Notbremse unter 15 % Füllstand einblenden |
| Funkentempo nach „Zündungsenergie“ mit Deckel | unsichtbar | liegt faktisch immer bei 175 px/s | **verstecken:** konstantes Tempo mit kurzer Startrampe |
| Hitzestufen ×1 / ×1,5 / ×3, dazu Funkentempo +15 % / +30 % | drei Stufen und eine Bruchzahl | Stufe 3 ist eine Todesfalle (L3), Stufe 2 dominiert (L2), Popups widersprechen dem HUD (L8) | **auf zwei Zustände reduzieren:** normal ×1, „heiß“ ×2 |
| Zündsprung von 0 / 48 / 128 px, angezeigt als Sprungzonen-Punkte | Das Feuer springt dir entgegen, wenn *du* Erfolg hast. | Häufigste Todesursache der nahen Profile. Nur nötig, um perfekte Bots zu bestrafen. | **für den Menschentest streichen.** Erst wieder einführen, wenn Menschen „heiß“ nachweislich risikolos halten. |
| Böller: Ring, rote Gefahrenpunkte, „eigene Durchfahrt ist sicher, Wiedereinfahrt zündet“ | eine geometrische Ausnahme | 23–26 % der Tode; ein unachtsamer Bot verliert dadurch 28 % aller Runden | **vereinfachen:** Böller zünden nur Feuerwerk, nie die Lunte |
| Kreuzung und Kurzschluss-Schleife | Eine Schleife schließt Körper ein, das Feuer springt zur Kreuzung. | Von Bots ungenutzt, also unvalidiert | **streichen**, später allenfalls als Entdeckung für Fortgeschrittene |
| Morgengrauen bei 140 s mit Finale | Der Himmel wird hell, die Runde endet. | Intuitiv. Das Finale bringt im Median 0 Punkte. | **behalten**, auf 90–120 s kürzen; Finale als Spektakel behalten |
| Umgreif-Toleranz, Kettenbonus | unsichtbar | Komfort | behalten, unsichtbar |
| Splitter (zweiter Finger) | – | ist aus | aus lassen |

**„LUNTE Lite“** (nur Konfiguration, für die Kontrollgruppe):
1. Zieh die Lunte, der Funke folgt.
2. Fädle Feuerwerk auf, bevor es verfällt.
3. Je näher der Funke ist, desto heißer wird es: ×2.
4. Holt er dich ein, ist die Runde vorbei.
5. Im Morgengrauen zündet alles.

Das sind fünf Regeln auf einem Bildschirm, ohne Tutorial.

Bei Menschen entsteht Risiko durch Unschärfe, Verdeckung und Zögern ganz von selbst. Genau das hat ein perfekter Bot nicht, und deshalb brauchte v2 künstliche Risiken wie Feuersprünge und die Wiedereinfahrtsregel. Halten Menschen „heiß“ dauerhaft ohne Risiko, ist LUNTE als Push-your-luck-Spiel gescheitert. Dann sollte man nicht weiter flicken.

**Methodische Lehre:**
- Bot-Kriterien taugen als **Vetos** („Dominiert Motorik? Dominiert ein Rezept?“), nicht als Optimierungsziel.
- Wer Regeln so lange ändert, bis ein perfekter Bot Risiko spürt, baut Regeln für Bots.
- Messbot und Kennzahl gehören vor der Iteration eingefroren, genauso wie die Kriterien.

---

## 5. Reproduktion

Alle Läufe arbeiteten auf Kopien vom 22.10.2026, 22:47 UTC. Der Godot-Aufruf ist jeweils `godot --headless --path <kopie>/game --script <Skript> -- <Argumente>`.

**Offizielle Läufe:**
- `res://tests/simulation/sim_lunte.gd -- 40` mit den Seeds 1000–1039.
- `res://tests/simulation/sim_echo.gd -- 40` mit den Seeds 3000–3039.

**Ergänzungen in der Kopie:**
- `sim_lunte.gd`:
  - Seed-Basis und Profilliste als Argumente.
  - Zündungen je Hitzestufe, Ø-Abstand, Finale-Punkte und Schleifen zusätzlich protokolliert.
  - Neue Todesursache „jump“: Tod innerhalb von 0,7 s nach einem Feuersprung.
- `lunte_bot.gd`: Profilsuffix `_c` für einen unachtsamen Bot, der keine Böller-Prüfung macht.
- `echo_bot.gd`: Strategien `chaser` und `chaser0` (reaktiv, ohne Planung).
- `sim_echo.gd`: Seed-Basis, Strategieliste und Lichttempo als Argumente.
- Eigenes Prüfskript `wave1_check.gd`: Löst eine einzelne Lichtquelle die Lehrwelle?

**Frische Seeds:**
- LUNTE: 5000–5059, 60 Runden je Profil.
- ECHO: 7000–7059, 60 Runden je Strategie, bei 300, 500 und 900 px/s.

Die Rohdaten liegen nur im Session-Scratchpad, sie sind nicht eingecheckt.
