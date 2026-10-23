# Geräte-Testplan (echte Android-Hardware)

Diese Prüfungen **können in der Entwicklungsumgebung nicht ausgeführt werden** (kein KVM/Emulator, kein Gerät,
siehe `docs/ENVIRONMENT.md`). Sie sind für jede Test-APK von einem Menschen auf mindestens einem Mittelklassegerät
durchzuführen. Ergebnisse bitte in `docs/playtests/device_results_<version>.md` festhalten (Vorlage unten).

## A. Installation & Start
| # | Schritt | Erwartung |
|---|---|---|
| A1 | APK per Datei-Manager installieren („Unbekannte Quellen“ für diesen Installer erlauben) | Installation ohne Fehler |
| A2 | App starten (Kaltstart, Zeit stoppen) | Spielbarer Bildschirm in < 3 s auf Mittelklassegerät |
| A3 | Systemberechtigungen prüfen (Einstellungen → Apps → Berechtigungen) | keine Laufzeit-Berechtigungsdialoge; höchstens „Vibration“ (normale Berechtigung) |
| A4 | Hochformat sperren/entsperren, Gerät drehen | Spiel bleibt im Hochformat, kein Neustart der Runde |

## B. Touch & Multitouch
| # | Schritt | Erwartung |
|---|---|---|
| B1 | Mit einem Finger spielen, schnell und langsam ziehen | Licht folgt dem Fingerweg ohne Sprünge; bei schnellen Wischern holt es kurz auf, driftet aber nie ab |
| B2 | Touch-Debug-Anzeige einschalten (Einstellungen) und zwei Finger gleichzeitig bewegen | zwei Kreise mit eigener ID, unabhängige Bewegung |
| B3 | Beide Finger exakt gleichzeitig loslassen | beide „up“ im Debug-Log, nichts bleibt hängen |
| B4 | Finger über den Bildschirmrand hinausziehen | kein Absturz, Eingabe endet sauber |
| B5 | Vom linken/rechten Rand nach innen wischen während einer Runde (Zurück-Geste) bzw. Zurück-Taste | Spiel pausiert (beendet sich **nicht**); erneutes Zurück setzt fort; im Hauptmenü beendet Zurück die App |
| B6 | Drei oder mehr Finger auflegen | keine Fehlfunktion; überzählige Finger werden ignoriert |
| B7 | Handfläche liegt am Rand auf (typische Einhandhaltung) | keine Geisterberührungen, die Runden zerstören |
| B8 | Nach Laufende Finger liegen lassen und leicht bewegen | **kein** neuer Lauf startet; erst Abheben + bewusster Zug aus dem Ring startet |
| B9 | Im Startring mit dem Finger zittern / kleine Kreise | Lauf startet nicht |
| B10 | Während eines Laufs zweiten Finger kurz auflegen, ohne zu ziehen | kein zweites Licht; erst ein Zug von ca. 4 mm entzündet es |
| B11 | Gerät mit Kamera-Aussparung (Punch-Hole/Notch) | Punkte, Welle, Pause-Knopf und Zeitleiste liegen vollständig unter der Aussparung |
| B12 | Gerät mit Gestenleiste unten | Kassieren-Button liegt vollständig darüber |

## C. Lebenszyklus
| # | Schritt | Erwartung |
|---|---|---|
| C1 | Während der Runde Home drücken, 30 s warten, zurückkehren | Spiel ist pausiert, Ton stumm, Fortsetzen per Tipp |
| C2 | Während der Runde anrufen lassen (oder Wecker) | Pause; nach Ende des Anrufs korrekt fortsetzbar; kein Ton während des Anrufs |
| C3 | App im Hintergrund vom System beenden lassen (Entwickleroptionen „Aktivitäten nicht behalten“) und neu starten | Bestwert und Einstellungen erhalten |
| C4 | Flugmodus an, App starten, mehrere Runden | Spiel vollständig ohne Netz spielbar, keine Wartedialoge |
| C5 | Bildschirm sperren während der Runde | Pause, kein Ton |

## D. Audio
| # | Schritt | Erwartung |
|---|---|---|
| D1 | Lautstärkeregler Musik/Effekte/Gesamt bewegen | sofort hörbar, nach Neustart gespeichert |
| D2 | Stummschalten | absolut still; Spiel bleibt verständlich |
| D3 | Musik einer anderen App läuft, Spiel starten | Verhalten dokumentieren (Godot nutzt Audiofokus des Systems) |
| D4 | Welle mit vielen Echos (Lauf 4–6) | Kanon klingt angenehm, kein Übersteuern/Knacken; man hört, wann Echos treffen |
| D5 | Sekundentakt und „Licht bereit“-Ton | hörbar, aber nicht störend (sonst Lautstärke-Notiz) |

## E. Leistung
| # | Schritt | Erwartung |
|---|---|---|
| E1 | Entwickleroptionen → „Profil-GPU-Rendering“ oder FPS-Anzeige; 3 Runden spielen | ≥ 55 FPS stabil auf Mittelklasse, ≥ 30 FPS auf Einsteigergerät |
| E2 | 10 Minuten durchspielen | Gerät wird nicht auffällig heiß; kein Ruckeln über die Zeit (Speicherlecks) |
| E3 | Akkuverbrauch nach 15 Minuten notieren | plausibel für ein 2D-Spiel |

## F. Spielerlebnis (menschlicher Playtest – die eigentliche Messlatte)
Siehe `PLAYTEST_PROTOCOL.md`. Kurzform: 5 Personen, die das Spiel nicht kennen, ohne Erklärung spielen lassen;
notieren: Zeit bis zum Verstehen, erste Reaktion, Anzahl freiwilliger Runden, „Eine Runde noch?“-Moment, Frustpunkte.

### Abbruch- und Umbaukriterien für NACHHALL (ADR 0002, vorab festgelegt)
- < 4/5 Tester erklären nach der ersten Nacht die Echo-Regel richtig → Onboarding umbauen oder Konzept stoppen.
- Median bis zur ersten **absichtlichen** Echo-Nutzung > 20 s.
- Nach 5 Nächten spielen alle dasselbe Rezept.
- < 3/5 spielen ungefragt ≥ 3 weitere Nächte.

### Zusatzfragen nach ADR 0003 (Nachglühen)
- Ist es vorgekommen, dass das Licht durch einen Schatten „durchgeglitten“ ist, ohne zu treffen? Fühlte sich das fair an?
- Vor Lauf 4 einer Welle fragen: „Welche Schatten kommen durch?“ – Anteil richtiger Vorhersagen (Ziel ≥ 60 %).
- Zwillinge: Anteil zerstörter Paare nach 5 Nächten (Ziel ≥ 50 %); Wort „unfair“ gefallen?

## G. Lesbarkeit & Darstellung (ab 0.4)
| # | Schritt | Erwartung |
|---|---|---|
| G1 | Bei voller und bei niedriger Helligkeit spielen, drinnen und draußen bei Tageslicht | Geistertypen, Echo-Ziffern, eigenes Licht und Zeitleiste ohne Anstrengung erkennbar |
| G2 | Erste Nacht nach frischer Installation | Lehr-Zettel erscheinen nur zwischen den Läufen, sind in < 3 s gelesen und nie veraltet („Zieh irgendwo…“ verschwindet nach dem ersten Lauf) |
| G3 | Kassieren nach einem Lauf mit Lecks | rotes Kosten-Etikett wird ohne Suchen gelesen; kostet es die letzten Flammen, steht „die Laterne erlischt“ dabei |
| G4 | System-Farbkorrektur „Graustufen“ bzw. Deuteranomalie einschalten (oder Testperson mit Farbsehschwäche) | die drei Geistertypen, Echo vs. eigenes Licht und Flamme vs. leerer Slot bleiben unterscheidbar |
| G5 | Kleines (≤ 5,5″) und großes (≥ 6,7″) Display | nichts abgeschnitten; Spielfeld gleich groß, nur die Ränder wachsen |
| G6 | Sternbilder-Seite öffnen, Laternenpapier wechseln | Papier wirkt sofort im Menü und im Spiel; gesperrte Papiere nennen ihre Bedingung |

## Vorlage Ergebnisprotokoll
```
Version: 0.x.y   Gerät: <Modell, Android-Version>   Datum:
A1 ok/nok – Notiz
...
Gesamteindruck:
Gefundene Fehler (mit Reproduktionsschritten):
```
