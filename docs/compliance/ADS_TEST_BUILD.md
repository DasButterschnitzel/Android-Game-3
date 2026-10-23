# Werbetest-Build „Android-AdsTest“ – Spike für 0.6 „Monetization Preview“ (Agent E2)

Stand: 2026-10-23 (überarbeitet für 0.7 nach dem Ads-Review) · Godot 4.7.2 · Google Mobile Ads SDK 25.5.0 · UMP 4.0.0

> Arbeitsdokument, keine Rechtsberatung. Der Build enthält ausschließlich **Googles öffentliche Test-IDs**, es gibt
> kein Werbekonto, und nichts wird veröffentlicht. Echte Anzeigen, ein AdMob-Konto und jede Veröffentlichung sind
> Entscheidungen des Inhabers (siehe §9).

## 1. Ergebnis in Kürze

| Frage | Ergebnis |
|---|---|
| Lässt sich ein **separater** Android-Build mit dem echten Google Mobile Ads SDK + UMP über ein **selbst geschriebenes** Godot-4-Android-Plugin (Plugin-System v2: AAR + `EditorExportPlugin`) bauen? | **Ja.** Preset `Android-AdsTest`, Gradle-Build, reproduzierbar mit `tools/build_ads_test.sh` (≈ 25 s bei warmem Cache, erster Lauf ≈ 2 min). |
| Ist das APK richtig verdrahtet? | **Ja, auf Build-Ebene geprüft** (aapt2, dexdump, apksigner): Test-App-ID im Manifest, Plugin-Registrierung, 658 Klassen `com.google.android.gms.ads.*`, 19 Klassen `com.google.android.ump.*`, Plugin-Klasse, Feature-Tag im `project.binary`, gültige Debug-Signatur. |
| Bleibt der Standard-Build unverändert? | **Ja.** Kein Werbe-SDK, **keine INTERNET-Berechtigung**; Manifest, alle `classes*.dex` und die nativen Bibliotheken sind **byte-identisch** zum Stand vor dem Spike. Nur das PCK enthält ≈ 9 KB zusätzliches, dort nie ausgeführtes GDScript (§4). |
| Funktioniert es auf einem Gerät? | **Nicht geprüft** – hier gibt es weder Gerät noch Emulator (keine KVM). Checkliste für den Gerätetest in §8. |

## 2. Was gebaut wurde

```
game/data/ads.json (nur Google-Test-IDs)
        │
AdService ("/root/Ads", nur im Werbetest-Build vorhanden)  ── AdPolicy (Frequenz, unverändert)
        │ adapter "admob"
AdMobAdapter (GDScript)  – Zeitlimits, nie blockierend, Vorladen
        │ JNI-Aufrufe / Signale
Singleton "NachhallAds" (Java, eigenes AAR, android_plugins/nachhall_ads)
        ├─ Google UMP 4.0.0: Einwilligung (Formular / Datenschutzoptionen)
        └─ Google Mobile Ads 25.5.0: Interstitial laden / zeigen

Export:  Preset "Android-AdsTest" (custom feature "nachhall_ads", Gradle-Build an)
         └─ addons/nachhall_ads (EditorExportPlugin) fügt NUR für dieses Feature hinzu:
            AAR + Maven-Abhängigkeiten + <meta-data APPLICATION_ID = Test-App-ID>
```

| Datei | Zweck |
|---|---|
| `android_plugins/nachhall_ads/` | Plugin-Quelltext (Java, ≈ 470 Zeilen) + Gradle-Projekt (Wrapper 8.11.1, AGP 8.6.1, compileSdk 36, minSdk 24, Java 17 – wie die Godot-4.7.2-Gradle-Vorlage). godot-lib `org.godotengine:godot:4.7.2.stable` (exakt passende Version, Maven Central) nur `compileOnly`. |
| `game/addons/nachhall_ads/bin/{debug,release}/NachhallAds-*.aar` | gebaute AARs (11 858 / 11 225 Byte), eingecheckt |
| `game/addons/nachhall_ads/plugin.cfg`, `plugin.gd`, `export_plugin.gd` | Editor-Addon; registriert den Export-Plugin. Aktiv im Projekt (`[editor_plugins]` in `project.godot`). |
| `game/scripts/ads/admob_adapter.gd` | echte Implementierung des `AdAdapter` gegen die Plugin-API (bisher Stub) |
| ~~`game/scripts/ads/ads_test_boot.gd`, Startszene~~ | im Spike vorhanden; seit 0.6 ersetzt durch den Autoload `Ads` in allen Builds (siehe §3) |
| `game/export_presets.cfg` | **neues** Preset `[preset.2] "Android-AdsTest"`; Presets 0 (`Android`) und 1 (`LinuxSmoke`) unverändert |
| `tools/build_ads_plugin.sh` | baut beide AARs und kopiert sie ins Addon |
| `tools/build_ads_test.sh` | installiert die Gradle-Vorlage, exportiert `Android-AdsTest`, prüft das APK |
| `tools/verify_ads_build.sh` | Build-Prüfungen für Werbetest-APK und (Gegenprobe) Standard-APK |
| `tools/gradle/maven_central_mirror.gradle` | optionales Gradle-Init-Skript gegen HTTP 429 von Maven Central in der Sandbox (§10) |
| `game/tests/unit/test_admob_adapter.gd` | 19 Tests des Adapters gegen ein nachgebautes Singleton, das sich wie UMP 4 verhält (vor der Aktualisierung keine Anzeigen) |

### Plugin-API (Singleton `NachhallAds`)

| Methode | Ergebnis-Signal(e) |
|---|---|
| `initialize(test_mode: bool, test_device_hashed_ids: String, max_ad_content_rating: String)` | `initialized(consent_status, can_request_ads, sdk_version)`; Status `refused`, wenn die App-ID im Manifest keine Google-Test-ID ist; danach die Aktualisierung der Einwilligungsinformationen → `consent_info(status, can_request_ads, error)` |
| `refresh_consent()` | `consent_info(status, can_request_ads, error)`; `error` leer = frisch, sonst gilt laut Google der Stand der letzten Sitzung |
| `request_consent(force: bool)` | `consent_form_shown()` (falls ein Formular erscheint), dann `consent_result(status, can_request_ads, error)` mit `granted` / `denied` / `not_required` / `unknown` |
| `cancel_consent()` | – (Zeitlimit: ein noch nicht erschienenes Formular erscheint nicht mehr) |
| `is_privacy_options_required() -> bool` | – (Knopf „Werbe-Einwilligung ändern“ nur, wenn UMP ihn verlangt) |
| `load_interstitial(unit_id: String, personalized: bool)` | `interstitial_loaded()` oder `interstitial_failed_to_load(code, message)` |
| `is_interstitial_ready() -> bool` | – |
| `show_interstitial()` | `interstitial_shown()`, dann `interstitial_closed()`; oder `interstitial_failed_to_show(code, message)` |
| `reset_consent()` | – (Testhilfe: UMP-Entscheidung vergessen) |

Ablauf (seit 0.7): Das Plugin startet erst, wenn Werbung eingeschaltet ist (Hauptschalter und Tester-Schalter), und
aktualisiert dann bei **jedem App-Start** die Einwilligungsinformationen (`requestConsentInfoUpdate`, Googles Vorgabe;
mit UMP 4.0.0 ist `canRequestAds()` vorher immer falsch). Das Formular erscheint nur, wenn das Spiel an einer Pause
fragt; ohne frische Information wartet die Pause nicht, sondern stößt eine neue Aktualisierung im Hintergrund an.
Angefragt wird nur mit Entscheidung (`OBTAINED`/`NOT_REQUIRED` **und** `canRequestAds()` – UMP meldet `canRequestAds()`
auch bei einem Fehlkonfigurations-Flag); `MobileAds.initialize()` erst beim ersten Laden, im Hintergrund-Thread.
Anfragen höchstens mit Inhaltseinstufung G (`setMaxAdContentRating`, aus `ads.json`). `personalized = false` setzt
`PublisherPrivacyPersonalizationState.DISABLED` (nicht personalisierte Anzeigen). Statuszuordnung: UMP `OBTAINED` →
`granted`, wenn laut TCF-Strings Zwecke 1, 3, 4 und Google (Anbieter 755) erlaubt sind, sonst `denied` (vereinfachte
Annahme, §9); `NOT_REQUIRED` → `not_required`; sonst `unknown` (z. B. offline → AdService fragt später erneut).
Im Testmodus: UMP-Debug-Geografie EWR + `setForceTesting(true)` (damit das Formular auch außerhalb des EWR erscheint).

### Sperren gegen echte IDs (vier Stellen)
1. `tests/unit/test_ad_service.gd::test_config_holds_only_google_test_ids` – jede ID in `ads.json` beginnt mit
   `ca-app-pub-3940256099942544`, `adapter_release` ist `none`.
2. Export-Plugin: schreibt die App-ID nur, wenn sie mit `ca-app-pub-3940256099942544~` beginnt; sonst wird **gar
   nichts** hinzugefügt (Fehlermeldung im Export-Log).
3. `AdMobAdapter.configure()`: andere Anzeigenblock-IDs → keine Anzeigen.
4. Java-Plugin: verweigert sich, wenn die App-ID im Manifest keine Test-ID ist (`initialized("refused", …)`), und lädt
   keine Anzeigenblöcke außerhalb von `ca-app-pub-3940256099942544/`.

## 3. Wie das Spiel den Dienst im Werbetest-Build nutzt
- **Seit 0.6:** `AdService` ist in allen Builds der Autoload `Ads` (Debug: Platzhalter, Release: keine Werbung).
  Das Feature-Tag `nachhall_ads` (nur im Preset `Android-AdsTest`) lässt ihn den Adapter `adapter_ads_test` wählen.
  Die Startszene des Spikes und der Feature-Override `run/main_scene.nachhall_ads` sind entfallen.
- `AdService` wählt mit dem Feature `adapter_ads_test` (= `admob`) und legt `ads_test_overrides` über die Frequenzregeln,
  damit ein Gerätetest schnell zum Ziel kommt: Einwilligung nach der **1.** Nacht, erstes Interstitial frühestens nach
  der **2.** Nacht, dann jede 2. Nacht, mindestens 60 s Abstand. Ohne Plugin (z. B. Desktop) fällt er auf „keine
  Werbung“ zurück.
- Neu und für jeden Build gültig (vorher fehlend): `EchoGame` meldet das Ende einer Nacht an `/root/Ads`
  (`on_round_finished()`), **nur falls** der Dienst existiert – im Standard-Build also wirkungslos.
- Nie blockierend: Einwilligung wartet höchstens 8 s auf das Netz (offen sichtbares Formular: bis 300 s, der Spieler
  liest); danach wird der Ablauf abgebrochen (`cancel_consent`), damit kein Formular verspätet über der nächsten Nacht
  aufgeht. Ohne frische Einwilligungsinformation (Start offline) wird an der Pause gar nicht gewartet. Ein
  Interstitial wird **nie** an der Pause geladen – ist keins vorgeladen, geht es sofort weiter und das
  nächste wird geladen. Nach „Zeigen“ höchstens 8 s bis zur Anzeige; die Zeit zählt nur, solange das Spiel selbst
  läuft (während eine Anzeige Godot pausiert, läuft keine Uhr ab).
- Erweiterung des `AdAdapter`-Vertrags: `request_consent()` darf `"unknown"` liefern (keine Entscheidung möglich).
  `AdService` behandelte das schon richtig (fragt bei der nächsten Pause erneut).

## 4. Warum der Standard-Build unberührt bleibt (Gegenprobe)

Das Export-Plugin liefert nur bei Presets mit dem Feature `nachhall_ads` Bibliotheken, Abhängigkeiten oder
Manifest-Einträge (geprüft: Godot setzt das Export-Preset vor diesen Aufrufen; Ablaufprotokoll beim ersten Export).
Vergleich `Android`-Preset vor dem Spike (Commit `ee7d5cb`) mit dem Stand danach:

| Merkmal | vorher | nachher |
|---|---|---|
| Größe | 60 337 764 Byte | 60 346 710 Byte (+8 946) |
| Berechtigungen | nur `VIBRATE` | nur `VIBRATE` |
| Manifest (`aapt2 dump xmltree`) | – | **identisch** |
| `classes*.dex`, `lib/**/*.so` | – | **identisch** (gleiche CRCs) |
| Werbe-SDK-Klassen | 0 | 0 |
| PCK-Unterschiede | – | geänderte Skripte (`ad_adapter`, `ad_service`, `admob_adapter`, `echo_game`), `ads.json`, neue Startszene, die zwei Editor-Skripte des Addons; in `project.binary` zwei wirkungslose Schlüssel (`run/main_scene.nachhall_ads`, `editor_plugins/enabled`) |

Die zwei Editor-Skripte (`plugin.gdc`, `export_plugin.gdc`) landen in jedem PCK, werden zur Laufzeit aber nie geladen
(kein `class_name`, keine Referenz). Ein Addon kann seine eigenen `.gd` nicht vom Export ausschließen, weil Godots
eingebauter GDScript-Exporter vorher läuft. Wer es strikt will: `addons/nachhall_ads/*` in den `exclude_filter` der
Presets aufnehmen – das ändert aber die bestehenden Presets, deshalb hier nicht gemacht (Entscheidung §9).

`tools/smoke_exported.sh` (Linux) besteht weiterhin. Zusätzlich wurde in einer Wegwerfkopie des Projekts ein
Linux-Build **mit** Feature `nachhall_ads` exportiert und der Smoke-Test darin ausgeführt:
`SMOKE ads_probe feature=true main_scene=res://scenes/ads_test/ads_test_boot.tscn ads=true adapter=none rounds=1` →
Startszene, `/root/Ads`, Rückfall auf „keine Werbung“ ohne Android-Singleton und Rundenmeldung funktionieren im
exportierten Build ohne Fehler. (Stand des Spikes; seit 0.6 ohne Startszene, siehe §3.)

## 5. Exakte Befehle

```bash
# Einmalig: Toolchain (Godot 4.7.2, Templates, SDK, Keystore) + Plattform android-36 für Gradle-Builds
WITH_GRADLE=1 bash tools/setup_toolchain.sh        # hier manuell: sdkmanager "platforms;android-36"
# Nur in der Sandbox nötig (Maven Central antwortet dort zeitweise mit HTTP 429, §10):
mkdir -p ~/.gradle/init.d && cp tools/gradle/maven_central_mirror.gradle ~/.gradle/init.d/

# Plugin-AARs bauen (nur nach Änderungen am Java-Code; die AARs sind eingecheckt)
tools/build_ads_plugin.sh

# Werbetest-APK exportieren und prüfen
tools/build_ads_test.sh
#  = GODOT_EXPORT_ARGS=--install-android-build-template tools/build_android.sh game \
#      builds/android/nachhall-adstest-debug.apk debug Android-AdsTest
#    + tools/verify_ads_build.sh builds/android/nachhall-adstest-debug.apk

# Standard-APK wie bisher + Gegenprobe
tools/build_android.sh game builds/android/nachhall-debug.apk debug
tools/verify_ads_build.sh builds/android/nachhall-adstest-debug.apk builds/android/nachhall-debug.apk

# Tests
godot --headless --path game --script res://tests/run_tests.gd
```

Gradle-Aufruf, den Godot beim Export absetzt (aus `--verbose`, gekürzt; Mitschnitt aus dem Spike mit Version 0.3.0):
```
game/android/build/gradlew validateJavaVersion clean assembleStandardDebug -p game/android/build
  -Pexport_package_name=io.github.dasbutterschnitzel.nachhall.adstest -Pexport_version_code=30
  -Pexport_version_name=0.3.0 -Pexport_version_min_sdk=24 -Pexport_version_target_sdk=36
  -Pexport_enabled_abis=armeabi-v7a|arm64-v8a
  -Pplugins_local_binaries=…/game/addons/nachhall_ads/bin/debug/NachhallAds-debug.aar
  -Pplugins_remote_binaries=com.google.android.gms:play-services-ads:25.5.0|com.google.android.ump:user-messaging-platform:4.0.0
  -Pperform_zipalign=true -Pperform_signing=true -Pcompress_native_libraries=true …
BUILD SUCCESSFUL in 8s
```

Umgebung dieses Laufs: JDK 21 (OpenJDK 21.0.12; Godots Gradle-Vorlage verlangt mindestens 17), Gradle 8.11.1 (Wrapper),
AGP 8.6.1, Kotlin-Plugin 2.1.21, Build-Tools 36.1.0, Plattform android-36, **kein NDK**.

## 6. Prüfergebnisse (Auszüge)

Vollständige Berichte: `docs/builds/ads_test_spike/` (Stand des Spikes, Version 0.3.0 mit Spike-Startszene; aktuelle
Berichte entstehen mit `tools/build_ads_test.sh` neben dem APK, `*.ads-check.txt`, und prüfen seit 0.7 auch die
verpackte `assets/data/ads.json` auf reine Test-IDs).

`aapt2 dump badging` (Werbetest-APK):
```
package: name='io.github.dasbutterschnitzel.nachhall.adstest' versionCode='30' versionName='0.3.0' … compileSdkVersion='36'
minSdkVersion:'24'
targetSdkVersion:'36'
uses-permission: name='android.permission.INTERNET'
uses-permission: name='android.permission.VIBRATE'
uses-permission: name='android.permission.ACCESS_NETWORK_STATE'
uses-permission: name='com.google.android.gms.permission.AD_ID'
uses-permission: name='android.permission.ACCESS_ADSERVICES_AD_ID'
uses-permission: name='android.permission.ACCESS_ADSERVICES_ATTRIBUTION'
uses-permission: name='android.permission.ACCESS_ADSERVICES_TOPICS'
uses-permission: name='android.permission.WAKE_LOCK'
uses-permission: name='android.permission.FOREGROUND_SERVICE'
uses-permission: name='io.github.dasbutterschnitzel.nachhall.adstest.DYNAMIC_RECEIVER_NOT_EXPORTED_PERMISSION'
application-label:'Nachhall Werbetest'
```

`aapt2 dump xmltree --file AndroidManifest.xml` (meta-data):
```
"com.google.android.gms.ads.APPLICATION_ID" = "ca-app-pub-3940256099942544~3347511713"
"org.godotengine.plugin.v2.NachhallAds" = "io.github.dasbutterschnitzel.nachhall.ads.NachhallAdsPlugin"
"com.google.android.gms.ads.flag.OPTIMIZE_AD_LOADING" = true        (aus dem SDK-Manifest)
"com.google.android.gms.ads.flag.OPTIMIZE_INITIALIZATION" = true    (aus dem SDK-Manifest)
```
Vom SDK eingebrachte Komponenten u. a.: `com.google.android.gms.ads.AdActivity`, `MobileAdsInitProvider`
(läuft beim App-Start; laut Bytecode-Prüfung im Ads-Review prüft er in 25.5.0 nur die App-ID und startet weder SDK
noch Netz – auf einem Gerät nicht mitgeschnitten), `com.google.android.gms.ads.AdService`, `OutOfContextTestingActivity`,
`NotificationHandlerActivity`, `com.google.android.play.core.hsdp.service.HsdpShimActivity`, WorkManager
(`SystemJobService`, `SystemForegroundService`, mehrere Receiver), Room.

`dexdump` über alle `classes*.dex`:
```
total: 16522
com/google/android/gms/ads/*: 658
com/google/android/ump/*: 19
  com/google/android/gms/ads/AdActivity
  com/google/android/gms/ads/MobileAds
  com/google/android/gms/ads/interstitial/InterstitialAd
  com/google/android/ump/UserMessagingPlatform
  io/github/dasbutterschnitzel/nachhall/ads/NachhallAdsPlugin
```
`assets/project.binary`: `_custom_features` = `nachhall_ads`, `application/run/main_scene.nachhall_ads` =
`res://scenes/ads_test/ads_test_boot.tscn`. `apksigner verify`: `Signer #1 certificate DN: CN=Android Debug, O=Android, C=US`.

Standard-APK (Gegenprobe): nur `uses-permission: name='android.permission.VIBRATE'`, 0 Werbe-Klassen, keine
`ca-app-pub`-Einträge, kein `_custom_features`.

Laufzeit-Abhängigkeiten der App (Gradle, `standardDebugRuntimeClasspath`): 115 Module, u. a.
`play-services-ads-api:25.5.0`, `play-services-measurement-sdk-api:20.1.2`, `androidx.work:work-runtime:2.7.0`,
`androidx.room:room-runtime:2.2.5`, `androidx.privacysandbox.ads:ads-adservices:1.0.0-beta05`,
`com.google.android.play:hsdp:2.0.1`, `kotlin-stdlib` → 2.1.21.

## 7. Größen

| APK (Debug, nicht minimiert) | Byte | MiB | Bemerkung |
|---|---:|---:|---|
| Standard `Android` (vorgefertigte Vorlage, ohne Gradle) | 60 346 710 | 57,6 | unverändert gegenüber vorher (+8 946 Byte GDScript) |
| Vergleichsbuild: Gradle **ohne** Werbe-SDK (nur gemessen, nicht eingecheckt) | 66 024 923 | 63,0 | +5,7 MB nur durch Verpackung: AGP komprimiert die identischen `.so` schwächer (55,2 → 60,8 MB) |
| **`Android-AdsTest`** (Gradle + SDK) | **70 939 270** | **67,7** | SDK selbst: **+4,9 MB** (dex 2,35 → 6,86 MB komprimiert, 6,1 → 16,8 MB entpackt; Ressourcen +0,37 MB) |
| `Android-AdsTest` mit unkomprimierten `.so` (erster Versuch) | 171 168 202 | 163,2 | daher im Preset `gradle_build/compress_native_libraries=true` |

Ein Release-Build mit R8-Minimierung wäre kleiner – nicht gemessen (kein Release-Keystore, Godots Vorlage minimiert
nicht).

## 8. Was NICHT geprüft werden konnte

Hier läuft kein Android (kein Gerät, kein Emulator, keine KVM). **Nicht** belegt ist daher:
- dass Godot das Plugin auf dem Gerät lädt (Singleton `NachhallAds` registriert) und die JNI-Aufrufe/Signale
  ankommen (nur Typen und Registrierung im Quelltext von godot-lib 4.7.2 geprüft);
- dass das UMP-Formular erscheint, die Entscheidung gespeichert wird und `setForceTesting(true)` das erwartete Verhalten
  hat (in der öffentlichen API-Referenz nicht beschrieben);
- dass eine Test-Anzeige lädt, im Vollbild/immersiv erscheint, sich schließen lässt und das Spiel danach normal
  weiterläuft (Ton, Pause-Logik, Zurück-Taste während der Anzeige);
- Verhalten offline, bei langsamem Netz, bei App-Wechsel während Formular/Anzeige; ANRs, Speicher;
- **Netzwerkverkehr vor der Einwilligung**: Gewollt ist nur die UMP-Abfrage beim Start (Googles Vorgabe). Der
  `MobileAdsInitProvider` läuft beim App-Start; das früher empfohlene Manifest-Flag `DELAY_APP_MEASUREMENT_INIT` kommt
  im dex von 25.5.0 nicht mehr vor und wurde deshalb nicht gesetzt. Was tatsächlich vor `MobileAds.initialize()`
  gesendet wird, muss auf einem Gerät mitgeschnitten werden;
- Play-Console-Prüfungen (das Release-Bundle ohne Werbung ist seit 0.8 gebaut und geprüft, `tools/build_release.sh`).

Gerätetest-Checkliste (Werbetest-APK, separat installierbar dank eigenem Paketnamen):
1. `adb install builds/android/nachhall-adstest-debug.apk`, `adb logcat -s godot NachhallAds Ads UserMessagingPlatform`.
   Erwartet: `AdMobAdapter: NachhallAds consent=unknown ads_allowed=false (25.5.0)` (o. ä.) nach dem Start, kurz danach
   ohne Warnung „consent information not updated“.
2. Eine Nacht spielen → „Nochmal“: UMP-Formular erscheint (Debug-Geografie EWR). Zustimmen bzw. ablehnen.
3. Zweite Nacht → „Nochmal“: Google-Testanzeige („Test Ad“) erscheint, schließen → neue Nacht startet, Ton läuft.
4. **App ganz beenden und neu starten**, zwei Nächte spielen: wieder eine Testanzeige, **keine** zweite Frage
   (Regression aus dem Ads-Review 0.7: vorher kam nach einem Neustart nie wieder eine Anzeige).
5. Einstellungen → Datenschutz → „Werbe-Einwilligung ändern“: Datenschutzoptionen-Formular erscheint.
6. Flugmodus: Spiel startet und läuft ohne Hänger, keine Anzeige, „Nochmal“ reagiert sofort; nach Wiederherstellen des
   Netzes wird die Einwilligung an einer späteren Pause erfragt.
7. Langsames Netz (z. B. Drosselung): erscheint das Formular nicht binnen 8 s, geht das Spiel weiter, und es darf auch
   später **nicht** über einer Nacht aufgehen.
8. Netzwerkverkehr vor der Einwilligung mitschneiden (z. B. Proxy/Profiler) und bewerten.
9. Den Hash der Testgeräte-ID aus logcat bei Bedarf in `admob_test_device_hashed_ids` (`ads.json`) eintragen.

## 9. Entscheidungen des Inhabers
1. **Echte Werbung** (AdMob-Konto, App-ID, Anzeigenblöcke) ist ausdrücklich nicht Teil des Spikes. Dafür müssten die
   vier Sperren (§2) bewusst gelockert und UMP-Debug-Einstellungen/Testmodus entfernt werden.
2. **Eigenbau-Plugin vs. Community-Plugin**: Der Eigenbau ist klein und vollständig nachvollziehbar, muss aber bei
   SDK-Updates selbst gepflegt werden (Versionen stehen an zwei Stellen: `build.gradle` des Plugins und
   `DEPENDENCIES` im Export-Plugin).
3. **Größe**: SDK ≈ +4,9 MB; ein Gradle-Build für die Store-Version (oder AAB) ist für Plugins ohnehin nötig.
4. **Berechtigungen/Formulare**: AD_ID, ADSERVICES_*, WAKE_LOCK, FOREGROUND_SERVICE (über WorkManager) müssen in
   Data Safety, Werbe-ID-Erklärung und ggf. Vordergrunddienst-Erklärung der Play Console abgebildet werden;
   `DATA_SAFETY.md` und `PRIVACY_POLICY.md` enthalten Entwürfe dafür (Googles Data disclosure für 25.5.0).
5. **Personalisierung**: Die Zuordnung „granted“ (TCF-Zwecke 1, 3, 4 + Anbieter 755) ist eine Vereinfachung –
   rechtlich prüfen; Kinder-/Families-Kennzeichnung (`tagForUnderAgeOfConsent`, Zielgruppe 13+) ist offen und
   bisher nicht gesetzt.
6. ~~**Erneute Einwilligung**~~ – erledigt in 0.7: Aktualisierung bei jedem Start, eine abgelaufene Entscheidung
   wird erneut erfragt (§2, Ablauf).
7. **Frequenz-Overrides** des Werbetest-Builds (`ads_test_overrides`) sind nur für Gerätetests gedacht.
8. **CI**: Der Werbetest-Build ist nicht in `.github/workflows/android.yml` (Laufzeit, Netz); bei Bedarf ergänzen.
   Seit 0.7 prüft die CI aber das Standard-APK auf „kein Werbe-SDK, kein `INTERNET`“ und baut das Release-Bundle.
9. **Editor-Skripte im PCK** (§4): so lassen oder per `exclude_filter` aus allen Presets nehmen.

## 10. Hinweise und Stolpersteine
- **HTTP 429 von Maven Central** (`repo.maven.apache.org`) in der Sandbox: Gradle bricht dabei ab statt das nächste
  Repository zu versuchen; längere Wiederholungen (`systemProp.org.gradle.internal.repository.*` in
  `~/.gradle/gradle.properties`) reichten nicht. Abhilfe: `tools/gradle/maven_central_mirror.gradle` leitet auf Googles
  offiziellen Maven-Central-Spiegel um (gilt auch für den Gradle-Lauf, den Godot startet). In CI vermutlich unnötig.
- `services.gradle.org` leitet den Gradle-Download auf `github.com/gradle/gradle-distributions` um; das war hier
  erreichbar. Ist es anderswo gesperrt, schlägt der Wrapper fehl (Ausweg: lokale Gradle-Installation).
- `--install-android-build-template` entpackt die Vorlage bei jedem Lauf neu nach `game/android/` (gitignored,
  inkl. Build-Ausgaben ≈ 1,2 GB).
- Warnungen ohne Folgen: AGP 8.6.1 ist offiziell nur bis compileSdk 35 getestet (Godot-Vorlage nutzt 36);
  „Unable to strip … libgodot_android.so“ (kein NDK – die `.so` sind identisch zur vorgefertigten Vorlage);
  Manifest-Merger meldet zwei `tools:node="replace"` ohne Gegenstück (aus Godots Vorlage).
- `runOnUiThread` ist in godot-lib 4.7 veraltet; das Plugin nutzt `runOnHostThread` (gleiche Wirkung: UI-Thread
  der Activity).
