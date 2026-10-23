# Werbung, Einwilligung und Richtlinien (Agent I)

> Arbeitsdokument, keine Rechtsberatung. Echte Anzeigen, ein Werbekonto (AdMob-App-ID) und die Veröffentlichung
> sind **Entscheidungen des Inhabers** und werden von diesem Projekt nicht eigenständig aktiviert. Stand 0.7.0.

## 1. Grundsätze (umgesetzt)
1. Werbung finanziert ein kostenloses Spiel, darf es aber nie stören: **nie während eines Laufs**, nie über
   Steuerelementen, nie als Überraschung nach einem Fingertipp im Spiel.
2. **Nicht direkt nach dem ersten Start**, nicht nach jeder verlorenen Nacht, keine App-Open-Werbung, keine Werbung
   beim Fortsetzen der App, keine Werbung beim Verlassen einer Nacht über das Pausemenü.
3. **Rewarded nur optional und fair**: vom Spieler selbst angestoßen, Belohnung rein kosmetisch.
4. Das Spiel funktioniert **ohne Netz** vollständig; ein fehlgeschlagenes Laden blockiert nichts (jeder Aufruf endet
   über ein Ergebnis-Signal oder ein Zeitlimit).
5. Werbung ist **vollständig abschaltbar**: Hauptschalter `ads_enabled` in `game/data/ads.json` (aus = es wird gar
   kein Werbe-Backend angelegt: keine Anzeige, keine Einwilligungsfrage, kein Netzwerkzugriff), getrennt
   `interstitials_enabled` / `rewarded_enabled`; in Debug-Builds zusätzlich der Tester-Schalter „Werbe-Platzhalter
   (Test)“ (im Werbetest-Build „Testanzeigen (Google)“) in den Einstellungen. Solange er aus ist, startet das
   Werbe-SDK-Plugin nicht einmal.

## 2. Platzierungen
| Platzierung | Wo | Regeln |
|---|---|---|
| Interstitial | Ergebniskarte → „Nochmal“ oder „Menü“ (`EchoGame._natural_break`) | nur nach einer **beendeten** Nacht; Frequenz siehe 3; ohne geladene Anzeige sofort weiter |
| Rewarded | Seite „Sternbilder“ → gesperrtes Laternenpapier „1 Nacht testen (Werbung)“ (zweizeilig) | nur auf Wunsch; Belohnung nur bei vollständigem Ansehen; nur Aussehen, eine Nacht lang. Bisher **nur als Platzhalter** (Debug-Builds); der AdMob-Adapter bietet noch keine Rewarded-Anzeigen an |

Verworfen: „Zweite Chance“ (eine Flamme zurück) – verändert Punkte und damit Bestwerte und die für alle gleiche
Tagesnacht; Multiplikator-Boni, mehr Lichter, Werbung für Grundfunktionen.

## 3. Frequenz (`game/scripts/ads/ad_policy.gd`, getestet)
- Erste Interstitial frühestens nach der **5. Nacht seit Installation** und in jeder Sitzung frühestens nach der
  **4. Nacht** (der Zähler „jede 4. Nacht“ beginnt mit der Sitzung bei 0, deshalb wird `min_rounds_before_first = 3`
  nie bindend), danach höchstens **jede 4. Nacht** und nie öfter als **alle 300 s** – auch über einen Neustart der
  App hinweg (Uhrzeit der letzten Anzeige im Spielstand, `ads.last_interstitial_unix`; eine zurückgestellte Uhr hebt
  nur diese Sperre auf, die Sperre innerhalb der Sitzung gilt weiter).
- Werbetest-Build (`ads_test_overrides`, nur damit ein Gerätetest schnell zum Ziel kommt): Einwilligung nach der
  1. Nacht, erste Anzeige ab der 2. Nacht, danach jede 2. Nacht, mindestens 60 s Abstand.
- Prüfung der Vorgabe („nach 3–5 Runden, nie öfter als alle 3 Minuten – ist selbst das zu viel?“): **ja, für
  verlierende Spieler.** Kurze Nächte (20–45 s) würden mit 180 s Abstand bis zu 20 Anzeigen pro Stunde erlauben –
  genau die frustrierten Spieler sähen am meisten Werbung. Deshalb 300 s.
- Ungünstigster Fall mit den ausgelieferten Werten (`AdPolicy.worst_case_ads_per_hour`, Test sichert ≤ 12/h):

| Nachtlänge | Anzeigen pro Stunde (max.) | begrenzt durch |
|---|---|---|
| 20 s | 12 | Zeitabstand |
| 45 s | 12 | Zeitabstand |
| 90 s | 10 | jede 4. Nacht |
| 180 s | 5 | jede 4. Nacht |

- Typische Sitzung (5 Minuten, 3–4 Nächte): **keine** Anzeige in den ersten Sitzungen, danach höchstens eine.

## 4. Einwilligung (DSGVO/TDDDG, UK GDPR, Schweiz)
- Gefragt wird **nach der zweiten Nacht** an einer natürlichen Pause (nicht beim ersten Start) oder vor der ersten
  vom Spieler gewünschten Rewarded-Anzeige. Bis dahin wird keine Anzeige angefragt.
- Antwort wird lokal gespeichert (`granted`, `denied`, `not_required`); `unknown` (z. B. offline) → später erneut.
- **Google UMP (Werbetest-Build):** Bei **jedem App-Start** werden die Einwilligungsinformationen aktualisiert, wie
  Google es vorschreibt (`requestConsentInfoUpdate`; vorher liefert `canRequestAds()` immer „nein“), ohne Formular.
  Die frische Auskunft gilt: Eine abgelaufene oder zurückgesetzte Entscheidung wird an der nächsten Pause erneut
  erfragt, eine bestehende wird übernommen (keine zweite Frage). Schlägt die Aktualisierung fehl (offline), gilt
  laut Google der Stand der letzten Sitzung, und die Pause wartet nicht auf das Netz: die Aktualisierung läuft im
  Hintergrund erneut.
- Anzeigen werden nur **mit einer Entscheidung** angefragt (UMP `OBTAINED` oder `NOT_REQUIRED` und
  `canRequestAds()`), nicht auf `canRequestAds()` allein – UMP meldet das auch, wenn es die Einrichtung des Publishers
  als fehlerhaft einstuft, ohne dass jemand gefragt wurde.
- Erscheint das Formular nicht binnen 8 s, bricht das Spiel den Ablauf ab (`cancel_consent`); ein verspätet
  geladenes Formular wird **nicht mehr gezeigt** (es könnte sonst über der nächsten Nacht aufgehen).
- Ohne Einwilligung: nur nicht personalisierte Anzeigen (`PublisherPrivacyPersonalizationState.DISABLED`). Ohne
  Einwilligung in die Speicherung auf dem Gerät (TCF-Zweck 1) liefert Google nach eigenen Regeln höchstens
  eingeschränkte Anzeigen („Limited Ads“). `not_required` (außerhalb von EWR/UK/CH) wird ebenfalls **nicht
  personalisiert** ausgeliefert – eine bewusst datensparsame Entscheidung, die Umsatz kostet (Inhaber kann sie ändern).
- Änderbar jederzeit: Datenschutz-Seite → „Werbe-Einwilligung ändern“ (bei Google UMP das Privacy-Options-Formular).
  Der Knopf erscheint, wo UMP ihn verlangt (`getPrivacyOptionsRequirementStatus() == REQUIRED`, z. B. im EWR; der
  Werbetest-Build erzwingt die EWR-Geografie), im Platzhalter-Ablauf immer.
- Debug-Builds zeigen einen deutlich markierten **Test-Ablauf**; der Werbetest-Build nutzt Googles UMP.

## 5. Build-Varianten
| Build | Adapter | Netzwerk | Was der Spieler sieht |
|---|---|---|---|
| `Android` (Debug, die Test-APKs) | `mock` | keine `INTERNET`-Berechtigung | markierte Platzhalter „TESTANZEIGE“, Einwilligungs-Test-Ablauf |
| `Android` (Release) | `none` | keine | keine Werbung, keine Einwilligungsfrage |
| `Android-AdsTest` (eigenes Paket `….adstest`) | `admob` (eigenes Plugin, Google Mobile Ads 25.5.0 + UMP 4.0.0) | ja | **Testanzeigen** von Google, UMP-Formular; nur Googles öffentliche Test-IDs, an vier Stellen erzwungen (`ADS_TEST_BUILD.md`) |

## 6. Google-Play-Richtlinien (Prüfliste)
- Werbe-Richtlinie: keine Anzeigen, die Bedienelemente imitieren; Interstitials nicht unerwartet; Schließen sichtbar;
  keine Anzeigen beim App-Start oder während des Spiels. ✔ im Code, Gerätetest offen.
- Anzeigeninhalte höchstens Einstufung **G** (`max_ad_content_rating` in `ads.json`, `setMaxAdContentRating`):
  Play verlangt, dass Anzeigen zur Altersfreigabe der App passen; erwartet ist USK 0 / PEGI 3.
- Families-Richtlinie greift, wenn Kinder Zielgruppe sind → nur zertifizierte SDKs, keine personalisierte Werbung,
  keine Werbe-ID. **Empfehlung:** Zielgruppe 13+ (Inhaber entscheidet). **Risiko:** Der Papierlaternen-Stil und die
  Sammelstücke könnten als „spricht Kinder an“ eingestuft werden, unabhängig von der angegebenen Zielgruppe. Dann
  braucht es Code-Änderungen, die der heutige Build nicht hat: `tagForChildDirectedTreatment` /
  `tagForUnderAgeOfConsent` (SDK und UMP), keine `AD_ID`-Berechtigung, nur Families-zertifizierte Werbung.
- Data Safety und Datenschutzerklärung bilden das Werbe-SDK ab (`DATA_SAFETY.md`, `PRIVACY_POLICY.md`).
- Werbe-ID: Manifest-Berechtigung `AD_ID` (im Werbetest-Build vom SDK eingebracht); Nutzer können sie in Android
  löschen.
- Der Werbetest-Build bringt über das SDK auch `FOREGROUND_SERVICE`/`WAKE_LOCK` und `ACCESS_ADSERVICES_*` mit –
  in der Play Console ggf. zu deklarieren; vor einer Veröffentlichung prüfen. `FOREGROUND_SERVICE`/`WAKE_LOCK`
  stammen von WorkManager 2.7 (`SystemForegroundService` ohne `foregroundServiceType`); laut dexdump ruft kein Code des
  Werbe-SDKs `setForegroundAsync` auf. In einer echten Werbe-Version ließe sich die Berechtigung per Manifest-Merger
  (`tools:node="remove"`) entfernen – vorher testen.
- Target API 36.

## 7. Offen / Entscheidungen des Inhabers
1. Werbekonto und echte Anzeigen-IDs (dann die Test-ID-Sperren bewusst lockern).
2. Zielgruppe und Altersfreigabe (Empfehlung 13+).
3. Eigenes Plugin behalten oder Community-Plugin (ADR 0004).
4. +4,9 MB APK-Größe durch das SDK.
5. Rechtliche Prüfung der Datenschutzerklärung und der Zuordnung „Einwilligung → personalisiert“.
6. Ob der Werbetest-Build in die CI kommt (heute prüft die CI: Standard-APK ohne Werbe-SDK und ohne `INTERNET`,
   Release-Bundle; der Werbetest-Build wird lokal mit `tools/build_ads_test.sh` gebaut und geprüft).
7. Personalisierung bei `not_required` (heute: nicht personalisiert).
