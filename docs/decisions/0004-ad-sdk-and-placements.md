# ADR 0004 – Werbe-SDK, Platzierungen und Build-Varianten

Status: entschieden für die Monetarisierungs-Vorschau 0.6 · 2026-10-23 · Entscheider: Agent I (Monetization &
Compliance) mit Agent A; umgesetzt von Agent E2 (Spike) und Agent E. **Echte Anzeigen bleiben Entscheidung des Inhabers.**
Grundlagen: `docs/compliance/ADS_AND_CONSENT.md`, `docs/compliance/ADS_TEST_BUILD.md`.

## Problem
Das Spiel soll werbefinanziert sein, darf aber ohne Freigabe keine echten Anzeigen zeigen und ohne Netz nicht leiden.
Gebraucht wird: eine austauschbare Anbindung, ein geprüfter Test-Pfad mit echtem SDK, Einwilligung nach DSGVO und
eine Frequenz, die Spielern nicht schadet.

## Entscheidung
1. **Fassade + Adapter:** `AdService` (Autoload `Ads`) entscheidet allein über `AdPolicy`; Adapter `none`, `mock`
   (offline-Platzhalter) und `admob`. Spielcode ruft nur `on_round_finished`, `maybe_show_interstitial`,
   `show_consent_form`, `rewarded_available`/`show_rewarded`.
2. **Google Mobile Ads SDK 25.5.0 + UMP 4.0.0** über ein **eigenes, schlankes Godot-Android-Plugin** (Java, ~360
   Zeilen). Gründe: Drittanbieter-Downloads von GitHub sind in dieser Umgebung gesperrt, Maven ist erreichbar; der
   Umfang (Einwilligung, Interstitial) ist klein; jede Zeile ist prüfbar. Mediation: keine.
3. **Drei Build-Varianten:** `Android` Debug = Platzhalter (keine `INTERNET`-Berechtigung), `Android` Release = keine
   Werbung, `Android-AdsTest` = eigenes Paket mit echtem SDK und **nur Googles öffentlichen Test-IDs** (vierfach
   erzwungen: Konfigurationstest, Export-Plugin, GDScript-Adapter, Java-Plugin).
4. **Platzierungen:** Interstitial nur beim Verlassen der Ergebniskarte; Rewarded nur auf Wunsch für eine
   kosmetische Probenacht mit einem gesperrten Laternenpapier. Keine „Zweite Chance“ (verzerrt Bestwerte und die
   gemeinsame Tagesnacht).
5. **Frequenz:** frühestens nach 5 Nächten seit Installation und 3 in der Sitzung, höchstens jede 4. Nacht, mindestens
   300 s Abstand (≤ 12 pro Stunde im ungünstigsten Fall; die Vorgabe mit 180 s hätte verlierenden Spielern bis zu 20
   erlaubt).

## Verworfen
- Community-Plugin (nicht ladbar hier, mehr Fläche als nötig) – für später wieder offen.
- Einwilligung beim ersten Start (stört den ersten Eindruck; gefragt wird nach der zweiten Nacht oder vor der ersten
  gewünschten Rewarded-Anzeige).
- App-Open-Anzeigen, Banner im Spiel.

## Belege und Grenzen
Unit- und Integrationstests (Adapter gegen einen Fake-Singleton, Frequenz, Einwilligung, Hauptschalter, Rewarded,
keine Anzeige beim Abbruch aus der Pause); Werbetest-APK auf Build-Ebene geprüft (Manifest, Klassen, Signatur,
Standard-APK unverändert). **Nicht geprüft:** Laufzeit auf einem Gerät (Plugin lädt, UMP-Formular, Testanzeige
erscheint und schließt, Spiel läuft weiter), Verhalten offline, Netzverkehr vor der Einwilligung.
