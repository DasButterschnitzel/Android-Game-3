# Play Console – Data-Safety-Angaben (Entwurf)

> Entwurf zur Vorbereitung; die verbindlichen Angaben macht der Inhaber in der Play Console. Für SDKs gelten die
> Angaben der Hersteller (für AdMob: Googles „Data disclosure“-Seite des Mobile Ads SDK) – vor der Abgabe prüfen.

## Version ohne Werbung (bis 0.5, aktueller Stand)
| Frage | Antwort | Begründung |
|---|---|---|
| Erhebt oder teilt die App Nutzerdaten? | **Nein** | keine Netzwerkberechtigung, nur lokale Speicherung |
| Werden Daten verschlüsselt übertragen? | entfällt | keine Übertragung |
| Können Nutzer Löschung verlangen? | entfällt / App-Deinstallation löscht alles | nur lokale Daten |
| Berechtigungen | `VIBRATE` | Vibrations-Rückmeldung |

## Version mit Werbung (ab 0.6-Vorschau, nur mit Test-Anzeigen; produktiv erst nach Freigabe)
Voraussichtliche Angaben bei Nutzung des Google Mobile Ads SDK (laut Hersteller; vor Abgabe abgleichen):

| Datentyp | erhoben | geteilt | Zweck | optional? |
|---|---|---|---|---|
| Geräte- oder andere IDs (Werbe-ID, App-Set-ID) | ja | ja | Werbung/Marketing, Analysen, Betrugsprävention | nein (SDK-Funktion), Personalisierung nur mit Einwilligung |
| Ungefährer Standort (aus IP) | ja | ja | Werbung, Betrugsprävention | nein |
| App-Aktivität (Interaktionen mit Anzeigen) | ja | ja | Werbung, Analysen | nein |
| App-Infos und Leistung (Absturzprotokolle, Diagnose) | ja | ja | Analysen, Betrugsprävention | nein |

Weitere Pflichten bei Werbung:
- Manifest: `com.google.android.gms.permission.AD_ID` (Zielplattform ≥ API 33 und Nutzung der Werbe-ID), `INTERNET`,
  `ACCESS_NETWORK_STATE`; AdMob-App-ID als `meta-data` (nur mit echtem Konto des Inhabers).
- Fragebogen „Enthält Werbung“: **Ja** (ab Werbe-Version).
- Zielgruppe/Altersfreigabe (IARC) konsistent mit Werbeeinstellungen (keine personalisierte Werbung für Kinder).
