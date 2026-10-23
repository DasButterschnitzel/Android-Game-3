# Veröffentlichung – Leitfaden für den Inhaber

Stand: 0.8.0 (Release Candidate), 2026-10-23. **Keiner dieser Schritte wurde vom Projekt ausgeführt.** Konto,
Kosten, Schlüssel, Werbung und die Veröffentlichung selbst sind Entscheidungen und Handlungen des Inhabers. Alle
Angaben zur Play Console sind vor der Nutzung in der aktuellen Google-Hilfe zu prüfen (sie ändern sich).

## 0. Was fertig vorliegt
| Was | Wo |
|---|---|
| Release-Konfiguration (App Bundle, ohne Tests/Prototypen, ohne `INTERNET`, nur `VIBRATE`) | Export-Preset `Android-Release` in `game/export_presets.cfg` |
| Bau + Prüfung des Bundles (bundletool, jarsigner, aapt2, apksigner) | `tools/build_release.sh` |
| Store-Texte DE/EN, Icon 512, Feature-Grafik 1024×500, 4 Screenshots 1080×1920 | `docs/store/` |
| Datenschutzerklärung (Entwurf), Data-Safety-Entwurf, Werbe- und Einwilligungskonzept | `docs/compliance/` |
| Gerätetest-Checkliste | `docs/playtests/DEVICE_TEST_PLAN.md` |
| Lizenzen (Schrift OFL, Godot MIT + Drittbestandteile im Spiel unter Credits → „Lizenzen“) | `ASSET_LICENSES.md` |

Die Release-Version **enthält keine Werbung** (`adapter_release: "none"` in `game/data/ads.json`, kein Werbe-SDK im
Bundle). Echte Werbung ist ein eigener Schritt (§6).

## 1. Entscheidungen vor dem ersten Upload
1. **Name und Marke:** „Nachhall“ ist ein Arbeitstitel, nicht markenrechtlich geprüft.
2. **Paketname** `io.github.dasbutterschnitzel.nachhall` – nach dem ersten Upload **nicht mehr änderbar**. Bei Bedarf
   vorher in allen drei Android-Presets ändern (das Werbetest-Preset behält sein `.adstest`).
3. **Lizenz** für Code und eigene Assets (das Repository hat noch keine `LICENSE`-Datei).
4. **Zielgruppe:** Empfehlung 13+ (siehe `docs/compliance/ADS_AND_CONSENT.md` §6, Families-Richtlinie).
5. **Datensicherung:** `user_data_backup/allow=false` – Fortschritt geht bei einem Gerätewechsel verloren. Android
   Auto Backup einzuschalten wäre spielerfreundlich (Spielstand in der Google-Sicherung des Nutzers); dann die
   Data-Safety-Angaben dazu prüfen.
6. **Verantwortlicher** (Name, Anschrift, E-Mail) für Datenschutzerklärung und Store-Eintrag; ggf. Impressum
   (Anbieterkennzeichnung, z. B. § 5 DDG – rechtlich prüfen).
7. **In der App:** öffentliche URL der Datenschutzerklärung und Kontakt-Adresse in `game/data/app.json` eintragen –
   die Datenschutz-Seite zeigt dann „Vollständige Datenschutzerklärung“ (öffnet den Browser) und „Kontakt: …“. Leer
   bleibt beides unsichtbar; der Kurztext zum Datenschutz ist ohnehin in der App.

## 2. Konto (kostenpflichtig, nur durch den Inhaber)
- Google-Play-Entwicklerkonto mit einmaliger Registrierungsgebühr und Identitätsprüfung.
- **Neue private Konten** (erstellt nach dem 13.11.2023): vor dem Zugang zur Produktion ein **geschlossener Test mit
  mindestens 12 Testern, die 14 Tage ununterbrochen** dabei sind (Google-Hilfe 14151465, abgerufen 2026-10-23).
  Das passt zum Gerätetest: die Tester arbeiten `DEVICE_TEST_PLAN.md` und `PLAYTEST_PROTOCOL.md` ab.

## 3. Upload-Schlüssel und Bundle
```bash
# Einmalig: Upload-Schlüssel erzeugen und sicher aufbewahren (nie ins Repository; *.jks ist in .gitignore)
keytool -genkeypair -v -keystore ~/keys/nachhall-upload.jks -alias upload -keyalg RSA -keysize 4096 -validity 10000

# Release-Bundle bauen und prüfen
export GODOT_ANDROID_KEYSTORE_RELEASE_PATH=~/keys/nachhall-upload.jks
export GODOT_ANDROID_KEYSTORE_RELEASE_USER=upload
export GODOT_ANDROID_KEYSTORE_RELEASE_PASSWORD='…'
tools/build_release.sh builds/release/nachhall-0.8.0.aab
cat builds/release/nachhall-0.8.0.verify.txt   # erwartet: valid, debuggable: 0, apksigner: ok, nur VIBRATE
```
- In der Play Console **Play App Signing** nutzen (Google verwaltet den App-Signaturschlüssel, das Bundle wird mit
  dem Upload-Schlüssel signiert).
- Die CI und dieses Projekt bauen das Bundle nur mit einem **Wegwerf-Schlüssel** (`--throwaway`) zur Prüfung – ein so
  signiertes Bundle nie hochladen.
- Jede neue Version braucht einen höheren `version/code` in `Android-Release` (0.8.0 = 80).

## 4. Play Console – App-Inhalte (Release ohne Werbung)
| Formular | Antwort für die werbefreie Release-Version | Quelle |
|---|---|---|
| Datenschutzerklärung | URL einer öffentlich erreichbaren Fassung von `docs/compliance/PRIVACY_POLICY.md` (Teil A; Verantwortlichen ergänzen, rechtlich prüfen) | Pflicht für alle Apps |
| Werbung | „Enthält keine Werbung“ – nur, solange das stimmt | `ads.json` `adapter_release` |
| App-Zugriff | alle Funktionen ohne Anmeldung zugänglich | kein Konto |
| Altersfreigabe (IARC-Fragebogen) | keine Gewalt gegen Menschen/Tiere, keine Angst-/Horror-Inhalte, kein Glücksspiel, keine Käufe, keine Nutzerinteraktion, kein Standort → voraussichtlich USK 0 / PEGI 3 (Ergebnis des Fragebogens abwarten) | Spielinhalt |
| Zielgruppe | 13+ empfohlen; bei jüngeren Zielgruppen gelten die Families-Richtlinien | `ADS_AND_CONSENT.md` §6 |
| Data Safety | keine Daten erhoben oder geteilt; Berechtigung nur `VIBRATE` | `docs/compliance/DATA_SAFETY.md` Teil A |
| Werbe-ID | wird nicht verwendet (keine `AD_ID`-Berechtigung im Bundle) | `builds/release/*.verify.txt` |
| Nachrichten-/Gesundheits-/Finanz-Apps | nicht zutreffend | – |

## 5. Test-Tracks und erste Geräteprüfung
1. **Interner Test**: Bundle hochladen, an wenige Tester verteilen. Der automatische **Pre-Launch-Bericht** von Google
   startet die App auf echten Geräten – das ist die **erste Prüfung auf echter Hardware** überhaupt (Abstürze,
   Darstellung, Barrierefreiheits-Hinweise).
2. **Geschlossener Test** (12 Tester × 14 Tage bei neuen privaten Konten): `DEVICE_TEST_PLAN.md` A–G und das
   Spieltest-Protokoll; Abbruchkriterien aus ADR 0002 beachten.
3. Funde beheben, neue Version mit höherem `version/code`, dann **Produktion**.
4. Danach: Android Vitals (Abstürze, ANRs), Bewertungen.

## 6. Später: echte Werbung (eigener, freigabepflichtiger Schritt)
Die Werbe-Infrastruktur ist mit Googles Test-IDs gebaut und auf Build-Ebene geprüft (`docs/compliance/ADS_TEST_BUILD.md`),
aber nie auf einem Gerät gelaufen. Für echte Anzeigen:
1. AdMob-Konto, App anlegen, Anzeigenblöcke (Interstitial), **DSGVO-Mitteilung in AdMob (UMP) veröffentlichen**.
2. Die vier Sperren gegen echte IDs bewusst lockern (`ADS_TEST_BUILD.md` §2), Testmodus/Debug-Geografie entfernen,
   ein eigenes Werbe-Preset aus `Android-AdsTest` ableiten (Paketname der App).
3. Gerätetest der Werbetest-APK nach `ADS_TEST_BUILD.md` §8 **vorher** abschließen (Neustart-Fall, Offline, langsames
   Netz, Netzverkehr vor der Einwilligung).
4. Data Safety Teil B, Datenschutzerklärung Teil B, Werbe-Erklärung „Enthält Werbung“, Werbe-ID-Erklärung,
   ggf. Vordergrunddienst-Erklärung (WorkManager), Inhaltseinstufung der Anzeigen (heute G).
5. Frequenz bleibt bei den getesteten Werten (`ads.json`); Rewarded ist bisher nur als Platzhalter umgesetzt.

## 7. Bekannte Grenzen dieses Release Candidates
- **Nichts lief bisher auf einem echten Android-Gerät oder Emulator.** Alle Aussagen beruhen auf automatischen Tests,
  Bot-Simulationen, dem exportierten Linux-Build und der Prüfung der Pakete.
- Kein Bildschirmleser (Godot 4.7 bietet ihn auf Android nicht).
- Nur Deutsch im Spiel (Store-Texte DE/EN liegen vor).
