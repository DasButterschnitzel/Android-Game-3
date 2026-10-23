# Architektur

Godot 4.7.2, GDScript mit statischen Typen, Renderer GL Compatibility (läuft auf OpenGL ES 3.0, also auch auf
älteren Android-Geräten). Hochformat 720×1280 als Basis, Stretch `canvas_items` / `expand`.

## Leitlinien
1. **Regeln sind reine, deterministische Logik** (`RefCounted`, fester Zeitschritt 1/60 s, Seeds). Darstellung, Ton und
   Eingabe lesen die Regeln, verändern sie aber nur über eine schmale Schnittstelle. Dadurch sind Regeln ohne Szene
   testbar und von Bots simulierbar.
2. **Eingabe nur über `PointerTracker`**: Jeder Finger behält seine Identität von „down“ bis „up“; verpasste Ereignisse
   werden repariert, Fokusverlust bricht alle Zeiger ab. Spiellogik liest nie rohe Events.
3. **Balancing in JSON** (`game/data/balance/*.json`), Overrides für Parameter-Sweeps (`Config.with_overrides`).
4. **Keine Binär-Ressourcen, wo Code reicht**: UI-Theme, Busse, Grafik und Klänge entstehen prozedural oder per Skript
   (`tools/`), damit alles diff-bar und lizenzrechtlich eindeutig eigen ist.
5. **Offline zuerst**: Kein Netzwerk für das Spiel; Speicherstand lokal, atomar geschrieben.

## Verzeichnisse
```
game/
  project.godot, export_presets.cfg     Projekt, Android- und Linux-Smoke-Export
  data/balance/echo.json                Regeln und Wellen von NACHHALL
  scenes/menus/                         Hauptmenü (mit Bot-Partie im Hintergrund), Einstellungen, Credits, Datenschutz
  scenes/gameplay/echo_game.tscn        das Spiel
  scripts/
    core/        Config (JSON), GameFlow (Autoload "Flow": Szenenwechsel mit Blende), SmokeTest
    input/       PointerTracker, TouchDebugOverlay
    save/        SaveStore (Autoload "Save")
    audio/       AudioDirector (Autoload "Audio")
    systems/     Haptics
    ads/         AdPolicy (Frequenzregeln, getestet; SDK-Anbindung folgt in 0.6)
    ui/          UiTheme (Theme in Code, Schrift Fredoka)
    gameplay/
      echo/      NACHHALL: EchoSim (Regeln), EchoBot (Simulation/Aufnahme), EchoGame (Controller),
                 EchoView (Welt), EchoHud, EchoAudio, EchoOnboarding
      fx/        SparkParticles, ArtKit (Glow, Skyline), FireworkArt (LUNTE)
      fuse/, lunte/  LUNTE (geparkt, nur Debug-Labor)
  prototypes/    Debug-Labor mit geparkten Prototypen (LUNTE, SCHWARM)
  assets/        Schriften (OFL), Shader, Klänge, Icons – alles eigen erzeugt außer der Schrift
  tests/         unit/, integration/, simulation/, capture/, Runner
tools/           Toolchain-Setup, APK-Build+Prüfung, Smoke-Test, Aufnahme, Audio- und Icon-Generatoren, Sim-Auswertung
docs/            Recherche, Konzepte, Entscheidungen (ADR), Playtests, Builds, Medien
```

## Laufzeit-Struktur (Spielszene)
```
EchoGame (Node2D)            Rundenlebenszyklus, Zustände play/paused/results, Eingabe-Mapping
├── PointerTracker           Fingeridentität → pointer_down/moved/up/cancelled
├── EchoView (Node2D)        Himmel-Shader, Skyline, Laterne, Geister, Lichter, Echos, Effekte
├── SparkParticles           additive Partikel (eine Glow-Textur, ein Draw-Call-Pfad)
├── EchoAudio (Node)         Signale der Regeln → Klänge; Sekundentakt; Musikbett
└── CanvasLayer
    ├── EchoHud (Control)    Punkte, Welle, Multiplikator, Zeitleiste, Hinweise, Banner
    ├── Kassieren-Button
    ├── TouchDebugOverlay    (Einstellung „Touch-Anzeige“)
    └── Pause-/Ergebnis-Overlays
```
`EchoSim` lebt als `RefCounted` im Controller. Signale (`light_struck`, `enemy_destroyed`, `run_ended`, …) treiben
Darstellung und Ton. Lambdas fangen nie die Simulation selbst (sonst Referenzzyklus; ein Test mit `WeakRef` prüft,
dass alte Runden freigegeben werden).

## Daten- und Kontrollfluss eines Laufs
1. Finger zieht → `PointerTracker.pointer_moved` → `EchoGame._on_move` addiert Fingerweg × Verstärkung zum **Ziel**.
2. `_physics_process` (60 Hz) übergibt je Licht `Ziel − Position`; `EchoSim.step` begrenzt auf das Tempolimit,
   bewegt Schatten, führt feste Echo-Treffer aus, löst Treffer geladener Lichter aus.
3. Laufende → `run_ended` → Controller verbraucht noch liegende Finger, zeigt Kassieren/Nochmal.
4. `bank()` → Punkte, Flammen, nächste Welle oder `game_over` → Ergebnis, Speicherstand.

## Speicherstand
`SaveStore`: ein JSON-Dokument in `user://save.json` mit Schema-Version (aktuell 2). Schreiben über Temp-Datei +
Umbenennen (atomar). Unbekannte Schlüssel fallen weg, fehlende werden ergänzt, defekte Dateien werden beiseitegelegt.
Bei App-Pause wird sofort gespeichert. Debug-Builds können per Startargument `save=<datei>` (und `fresh_save`) eine
eigene Datei nutzen – Tests, Aufnahmen und Smoke-Test berühren so nie echte Spielstände.

## Lebenszyklus (Android)
- `NOTIFICATION_APPLICATION_PAUSED` / `FOCUS_OUT`: laufender Lauf → Pause-Menü; sonst alle Zeiger abbrechen;
  `AudioDirector` stummt den Master-Bus; `SaveStore` speichert sofort.
- Zurückkehren: Ton wieder an (Stummschaltung aus den Einstellungen bleibt), Spiel bleibt pausiert bis „Weiter“.

## Tests und Werkzeuge
Siehe `TEST_REPORT.md`. Kurz: Unit- und Integrationstests (echte Touch-Pipeline), Compile-Check aller Skripte,
Bot-Simulationen mit automatisch geprüften Abnahmekriterien, Smoke-Test im exportierten Build, Video-Aufnahme unter
Xvfb, APK-Prüfung mit aapt2/apksigner, CI auf GitHub Actions.
