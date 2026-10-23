# Entwicklungsumgebung & Build-Fähigkeiten

Stand: 2026-10-22 · geprüft zu Projektbeginn (Agent E – Lead Engineer)

## Tatsächlich geprüft

| Bereich | Ergebnis | Nachweis |
|---|---|---|
| Betriebssystem | Ubuntu 24.04.5 LTS, x86_64, 4 Kerne, 15 GiB RAM | `uname`, `/etc/os-release`, `free` |
| Engine | **Godot 4.7.2-stable** (offizielle Linux-Binary von downloads.godotengine.org) | `godot --version` → `4.7.2.stable.official.ed1daf0bf` |
| Export-Templates | 4.7.2-stable installiert (Android, Linux x86_64, Web) | `~/.local/share/godot/export_templates/4.7.2.stable/` |
| JDK | OpenJDK 21 (Godot empfiehlt 17, höhere Versionen werden laut Doku unterstützt) | `/usr/lib/jvm/java-21-openjdk-amd64` |
| Android SDK | cmdline-tools 23.0, platform-tools, build-tools 35.0.1 + 36.1.0, platform android-35 | `/opt/android-sdk` |
| APK-Export | **funktioniert** (nicht-Gradle-Export mit vorgefertigtem Template) | `tools/build_android.sh` → APK + `*.verify.txt` |
| Gradle-Export (2026-10-23) | **funktioniert** (Godot-Vorlage 4.7.2, Gradle 8.11.1, AGP 8.6.1; braucht Plattform android-36; in der Sandbox Maven-Central-Spiegel wegen HTTP 429) | `tools/build_ads_test.sh`, `docs/compliance/ADS_TEST_BUILD.md` |
| APK-Verifikation | aapt2 (Manifest, SDK-Level, Berechtigungen), apksigner (Signatur v2/v3) | `builds/android/*.verify.txt` |
| Rendering ohne Display | Xvfb + Mesa llvmpipe (OpenGL 3.3/ES 3.0-kompatibel) rendert echte Frames | Screenshot-Test erfolgreich |
| Video/Audio-Werkzeuge | ffmpeg 6.1 (libvorbis, libopus), ImageMagick 6.9, Python 3 + numpy + scipy | `ffmpeg -encoders` |
| Subagenten | verfügbar (parallele Recherche-/Review-Agenten) | genutzt in Phase 1/2 |
| Websuche | verfügbar | genutzt in Phase 1 |

Der erste Test-Export ergab: `minSdkVersion 24` (Android 7.0), `targetSdkVersion 36`, Signatur v2+v3 gültig,
native Bibliotheken für `arm64-v8a` und `armeabi-v7a`, **keine** angeforderten Berechtigungen.

## Blocker und Grenzen (ehrlich benannt)

1. **Kein Android-Emulator möglich.** `/dev/kvm` existiert nicht und die CPU meldet keine Virtualisierungs-
   Erweiterungen (vmx/svm). Der Android-Emulator benötigt für x86_64-Images Hardware-Beschleunigung; ARM-Images
   sind ohne sie praktisch unbenutzbar. **Folge:** Installation/Start der APK auf einem Android-System kann in
   dieser Umgebung *nicht* automatisiert getestet werden. Es wird kein solcher Test behauptet.
2. **Kein angeschlossenes Gerät** (`adb` findet keinen Server/kein Gerät).
3. **Kein Audio-Ausgabegerät.** Godot fällt auf den Dummy-Treiber zurück. Audio wird offline erzeugt und
   per Analyse (Pegel, Spektrum, Dauer) geprüft – nicht durch Anhören.
4. **GitHub-Releases-Downloads sind über den Proxy gesperrt (403).** Godot wird daher von
   `downloads.godotengine.org` (offizieller Mirror) geladen.

## Ersatzstrategie für Tests

Da derselbe Godot-Code auf Desktop-Linux und Android läuft, werden Spiellogik, Eingabeverarbeitung und
Rendering hier getestet:

- **Unit-/Integrationstests** headless (`game/tests/run_tests.gd`), inkl. Multitouch-Injektion über die
  echte Godot-Input-Pipeline (`Input.parse_input_event`).
- **Simulierte Runs** (Bots) für Balancing und Softlock-Suche – ausdrücklich *keine* menschlichen Playtests.
- **Gerenderte Screenshots/Videos** unter Xvfb (gleicher Renderer-Pfad „GL Compatibility“ wie auf Android).
- **APK-Strukturprüfung** mit aapt2/apksigner.

Was zwingend auf echter Hardware geprüft werden muss, steht in `docs/playtests/DEVICE_TEST_PLAN.md`.

## Reproduzierbarkeit

- `tools/setup_toolchain.sh` – installiert Godot, Templates, SDK-Pakete, Debug-Keystore, Editor-Einstellungen.
- `tools/build_android.sh <projekt> <apk> [debug|release]` – Export + Verifikation + Build-Log.
- `.github/workflows/android.yml` – baut bei jedem Push eine Debug-APK als Download-Artefakt.
