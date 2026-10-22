# Asset-Lizenzen

Verantwortlich: Agent I (Compliance) · Jede Datei, die in die APK gelangt und nicht aus eigenem Code stammt,
muss hier stehen. Regel: nur Lizenzen, die kommerzielle Nutzung und Weitergabe in einer App erlauben.

## Übersicht

| Datei(en) | Herkunft | Autor | Lizenz | Nachweis | Änderungen | Namensnennung |
|---|---|---|---|---|---|---|
| `game/assets/fonts/Fredoka-Medium.ttf`, `Fredoka-Bold.ttf` | Google Fonts (statische Instanzen der variablen Schrift, ausgeliefert über fonts.gstatic.com, Version v17) | Milena Brandão, Hafontia („The Fredoka Project Authors“) | SIL Open Font License 1.1 | `game/assets/fonts/OFL-Fredoka.txt` (von github.com/google/fonts/ofl/fredoka) | keine | Lizenztext liegt bei; Credits-Bildschirm nennt die Schrift |
| `game/assets/audio/**` | **eigene Synthese** mit `tools/audio/*.py` (numpy/scipy, keine Samples) | dieses Projekt | eigenes Werk (frei verwendbar) | Generator-Skripte im Repo, reproduzierbar | – | keine nötig |
| Grafik (Formen, Partikel, Shader) | **eigener Code** (prozedural in GDScript/Shadern) | dieses Projekt | eigenes Werk | Quellcode | – | keine nötig |
| Godot Engine (Laufzeit in der APK) | godotengine.org, 4.7.2-stable | Godot Engine contributors | MIT (+ Drittlizenzen der Engine) | https://godotengine.org/license | keine | Engine-Lizenzhinweis im Credits-Bildschirm (MIT verlangt Beilage des Hinweises) |

## Prüfnotizen

- **SIL OFL 1.1:** Bündeln/Einbetten in Software erlaubt, auch kommerziell; die Schrift darf nicht *allein* verkauft
  werden; Lizenztext muss mitgeliefert werden. Keine „Reserved Font Name“-Klausel im Copyright-Hinweis; wir verändern
  die Schrift ohnehin nicht. Glyphenabdeckung geprüft: ÄÖÜäöüß × vorhanden; → und ✓ fehlen (werden nicht als Text verwendet).
- **Godot (MIT):** Der Copyright- und Lizenzhinweis muss in Kopien enthalten sein → Credits-Bildschirm.
  Godot bündelt Drittbibliotheken (z. B. FreeType, libpng, zlib) mit eigenen permissiven Lizenzen; der vollständige
  Text ist über `Engine.get_license_text()` / `Engine.get_copyright_info()` abrufbar und wird im Credits-Bildschirm verlinkt.
- **Keine** Assets aus ungeprüften Quellen (Google-Bildersuche o. Ä.), keine geschützten Marken/Figuren.
- Werbe-SDKs (falls integriert) werden separat unter „SDKs“ dokumentiert, inkl. Datenerhebung (siehe `docs/compliance/`).
