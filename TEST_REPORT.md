# Testbericht

Lebendes Dokument; jeder Build ergänzt einen Abschnitt. Grundsatz: **Nur was hier mit Befehl und Ergebnis steht, gilt
als getestet.** Bots und Simulationen sind keine Menschen.

## Testumgebung

| Was | Stand |
|---|---|
| Engine | Godot 4.7.2-stable, Renderer GL Compatibility |
| Automatische Tests | `godot --headless --path game --script res://tests/run_tests.gd` (Unit + Integration, echte Touch-Pipeline über `Input.parse_input_event`) |
| Smoke-Test | `tools/smoke_exported.sh`: exportiert den Linux-Build mit denselben Ressourcen wie Android und spielt darin eine komplette Nacht mit einem Bot |
| Simulation | `tests/simulation/sim_echo.gd` + `tools/sim/summarize_echo.py` (Abnahmekriterien automatisch) |
| Bild/Video | `tools/capture.sh` (Xvfb + llvmpipe, Godot Movie Maker): Bot spielt über die echte Touch-Pipeline |
| APK-Prüfung | `tools/build_android.sh`: aapt2 (Paket, SDK, Berechtigungen, Icon), apksigner (Signatur), Liste nativer Bibliotheken |
| CI | GitHub Actions `.github/workflows/android.yml`: Tests, Smoke-Test, APK-Export, Artefakt-Upload |
| Android-Gerät / Emulator | **nicht verfügbar** (keine KVM, kein Gerät). Gerätetests: `docs/playtests/DEVICE_TEST_PLAN.md` |

## 0.5.0 (2026-10-23)

| Prüfung | Befehl | Ergebnis |
|---|---|---|
| Unit- und Integrationstests | `run_tests.gd` | **117 / 117 grün** (neu u. a.: jede Formation kommt vor Laufende an, Kettenabstand und **Doppeltreffer** zwischen zwei Gliedern, Zangen gespiegelt und gleichzeitig, Regen in eigenen Bahnen, Determinismus, erste Nacht nur Streuung, Tagesnacht-Gewichtung und -Rotation, Ketten-Zettel einmalig, nächstes Sternbild, Nacht-Historie (Kappung, Laden alter Spielstände), Diagramm auf der Sternbilder-Seite, ungelesene Zettel gehen nicht verloren, Sprite-Atlas) |
| Bot-Simulation Formationen | `sim_echo.gd -- 40 7000 600 [overrides]`, 5 Einstellungen + Vollmond | alle Abnahmekriterien in allen Einstellungen bestanden (`docs/playtests/ECHO_SIM.md` Teil C) |
| Render-Last | `perf_probe.tscn` (llvmpipe, Bot-Nacht Seed 11) | Draw-Calls Median 31–34, Spitze 42 (0.4.0: 190–308 / 394); `EchoView._draw` Median 0,42–0,49 ms Skriptzeit; Vergleich alter/neuer Frame in doppelter Vergrößerung ohne sichtbaren Unterschied |
| Smoke-Test exportierter Build | `tools/smoke_exported.sh` | `SMOKE OK`; Bot-Nacht erreicht das Morgengrauen (1.350 Punkte) |
| Sichtprüfung | `tools/capture.sh … profile=early seed=2 played=3` (40 s) + Standbilder je Formation | Ketten, Zangen und Regen werden wie beschrieben erzeugt; fand den verlorenen Ketten-Zettel (behoben, Regressionstest) |
| APK-Build | `tools/build_android.sh game builds/android/nachhall-0.5.0-debug.apk debug` | gebaut, 60.178.652 Bytes, SHA-256 `92e4e666…1001`, Signatur gültig (Debug), Berechtigung nur `VIBRATE` (`docs/builds/nachhall-0.5.0-debug.verify.txt`) |

**Nicht getestet:** alles am Gerät; ob Menschen den Doppeltreffer in Ketten entdecken; ob die Nacht-Historie motiviert
oder unter Druck setzt (bewusst ohne Serien/Streaks gebaut).

## 0.4.0 (2026-10-23)

| Prüfung | Befehl | Ergebnis |
|---|---|---|
| Unit- und Integrationstests | `run_tests.gd` | **97 / 97 grün** (neu u. a.: Overlays füllen den Bildschirm, Zurück-Taste auf jedem Bildschirm, sicherer Bereich, Lehr-Zettel warten auf die Pause und der neueste gewinnt, Zettel blenden ein, „Dein Echo“ fährt mit dem Echo, **Spielschrift auf allen Texten** in Spiel, Pause-Karte, Menü und Overlays, Glyphen-Abdeckung aller UI-Texte, Sternbilder/Vollmond/Tagesnacht-Nummer, Speicher-Migration v1→v2) |
| Gegenprobe der Regressionstests | Korrekturen vorübergehend zurückgenommen | Overlay-Tests schlagen mit dem Anker-Code aus 0.3.0 fehl; Schrift-, Label- und Zettel-Test schlagen ohne ihre Korrektur fehl (3 / 3) – die Tests erkennen die Fehler wirklich |
| Smoke-Test exportierter Build | `tools/smoke_exported.sh` | `SMOKE OK`; Bot-Nacht erreicht das Morgengrauen (1.325 Punkte), keine Engine-/Skriptfehler |
| Farbsehschwäche | Debug-Shader „Farbsicht-Test“ + `tools/art/cvd_sheet.py` (Machado 2009) | Protan, Deutan, Tritan, Graustufen: eigenes Licht vs. Echo, die drei Geistertypen (Feld und Zeitleiste) und Flamme vs. leerer Slot bleiben unterscheidbar – **Sichtprüfung simulierter Bilder, kein Test mit farbfehlsichtigen Menschen** |
| Sichtprüfung Aufnahmen | `tools/capture.sh` (48 s `profile=early seed=11`, 30 s + 14 s `profile=solo seed=5`, Menü, Sternbilder) | fand 3 Fehler, alle behoben und mit Tests abgesichert: Kassieren-Knopf in Godot-Standardschrift, „Dein Echo“ blieb am Startpunkt, neuer Zettel einen Frame lang leer; Endstand ohne Befund (`docs/media/nachhall_0.4.0_*`) |
| Render-Last (Software-Renderer) | `tests/capture/perf_probe.tscn` unter Xvfb/llvmpipe, Bot „perfect“, Seed 11; gleiche Sonde auf dem 0.3.0-Commit | Draw-Calls Median je Echo-Zahl 0–3: **190 / 245 / 272 / 308** (0.3.0: 113 / 142 / 157 / 172), Spitze **394** (0.3.0: 252); Primitive Spitze 12.132 (0.3.0: 10.847). **Die neue Grafik kostet ≈ 70–80 % mehr Draw-Calls** (Tuschekonturen, Schatten, Plattenringe als Einzelbefehle) → Batching-Optimierung ist für 0.5 eingeplant. Frame-Zeiten unter llvmpipe sind **keine Handy-Werte** |
| APK-Build | `tools/build_android.sh game builds/android/nachhall-0.4.0-debug.apk debug` | gebaut, 60.145.338 Bytes, SHA-256 `80408c92…c614`, Signatur gültig (Debug), minSdk 24, targetSdk 36, Berechtigung nur `VIBRATE` (`docs/builds/nachhall-0.4.0-debug.verify.txt`) |

**Nicht getestet:** alles am Gerät (siehe 0.2.0) – insbesondere Lesbarkeit auf echten Displays und bei Sonnenlicht,
tatsächliche Bildrate auf Mittelklasse- und Einsteigergeräten mit der neuen Grafik, Wirkung auf Menschen mit
Farbsehschwäche. Neue Prüfschritte dafür: `docs/playtests/DEVICE_TEST_PLAN.md`, Abschnitt G.

## 0.3.0 (2026-10-23)

| Prüfung | Befehl | Ergebnis |
|---|---|---|
| Unit- und Integrationstests | `run_tests.gd` | **77 / 77 grün** (neu: erste Lehr-Welle ohne Kassieren vor dem ersten Echo) |
| Smoke-Test exportierter Build | `tools/smoke_exported.sh` | `SMOKE OK`; Bot-Nacht erreicht das Morgengrauen (1.350 Punkte), keine Engine-/Skriptfehler |
| Audio-Prüfung | `tools/audio/analyze_audio.py --report docs/audio/AUDIO_REPORT.md` | 61 Dateien, keine Regelverletzung; **neue Klick-Regel** fand Klicks in 15 Dateien (auch LUNTE-Satz aus 0.1) → Ursache behoben, neu erzeugt |
| Video-Aufnahme 50 s | `tools/capture.sh … echo_game.tscn profile=early seed=11` | Effekte sichtbar (Schweife, Splats, Wellen, Punkteflug), keine Fehler im Log |
| APK-Build | `tools/build_android.sh game builds/android/nachhall-0.3.0-debug.apk debug` | gebaut, 60.311.945 Bytes, SHA-256 `658f8931…d75a`, Signatur gültig (Debug), Berechtigung nur `VIBRATE` (`docs/builds/nachhall-0.3.0-debug.verify.txt`) |

**Nicht getestet:** alles am Gerät (siehe 0.2.0), insbesondere ob die Klänge auf Handy-Lautsprechern angenehm und
gut unterscheidbar sind – Klangqualität ist nur objektiv gemessen (Pegel, Klicks, Bassanteil), **nicht angehört**.

## 0.2.0 (2026-10-23)

| Prüfung | Befehl | Ergebnis |
|---|---|---|
| Unit- und Integrationstests | `run_tests.gd` | **76 / 76 grün** |
| Compile-Check aller Spielskripte | Teil der Tests (`test_scripts_compile.gd`) | grün |
| Smoke-Test exportierter Build | `tools/smoke_exported.sh` | `SMOKE OK`, Bot-Nacht über 5 Wellen ohne Engine-/Skriptfehler |
| Simulation 40 Seeds × 5 Strategien | `sim_echo.gd -- 40 7000 600` (+ 400/900 px/s, Seeds 3000) | E1, C1, T1, T2, L1, E2 bestanden (Werte: `docs/playtests/ECHO_SIM.md`) |
| Video-Aufnahme 75 s | `tools/capture.sh … echo_game.tscn profile=early seed=11` | ganze Nacht inkl. Neustart, keine Fehler im Log; Sichtprüfung: Popups überlappten → behoben |
| APK-Build | `tools/build_android.sh game builds/android/nachhall-0.2.0-debug.apk debug` | gebaut, 59.457.665 Bytes, SHA-256 `e02d2b6d…d75d`, Signatur v2/v3 gültig (Debug), minSdk 24, targetSdk 36, Berechtigung nur `VIBRATE` (Bericht: `docs/builds/nachhall-0.2.0-debug.verify.txt`) |

**Nicht getestet:** Installation und Start auf Android, Touch-Gefühl, Lesbarkeit auf echten Displays, Haptik,
Audio-Ausgabe über Gerätelautsprecher, Lebenszyklus (Hintergrund/Anruf) auf Android, Leistung auf schwachen Geräten.

### Was die Integrationstests über die echte Touch-Pipeline abdecken
- Fingerzittern im Startring startet keinen Lauf; bewusster Zug aus dem Ring startet und steuert relativ (Weg × Verstärkung).
- Schneller Wischer: Tempolimit hält, Licht holt ohne Drift auf.
- Ein Finger, der beim Laufende noch liegt, startet keinen neuen Lauf; ein neuer bewusster Zug schon.
- Kassieren-Button kassiert und bewegt das Licht nicht.
- Zweiter Finger: Streifen/Ruhen tut nichts, bewusster Zug entzündet ein zweites Licht (Multiplikator sinkt).
- Pause friert den Lauf ein, Fortsetzen läuft weiter.
- Verlorene Nacht → Ergebnis, Neustart-Sperre 0,9 s, Neustart gibt die alte Runde frei (WeakRef).

### Regelbeweise (Unit-Tests)
- Lehr-Welle: beide Trefferfenster liegen innerhalb einer Nachglühzeit → für ein Licht beweisbar unlösbar.
- Echos wiederholen Ort und Zeitpunkt jedes Treffers exakt.
- Monotonie: Ein zusätzliches Licht rettet nie einen sonst zerstörten Schatten (12 zufällige Szenarien).
- Gepanzerte brauchen zwei verschiedene Lichter; Zwillinge zwei Lichter im Zeitfenster.
- Jeder Schatten erreicht die Laterne vor Laufende (40 Seeds × 5 Wellen).

## 0.1.0 (2026-10-22)
Siehe `docs/builds/pocket-lab-0.1.0.verify.txt` und `docs/playtests/` (Prototyp-Labor; 58 Tests grün zum damaligen Stand).
