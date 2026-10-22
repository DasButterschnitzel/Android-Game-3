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
| B1 | Mit einem Finger spielen, schnell und langsam ziehen | Linie folgt ohne Sprünge/Lücken; kein Versatz |
| B2 | Touch-Debug-Anzeige einschalten (Einstellungen) und zwei Finger gleichzeitig bewegen | zwei Kreise mit eigener ID, unabhängige Bewegung |
| B3 | Beide Finger exakt gleichzeitig loslassen | beide „up“ im Debug-Log, nichts bleibt hängen |
| B4 | Finger über den Bildschirmrand hinausziehen | kein Absturz, Eingabe endet sauber |
| B5 | Vom linken/rechten Rand nach innen wischen während einer Runde | Systemgeste (Zurück) darf greifen; Spiel pausiert, verliert keinen Zustand |
| B6 | Drei oder mehr Finger auflegen | keine Fehlfunktion; überzählige Finger werden ignoriert |
| B7 | Handfläche liegt am Rand auf (typische Einhandhaltung) | keine Geisterberührungen, die Runden zerstören |

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
| D4 | Viele Explosionen gleichzeitig | kein Übersteuern/Knacken, keine Pegelsprünge |

## E. Leistung
| # | Schritt | Erwartung |
|---|---|---|
| E1 | Entwickleroptionen → „Profil-GPU-Rendering“ oder FPS-Anzeige; 3 Runden spielen | ≥ 55 FPS stabil auf Mittelklasse, ≥ 30 FPS auf Einsteigergerät |
| E2 | 10 Minuten durchspielen | Gerät wird nicht auffällig heiß; kein Ruckeln über die Zeit (Speicherlecks) |
| E3 | Akkuverbrauch nach 15 Minuten notieren | plausibel für ein 2D-Spiel |

## F. Spielerlebnis (menschlicher Playtest – die eigentliche Messlatte)
Siehe `PLAYTEST_PROTOCOL.md`. Kurzform: 5 Personen, die das Spiel nicht kennen, ohne Erklärung spielen lassen;
notieren: Zeit bis zum Verstehen, erste Reaktion, Anzahl freiwilliger Runden, „Eine Runde noch?“-Moment, Frustpunkte.

## Vorlage Ergebnisprotokoll
```
Version: 0.x.y   Gerät: <Modell, Android-Version>   Datum:
A1 ok/nok – Notiz
...
Gesamteindruck:
Gefundene Fehler (mit Reproduktionsschritten):
```
