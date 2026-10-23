# Werbung, Einwilligung und Richtlinien (Agent I)

> Arbeitsdokument, keine Rechtsberatung. Echte Anzeigen, ein Werbekonto (AdMob-App-ID) und die Veröffentlichung
> sind **Entscheidungen des Inhabers** und werden von diesem Projekt nicht eigenständig aktiviert. Stand 0.6.0.

## 1. Grundsätze (umgesetzt)
1. Werbung finanziert ein kostenloses Spiel, darf es aber nie stören: **nie während eines Laufs**, nie über
   Steuerelementen, nie als Überraschung nach einem Fingertipp im Spiel.
2. **Nicht direkt nach dem ersten Start**, nicht nach jeder verlorenen Nacht, keine App-Open-Werbung, keine Werbung
   beim Fortsetzen der App, keine Werbung beim Verlassen einer Nacht über das Pausemenü.
3. **Rewarded nur optional und fair**: vom Spieler selbst angestoßen, Belohnung rein kosmetisch.
4. Das Spiel funktioniert **ohne Netz** vollständig; ein fehlgeschlagenes Laden blockiert nichts (jeder Aufruf endet
   über ein Ergebnis-Signal oder ein Zeitlimit).
5. Werbung ist **vollständig abschaltbar**: Hauptschalter `ads_enabled` in `game/data/ads.json` (aus = keine Anzeige,
   keine Einwilligungsfrage), getrennt `interstitials_enabled` / `rewarded_enabled`; in Debug-Builds zusätzlich der
   Tester-Schalter „Werbe-Platzhalter (Test)“ in den Einstellungen.

## 2. Platzierungen
| Platzierung | Wo | Regeln |
|---|---|---|
| Interstitial | Ergebniskarte → „Nochmal“ oder „Menü“ (`EchoGame._natural_break`) | nur nach einer **beendeten** Nacht; Frequenz siehe 3; ohne geladene Anzeige sofort weiter |
| Rewarded | Seite „Sternbilder“ → gesperrtes Laternenpapier „1 Nacht ausprobieren (Werbung)“ | nur auf Wunsch; Belohnung nur bei vollständigem Ansehen; nur Aussehen, eine Nacht lang |

Verworfen: „Zweite Chance“ (eine Flamme zurück) – verändert Punkte und damit Bestwerte und die für alle gleiche
Tagesnacht; Multiplikator-Boni, mehr Lichter, Werbung für Grundfunktionen.

## 3. Frequenz (`game/scripts/ads/ad_policy.gd`, getestet)
- Erste Interstitial frühestens nach **5 Nächten seit Installation** und **3 Nächten in der Sitzung**, danach
  höchstens **jede 4. Nacht** und nie öfter als **alle 300 s**.
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

## 4. Einwilligung (DSGVO/TTDSG, UK GDPR, Schweiz)
- Gefragt wird **nach der zweiten Nacht** an einer natürlichen Pause (nicht beim ersten Start) oder vor der ersten
  vom Spieler gewünschten Rewarded-Anzeige. Bis dahin wird keine Anzeige angefragt.
- Antwort wird lokal gespeichert (`granted`, `denied`, `not_required`); `unknown` (z. B. offline) → später erneut.
- Ohne Einwilligung: nur nicht personalisierte Anzeigen.
- Änderbar jederzeit: Datenschutz-Seite → „Werbe-Einwilligung ändern“ (bei Google UMP das Privacy-Options-Formular).
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
- Families-Richtlinie greift, wenn Kinder Zielgruppe sind → nur zertifizierte SDKs, keine personalisierte Werbung,
  keine Werbe-ID. **Empfehlung:** Zielgruppe 13+ (Inhaber entscheidet).
- Data Safety und Datenschutzerklärung bilden das Werbe-SDK ab (`DATA_SAFETY.md`, `PRIVACY_POLICY.md`).
- Werbe-ID: Manifest-Berechtigung `AD_ID` (im Werbetest-Build vom SDK eingebracht); Nutzer können sie in Android
  löschen.
- Der Werbetest-Build bringt über das SDK auch `FOREGROUND_SERVICE`/`WAKE_LOCK` und `ACCESS_ADSERVICES_*` mit –
  in der Play Console ggf. zu deklarieren; vor einer Veröffentlichung prüfen.
- Target API 36.

## 7. Offen / Entscheidungen des Inhabers
1. Werbekonto und echte Anzeigen-IDs (dann die Test-ID-Sperren bewusst lockern).
2. Zielgruppe und Altersfreigabe (Empfehlung 13+).
3. Eigenes Plugin behalten oder Community-Plugin (ADR 0004).
4. +4,9 MB APK-Größe durch das SDK.
5. Rechtliche Prüfung der Datenschutzerklärung und der Zuordnung „Einwilligung → personalisiert“.
6. Einwilligungsabfrage bei jedem Start (Googles Empfehlung) statt nur bei Bedarf.
7. Ob der Werbetest-Build in die CI kommt.
