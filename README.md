# NACHHALL (Arbeitstitel)

Ein kostenloses, werbefinanziertes Android-Casualspiel für sehr kurze Pausen: Du verteidigst eine Papierlaterne gegen
Tuschegeister, in Läufen von höchstens acht Sekunden – und **jeder Lauf wird ein Echo, das danach mitspielt**.
Eine Nacht dauert 1–3 Minuten. Keine Käufe, keine Energie, kein Login, vollständig offline spielbar.

Entstanden als „autonomes Multi-Agenten-Studio“ (Recherche → 19 Konzepte → Kritik → zwei Prototypen → Entscheidung).
Der Weg dorthin ist in `docs/` dokumentiert, insbesondere `docs/decisions/` (ADR 0001–0003).

## Status
Aktueller Build und Testergebnisse: `CHANGELOG.md`, `TEST_REPORT.md`.
**Wichtig:** Kein Build wurde bisher auf einem echten Android-Gerät oder Emulator gestartet. Getestet wird mit
automatischen Tests, Bot-Simulationen, einem Smoke-Test des exportierten Builds und Videoaufnahmen.

## Spielen (Debug-APK)
1. APK aus den GitHub-Actions-Artefakten („Android test build“) oder aus `builds/android/` nehmen.
2. Auf dem Android-Gerät „Installation aus unbekannten Quellen“ für den Dateimanager erlauben, APK öffnen.
3. Mindestens Android 7.0 (API 24), arm64 oder armv7.

Debug-APKs sind mit dem Android-Debug-Zertifikat signiert und nicht für den Play Store bestimmt.

## Entwickeln
```bash
tools/setup_toolchain.sh                      # Godot 4.7.2, Export-Templates, Android SDK, Debug-Keystore
cd game && godot --headless --path . --import # einmalig: Assets importieren
godot --headless --path game --script res://tests/run_tests.gd          # Tests
tools/smoke_exported.sh                       # exportierter Linux-Build spielt eine Nacht mit Bot
tools/build_android.sh game builds/android/nachhall-debug.apk debug   # APK bauen + prüfen
godot --headless --path game --script res://tests/simulation/sim_echo.gd -- 40 7000 600 | python3 tools/sim/summarize_echo.py
tools/capture.sh /tmp/cap 40 scene=res://scenes/gameplay/echo_game.tscn profile=early seed=11   # Video
python3 tools/audio/make_nachhall_audio.py && python3 tools/audio/analyze_audio.py --report docs/audio/AUDIO_REPORT.md
python3 tools/art/make_icon.py && python3 tools/art/make_store_art.py
python3 tools/art/cvd_sheet.py out.png frame1.png [frame2.png ...]   # Farbsehschwäche-Simulation von Aufnahmen
```
Im Editor: `game/project.godot` öffnen und starten. Mit der Maus wird Touch emuliert (ein Finger).
Debug-Builds zeigen im Hauptmenü ein Prototyp-Labor mit den geparkten Prototypen.

## Dokumente
| Datei | Inhalt |
|---|---|
| `GAME_DESIGN.md` | Regeln, Wellen, Lesbarkeit, Onboarding, Ton, Werbe-Rahmen, offene Risiken |
| `ARCHITECTURE.md` | Aufbau, Datenfluss, Speicherstand, Lebenszyklus |
| `ASSET_LICENSES.md` | Herkunft und Lizenz jedes Assets |
| `CHANGELOG.md` | Versionen |
| `TEST_REPORT.md` | was wie getestet ist – und was nicht |
| `ROADMAP.md` | Meilensteine bis zum Release-Kandidaten |
| `docs/research/` | Markt- und Spielrecherche, Innovation Map |
| `docs/concepts/` | Konzepte, Kritik, Bewertung |
| `docs/decisions/` | Entscheidungen (ADR) |
| `docs/playtests/` | Simulationsprotokolle, Gerätetest-Plan, Testprotokoll |
| `docs/art/` | Stilguide „Papiertheater bei Laternenlicht“, Art-Gutachten 0.4 (Kontrast-, Farbsicht-Messungen) |
| `docs/audio/` | Klang-Bericht (Pegel, Klicks, Bassanteil je Datei) |
| `docs/compliance/` | Datenschutzerklärung (Entwurf), Data-Safety-Angaben, Werbung und Einwilligung |
| `docs/store/` | Store-Eintrag (Entwurf), Feature-Grafik |
| `docs/builds/`, `docs/media/` | APK-Prüfberichte (aapt2/apksigner), Bot-Videos und Kontaktbögen je Version |

## Lizenz
Code und eigene Assets: noch nicht festgelegt (Entscheidung des Projektinhabers). Fremdbestandteile siehe
`ASSET_LICENSES.md` (Godot Engine MIT, Schrift Fredoka SIL OFL 1.1).
