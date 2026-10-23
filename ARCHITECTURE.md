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
  scenes/menus/                         Hauptmenü (mit Bot-Partie im Hintergrund), Einstellungen, Sternbilder
                                        (Sammlung/Statistik), Credits, Datenschutz
  scenes/gameplay/echo_game.tscn        das Spiel
  scripts/
    core/        Config (JSON), GameFlow (Autoload "Flow": Szenenwechsel mit Blende), SmokeTest
    input/       PointerTracker, TouchDebugOverlay
    save/        SaveStore (Autoload "Save")
    audio/       AudioDirector (Autoload "Audio")
    systems/     Haptics, Progression (Sternbilder/Achievements, kosmetische Laternenpapiere)
    ads/         AdPolicy (Frequenzregeln), AdService (Autoload "Ads") mit Adaptern none/mock/admob;
                 AdMobAdapter nur im Werbetest-Build "Android-AdsTest" (docs/compliance/ADS_TEST_BUILD.md)
    ui/          UiTheme (Theme in Code, Schrift Fredoka), SafeArea (Kamera-Aussparung, Gestenleiste)
    gameplay/
      echo/      NACHHALL: EchoSim (Regeln), EchoBot (Simulation/Aufnahme), EchoGame (Controller),
                 EchoView (Welt), EchoHud, EchoAudio, EchoOnboarding
      fx/        SparkParticles, ArtKit (Glow, Skyline), FireworkArt (LUNTE)
      fuse/, lunte/  LUNTE (geparkt, nur Debug-Labor)
  prototypes/    Debug-Labor mit geparkten Prototypen (LUNTE, SCHWARM)
  addons/nachhall_ads/  Editor-Export-Plugin + AARs des Werbetest-Builds (wirkt nur auf Preset "Android-AdsTest")
  assets/        Schriften (OFL), Shader, Klänge, Icons – alles eigen erzeugt außer der Schrift
  tests/         unit/, integration/, simulation/, capture/, Runner
android_plugins/nachhall_ads/  Quelltext des Android-Plugins (Java, Gradle) für Google Mobile Ads + UMP
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
Controls unter einer `CanvasLayer` erben kein Theme: sie bekommen das Theme oder die Schrift explizit
(`UiTheme.primary_button` setzt Fredoka selbst); `TestCase.assert_game_font` prüft das für Spiel, Menü und Overlays.
Kurzlabels am Objekt (`EchoView.light_label`) fahren mit ihrem Licht mit; Lehrtexte sammelt `EchoHud` und zeigt in
der nächsten Pause den neuesten als Zettel.

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
Umbenennen (atomar); die vorherige Datei bleibt als `save.json.bak` (letzte gute Kopie – GDScript kann kein fsync,
nach einem Stromausfall kann die neueste Datei leer sein). Laden: Hauptdatei, sonst die Kopie, sonst Standardwerte;
defekte Dateien werden beiseitegelegt (`.corrupt`). Unbekannte Schlüssel fallen weg, fehlende werden ergänzt,
Sternbilder, die die Statistik belegt, werden nachgetragen (`Progression.backfill`). Änderungen werden am Ende des
Frames gebündelt gespeichert; nach einem fehlgeschlagenen Schreiben versucht es die nächste Änderung erneut. Bei
App-Pause wird sofort gespeichert. Debug-Builds können per Startargument `save=<datei>` (und `fresh_save`) eine
eigene Datei nutzen – Tests, Aufnahmen und Smoke-Test berühren so nie echte Spielstände.

## Zurück-Taste und sicherer Bereich
- Android-Zurück (Taste oder Geste) kommt als `NOTIFICATION_WM_GO_BACK_REQUEST` bei `GameFlow` an
  (`quit_on_go_back` ist aus). `handle_back()` fragt den obersten sichtbaren Knoten der Gruppe `back_handler`
  (`on_back()`): Spiel → Pause/Weiter, Overlays → schließen, Hauptmenü → App verlassen.
- `SafeArea` rechnet `DisplayServer.get_display_safe_area()` in Viewport-Einheiten um: HUD und Spielfeld rücken unter
  eine Kamera-Aussparung, der Kassieren-Button über die Gestenleiste, alle Seiten halten Abstand. Das Ergebnis wird
  eine Sekunde lang wiederverwendet (auf Android ist jede Abfrage ein JNI-Aufruf, der HUD fragt jeden Frame). Tests
  setzen `SafeArea.override`.
- Oberfläche: `UiTheme` baut das Theme im Code; `TOUCH_MIN` (96 Einheiten = 48 dp auf 360-dp-Telefonen) ist die
  Mindesthöhe jedes Knopfes, `fs()` skaliert Schriftgrößen mit der Einstellung „Schrift“ (`text_scale`, gesetzt von
  `GameFlow` vor dem ersten Bildschirm).

## Lebenszyklus (Android)
- `NOTIFICATION_APPLICATION_PAUSED` / `FOCUS_OUT`: laufender Lauf → Pause-Menü; sonst alle Zeiger abbrechen (sie
  zählen erst nach dem Abheben wieder); `AudioDirector` stummt den Master-Bus; `SaveStore` speichert sofort.
- Zurückkehren: Ton erst wieder an, wenn die App fortgesetzt **und** fokussiert ist (nicht hinter dem
  Sperrbildschirm); die Stummschaltung aus den Einstellungen bleibt; das Spiel bleibt pausiert bis „Weiter“.
- Akku (nur Telefone): `EchoGame.power_for(state)` – Bildschirm bleibt nur während einer Nacht an
  (`screen_set_keep_on`), Pause und Ergebnis rendern mit 30 fps; Menüs lassen das Telefon schlafen.

## Werbung (Kurzfassung, Details in ADR 0004 und `docs/compliance/`)
- `AdService` (Autoload `Ads`) mit Adaptern `none` / `mock` (Platzhalter, Debug) / `admob` (Werbetest-Build, eigenes
  Plugin). Hauptschalter aus → kein Adapter; ein Adapter startet erst, wenn Werbung eingeschaltet ist (`start()`).
- AdMob/UMP: Aktualisierung der Einwilligungsinformationen bei jedem Start (ohne Formular); die frische Auskunft
  synchronisiert den gespeicherten Stand (`consent_info_changed`); Formular nur an einer Pause, abbrechbar
  (`cancel_consent`); Anzeigen nur mit Entscheidung. `AdPolicy` entscheidet die Frequenz (Zeitabstand auch über
  Neustarts, `ads.last_interstitial_unix`).

## Tests und Werkzeuge
Siehe `TEST_REPORT.md`. Kurz: Unit- und Integrationstests (echte Touch-Pipeline), Compile-Check aller Skripte,
Bot-Simulationen mit automatisch geprüften Abnahmekriterien, Smoke-Test im exportierten Build, Dauertest über 30
Nächte (`tools/soak.sh`), Layout-Prüfung jeder Seite in vier Bildschirmgrößen (`tools/layout_check.sh`),
Video-Aufnahme unter Xvfb, APK-Prüfung mit aapt2/apksigner, Werbe-SDK-Prüfung (`tools/verify_ads_build.sh`),
Release-Bundle mit bundletool (`tools/build_release.sh`), CI auf GitHub Actions.
