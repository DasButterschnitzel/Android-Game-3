# Play Console – Data-Safety-Angaben (Entwurf)

> Entwurf zur Vorbereitung; die verbindlichen Angaben macht der Inhaber in der Play Console. Stand 0.7.0.

## A. `Android`-Build (alle bisherigen Test-APKs; Release ohne Werbung)
| Frage | Antwort | Begründung |
|---|---|---|
| Erhebt oder teilt die App Nutzerdaten? | **Nein** | keine Netzwerkberechtigung, nur lokale Speicherung; die Werbe-Platzhalter der Debug-Builds laden und senden nichts |
| Werden Daten verschlüsselt übertragen? | entfällt | keine Übertragung |
| Können Nutzer Löschung verlangen? | entfällt / Deinstallation löscht alles | nur lokale Daten |
| Berechtigungen | `VIBRATE` | Vibrations-Rückmeldung (abschaltbar) |

## B. Mit Google Mobile Ads SDK (Werbetest-Build `Android-AdsTest`; später eine Werbe-Version)
Quelle: Googles „Data disclosure“ für das Google Mobile Ads SDK, gültig für **Version 25.5.0** (die im Werbetest-Build
verwendete), abgerufen am 2026-10-23:
<https://developers.google.com/admob/android/privacy/play-data-disclosure>. Laut Seite werden alle Daten
**automatisch erhoben und geteilt**, Zweck **Werbung, Analysen, Betrugsprävention**, **verschlüsselt übertragen (TLS)**.

| Laut Google | Kategorie im Play-Formular (unsere Zuordnung, vom Inhaber zu prüfen) | erhoben | geteilt |
|---|---|---|---|
| IP-Adresse (zur Schätzung des ungefähren Standorts) | Standort → ungefährer Standort | ja | ja |
| Produkt-Interaktionen (App-Start, Taps, Video-Aufrufe) | App-Aktivität → App-Interaktionen | ja | ja |
| Diagnose (Leistung von App und SDK) | App-Informationen und -Leistung → Diagnose | ja | ja |
| Geräte- und Konto-Kennungen (Werbe-ID, App-Set-ID und, falls zutreffend, weitere Kennungen angemeldeter Konten auf dem Gerät) | Geräte- oder andere IDs | ja | ja |

Laut derselben Seite ist die Erhebung der Werbe-ID per Manifest abschaltbar; Funktionen wie „Limited Ads“ können die
Übertragung von Werbe-ID und weiteren Daten unterbinden. Optionale SDK-Funktionen können weitere Angaben nötig machen.

Nicht von dieser Seite abgedeckt: die **Einwilligungsplattform UMP 4.0.0**. Sie kontaktiert Google bei jedem App-Start
(IP-Adresse, Geräteinformationen), auch bevor der Spieler gefragt wurde; der Inhaber prüft, ob das zusätzliche
Angaben erfordert.

Löschung: Die App selbst speichert nichts auf Servern; „Können Nutzer die Löschung ihrer Daten beantragen?“ betrifft
die vom SDK an Google übermittelten Daten – Antwort und Verweis (Googles Prozesse, Zurücksetzen/Löschen der Werbe-ID
in den Android-Einstellungen) legt der Inhaber fest.

Weitere Punkte bei Werbung:
- Fragebogen „Enthält Werbung“: **Ja** (nur für eine Version mit Werbung).
- Berechtigungen im Werbetest-Build (vom SDK eingebracht): `INTERNET`, `ACCESS_NETWORK_STATE`, `AD_ID`,
  `ACCESS_ADSERVICES_*`, `WAKE_LOCK`, `FOREGROUND_SERVICE` – vor einer Veröffentlichung einzeln prüfen und ggf. deklarieren.
- Zielgruppe/Altersfreigabe (IARC) konsistent mit den Werbeeinstellungen (keine personalisierte Werbung für Kinder).
