# Werbung, Einwilligung und Richtlinien – Konzept (Agent I)

> Arbeitsdokument, keine Rechtsberatung. Echte Anzeigen, ein Werbekonto (AdMob-App-ID) und die Veröffentlichung
> sind **Entscheidungen des Inhabers** und werden von diesem Projekt nicht eigenständig aktiviert.

## 1. Grundsätze
1. Werbung finanziert ein kostenloses Spiel, darf aber das Spiel nie stören: **nie während eines Laufs**, nie über
   Steuerelementen, nie als Überraschung nach einem Fingertipp.
2. **Nicht direkt nach dem ersten Start**, nicht nach jeder verlorenen Nacht, keine App-Open-Werbung.
3. **Rewarded nur optional und fair**: nur echte Komfort-Angebote (siehe 4), nie zum Aufheben künstlicher Sperren
   (es gibt keine), nie Pflicht zum Weiterkommen.
4. Spiel funktioniert **ohne Netz** vollständig; fehlgeschlagenes Laden blockiert nichts.
5. Werbung vollständig abschaltbar per Konfiguration (Build-Schalter) – z. B. für Tests oder eine werbefreie Version.

## 2. Frequenz (`game/scripts/ads/ad_policy.gd`, getestet)
- Erstes Interstitial frühestens nach **3 abgeschlossenen Nächten**, danach höchstens **jede 4. Nacht** und nie öfter
  als **alle 180 s**. Nur an natürlichen Pausen: Ergebnis-Bildschirm → „Nochmal“ oder „Menü“.
- Ungünstigster Fall (sehr kurze Nächte von 90 s): ≈ 10 Interstitials pro Stunde. Für ein Toilettenpausen-Spiel mit
  5-Minuten-Sitzungen bedeutet das typischerweise **0–1 Interstitial pro Sitzung**.
- Prüfung „ist das zu viel?“: Bei 5-Minuten-Sitzungen mit 2–3 Nächten fällt in der ersten Sitzung keine Anzeige an.
  Vorschlag für 0.6: zusätzlich **max. 1 Interstitial pro 5 Minuten Spielzeit** und **kein Interstitial in den ersten
  10 Minuten** nach der Installation (gemessen in Spielzeit) – noch zu entscheiden nach Gerätetest.

## 3. Einwilligung (DSGVO/TTDSG, UK GDPR, Schweiz)
- Vor dem ersten Laden einer Anzeige: Google UMP abfragen (`requestConsentInfoUpdate`), bei Bedarf Formular zeigen.
- Ohne Einwilligung: nur nicht personalisierte Anzeigen (soweit vom Netzwerk unterstützt) oder keine.
- Einwilligung jederzeit änderbar: Einstellungen → Datenschutz & Werbung → „Werbe-Einwilligung ändern“
  (Privacy-Options-Formular von UMP).
- Kein Laden von Anzeigen, bevor der Einwilligungsstatus bekannt ist (`AdPolicy.consent_ready`).

## 4. Rewarded – faire Angebote (Vorschlag, Entscheidung in 0.6)
| Angebot | Warum fair |
|---|---|
| „Zweite Chance“: einmal pro Nacht nach Verlust der letzten Flamme mit einer Flamme weiterspielen | rein optional; Punkte der Nacht bleiben ohnehin; kein Rangvorteil (Tagesnacht-Bestwert ohne zweite Chance gewertet) |
| Kosmetik schneller freischalten | nur Aussehen, nie Spielstärke |
Nicht erlaubt: Multiplikator-Boni, mehr Lichter, Werbung für Grundfunktionen.

## 5. Google-Play-Richtlinien (Prüfliste)
- Werbe-Richtlinie: keine Anzeigen, die Bedienelemente imitieren; Interstitials nicht unerwartet; Schließen-Button
  sichtbar; keine Anzeigen beim App-Start oder während des Spiels.
- Families-Richtlinie greift, wenn Kinder Zielgruppe sind → dann nur von Google zertifizierte Werbe-SDKs,
  keine personalisierte Werbung, keine Werbe-ID. **Empfehlung:** Zielgruppe 13+ (Inhaber entscheidet).
- Data Safety und Datenschutzerklärung müssen das Werbe-SDK abbilden (`DATA_SAFETY.md`, `PRIVACY_POLICY.md`).
- Werbe-ID: Manifest-Berechtigung `AD_ID`, Respektieren von „Werbe-ID löschen“.
- Target API: aktuell 36 (Play verlangt jeweils aktuelle Ziel-API).

## 6. Technischer Plan für 0.6 (ohne echtes Konto)
- Autoload `Ads` (`AdService`) mit Adapter-Schnittstelle: `MockAdapter` (zeigt einen klar markierten Platzhalter im
  Spiel, offline, für Tests und Captures) und vorbereiteter `AdMobAdapter` (Godot-Android-Plugin, **nur Test-Anzeigen-IDs**
  von Google). Ohne Plugin im Build fällt der Dienst automatisch auf „keine Werbung“ zurück.
- Alle Entscheidungen über `AdPolicy`; Laden im Hintergrund, Timeout, keine Blockade.
- Ehrlich: Ob die AdMob-Integration auf dem Gerät funktioniert, kann ohne Gerät/Emulator nicht geprüft werden.
