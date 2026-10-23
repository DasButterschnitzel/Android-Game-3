# ADR 0003 – Nachglühen, Echo-Treffer als feste Ereignisse, Wertung nach Lichtern

Status: entschieden · 2026-10-23 · Entscheider: Agent A (Game Director), umgesetzt von Agent E
Grundlagen: ADR 0002 (verbindliche Bedingungen), `docs/playtests/PROTOTYPE_COMPARISON_CRITIC.md` §3,
`docs/playtests/ECHO_SIM.md` (Abschnitt „Produktionsregeln“).

## Problem

ADR 0002 verlangt: Die Lehr-Welle muss für ein einzelnes Licht **nachweislich unlösbar** sein. Der Kritiker schlug
vor: „zwei Schatten gleichzeitig dicht vor dem Kern, auf gegenüberliegenden Seiten“.

Nachrechnung (erschöpfende Suche über alle Trefferzeitpunkte, `tools/sim/teach_check_prototype_rules.py`):
Mit den Prototyp-Regeln (Treffer bei Berührung, ohne Erholzeit) löst **ein** Licht diese Welle bei 300, 520 und
900 px/s. Grund: Alle Schatten laufen auf denselben kleinen Kern zu. Ein Licht, das 3–6× schneller ist als die
Schatten, wartet am Kern und erwischt beide nacheinander. Geometrie allein kann die Bedingung bei spielbarem Lichttempo
nicht erfüllen; ein langsameres Licht würde die Steuerung zäh machen.

## Entscheidung

1. **Nachglühen:** Nach einem Treffer braucht ein Licht 1,0 s, bis es wieder trifft (sichtbarer Ladering).
   Ein Treffer erfasst alle Schatten im Trefferradius („Doppelt!“).
2. **Echos wiederholen Weg *und* Trefferzeitpunkte exakt.** Ein Echo-Treffer ist ein festes Ereignis (Tick, Ort).
   Es blitzt dort auch dann, wenn der Schatten schon weg ist.
3. **Multiplikator zählt Lichter, nicht Läufe.** Ein zweiter Finger entzündet ein zweites Licht im selben Lauf und
   kostet genau wie ein weiterer Lauf. Mehrfinger spart Zeit, keine Punkte.
4. **Drei Flammen statt fünf Leben, Morgengrauen-Bonus 100 je Flamme.**
5. **Zwillinge** ab Welle 3 mit 0,6 s Fenster und Ankündigung; **Gepanzerte** ab Welle 4 (je zwei verschiedene Lichter).
6. **Lauf-Start nur durch bewussten Zug aus dem Startring** (56 px Lichtweg ≈ 40 px Fingerweg). Ein Finger, der beim
   Laufende noch liegt, ist verbraucht. Kassieren ist ein eigener Button.

## Warum das trägt

- **Beweisbar statt gemessen:** Die beiden Lehr-Schatten sind nur in einem Fenster von 49 Ticks trefferbar, das
  Nachglühen dauert 60 Ticks. Damit trifft ein einzelnes Licht – egal wie schnell – höchstens einen
  (`test_teaching_wave_is_provably_unsolvable_for_one_light`). Dasselbe Argument macht Zwillinge (0,6 s < 1,0 s) zu
  einer echten Zwei-Lichter-Aufgabe.
- **Echos bleiben vorhersagbar:** Weil Echo-Treffer feste Ereignisse sind, kann ein zusätzliches Licht nie dafür sorgen,
  dass ein sonst getroffener Schatten durchkommt (Monotonie, `test_extra_light_never_saves_a_shadow`). Für Spieler heißt
  das: Die Ringe auf der Echo-Spur zeigen genau, wo und wann das Echo zuschlagen wird – die Frage des Kritikers
  „Welche Schatten kommen durch?“ ist am Bildschirm beantwortbar.
- **Wertung nach Lichtern** verhindert, dass der zweite Finger zur Pflicht oder zum Exploit wird.
- **Drei Flammen:** Ohne diese Änderung erreichte „immer allein kassieren“ 55 % des Planer-Bestwerts (Grenze 40 %).
  Mit drei Flammen: 37–39 % auf frischen Seeds, bei 400/600/900 px/s Bot-Tempo.

## Messung (Bots, keine Menschen)

`godot --headless --path game --script res://tests/simulation/sim_echo.gd -- 40 7000 600 | python3 tools/sim/summarize_echo.py`

| Kriterium | Ergebnis (Seeds 7000–7039, 600 px/s) | Grenze |
|---|---|---|
| E1 allein / Planer | 0,374 | ≤ 0,40 |
| C1 reaktiv / Planer | 0,235 | ≤ 0,50 |
| T1 Lehr-Welle allein verloren | 100 % | 100 % |
| T2 Zwillingspaare zerstört (Planer) | 94–95 % | ≥ 80 % |
| L1 Rundenlänge Planer (Median, inkl. 2 s Entscheidung je Pause) | 75–89 s | 60–180 s |
| E2 Strategien ≥ 80 % des Besten | perfect, early | ≥ 2 (schwach, siehe ECHO_SIM.md) |

## Kosten und Risiken

- Eine Regel mehr (Nachglühen). Sie ist sichtbar (Ladering, gedimmtes Licht) und wird beim ersten Auftreten erklärt.
- Ein Licht kann durch einen Schatten gleiten, ohne zu treffen. Ob das als unfair empfunden wird, zeigt nur der
  Gerätetest (Frage im Protokoll ergänzt).
- Automatisches Treffen bei Berührung kann eine Ladung an einen unwichtigen Schatten „verschwenden“. Das ist eine
  bewusste Routen-Entscheidung, muss aber am Gerät beobachtet werden.
