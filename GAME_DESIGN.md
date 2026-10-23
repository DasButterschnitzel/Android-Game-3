# NACHHALL – Game Design

Stand 0.3 · Arbeitstitel (Name nicht markenrechtlich geprüft) · Grundlage: ADR 0001–0003, `docs/playtests/ECHO_SIM.md`.
Alle Aussagen über Spaß sind Hypothesen, bis Menschen am Gerät gespielt haben (`docs/playtests/DEVICE_TEST_PLAN.md`).

## 1. Ein Satz
Du verteidigst eine Papierlaterne gegen Tuschegeister – in Läufen von höchstens acht Sekunden, und **jeder Lauf wird
ein Echo, das im nächsten Lauf exakt mitspielt**.

## 2. Kern-Loop (eine Welle)
1. Die Welle ist bei jedem Lauf **dieselbe** (deterministischer Seed). Wege der Schatten sind vorab sichtbar.
2. Du ziehst dein Licht aus dem **Startring** (bewusste Geste) – der Lauf beginnt.
3. Dein Licht trifft automatisch, wenn es geladen ist und einen Schatten berührt; danach **glüht es 1 s nach**.
4. Läuft ein Schatten in die Laterne, ist er „durch“.
5. Nach dem Lauf: **Kassieren** (Punkte × Multiplikator, jeder Durchgekommene kostet eine Flamme) oder
   **Nochmal ziehen** (ein Licht mehr, niedrigerer Multiplikator; dein letzter Lauf spielt als Echo mit).
6. Perfekter Lauf → wird automatisch kassiert.

Eine **Nacht** = 5 Wellen. Drei Flammen. Ohne Flammen ist die Nacht vorbei; wer das Morgengrauen erreicht, bekommt
100 Punkte je verbliebener Flamme. Typische Rundenlänge (Bots): 75–90 s, Spieler vermutlich 1–3 min.

## 3. Regeln im Detail

| Regel | Wert | Warum |
|---|---|---|
| Laufdauer | max. 8 s, endet früher, wenn alle Schatten erledigt sind | kurze, dichte Entscheidungen |
| Steuerung | relativ: Finger irgendwo, Licht folgt Fingerweg × 1,4 (Einstellung 0,75/1,0/1,3) | Daumen verdeckt nie das Licht |
| Tempolimit Licht | 900 px/s, Ziel-Nachführung | Wischer laggen kurz, driften nie |
| Treffer | alle Schatten im Radius 38 px | „Doppelt!“ belohnt gutes Timing |
| Nachglühen | 1,0 s | macht „zwei Orte zugleich“ zur echten Aufgabe |
| Echo | wiederholt Weg **und** Trefferzeitpunkte exakt (feste Ereignisse) | vorhersagbar, monoton |
| Multiplikator | nach Zahl der Lichter: ×6 / ×4 / ×3 / ×2 / ×1,5 / ×1; max. 6 Lichter je Welle | Push-your-luck |
| Zweiter Finger | entzündet nach bewusstem Zug (≥ 40 px) ein zweites Licht im selben Lauf; zählt wie ein Lauf; höchstens zwei Lichter gleichzeitig | Multitouch mit Nutzen, kein Exploit |
| Daumenwechsel | hebt der lenkende Finger ab, übernimmt ein schon ruhender Finger sein Licht (kein neues Licht, nichts friert ein) | Umgreifen mit beiden Daumen ist normal |
| Leben | 3 Flammen; Durchgekommene kosten beim Kassieren je eine | Risiko ist sichtbar an der Laterne |
| Punkte | normal 10, Zwilling 15, gepanzert 25 | |

### Schatten-Typen
Typ über **Form**, Farbe nur als zweiter Kanal (farbsehschwäche-sicher, geprüft per Simulation):
- **Normal** (rosa Rand, zwei Augen, Symbol ▲) – ein Treffer.
- **Zwillinge** (violett, ein großes Auge, Tusche-Faden zum Partner, Symbol ▲▲; ab Welle 3, angekündigt) – zwei verbundene Schatten, die von **zwei verschiedenen Lichtern
  innerhalb von 0,6 s** getroffen werden müssen. Wird einer getroffen, zeigt ein Countdown-Ring am Partner das Fenster.
- **Gepanzert** (orange Plattenring, Symbol ■; ab Welle 4) – braucht Treffer von **zwei verschiedenen Lichtern** (beliebige Zeit);
  ein Licht verschwendet keine Ladung an einen Panzer, den es schon angeknackst hat.

### Wellen (`game/data/balance/echo.json`)
| Welle | Inhalt | Lehrziel |
|---|---|---|
| 1 | 2 Schatten, nah, gleichzeitig, links/rechts | „Ein Licht schafft nicht beide“ – beweisbar unlösbar allein |
| 2 | 4 normale | allein schaffbar → ×6 möglich |
| 3 | 4 normale + Zwillingspaar | Synchronisieren mit dem Echo |
| 4 | 4 normale + Zwillinge + 1 gepanzerter | zwei Lichter auf ein Ziel |
| 5 | 5 normale + Zwillinge + 2 gepanzerte | alles zusammen |

**Formationen (ab 0.5, ADR 0005):** Die normalen Schatten einer Welle kommen in einer von vier Anordnungen –
*Streuung* (zufällig verteilt), *Kette* (2–3 auf einer Route, 46 px Abstand: ein Schlag zwischen zweien trifft beide),
*Zange* (Paare links/rechts gespiegelt, gleichzeitige Ankunft), *Regen* (alle von oben, eigene Bahnen). Gewichte 4/2/2/1,
deterministisch je Seed und Welle; das Wellenbanner nennt die Formation. Die erste Nacht eines Spielers ist immer
Streuung, damit das Onboarding ungestört bleibt. Bot-Belege: `docs/playtests/ECHO_SIM.md` Teil C.

## 4. Warum es nicht trivial wird (Bot-Belege, keine Menschen)
- Planen schlägt Reagieren: Ein reaktiver Bot erreicht 23–25 % des Planers.
- Echos sind nötig: Allein-Kassieren erreicht 37–39 % (Grenze 40 %).
- Das „Tortenstück“-Rezept (jede Runde eine Seite) erreicht nur 44–47 %.
- Perfektion vs. frühes Kassieren liegen nah beieinander (≈ 9 %) – eine echte Entscheidung.

## 5. Lesbarkeit und Fairness
- Alles, was während eines Laufs gelesen werden muss, steht **oben**: Punkte, Welle, Multiplikator mit Licht-Punkten,
  Zeitleiste mit Abspielkopf, Ankunft jedes Schattens (dasselbe Typ-Symbol wie am Rand) und Echo-Treffern (Rauten).
- Echos sind **nummerierte Scheiben** in kühlem „Mondlicht“; warm ist nur das eigene Licht. Ihre Wege erscheinen nur
  1 s voraus, ihre Treffer 2 s voraus als Ring mit Ziffer (wo und wann das Echo zuschlägt).
- Die Wege der Schatten sind zwischen den Läufen gedämpft sichtbar, im Lauf nur für Schatten, die gleich erscheinen.
- **Ein Textkanal:** Lehrtexte nur zwischen den Läufen als Zettel über dem Startring; im Lauf nur Kurzlabels, die am
  Objekt mitfahren („Dein Echo“, „lädt …“, „Zwillinge!“). Stil und Messwerte: `docs/art/STYLE_GUIDE.md`.
- Kein versteckter Zufall: Welle und Echos sind deterministisch.
- Fehleingaben: Startring (bewusster Zug), verbrauchte Finger nach Laufende, Kassieren als eigener Button,
  Neustart-Sperre 0,9 s auf dem Ergebnis-Bildschirm.

## 5a. Barrierefreiheit (Stand 0.7)
- **Form vor Farbe:** Schatten-Typen, Echo-Nummern, Morgengrauen im Verlauf (Sonne) sind auch ohne Farbe
  unterscheidbar; Farbsehschwächen mit dem Debug-Simulator geprüft (`docs/art/ART_REVIEW_0.4.md`).
- **Effekte voll / reduziert / minimal:** „minimal“ ohne Wackeln, Blitze, Druckwellen und Flackern; kein Element
  blinkt schneller als 2 Hz. Schlagringe bleiben als ruhige Rückmeldung (sie sind Spielinformation).
- **Schrift normal / groß** (+20 % für Menüs, Karten, Lehr-Zettel); der HUD im Lauf bleibt bewusst fest.
- **Touch-Ziele ≥ 48 dp** auf 360-dp-Telefonen (`UiTheme.TOUCH_MIN`), sichere Bildschirmränder auf allen Seiten.
- **Ohne Ton spielbar** (alles Hörbare auch sichtbar), Vibration abschaltbar, Lautstärken getrennt.
- **Motorik:** relative Steuerung mit drei Empfindlichkeiten, Daumenwechsel ohne Strafe, zweites Licht abschaltbar,
  bewusste Gesten statt Antippen für folgenreiche Aktionen (Startring, Kassieren-Knopf).
- Nicht vorhanden: Bildschirmleser-Unterstützung (Godot 4.7 bietet sie auf Android nicht).

## 6. Onboarding (ohne Tutorial-Bildschirme)
Die Lehr-Welle lehrt selbst. Hinweise erscheinen einmalig im Moment, in dem sie gebraucht werden (gespeichert);
als Zettel in der nächsten Pause, wobei der neueste gewinnt (ein Zettel gilt erst nach 1 s Sichtbarkeit als gelesen):
Steuerung → „Ein Licht schafft nicht beide“ → „Dein Echo wiederholt Weg und Treffer“ → Nachglühen → Kassieren →
Flammen → Zwillinge → Gepanzerte → Ketten (Doppeltreffer) → Profi-Tipp zweiter Finger. In der allerersten Lehr-Welle wird der
Kassieren-Button erst angeboten, nachdem man ein Echo gesehen hat.

## 7. Ton (Funktion, nicht Deko)
- Jedes Licht besitzt einen Ton der D-Dur-Pentatonik. Das lebende Licht klingt als klare Glasglocke, sein Echo als
  weichere, verhallte Erinnerung desselben Tons → eine verteidigte Welle klingt wie ein Kanon und man **hört**, wann
  jedes Echo trifft.
- Leiser Holz-Tick jede Sekunde = hörbare Zeitleiste; „Licht bereit“-Klang nach dem Nachglühen.
- Misserfolg klingt weich (erlöschende Flamme, Atem), nie wie ein Summer.
- Vollständig spielbar ohne Ton; alles Hörbare ist auch sichtbar.

## 8. Wiederspielwert ohne Dark Patterns
- Tagesnacht (gleicher Seed für alle am selben Tag, fortlaufende Nummer, eigener Tagesbestwert, offline) mit
  **Leitmotiv**: reihum Ketten, Zangen oder Regen – im Menü angekündigt, kein Streak, keine Strafe fürs Auslassen.
- **Nächstes Ziel** auf der Ergebniskarte: das nächstliegende offene Sternbild mit Fortschritt („18 / 25 perfekte
  Wellen“) – konkret, ohne Uhr und ohne Druck.
- **Nacht-Historie** auf der Seite „Sternbilder“: die letzten 15 Nächte als Balken (warm mit Sonne = Morgengrauen, Ring =
  Vollmond), Bestwert-Linie, Durchschnitt der letzten 10 – Fortschritt sichtbar machen statt Tage zählen.
- Persönlicher Bestwert je Modus, Statistiken auf der Seite „Sternbilder“.
- **Sternbilder** (10 Achievements) schalten **rein kosmetische** Laternenpapiere frei – kein Spielvorteil.
- **Vollmond** (schwerer, freigeschaltet durch das erste Morgengrauen) als Ziel für Geübte.
- Keine Energie, keine Wartezeiten, keine Echtgeld-Währung, keine Lootboxen, keine Streak-Strafen, kein Login.

## 9. Werbung (umgesetzt als Vorschau in 0.6, ADR 0004)
- Nie während eines Laufs, nie direkt nach dem ersten Start, nie bei jedem Verlust.
- Neue Spieler: die ersten 5 Nächte überhaupt werbefrei; pro Sitzung frühestens nach der 4. Nacht, danach höchstens
  jede 4. Nacht und nie öfter als alle 5 Minuten, auch über App-Neustarts (`AdPolicy`, getestet; ungünstigster Fall
  ≤ 12/h – die ursprünglichen 3 Minuten hätten verlierenden Spielern bis zu 20/h erlaubt). Nur beim Verlassen der Ergebniskarte, nie beim Abbruch
  über das Pausemenü. Einwilligung wird erst nach der zweiten Nacht erfragt, nicht beim ersten Start;
  Rewarded nur auf Wunsch und rein kosmetisch (ein gesperrtes Laternenpapier eine Nacht lang). Werbung vollständig
  abschaltbar; Spiel funktioniert ohne Netz. Details und Frequenz-Analyse: `docs/compliance/ADS_AND_CONSENT.md`.

## 10. Offene Risiken (für den Gerätetest)
1. Kommt der Aha-Moment in der ersten Minute? (Kriterium: ≥ 4/5 erklären Echos nach Runde 1.)
2. Sind Zwillinge mit 0,6 s Fenster lesbar oder frustrierend?
3. Fühlt sich Nachglühen fair an, wenn das Licht durch einen Schatten gleitet?
4. Relative Steuerung auf 6"-Displays: Empfindlichkeit, Ermüdung.
5. Lesbarkeit bei Lauf 4–6 (viele Echos).
6. Werden Ketten als „Trick“ (Schlag zwischen zwei Glieder) entdeckt, oder fühlen sie sich nur dichter an?
