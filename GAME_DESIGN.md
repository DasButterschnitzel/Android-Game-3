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
| Zweiter Finger | entzündet nach bewusstem Zug (≥ 40 px) ein zweites Licht im selben Lauf; zählt wie ein Lauf | Multitouch mit Nutzen, kein Exploit |
| Leben | 3 Flammen; Durchgekommene kosten beim Kassieren je eine | Risiko ist sichtbar an der Laterne |
| Punkte | normal 10, Zwilling 15, gepanzert 25 | |

### Schatten-Typen
- **Normal** (rosa Rand) – ein Treffer.
- **Zwillinge** (violett, ab Welle 3, angekündigt) – zwei verbundene Schatten, die von **zwei verschiedenen Lichtern
  innerhalb von 0,6 s** getroffen werden müssen. Wird einer getroffen, zeigt ein Countdown-Ring am Partner das Fenster.
- **Gepanzert** (orange Platten, ab Welle 4) – braucht Treffer von **zwei verschiedenen Lichtern** (beliebige Zeit);
  ein Licht verschwendet keine Ladung an einen Panzer, den es schon angeknackst hat.

### Wellen (`game/data/balance/echo.json`)
| Welle | Inhalt | Lehrziel |
|---|---|---|
| 1 | 2 Schatten, nah, gleichzeitig, links/rechts | „Ein Licht schafft nicht beide“ – beweisbar unlösbar allein |
| 2 | 4 normale | allein schaffbar → ×6 möglich |
| 3 | 4 normale + Zwillingspaar | Synchronisieren mit dem Echo |
| 4 | 4 normale + Zwillinge + 1 gepanzerter | zwei Lichter auf ein Ziel |
| 5 | 5 normale + Zwillinge + 2 gepanzerte | alles zusammen |

## 4. Warum es nicht trivial wird (Bot-Belege, keine Menschen)
- Planen schlägt Reagieren: Ein reaktiver Bot erreicht 23–25 % des Planers.
- Echos sind nötig: Allein-Kassieren erreicht 37–39 % (Grenze 40 %).
- Das „Tortenstück“-Rezept (jede Runde eine Seite) erreicht nur 44–47 %.
- Perfektion vs. frühes Kassieren liegen nah beieinander (≈ 9 %) – eine echte Entscheidung.

## 5. Lesbarkeit und Fairness
- Alles, was während eines Laufs gelesen werden muss, steht **oben**: Punkte, Welle, Multiplikator mit Licht-Punkten,
  Zeitleiste mit Ankunft jedes Schattens (Dreiecke) und Echo-Treffern (Rauten).
- Echo-Spuren zeigen **Ring-Marken**, wo und wann das Echo zuschlagen wird; ältere Echos sind blasser.
- Die Wege der Schatten sind vor dem Lauf als gestrichelte Linien sichtbar.
- Kein versteckter Zufall: Welle und Echos sind deterministisch.
- Fehleingaben: Startring (bewusster Zug), verbrauchte Finger nach Laufende, Kassieren als eigener Button,
  Neustart-Sperre 0,9 s auf dem Ergebnis-Bildschirm.

## 6. Onboarding (ohne Tutorial-Bildschirme)
Die Lehr-Welle lehrt selbst. Hinweise erscheinen einmalig im Moment, in dem sie gebraucht werden (gespeichert):
Steuerung → „Ein Licht schafft nicht beide“ → „Dein Echo wiederholt Weg und Treffer“ → Nachglühen → Kassieren →
Flammen → Zwillinge → Gepanzerte → Profi-Tipp zweiter Finger. In der allerersten Lehr-Welle wird der
Kassieren-Button erst angeboten, nachdem man ein Echo gesehen hat.

## 7. Ton (Funktion, nicht Deko)
- Jedes Licht besitzt einen Ton der D-Dur-Pentatonik. Das lebende Licht klingt als klare Glasglocke, sein Echo als
  weichere, verhallte Erinnerung desselben Tons → eine verteidigte Welle klingt wie ein Kanon und man **hört**, wann
  jedes Echo trifft.
- Leiser Holz-Tick jede Sekunde = hörbare Zeitleiste; „Licht bereit“-Klang nach dem Nachglühen.
- Misserfolg klingt weich (erlöschende Flamme, Atem), nie wie ein Summer.
- Vollständig spielbar ohne Ton; alles Hörbare ist auch sichtbar.

## 8. Wiederspielwert ohne Dark Patterns
- Tagesnacht (gleicher Seed für alle am selben Tag, eigener Tagesbestwert, offline).
- Persönlicher Bestwert, Statistiken. Geplant (0.5): rein kosmetische Freischaltungen über Spielerfolge.
- Keine Energie, keine Wartezeiten, keine Echtgeld-Währung, keine Lootboxen, keine Streak-Strafen, kein Login.

## 9. Werbung (Rahmen, Umsetzung ab 0.6)
- Nie während eines Laufs, nie direkt nach dem ersten Start, nie bei jedem Verlust.
- Interstitial frühestens nach 3 abgeschlossenen Nächten, danach höchstens jede 4. Nacht und nie öfter als alle
  3 Minuten (`AdPolicy`, getestet; Obergrenze im ungünstigsten Fall ≈ 10/h bei 90-s-Nächten – wird in 0.6 geprüft);
  Rewarded nur optional und fair. Werbung vollständig abschaltbar; Spiel funktioniert ohne Netz.

## 10. Offene Risiken (für den Gerätetest)
1. Kommt der Aha-Moment in der ersten Minute? (Kriterium: ≥ 4/5 erklären Echos nach Runde 1.)
2. Sind Zwillinge mit 0,6 s Fenster lesbar oder frustrierend?
3. Fühlt sich Nachglühen fair an, wenn das Licht durch einen Schatten gleitet?
4. Relative Steuerung auf 6"-Displays: Empfindlichkeit, Ermüdung.
5. Lesbarkeit bei Lauf 4–6 (viele Echos).
