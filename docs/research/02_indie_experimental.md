# B2 – Indie- & Experimental-Games: Mechanik-Recherche für ein Kurzsession-Android-Spiel

- **Stand:** 22.10.2026
- **Rolle:** Agent B2 – Indie & Experimental Games Researcher
- **Ziel:** Ungewöhnliche, gut übertragbare **Kernmechaniken** aus PC/Steam, itch.io, Game Jams und älteren Mobile-Indies finden – als Input für ein **originelles, kostenloses Android-Casual-Spiel** mit Sessions von **30 s bis 3 min** (kein Reskin von Match-3, Merge, 2048, Flappy, Endless Runner, Idle Clicker, Standard-Tower-Defense).

**Lesehilfe:** Jeder Steckbrief trennt **„Belegte Fakten"** (mit Quellen-Link) von **„Einschätzung"** (Urteil von B2, nicht belegt). **„Schätzung"** markiert unbelegte Zahlen. **„nicht verifiziert"** markiert Aussagen, die nur aus Suchmaschinen-Snippets stammen.

## Inhalt

0. [Methodik & Grenzen](#0-methodik--grenzen)
1. [Überblick: 12 Spiele](#1-überblick-12-spiele)
2. [Steckbriefe](#2-steckbriefe)
   - (a) Steam-/Indie-Hits 2022–2026: Balatro · BALL x PIT · Blue Prince · Dorfromantik · Bore Blasters
   - (b) Game-Jam-/itch.io-Standouts: Stretchmancer · Windowkill · „Panda" (GMTK 2024 #1) · Draftula
   - (c) Ältere Ein-Mechanik-Klassiker: Holedown · Desert Golfing · Hoplite
3. [Mechanik-Bausteine](#3-mechanik-bausteine)
4. [Mechaniken ohne überzeugendes Mobile-Spiel (Hypothesen)](#4-mechaniken-ohne-überzeugendes-mobile-spiel-hypothesen)
5. [Gegenproben: bereits gut abgedeckte Mechaniken](#5-gegenproben-bereits-gut-abgedeckte-mechaniken)
6. [Kurzfazit für das Konzept-Team (Einschätzung)](#6-kurzfazit-für-das-konzept-team-einschätzung)

---

## 0. Methodik & Grenzen

- **Quellen:** Steam-Storeseiten, Wikipedia, itch.io-Spielseiten und offizielle itch.io-Jam-Ergebnisseiten, App-Store-Seiten, Fachpresse (Reviews/News), Entwickler-Seiten. Ludum-Dare-Platzierungen über den inoffiziellen Datenexplorer [ludum-dare.foon.uk](https://ludum-dare.foon.uk/) (ldjam.com ist stark JavaScript-basiert), gegengeprüft mit den Angaben der Entwickler.
- **Steam-Bewertungen** sind Momentaufnahmen vom 22.10.2026 und beziehen sich laut Storeseite meist nur auf **englischsprachige** Reviews.
- **Nicht abrufbar (übersprungen, nicht wiederholt):** Google-Play-Seiten (nicht auswertbar), PC Gamer (Inhalt abgeschnitten), Thinky Games, Mobalytics, Giant Bomb, Android Authority, AppUnwrapper (HTTP 403), TrendingNow (DNS-Fehler). Deshalb sind z. B. Android-Preise teils nur über Presseartikel belegt.
- **Jam-Rankings sind statistisch dünn:** GMTK 2024 hatte im Schnitt 21,1 Ratings pro Spiel (Median 14); der Gesamtsieger wurde aus 30 Ratings ermittelt, Draftula (GMTK 2025) aus 16 ([GMTK-2024-Ergebnisse](https://itch.io/jam/gmtk-2024/results), [GMTK-2025-Enjoyment](https://itch.io/jam/gmtk-2025/results/enjoyment)). Platzierungen sind daher Hinweise, keine harten Qualitätsbelege.
- **Auswahl-Hinweis:** *Cats Organized Neatly* (Packing-Puzzle) wurde geprüft, ist aber laut [Steam](https://store.steampowered.com/app/1369340/) von **Oktober 2020** und fällt damit aus dem Zeitfenster 2022–2026; es taucht nur als Referenz im Baustein „Packing" auf. Der GMTK-2023-Sieger *I overscoped.* ist laut [itch.io](https://nitramiuz.itch.io/i-overscoped) ein voll vertontes Meta-Abenteuer („help him finish the game") – mechanisch kaum übertragbar, daher nicht als Steckbrief aufgenommen.

---

## 1. Überblick: 12 Spiele

| # | Spiel | Kat. | Jahr | Kernmechanik in einer Zeile | Auf Mobile? |
|---|---|---|---|---|---|
| 1 | Balatro | a | 2024 | Poker-Hände spielen, Joker brechen Regeln, Wertung = Chips × Mult | Ja (seit 09/2024, Premium) |
| 2 | BALL x PIT | a | 2025 | Breakout-Bälle abfeuern, Bälle fusionieren/entwickeln, Basisbau zwischen Runs | Ja (seit 03/2026, Free-to-try + Kauf) |
| 3 | Blue Prince | a | 2025 | Herrenhaus Raum für Raum „draften" (1 aus 3 Grundrissen), 50 Schritte pro Tag | Nein (offiziell) |
| 4 | Dorfromantik | a | 2022 | Hex-Kacheln mit passenden Kanten legen; Quests; Kachelstapel ist der Timer | Angekündigt (2025), Release nicht verifiziert |
| 5 | Bore Blasters | a | 2024 | Bohren & Sammeln mit Treibstoff-Timer; Beute bleibt bei Abbruch | Nein (nicht gefunden) |
| 6 | Stretchmancer | b | 2023 (LD54) | Die Welt dehnen und stauchen als einziges Verb | Nein |
| 7 | Windowkill | b | 2023 (LD54) / 2024 Steam | Das Spielfenster schrumpft; man schießt die Ränder zurück | Nein (nicht gefunden) |
| 8 | „That Time I Got Reincarnated as a Panda…" | b | 2024 (GMTK #1) | Figur rollt autonom; Spieler baut und skaliert Plattformen | Nein |
| 9 | Draftula | b | 2025 (GMTK) | Räume Tetris-artig zu einem Turm stapeln, Nachbarschaftsboni, Roguelite | Nein (Steam TBA) |
| 10 | Holedown | c | 2018 | Zielen–Loslassen; Bälle graben durch Blöcke mit Trefferzählern; Statik | Ja (Mobile-nativ) |
| 11 | Desert Golfing | c | 2014 | Ein-Swipe-Golf auf endlosem, prozeduralem Kurs, ohne Reset | Ja (Mobile-nativ) |
| 12 | Hoplite | c | 2013 | Rundenbasierte Mini-Taktik: Bewegung = Angriff, deterministische Gegner | Ja (Mobile-nativ) |

---

## 2. Steckbriefe

### (a) Steam-/Indie-Hits 2022–2026

#### 2.1 Balatro
*Kategorie (a) · Steam-/Indie-Hit*

| Feld | Belegte Fakten | Einschätzung |
|---|---|---|
| **Name** | Balatro – Entwickler LocalThunk (Solo), Publisher Playstack ([Wikipedia](https://en.wikipedia.org/wiki/Balatro), [Steam](https://store.steampowered.com/app/2379780/Balatro/)) | – |
| **Plattform** | Windows, PS4/PS5, Xbox One/Series, Switch; macOS; Android & iOS inkl. „Balatro+" auf Apple Arcade; Switch 2 ([Wikipedia](https://en.wikipedia.org/wiki/Balatro)) | Der Mobile-Port gilt in der Presse als Musterbeispiel für PC→Touch. |
| **Veröffentlichungszeitraum** | 20.02.2024 (PC/Konsolen), 01.03.2024 (macOS), 26.09.2024 (Android/iOS), 25.02.2026 (Switch 2) ([Wikipedia](https://en.wikipedia.org/wiki/Balatro)) | – |
| **Kernmechanik** | Poker-basierter Roguelike-Deckbuilder. Ein Run besteht aus Antes mit je drei Blinds (Small, Big, Boss); pro Runde muss mit begrenzten Händen und Abwürfen eine Zielpunktzahl erreicht werden. Der Wert einer Hand sind Chips, multipliziert mit Mult; Joker verändern Wertung und Regeln; Shop zwischen den Runden; Sieg nach Ante 8, danach Endlosmodus ([Wikipedia](https://en.wikipedia.org/wiki/Balatro)). | Die Stärke ist die Kombination aus einer allgemein bekannten Basisregel (Poker) und „Regelbrechern" (Joker). Der Höhepunkt ist der Moment, in dem sich die Rechnung Chips × Mult aufbaut. |
| **Typische Sessionlänge** | „Most runs complete in 20-30 minutes" ([Games Genie, FAQ](https://www.games-genie.com/games/balatro)). Shacknews spielte auf dem Handy „in smaller sessions compared to my PC and Steam Deck" ([Shacknews](https://shacknews.com/article/141549/balatro-mobile-impressions)). | Ein voller Run passt **nicht** in 30 s–3 min. Ein einzelner Blind dauert eher 1–3 min (**Schätzung**). |
| **Wiederspielwert** | Endlosmodus nach Ante 8 ([Wikipedia](https://en.wikipedia.org/wiki/Balatro)); Steam-Tag „Replay Value" ([Steam](https://store.steampowered.com/app/2379780/Balatro/)). | Sehr hoch: Joker-Kombinatorik und Freischaltungen erzeugen ständig neue „Builds". |
| **Spielerfeedback** | Steam „Overwhelmingly Positive" (98 % von 105.243 engl. Reviews) ([Steam](https://store.steampowered.com/app/2379780/Balatro/)). Metacritic PC 90, OpenCritic 100 % Empfehlung; bei den TGA 2024 Best Independent, Best Debut Indie und Best Mobile Game ([Wikipedia](https://en.wikipedia.org/wiki/Balatro)). Mobile-Port: „almost perfect mobile port"; Kritik: Position des Skip-Buttons beim Öffnen von Packs (Fehltipps), auf sehr kleinen Geräten schwer lesbarer Text, Foldables nicht voll genutzt ([Engadget](https://www.engadget.com/gaming/balatro-is-an-almost-perfect-mobile-port-163050971.html)). PEGI stufte das Spiel kurz nach Release wegen „prominent gambling imagery" auf 18+ hoch, im Februar 2025 wurde es auf 12+ zurückgestuft. Im Endlosmodus tritt ab einem bestimmten Punktestand ein Überlauf auf ([Wikipedia](https://en.wikipedia.org/wiki/Balatro)). | Die Glücksspiel-Optik ist für ein kostenloses Android-Spiel ein reales Risiko bei Alterseinstufung und Store-Richtlinien und sollte vermieden werden. |
| **Visuelle Besonderheiten** | Steam-Tag „Pixel Graphics" ([Steam](https://store.steampowered.com/app/2379780/Balatro/)). | (Aus eigener Kenntnis, nicht quellengeprüft:) Retro-/CRT-Anmutung mit animiertem Shader-Hintergrund. Große, „hüpfende" Zahlen tragen das Feedback. |
| **Steuerungsprinzip** | Mobile: Statt „Karte antippen und dann Aktion wählen" zieht man Elemente in Bildschirmzonen (Pack nach oben = kaufen, Planet-Karte nach rechts = kaufen und nutzen, verkaufen = nach oben rechts). Leichte Haptik bei Taps ([Shacknews](https://shacknews.com/article/141549/balatro-mobile-impressions)). | **Drag-to-Zone** statt Mini-Buttons ist ein direkt übertragbares Muster für kleine Screens. |
| **Monetarisierung** | Steam 14,99 $ ([Steam](https://store.steampowered.com/app/2379780/Balatro/)). Mobile 10 $ ohne Werbung und Zusatzkäufe: „zero intrusive ads or other extra purchases" ([Engadget](https://www.engadget.com/gaming/balatro-is-an-almost-perfect-mobile-port-163050971.html)). Über 5 Mio. verkaufte Einheiten bis Januar 2025, etwa die Hälfte nach dem Mobile-Release ([Wikipedia](https://en.wikipedia.org/wiki/Balatro)). | Belegt, dass Premium-Mobile mit starker Mechanik trägt. Für unser Free-Modell ist das nur bedingt übertragbar. |
| **Schwächen** | Gambling-Rating-Kontroverse, Endlos-Overflow, kleine UI-Mängel mobil (Quellen oben). | Runs sind zu lang für Mikro-Sessions, Joker-Beschreibungen sind textlastig, und der Einstieg setzt Poker-Wissen voraus. |
| **Übertragbare Designprinzipien** | (Ableitung aus den Fakten oben) | 1) Bekannte Basisregel plus Modifikatoren, die die Regel brechen. 2) Multiplikatives Scoring mit **sichtbarer Rechnung** als Belohnungsmoment. 3) Harte Ressourcen pro Runde (Hände, Abwürfe) erzeugen Entscheidungsdruck **ohne Timer**. 4) Drag-to-Zone-Bedienung. |

#### 2.2 BALL x PIT
*Kategorie (a) · Steam-/Indie-Hit*

| Feld | Belegte Fakten | Einschätzung |
|---|---|---|
| **Name** | BALL x PIT – Kenny Sun (Steam: „Kenny Sun and Friends"), Publisher Devolver Digital ([Wikipedia](https://en.wikipedia.org/wiki/Ball_x_Pit), [Steam](https://store.steampowered.com/app/2062430/BALL_x_PIT/)) | – |
| **Plattform** | Windows, macOS, Switch, PS5, Xbox Series; Switch 2; iOS/Android ([Wikipedia](https://en.wikipedia.org/wiki/Ball_x_Pit)) | – |
| **Veröffentlichungszeitraum** | 15.10.2025 (PC/Konsolen), 28.10.2025 (Switch 2), 12.03.2026 (iOS/Android) ([Wikipedia](https://en.wikipedia.org/wiki/Ball_x_Pit)) | – |
| **Kernmechanik** | „brick-breaking, ball-fusing, base-building survival roguelite" ([Steam](https://store.steampowered.com/app/2062430/BALL_x_PIT/)). Monster werden mit abprallenden Bällen besiegt; erreichen sie den unteren Rand, nimmt der Held Schaden. Items erlauben Ball-Fusion und -Evolution; zwischen Runs Basisbau mit Arbeitern ([Wikipedia](https://en.wikipedia.org/wiki/Ball_x_Pit)). Über 60 randomisierte Bälle, über 70 Gebäude ([Steam](https://store.steampowered.com/app/2062430/BALL_x_PIT/)). Der Loop entwickelt sich zu einem „Vampire Survivors-inspired auto-shooter" ([Rogueliker](https://rogueliker.com/ball-x-pit-review/)). | Breakout-Physik wird mit dem Survivors-Build-Rausch gekreuzt. Der stärkste Einzelbaustein ist die **Fusion**: Zwei Elemente ergeben ein neues Verhalten. |
| **Typische Sessionlänge** | Ein Run dauert „12 to 15 minutes" ([Destructoid](https://www.destructoid.com/ball-x-pit-review/)), „bite-sized 10-15 minute runs" ([Dexerto](https://www.dexerto.com/list/the-10-best-games-of-2025-so-far-3228094-19)). | Zu lang für 30 s–3 min; ein einzelner Abpraller-Moment ist jedoch Sekunden-Gameplay. |
| **Wiederspielwert** | Viele Bälle, Gebäude und Charaktere mit eigenen Mechaniken ([Steam](https://store.steampowered.com/app/2062430/BALL_x_PIT/)). | Hoch, weil man Fusionen entdeckt – aber stark an Grind gekoppelt (siehe Feedback). |
| **Spielerfeedback** | Steam „Overwhelmingly Positive" (95 % von 15.753 engl. Reviews) ([Steam](https://store.steampowered.com/app/2062430/BALL_x_PIT/)). Metacritic PS5 88, Switch 89, PC 84; OpenCritic 92 %; über 300.000 Verkäufe in fünf Tagen, über 1 Mio. bis Dezember 2025 ([Wikipedia](https://en.wikipedia.org/wiki/Ball_x_Pit)). Destructoid 9/10: Kernloop „simple and very addictive", Basisbau „feels a bit like a puzzle minigame"; Kritik: in langen Sessions eintönig, Endboss zu leicht, abrupter New Game+ ([Destructoid](https://www.destructoid.com/ball-x-pit-review/)). Shacknews 6/10: „obnoxiously grindy", der DPS-Fokus erstickt Nuancen ([Shacknews](https://www.shacknews.com/article/146348/ball-x-pit-review-score)). Rogueliker: Das Hochleveln vieler schwacher Charaktere ist repetitiv; der Basisbau ist ein „fantastic little palette cleanser" ([Rogueliker](https://rogueliker.com/ball-x-pit-review/)). | Wiederkehrendes Muster: Die Kernaktion begeistert, die Meta-Schicht polarisiert (Grind). |
| **Visuelle Besonderheiten** | Steam-Tags Pixel Graphics, Top-Down, Bullet Heaven ([Steam](https://store.steampowered.com/app/2062430/BALL_x_PIT/)). Bälle, die den Bildschirm füllen: „a delight that never gets old" ([Destructoid](https://www.destructoid.com/ball-x-pit-review/)). | Im Spätspiel sind viele Projektile auf dem Handy ein Lesbarkeitsrisiko. |
| **Steuerungsprinzip** | PC: Figur bewegen und Bälle abfeuern; Entwicklung zum Auto-Shooter ([Rogueliker](https://rogueliker.com/ball-x-pit-review/)). Mobile mit vollem Funktionsumfang ([Gematsu](https://www.gematsu.com/2026/03/ball-x-pit-now-available-for-ios-android)); das genaue Touch-Layout ist **nicht verifiziert**. | Auf Touch tragen Positionieren und Auto-Feuer; präzises Zielen per Daumen wäre schwieriger. |
| **Monetarisierung** | Steam 14,99 $ ([Steam](https://store.steampowered.com/app/2062430/BALL_x_PIT/)). Mobile „free to try and 9.99€ to own forever" ([Cosmocover-Pressemitteilung](https://www.cosmocover.com/newsroom/ball-x-pit-breaks-out-on-mobile-today-letting-you-enjoy-its-killer-fusion-of-survival-base-building-and-ball-bouncing-on-the-move/)); 9,99 $ auf App Store und Google Play ([Gematsu](https://www.gematsu.com/2026/03/ball-x-pit-now-available-for-ios-android)). | **Free-to-try mit einmaligem Unlock** ist ein faires Modell, das zu unserem kostenlosen Spiel mit optionalem Kauf passt. |
| **Schwächen** | Grind, DPS-Dominanz, Eintönigkeit in langen Sessions (Quellen oben). | Ohne den Basisbau würde die Kernaktion allein womöglich nicht lange tragen. Den Fortschritt nicht künstlich über Grind strecken. |
| **Übertragbare Designprinzipien** | (Ableitung) | 1) Physik + Abprall = emergente Treffer, die man nur **indirekt** steuert. 2) **Kombinieren erzeugt neues Verhalten** (Fusion) → Entdeckungsreiz. 3) Wechsel zwischen hektischer Aktion und ruhiger Planung. 4) Lesbarkeit vor Effektfülle. |

#### 2.3 Blue Prince
*Kategorie (a) · Steam-/Indie-Hit*

| Feld | Belegte Fakten | Einschätzung |
|---|---|---|
| **Name** | Blue Prince – Dogubomb (Solo-Entwickler Tonda Ros, rund acht Jahre Entwicklung), Publisher Raw Fury ([Wikipedia](https://en.wikipedia.org/wiki/Blue_Prince_(video_game))) | – |
| **Plattform** | PS5, Windows, Xbox Series; macOS; Switch 2; keine Mobile-Version ([Wikipedia](https://en.wikipedia.org/wiki/Blue_Prince_(video_game))). Laut MacTech (04/2025) gibt es das Spiel nur auf Steam, Xbox und PlayStation; Entwickler und Publisher warnten in einem gemeinsamen Post vor Spielen, die sich auf iOS als Blue Prince ausgeben ([MacTech](https://www.mactech.com/2025/04/28/unapproved-ios-version-of-blue-prince-game-pops-up-on-the-apple-app-store/amp/)). | – |
| **Veröffentlichungszeitraum** | 10.04.2025 (PC/PS5/Xbox), 29.09.2025 (macOS), 03.03.2026 (Switch 2) ([Wikipedia](https://en.wikipedia.org/wiki/Blue_Prince_(video_game))) | – |
| **Kernmechanik** | Das Herrenhaus ist ein Raster aus 45 Räumen („nine rows by five"). Beim Öffnen einer Tür draftet man einen Raum: „choosing one of three randomly selected floor plans". Pro Tag gibt es 50 Schritte, jeder Raumwechsel kostet einen. Ziel ist der verborgene Raum 46; schafft man ihn nicht, beginnt am nächsten Tag die Suche neu ([Wikipedia](https://en.wikipedia.org/wiki/Blue_Prince_(video_game))). | Man **baut die Karte, auf der man sich bewegt**. Jede Wahl verändert zugleich Weg, Ressourcen und künftige Optionen – ein hervorragender Kern für räumliche Kurzrätsel. |
| **Typische Sessionlänge** | Nicht belegt. | **Schätzung:** Ein „Tag" (Run) liegt deutlich über 3 Minuten, eher im zweistelligen Minutenbereich. |
| **Wiederspielwert** | Zufällige Draft-Optionen pro Tag; Steam-Tag „Replay Value" ([Steam](https://store.steampowered.com/app/1569580/Blue_Prince/)). | Hoch, bis die Rätselebene gelöst ist; der Hauptfortschritt ist Wissen, nicht Werte. |
| **Spielerfeedback** | Steam „Very Positive" (85 % von 14.885 engl. Reviews) ([Steam](https://store.steampowered.com/app/1569580/Blue_Prince/)). Metacritic PC 92, PS5 85, Xbox 90; OpenCritic 95 %; u. a. D.I.C.E. „Outstanding Achievement in Game Design" ([Wikipedia](https://en.wikipedia.org/wiki/Blue_Prince_(video_game))). Kritik: RNG – Spieler auf Social Media und im Subreddit berichten, Zufall habe ihre Versuche ruiniert, manche hörten deshalb auf ([Gfinity](https://www.gfinityesports.com/article/why-blue-princes-rng-might-be-undermining-its-game-of-the-year-potential)). Anfangs fehlte Farbenblind-Unterstützung (per Update adressiert), das Spiel ist nur auf Englisch ([Wikipedia](https://en.wikipedia.org/wiki/Blue_Prince_(video_game))). | Die im Vergleich niedrigere Steam-Quote (85 %) passt zum RNG-Frust. Lehre: Zufall braucht Ausgleichsmechaniken. |
| **Visuelle Besonderheiten** | Steam-Tags First-Person, 3D, Stylized ([Steam](https://store.steampowered.com/app/1569580/Blue_Prince/)); Räume werden als „floor plans" gewählt ([Wikipedia](https://en.wikipedia.org/wiki/Blue_Prince_(video_game))). | Grundriss-Karten sind ein schnell lesbares, icon-artiges Format – ideal für Touch-Karten. |
| **Steuerungsprinzip** | First-Person-Erkundung; Raumwahl beim Türöffnen aus drei Plänen ([Wikipedia](https://en.wikipedia.org/wiki/Blue_Prince_(video_game))). Ein inoffizieller iOS-Klon nutzte einen virtuellen Joystick ([MacStories](https://www.macstories.net/linked/how-does-this-keep-happening/) berichtet über den Fake-Port; Details zum Joystick nur aus Suchsnippet, **nicht verifiziert**). | Der Drafting-Teil (Karte wählen, ins Raster legen) ist touch-tauglich, die First-Person-Navigation nicht. |
| **Monetarisierung** | Steam 29,99 $ ([Steam](https://store.steampowered.com/app/1569580/Blue_Prince/)) | Premium. |
| **Schwächen** | RNG-Frust, Sprachbarriere (Quellen oben). | Lange Tage, hohe Text- und Rätsellast; für Kurzsessions ungeeignet. |
| **Übertragbare Designprinzipien** | (Ableitung) | 1) **„1 aus 3"-Drafting räumlicher Teile** in ein festes Raster. 2) **Schrittbudget** als Session-Begrenzer. 3) Täglicher Reset mit persistentem Wissen. 4) RNG mit Rerolls oder Garantien abfedern. |

#### 2.4 Dorfromantik
*Kategorie (a) · Steam-/Indie-Hit*

| Feld | Belegte Fakten | Einschätzung |
|---|---|---|
| **Name** | Dorfromantik – Toukana Interactive (Berlin), Self-Publishing ([Wikipedia](https://en.wikipedia.org/wiki/Dorfromantik)) | – |
| **Plattform** | Windows, Switch, PS4/PS5, Xbox One/Series, macOS ([Wikipedia](https://en.wikipedia.org/wiki/Dorfromantik)). Mobile: „under development by ClockStone Studio, to be published by Headup Games" ([Wikipedia](https://en.wikipedia.org/wiki/Dorfromantik)); angekündigt als „reimagined mobile version" mit „new gameplay flow and mechanics optimised for touch controls and on-the-go play" ([GamesMarket, 07.05.2025](https://www.gamesmarket.global/games-and-products/new-platforms-dorfromantik-comes-to-mobile-phones-and-more-consoles-with-the-help-of-clockstone-and-headup-04f6c37bb4b4e2c646fda3aa72551721)). Ein Mobile-Release ist bis 22.10.2026 **nicht verifiziert**; die [Pocket-Gamer-Seite](https://www.pocketgamer.com/dorfromantik/) ist widersprüchlich. | – |
| **Veröffentlichungszeitraum** | Early Access 25.03.2021; 1.0 am 28.04.2022 (Windows); Switch 29.09.2022; PS/Xbox 14.08.2025; macOS 25.06.2026 ([Wikipedia](https://en.wikipedia.org/wiki/Dorfromantik)) | – |
| **Kernmechanik** | Man legt Hex-Kacheln mit Landschaftselementen. Der Stapel umfasst 40 Zufallskacheln, die obersten drei sind sichtbar. Punkte gibt es für passende Kanten. Quests (z. B. Bahnlinie einer Mindestlänge, Feld schließen) bringen Punkte und Extrakacheln. Das Spiel endet, wenn die Kacheln ausgehen ([Wikipedia](https://en.wikipedia.org/wiki/Dorfromantik)). | Der Kachelstapel ist ein **„Timer ohne Uhr"**: Spannung ohne Hektik. Quests geben Mittelfristziele und füllen den Stapel nach (Push-your-luck light). |
| **Typische Sessionlänge** | Modi: Standard, Kreativ (ohne Kachellimit), Quick (begrenzte Kachelzahl), Challenges ([Wikipedia](https://en.wikipedia.org/wiki/Dorfromantik)). Die Partielänge ist nicht belegt. | **Schätzung:** Quick-Partie etwa 10–20 min, Standard deutlich länger. |
| **Wiederspielwert** | „High replay value – every session is different"; freischaltbare Kacheln und Biome ([Steam](https://store.steampowered.com/app/1455840/Dorfromantik/)). | Hoch für entspannte Spieler, begrenzt für Optimierer. |
| **Spielerfeedback** | Steam „Overwhelmingly Positive" (96 % von 15.816 engl. Reviews) ([Steam](https://store.steampowered.com/app/1455840/Dorfromantik/)). Kritiker lobten Präsentation und entspannte Atmosphäre, die Tiefe wurde gemischt bewertet; Nintendo Life: „relatively shallow in the long run". Deutscher Computerspielpreis 2021 „Bestes Game Design" ([Wikipedia](https://en.wikipedia.org/wiki/Dorfromantik)). Das Studio nennt als Antrieb für den ersten Mobile-Anlauf u. a. „der starken öffentlichen Nachfrage" sowie inoffizielle Mobile-Klone, „von denen einige täglich in unseren Community-Hubs und sozialen Netzwerken auftauchten" ([appgefahren](https://www.appgefahren.de/dorfromantik-beliebter-spiele-hit-kommt-auf-iphone-und-ipad-378717.html)). | Eindeutiges Nachfragesignal für die **Mechanik auf Mobile**. |
| **Visuelle Besonderheiten** | „Original Artstyle with handpainted boardgame feel" ([Steam](https://store.steampowered.com/app/1455840/Dorfromantik/)) | Eine Diorama-Welt, die mit jeder Kachel wächst, ist ein sichtbares „Werk" am Session-Ende (Screenshot-Moment). |
| **Steuerungsprinzip** | Kacheln nacheinander platzieren, Punkte für passende Kanten ([Wikipedia](https://en.wikipedia.org/wiki/Dorfromantik)). | (Nicht quellengeprüft) Maus: drehen und ablegen. Auf Touch naheliegend: Tap-to-rotate + Drag-to-place, einhändig. |
| **Monetarisierung** | Steam 13,99 $ ([Steam](https://store.steampowered.com/app/1455840/Dorfromantik/)); keine Verkaufszahlen veröffentlicht ([Wikipedia](https://en.wikipedia.org/wiki/Dorfromantik)). | Premium. |
| **Schwächen** | Geringe Langzeittiefe laut Nintendo Life ([Wikipedia](https://en.wikipedia.org/wiki/Dorfromantik)). Der erste Mobile-Anlauf 2022 wurde nach wenigen Monaten gestoppt, „weil die Moral im Team deutlich gesunken war" ([appgefahren](https://www.appgefahren.de/dorfromantik-beliebter-spiele-hit-kommt-auf-iphone-und-ipad-378717.html)). | Große Karte plus kleine Kacheln ergeben Zoom- und Präzisionsprobleme auf Phones. Eine Mobile-Adaption ist offenbar nicht trivial. |
| **Übertragbare Designprinzipien** | (Ableitung) | 1) Sofortbelohnung pro Zug (Kanten) + Mittelfristziel (Quest) + **Ressourcen-Ende statt Tod**. 2) Begrenzte Vorschau (Top 3) ermöglicht Planung. 3) **Quick-Modus als eigenes Kurzformat**. 4) Wachsende Welt als Session-Andenken. |

#### 2.5 Bore Blasters
*Kategorie (a) · kleinerer Steam-Indie (kein Megahit), aufgenommen wegen sehr kompakter Runs*

| Feld | Belegte Fakten | Einschätzung |
|---|---|---|
| **Name** | BORE BLASTERS – 8BitSkull (Schottland), Self-Publishing ([Steam](https://store.steampowered.com/app/2398170/BORE_BLASTERS/), [PCGamesN](https://www.pcgamesn.com/bore-blasters/steam-launch)) | – |
| **Plattform** | PC über Steam ([Steam](https://store.steampowered.com/app/2398170/BORE_BLASTERS/)); Browser-Demo (HTML5) auf [itch.io](https://8bitskull.itch.io/bore-blasters). Kein Mobile-Release gefunden. | – |
| **Veröffentlichungszeitraum** | 08.03.2024 ([Steam](https://store.steampowered.com/app/2398170/BORE_BLASTERS/)) | – |
| **Kernmechanik** | Gyrokopter mit Maschinengewehr-Bohrer; Gestein abbauen, Edelsteine, Erze und Artefakte sammeln, Schiff upgraden ([Steam](https://store.steampowered.com/app/2398170/BORE_BLASTERS/)). Ziel: „get to the bottom and find the chest before you run out of fuel or hull integrity". Der Entwickler: „you are intended to eventually run out of fuel"; Tank-Upgrades verlängern die Runs ([itch.io](https://8bitskull.itch.io/bore-blasters)). Bei frühem Abbruch behält man alles Gesammelte ([PCGamesN](https://www.pcgamesn.com/bore-blasters/steam-launch)); „even failed runs aren't punishing" ([Steam](https://store.steampowered.com/app/2398170/BORE_BLASTERS/)). | Die **Treibstoff-Uhr** macht das Run-Ende erwartbar und fair. Der freiwillige Ausstieg mit Beutesicherung ist ein klassischer **Push-your-luck**-Hebel. |
| **Typische Sessionlänge** | „Runs can be just a few minutes, or last up to 10-15 minutes" ([PCGamesN](https://www.pcgamesn.com/bore-blasters/steam-launch)); ähnlich [GamingOnLinux](https://www.gamingonlinux.com/2024/02/youre-going-to-need-to-take-mining-shooter-bore-blasters-away-from-me). | Frühe Runs liegen nah an unserem Zielkorridor. |
| **Wiederspielwert** | Prozedural generierte Level, verschiedene Biome, Upgrades ([Steam](https://store.steampowered.com/app/2398170/BORE_BLASTERS/)) | Mittel; der Fortschritt ist stark meta-getrieben. |
| **Spielerfeedback** | Steam „Very Positive" (80 % von 715 Reviews) ([Steam](https://store.steampowered.com/app/2398170/BORE_BLASTERS/)). GamingOnLinux: „Nice and accessible"; die Treibstoffmechanik „may need some tweaks" ([GamingOnLinux](https://www.gamingonlinux.com/2024/02/youre-going-to-need-to-take-mining-shooter-bore-blasters-away-from-me)). Ein PC-Gamer-Review mit 68 Punkten (Kritik an repetitiver Kampagne und Spätspiel-Balance) ist nur per Suchsnippet bekannt; [die Seite](https://www.pcgamer.com/games/roguelike/bore-blasters-review/) war nicht abrufbar → **nicht verifiziert**. | – |
| **Visuelle Besonderheiten** | Steam-Tags Pixel Graphics, Steampunk, Dwarves ([Steam](https://store.steampowered.com/app/2398170/BORE_BLASTERS/)) | – |
| **Steuerungsprinzip** | WASD bewegen, Maus zielen, Linksklick schießen, Leertaste für die Spezialfähigkeit; Gamepad im Twin-Stick-Stil ([itch.io](https://8bitskull.itch.io/bore-blasters)) | Twin-Stick ist auf Touch unbequem; für Mobile müsste Bohren automatisch oder richtungsbasiert werden. |
| **Monetarisierung** | 9,99 $ ([Steam](https://store.steampowered.com/app/2398170/BORE_BLASTERS/)); kostenlose Browser-Demo ([itch.io](https://8bitskull.itch.io/bore-blasters)) | Premium. |
| **Schwächen** | Treibstoff-Balance (GamingOnLinux). | Kämpfen und Bohren gleichzeitig verlangt zwei Aufmerksamkeitslasten – für Casual auf Touch zu viel. |
| **Übertragbare Designprinzipien** | (Ableitung) | 1) **Ressourcen-Timer statt Lebenspunkte**. 2) **„Behalte, was du hast"** beim Abbruch → kein Frust, Spannung bleibt. 3) Run-Länge über Upgrades wachsen lassen; die ersten Runs sind sehr kurz. |

### (b) Game-Jam- und itch.io-Standouts

#### 2.6 Stretchmancer (Ludum Dare 54, Jam-Version)
*Kategorie (b) · Jam-Sieger*

| Feld | Belegte Fakten | Einschätzung |
|---|---|---|
| **Name** | Stretchmancer – Triangle Wave (Ollie Powell, Tom Carrell, Adam Butcher; zusätzliches Game Design: Ezgi Hazal Aygan) ([itch.io](https://trianglewave.itch.io/stretchmancer)) | – |
| **Plattform** | Jam-Version: HTML5 und Windows ([itch.io](https://trianglewave.itch.io/stretchmancer)). Vollversion: Windows, Publisher Offbrand Games ([Offbrand](https://offbrand.gg/stretchmancer)). | – |
| **Veröffentlichungszeitraum** | Ludum Dare 54 (2023), in 72 h zum Thema „Limited Space" ([itch.io](https://trianglewave.itch.io/stretchmancer)). Vollversion: „isn't releasing until 2027" ([Offbrand](https://offbrand.gg/stretchmancer)). | – |
| **Jam-Ergebnis** | „1st for Overall, 1st for Fun, 1st for Innovation" ([itch.io](https://trianglewave.itch.io/stretchmancer)); LD54-Jam #1 Overall mit 4,70 bei 2.222 Einreichungen im Event ([foon.uk LD54](https://ludum-dare.foon.uk/events/54)). Best Innovation bei Devgamm Portugal 2025 ([Offbrand](https://offbrand.gg/stretchmancer)). | – |
| **Kernmechanik** | „Unique world-stretching puzzles", „5 levels of Portal-like fun" ([itch.io](https://trianglewave.itch.io/stretchmancer)). In der Vollversion gibt es zwei Formen der Fähigkeit: „the right hand pushing things and the left hand pulling them" – Objekte werden gestreckt und gestaucht ([TheSixthAxis](https://www.thesixthaxis.com/2025/12/10/stretchmancer-is-a-squishy-squashy-stretchy-puzzle-game/)). | **Ein einziges Verb (dehnen/stauchen) wirkt auf alles** – ein riesiger Lösungsraum aus einer Regel. Das Thema „wenig Platz" wird selbst zur Mechanik. |
| **Typische Sessionlänge** | Nicht belegt (5 Level, [itch.io](https://trianglewave.itch.io/stretchmancer)). | **Schätzung:** Die Jam-Version dauert insgesamt 15–30 Minuten. |
| **Wiederspielwert** | 5 Level plus Geheimnisse ([itch.io](https://trianglewave.itch.io/stretchmancer)) | Gering (lineares Puzzle). Das Verb selbst hat aber großes Variationspotenzial, etwa für prozedurale Arcade-Varianten. |
| **Spielerfeedback** | itch.io 4,9/5 (131 Ratings). Kommentare loben die Stretch-Mechanik, Humor und Vertonung; viele wünschen mehr Level; einige berichten von Motion Sickness ([itch.io](https://trianglewave.itch.io/stretchmancer)). | – |
| **Visuelle Besonderheiten** | Tags 3D, First-Person, Low-poly, Retro ([itch.io](https://trianglewave.itch.io/stretchmancer)) | – |
| **Steuerungsprinzip** | Tastatur, Maus, Gamepad ([itch.io](https://trianglewave.itch.io/stretchmancer)); Push- und Pull-„Hände" ([TheSixthAxis](https://www.thesixthaxis.com/2025/12/10/stretchmancer-is-a-squishy-squashy-stretchy-puzzle-game/)) | Auf Touch ist **Pinch/Spread** das natürliche Äquivalent von Stauchen/Strecken – in 2D direkt übertragbar. |
| **Monetarisierung** | Jam-Version im Browser spielbar; Vollversion per Steam-Wishlist ([itch.io](https://trianglewave.itch.io/stretchmancer), [Offbrand](https://offbrand.gg/stretchmancer)) | – |
| **Schwächen** | Motion Sickness (Kommentare, [itch.io](https://trianglewave.itch.io/stretchmancer)) | 3D-First-Person ist nicht direkt Casual-Touch-tauglich. Kurze Spieldauer. |
| **Übertragbare Designprinzipien** | (Ableitung) | 1) **Ein Verb, das auf die Welt selbst wirkt** (nicht nur auf die Spielfigur). 2) Die Geste entspricht der Fantasie: Strecken = Spreizen, Stauchen = Kneifen. 3) Thema als Mechanik („Limited Space"). |

#### 2.7 Windowkill
*Kategorie (b) · Jam-Spiel → Steam-Hit*

| Feld | Belegte Fakten | Einschätzung |
|---|---|---|
| **Name** | Windowkill – torcado (Solo), Self-Publishing ([Steam](https://store.steampowered.com/app/2726450/Windowkill/), [itch.io](https://torcado.itch.io/windowkill)) | – |
| **Plattform** | Windows, Linux ([itch.io](https://torcado.itch.io/windowkill)); Steam ([Steam](https://store.steampowered.com/app/2726450/Windowkill/)). Keine Mobile-Version gefunden. | – |
| **Veröffentlichungszeitraum** | Ursprünglich in 72 h für Ludum Dare 54 (2023) entstanden ([itch.io](https://torcado.itch.io/windowkill)); Steam-Release am 23.02.2024 ([Steam](https://store.steampowered.com/app/2726450/Windowkill/)). | – |
| **Jam-Ergebnis** | LD54-Jam #2 Overall (4,58), direkt hinter Stretchmancer ([foon.uk LD54](https://ludum-dare.foon.uk/events/54)) | – |
| **Kernmechanik** | Twin-Stick-Shooter, bei dem „the game window itself is constantly closing in on you". Man schießt auf die Fensterränder, um das Fenster zu verschieben; Gegner und Bosse haben eigene Fenster ([itch.io](https://torcado.itch.io/windowkill), [Steam](https://store.steampowered.com/app/2726450/Windowkill/)). „your screen itself is the play area" ([Godot Showcase](https://godotengine.org/showcase/windowkill/)). | Die **Spielfeldgrenze ist zugleich Gegner und Ressource**, und die eigene Angriffsaktion formt gleichzeitig die Arena. |
| **Typische Sessionlänge** | Nicht belegt. | **Schätzung:** Runs von einigen Minuten bis etwa 20 Minuten. |
| **Wiederspielwert** | Roguelike-Permadeath, Shops, Upgrades und Perks, mehrere Charaktere, Unlocks, Secrets, lokaler Koop ([Steam](https://store.steampowered.com/app/2726450/Windowkill/)) | Mittel bis hoch; der Hook trägt stärker als die Meta-Schicht. |
| **Spielerfeedback** | Steam „Overwhelmingly Positive" (96 % von 2.503 engl. Reviews) ([Steam](https://store.steampowered.com/app/2726450/Windowkill/)). itch.io 4,8/5 (703 Ratings); Lob für das Konzept („unique concept") und den Soundtrack. Kritik: Performance bei vielen Gegnern und Orbs, Probleme der Linux-Demo, „Don't try to play with a touchpad", ein Boss mit Präzisionsklicks lenkt von der eigenen Figur ab ([itch.io](https://torcado.itch.io/windowkill)). | – |
| **Visuelle Besonderheiten** | Tags Minimalist, Experimental ([Steam](https://store.steampowered.com/app/2726450/Windowkill/)); „Vector" ([itch.io](https://torcado.itch.io/windowkill)) | Minimalistische Vektorgrafik bleibt auch bei Chaos lesbar – gut für kleine Screens. |
| **Steuerungsprinzip** | WASD bewegen, Klick schießen, Rechtsklick Fähigkeit ([itch.io](https://torcado.itch.io/windowkill)) | Auf Touch müsste das Schießen gegen den Rand vereinfacht werden, z. B. automatisch oder per Tap auf den Rand. |
| **Monetarisierung** | Steam 4,99 $ ([Steam](https://store.steampowered.com/app/2726450/Windowkill/)); itch.io „Name your own price" ([itch.io](https://torcado.itch.io/windowkill)) | Niedriger Preis, starker Hook. |
| **Schwächen** | OS- und Performance-Abhängigkeit (Kommentare, [itch.io](https://torcado.itch.io/windowkill)) | Der Gag lebt vom Desktop-Fenster und ist auf iOS/Android (Vollbild-Apps) **nicht 1:1 möglich** – man müsste einen „Viewport im Screen" simulieren. |
| **Übertragbare Designprinzipien** | (Ableitung) | 1) **Arena als Lebensbalken**: Der sichtbare Platz zeigt den Zustand ohne HUD. 2) Doppelfunktion einer Eingabe (Angriff = Raum schaffen). 3) Einen „Medium-Bruch" als einprägsamen Hook nutzen. |

#### 2.8 „That Time I Got Reincarnated as a Panda and had to Collect Coins by Rolling Away on Built-to-Scale Platforms" (GMTK 2024 #1)
*Kategorie (b) · Jam-Sieger*

| Feld | Belegte Fakten | Einschätzung |
|---|---|---|
| **Name** | (Titel wie oben) – Colisan (Solo) ([itch.io](https://colisan.itch.io/that-time-i-got-reincarnated-as-a-panda-a-h-t-c-c-b-r-a-o-b-t-s-p)) | Der absurde Titel ist Teil des Charmes und wurde in den Kommentaren am häufigsten erwähnt. |
| **Plattform** | Windows-Download; der Web-Export der Engine ist laut Entwickler defekt ([itch.io](https://colisan.itch.io/that-time-i-got-reincarnated-as-a-panda-a-h-t-c-c-b-r-a-o-b-t-s-p)) | – |
| **Veröffentlichungszeitraum** | GMTK Game Jam 2024, 16.–20.08.2024, Thema „Built to Scale" ([Jam-Seite](https://itch.io/jam/gmtk-2024)) | – |
| **Jam-Ergebnis** | #1 Overall (4,689; aus 30 Ratings; Style #2, Enjoyment #6, Creativity #9) bei 7.511 Einreichungen ([Ergebnisse](https://itch.io/jam/gmtk-2024/results)) | Kleine Datenbasis – mit Vorsicht lesen (siehe Feedback). |
| **Kernmechanik** | Der Panda „rolls forward and falls on its own" und ist nicht steuerbar. Der Spieler baut Plattformen per Klick-Drag und skaliert sie mit dem Mausrad. Maximal zwei Plattformen gleichzeitig; zu dünn skaliert verschwindet eine Plattform. Man verliert, wenn der Panda zerquetscht wird oder den Screen verlässt. Schnellere Bewegung bringt mehr Punkte pro Münze; rote Münzen beschleunigen (mehr Punkte), blaue bremsen (weniger) ([itch.io](https://colisan.itch.io/that-time-i-got-reincarnated-as-a-panda-a-h-t-c-c-b-r-a-o-b-t-s-p)). | **Indirekte Steuerung in Echtzeit**: Man formt die Umgebung, nicht die Figur. Das Limit von zwei Plattformen erzwingt Abwägen statt Spammen. |
| **Typische Sessionlänge** | Laut Entwickler etwa 5 Minuten zum Entdecken und etwa 15 Minuten zum „Gutwerden" ([itch.io](https://colisan.itch.io/that-time-i-got-reincarnated-as-a-panda-a-h-t-c-c-b-r-a-o-b-t-s-p)) | **Schätzung:** Ein Einzelversuch dauert unter 1 Minute – genau unser Korridor. |
| **Wiederspielwert** | Highscore-Fokus mit Leaderboard ([itch.io](https://colisan.itch.io/that-time-i-got-reincarnated-as-a-panda-a-h-t-c-c-b-r-a-o-b-t-s-p)) | Score-Chasing; Langzeitmotivation unklar. |
| **Spielerfeedback** | itch.io-Seite 3,6/5 (18 Ratings). Lob für Titel und Ästhetik („Game has potential"); Kritik: sehr schwer, Steuerung und Art wirken „clunky". Mehrere Kommentare zweifeln die Legitimität des Jam-Rankings an; der Entwickler widerspricht und verweist auf Ratings von Playtest-Streamern ([itch.io](https://colisan.itch.io/that-time-i-got-reincarnated-as-a-panda-a-h-t-c-c-b-r-a-o-b-t-s-p)). | Neutral festzuhalten: Die Jam-Platzierung ist umstritten, die **Mechanik-Idee** bleibt unabhängig davon interessant. |
| **Visuelle Besonderheiten** | Tag „Pixel Art" ([itch.io](https://colisan.itch.io/that-time-i-got-reincarnated-as-a-panda-a-h-t-c-c-b-r-a-o-b-t-s-p)) | – |
| **Steuerungsprinzip** | Nur Maus: Drag = bauen, Scrollrad = skalieren; Backspace = Schnellneustart ([itch.io](https://colisan.itch.io/that-time-i-got-reincarnated-as-a-panda-a-h-t-c-c-b-r-a-o-b-t-s-p)) | Auf Touch nativer als am PC: **Ziehen = bauen, Spreizen = skalieren**. |
| **Monetarisierung** | Jam-Spiel als itch.io-Download; ein Preis ist auf der Seite nicht angegeben (**nicht verifiziert**). | – |
| **Schwächen** | Schwierigkeit, Ranking-Kontroverse, nur Windows ([itch.io](https://colisan.itch.io/that-time-i-got-reincarnated-as-a-panda-a-h-t-c-c-b-r-a-o-b-t-s-p)) | Unklare Lernkurve; das Zerquetschen durch eigene Plattformen kann sich unfair anfühlen. |
| **Übertragbare Designprinzipien** | (Ableitung) | 1) **Gott-Hand-Steuerung**: Die Figur ist autonom, der Spieler formt die Welt. 2) Harte Objektlimits halten das Bild lesbar. 3) **Selbstgewähltes Risiko** (Tempo-Münzen) als Scoring-Hebel. |

#### 2.9 Draftula (Jam-Version)
*Kategorie (b) · Jam-Spiel → kommende Steam-Vollversion*

| Feld | Belegte Fakten | Einschätzung |
|---|---|---|
| **Name** | Draftula (Jam Version) – joespacio; Steam-Entwickler „Team Draftula" ([itch.io](https://joespacio.itch.io/draftula), [Steam](https://store.steampowered.com/app/4598280/Draftula/)) | – |
| **Plattform** | Browser (HTML5, Godot), Windows-Download ([itch.io](https://joespacio.itch.io/draftula)). Steam-Vollversion „To be announced", kostenlose Steam-Demo ([Steam](https://store.steampowered.com/app/4598280/Draftula/)) | – |
| **Veröffentlichungszeitraum** | GMTK Game Jam 2025 (30.07.–03.08.2025, Thema „Loop") ([Jam-Seite](https://itch.io/jam/gmtk-2025)). Halloween-Update und Web-Build am 31.10.2025; Steam-Ankündigung am 12.05.2026; Steam-Demo am 28.07.2026 ([Devlog](https://joespacio.itch.io/draftula/devlog)) | – |
| **Jam-Ergebnis** | Enjoyment #1 (4,812; 16 Ratings), Creativity #62; GMTK 2025 hatte keine „Overall"-Kategorie; 9.514 Einreichungen ([Ergebnisse](https://itch.io/jam/gmtk-2025/results/enjoyment)) | – |
| **Kernmechanik** | „Build up the castle by placing rooms strategically to get bonuses"; zwischen den „Jahrhunderten" gibt man Edelsteine für neue Räume aus ([itch.io](https://joespacio.itch.io/draftula)). Steam: Roguelike-Variante von „block-dropping puzzlers", Räume geben Boni, wenn sie neben bestimmten anderen Räumen liegen ([Steam](https://store.steampowered.com/app/4598280/Draftula/)). Ein Kommentar nennt es „the twist on Tetris" ([itch.io](https://joespacio.itch.io/draftula)). Das genaue Platzierungsverfahren (Fallen, Drehen, Ziehen) ist **nicht dokumentiert**. | **Räumliche Synergie**: Tetris-artige Platzierung trifft Nachbarschaftsboni. Das Thema erklärt den Loop (Dracula kehrt alle 100 Jahre zurück, ein Run ist ein Jahrhundert). |
| **Typische Sessionlänge** | Steam verspricht „Short, engaging runs that make it really easy to pick up and play" ([Steam](https://store.steampowered.com/app/4598280/Draftula/)). Kommentare berichten von Sessions zwischen etwa 30 Minuten und mehreren Stunden ([itch.io](https://joespacio.itch.io/draftula)). | Die Run-Länge skaliert mit der Turmhöhe; für 3 min müsste man deckeln (z. B. feste Stockwerkzahl). |
| **Wiederspielwert** | Steam-Version: über 50 Räume, 3 Karten mit eigenen Mechaniken, Secrets ([Steam](https://store.steampowered.com/app/4598280/Draftula/)) | Hoch durch Raum-Kombinatorik. |
| **Spielerfeedback** | itch.io 4,6/5 (294 Ratings). Lob für Game Feel, Musik und SFX, Suchtfaktor sowie die Balance des Geld-und-Turm-Systems. Kritik: Screenshake (Toggle gewünscht), wenig Raumvielfalt in der Jam-Version („a lot of the small 1x1 rooms can feel limiting"), unklare Regeln (Friedhof, „bottomless pit"), fehlende Kostenanzeige, Abstürze in Safari ([itch.io](https://joespacio.itch.io/draftula)). | Die Kritik betrifft vor allem **Regeltransparenz**. Synergien brauchen eine Live-Vorschau. |
| **Visuelle Besonderheiten** | Steam-Tags Pixel Graphics, Retro ([Steam](https://store.steampowered.com/app/4598280/Draftula/)) | – |
| **Steuerungsprinzip** | Nicht dokumentiert. | Vermutlich Maus; auf Touch liegen Drag-and-Drop oder Fallen-und-Tippen nahe. |
| **Monetarisierung** | Jam-Version im Browser spielbar ([itch.io](https://joespacio.itch.io/draftula)); ein Preis für die Steam-Version ist nicht gelistet ([Steam](https://store.steampowered.com/app/4598280/Draftula/)). | – |
| **Schwächen** | Siehe Kritik oben. | Komplexe Nachbarschaftsregeln auf kleinem Screen sind nur mit klarer Visualisierung lesbar. |
| **Übertragbare Designprinzipien** | (Ableitung) | 1) **Platzieren + Nachbarschaftsbonus** = sofortige, sichtbare Synergie-Belohnung. 2) Thematische Rahmung des Run-Zyklus. 3) Neue Teile zwischen den Runs freischalten (Meta-Progression ohne Zahlen-Grind). |

### (c) Ältere Ein-Mechanik-Klassiker

#### 2.10 Holedown
*Kategorie (c) · Mobile-Indie-Klassiker*

| Feld | Belegte Fakten | Einschätzung |
|---|---|---|
| **Name** | holedown – grapefrukt games (Martin Jonasson); Anbieter im App Store: webbfarbror AB ([holedown.com](https://holedown.com/), [App Store](https://apps.apple.com/us/app/holedown/id1297270249)) | – |
| **Plattform** | iOS, Android, Steam, Nintendo Switch ([holedown.com](https://holedown.com/)) | – |
| **Veröffentlichungszeitraum** | iOS v1.0.0 am 25.07.2018 ([App Store](https://apps.apple.com/us/app/holedown/id1297270249)); Review für iOS und Android am 26.07.2018 ([Pocket Gamer](https://www.pocketgamer.com/holedown/review/)); Steam am 09.04.2020 ([Steam](https://store.steampowered.com/app/1268370/holedown/)) | – |
| **Kernmechanik** | Man schießt Bälle, um Blöcke zu brechen und sich zum Planetenkern zu graben; die Schüsse pro Runde sind begrenzt; manche Blöcke sind an der Wand fixiert; Kristalle kaufen Upgrades ([holedown.com](https://holedown.com/)). Blöcke tragen Trefferzahlen, einige fallen, wenn ihre Stützen zerstört werden, und Hindernisse rücken pro Zug nach oben. Erreichen sie die Oberfläche, beginnt ein neues prozedurales Level. Das Endlos-Level „Black Hole" hat keinen Kern ([MacStories](https://www.macstories.net/reviews/game-day-holedown/), [Pocket Gamer](https://www.pocketgamer.com/holedown/review/)). | Das Genre „Ball-Bouncer" wird durch **Graben + Statik + klares Ziel (Kern)** aufgewertet. |
| **Typische Sessionlänge** | „It's the kind of app you can dive into for a few minutes and return to later" ([TapSmart](https://www.tapsmart.com/games/review-holedown-ball-bouncing-block-breaking-blast/)); jederzeit beendbar ohne Fortschrittsverlust ([MacStories](https://www.macstories.net/reviews/game-day-holedown/)). | Passt sehr gut zu 1–3 min pro Session. |
| **Wiederspielwert** | Endlosmodus, 11 Leaderboards ([Steam](https://store.steampowered.com/app/1268370/holedown/), [App Store](https://apps.apple.com/us/app/holedown/id1297270249)) | Mittel. Der Kerninhalt (sechs Planeten) ist endlich. |
| **Spielerfeedback** | Pocket Gamer 4/5: „This isn't a brainless game by any means"; weniger süchtig machend als simplere Genrevertreter, dafür lohnender ([Pocket Gamer](https://www.pocketgamer.com/holedown/review/)). MacStories: „a perfect example of a well-designed mobile game" ([MacStories](https://www.macstories.net/reviews/game-day-holedown/)). TapSmart 4,5★, Kritik an ähnlichen Bosskämpfen und fehlenden neuen Inhalten ([TapSmart](https://www.tapsmart.com/games/review-holedown-ball-bouncing-block-breaking-blast/)). App Store 4,3/5 (399) ([App Store](https://apps.apple.com/us/app/holedown/id1297270249)); Steam 85 % (54 Reviews) ([Steam](https://store.steampowered.com/app/1268370/holedown/)). | – |
| **Visuelle Besonderheiten** | Steam-Tags Stylized, Cartoony, Minimalist; Screenshake abschaltbar ([Steam](https://store.steampowered.com/app/1268370/holedown/), [App Store](https://apps.apple.com/us/app/holedown/id1297270249)) | Klare Formen und große Zahlen bleiben auf dem Phone lesbar. Der Screenshake-Toggle ist ein Accessibility-Muss (siehe auch die Draftula-Kritik). |
| **Steuerungsprinzip** | Finger ziehen zum Zielen; „lift your finger and the balls go careening across the screen" ([MacStories](https://www.macstories.net/reviews/game-day-holedown/)); „Intuitive, one-handed play" ([App Store](https://apps.apple.com/us/app/holedown/id1297270249)) | Referenz für **Zielen–Loslassen–Zuschauen**. |
| **Monetarisierung** | iOS 3,99 $ einmalig, keine In-App-Käufe ([MacStories](https://www.macstories.net/reviews/game-day-holedown/), [App Store](https://apps.apple.com/us/app/holedown/id1297270249)); Steam 9,99 $ ([Steam](https://store.steampowered.com/app/1268370/holedown/)). Android 3,99 $ zum Launch laut Android Authority (Seite nicht abrufbar → **nicht verifiziert**). | – |
| **Schwächen** | Wenig neue Inhalte, kaum Boss-Varianz ([TapSmart](https://www.tapsmart.com/games/review-holedown-ball-bouncing-block-breaking-blast/)) | Die Nähe zum etablierten Ball-Bouncer-Genre macht die Differenzierung schwer. |
| **Übertragbare Designprinzipien** | (Ableitung) | 1) **Zielen → Loslassen → Physik-Kaskade**. 2) **Statik/Einsturz** als Kettenreaktion. 3) Räumliches Fortschrittsziel (Tiefe) statt abstrakter Levelnummern. 4) **Schussbudget** als natürliche Session-Grenze. |

#### 2.11 Desert Golfing
*Kategorie (c) · Mobile-Indie-Klassiker*

| Feld | Belegte Fakten | Einschätzung |
|---|---|---|
| **Name** | Desert Golfing – Blinkbat Games (Justin Smith) ([Wikipedia](https://en.wikipedia.org/wiki/Desert_Golfing)) | – |
| **Plattform** | iOS, Android, Windows, macOS ([Wikipedia](https://en.wikipedia.org/wiki/Desert_Golfing)) | – |
| **Veröffentlichungszeitraum** | iOS/Android am 06.08.2014; Windows/macOS am 19.12.2017; Nachfolger „Golf on Mars" 2020 ([Wikipedia](https://en.wikipedia.org/wiki/Desert_Golfing)) | – |
| **Kernmechanik** | Ein-Finger-Swipe bestimmt Richtung und Kraft. Der endlose Wüstenkurs (komplett Sand) wird pseudozufällig generiert, die Strokes summieren sich dauerhaft ([Wikipedia](https://en.wikipedia.org/wiki/Desert_Golfing), [Kotaku](https://kotaku.com/f-k-you-desert-golfing-aka-the-worst-best-game-in-th-1633266512)). Kein Menü, kein Reset des Scores ([Kotaku](https://kotaku.com/f-k-you-desert-golfing-aka-the-worst-best-game-in-th-1633266512), [Reverse Shot](https://reverseshot.org/features/1927/desert_golfing)). Später kam ein Update gegen unmögliche Löcher und ein Ende bei Loch 10.001 ([Wikipedia](https://en.wikipedia.org/wiki/Desert_Golfing)). | Radikale Reduktion: nur ein Verb, keine UI. Die **Permanenz** macht jeden Schlag bedeutsam. |
| **Typische Sessionlänge** | Nicht belegt. | **Schätzung:** Ein Loch dauert Sekunden bis etwa 1 Minute, die Session ist beliebig kurz. |
| **Wiederspielwert** | Endloser Kurs; „Desert Golfing is a game in which you never die" ([Reverse Shot](https://reverseshot.org/features/1927/desert_golfing)) | Kein Neustart: Wiederspielen bedeutet **Weiterreisen**. |
| **Spielerfeedback** | Eurogamer 9/10, „wonderfully sparse", Steuerung und Physik „superb"; Ars Technica: „transcendent beauty" ([Wikipedia](https://en.wikipedia.org/wiki/Desert_Golfing)). „mesmerizing (and stressful!) sense of permanency" ([Reverse Shot](https://reverseshot.org/features/1927/desert_golfing)). Kotaku nennt den Fortschritt „torture" und fand auf Android keine Leaderboards ([Kotaku](https://kotaku.com/f-k-you-desert-golfing-aka-the-worst-best-game-in-th-1633266512)). Der Entwickler hätte bei absehbarer Spielerbindung spätere Löcher variabler gestaltet oder ein echtes Ende eingebaut ([Wikipedia](https://en.wikipedia.org/wiki/Desert_Golfing)). | Polarisierend, aber kultig. Die Permanenz ist zugleich Reiz und Frustquelle. |
| **Visuelle Besonderheiten** | Etwa drei Farben, keine Menüs und keine Anleitung; ein Farbverlauf (orange → lila → blau/grün) vermittelt Tag-Nacht- und Fortschrittsgefühl ([Reverse Shot](https://reverseshot.org/features/1927/desert_golfing)) | Fortschritt wird über **Umweltveränderung** statt über Zahlen kommuniziert. |
| **Steuerungsprinzip** | Ein-Finger-Swipe ([Wikipedia](https://en.wikipedia.org/wiki/Desert_Golfing)) | Touch-nativ, einhändig, ohne Tutorial verständlich. |
| **Monetarisierung** | Zum Launch 1,99 $ (iOS) bzw. 0,99 $ (Android) ([Kotaku, 2014](https://kotaku.com/f-k-you-desert-golfing-aka-the-worst-best-game-in-th-1633266512)) | Premium zum Kleinstpreis. |
| **Schwächen** | Permanente Fehler frustrieren; späte Löcher waren zeitweise unlösbar ([Kotaku](https://kotaku.com/f-k-you-desert-golfing-aka-the-worst-best-game-in-th-1633266512), [Wikipedia](https://en.wikipedia.org/wiki/Desert_Golfing)) | Kaum Zielstruktur für Spieler, die Belohnungen brauchen. |
| **Übertragbare Designprinzipien** | (Ableitung) | 1) Ein Verb, null UI. 2) **Persistenter Einzel-Run** statt Neustart-Schleife. 3) Prozedural mit menschlich gesetzten Constraints. 4) Fortschritt über subtile Umweltveränderung. |

#### 2.12 Hoplite
*Kategorie (c) · Mobile-Indie-Klassiker (mit Jam-Ursprung)*

| Feld | Belegte Fakten | Einschätzung |
|---|---|---|
| **Name** | Hoplite – Douglas Cowley / Magma Fortress ([App Store](https://apps.apple.com/us/app/hoplite/id782438457), [Magma Fortress](http://www.magmafortress.com/p/hoplite.html)) | – |
| **Plattform** | iOS, Android ([Magma Fortress](http://www.magmafortress.com/p/hoplite.html)) | – |
| **Veröffentlichungszeitraum** | Ursprünglich für die 7-Day-Roguelike-Challenge 2013 entwickelt (laut Entwickler dort Platz 4) ([Magma Fortress](http://www.magmafortress.com/p/hoplite.html)). iOS v1.0 am 21.12.2013, laufend gepflegt bis v2.8.65 am 22.10.2025 ([App Store](https://apps.apple.com/us/app/hoplite/id782438457)). Das genaue Android-Datum ist **nicht verifiziert**. | Seltener Fall: über zwölf Jahre gepflegt. |
| **Kernmechanik** | „turn-based strategy game focusing on tactical movement around small maps"; „movement based attacks" statt Bump-to-attack; Permadeath, prozedurale Level ([Magma Fortress](http://www.magmafortress.com/p/hoplite.html)). Deterministisch – Gegner reagieren vorhersehbar; Level „fitting on your screen"; Speerwurf, Schildstoß, Sprung, Schreine ([Pocket Gamer](https://www.pocketgamer.com/hoplite/review/)). „As you move from one tile to another, you Slash any enemy who's adjacent to both" ([Tom Francis](https://www.pentadact.com/?p=6934)). | **Bewegung = Angriff**: Jede Eingabe hat Doppelbedeutung. Deterministische, telegrafierte Gegner machen jeden Zug zum lösbaren Mikro-Puzzle. |
| **Typische Sessionlänge** | „superb lunch break strategy" ([Pocket Gamer](https://www.pocketgamer.com/hoplite/review/)) | **Schätzung:** Ein Run dauert 5–20 min, ein einzelner Zug Sekunden; über die Daily Challenge gibt es kurze Einstiege. |
| **Wiederspielwert** | Prozedurale Level; Challenge Mode mit Daily Challenge und vordefinierten Challenges in zwei Schwierigkeitsgraden ([App Store](https://apps.apple.com/us/app/hoplite/id782438457)) | Hoch für Taktik-Fans. |
| **Spielerfeedback** | Pocket Gamer 4,5/5: „the best roguelike I've played on mobile", aber „may lack a little longevity" ([Pocket Gamer](https://www.pocketgamer.com/hoplite/review/)). Tom Francis (Entwickler von Gunpoint) widmete der taktischen Eleganz einen Blogpost ([pentadact](https://www.pentadact.com/?p=6934)). App Store 4,7/5 (791 Ratings) ([App Store](https://apps.apple.com/us/app/hoplite/id782438457)). TapTap 8,9/10 (73 Ratings); Nutzer kritisieren, dass Tiefe über 16, Achievements, mehr Altar-Optionen und der Challenge Mode hinter einem einmaligen IAP liegen ([TapTap](https://www.taptap.io/app/24410)). | – |
| **Visuelle Besonderheiten** | Kleine, bildschirmfüllende Level ([Pocket Gamer](https://www.pocketgamer.com/hoplite/review/)) | (Nicht quellengeprüft) Schlichte Pixel-Art mit klarer Telegrafie der Gegnerabsichten. |
| **Steuerungsprinzip** | Zugbasiert; Bewegung löst Angriffe aus ([Magma Fortress](http://www.magmafortress.com/p/hoplite.html), [Tom Francis](https://www.pentadact.com/?p=6934)) | Tap auf das Zielfeld – touch-ideal, einhändig. |
| **Monetarisierung** | iOS 3,99 $ ([App Store](https://apps.apple.com/us/app/hoplite/id782438457)). Android: kostenlos mit einmaligem Premium-Kauf: „Venture deeper, earn achievements, unlock additional choices and access challenge mode" ([TapTap](https://www.taptap.io/app/24410)). | **Free + einmaliger Unlock** ist ein bewährtes, faires Free-Modell für Android. |
| **Schwächen** | Langzeitmotivation ([Pocket Gamer](https://www.pocketgamer.com/hoplite/review/)); wahrgenommene Paywall ([TapTap](https://www.taptap.io/app/24410)) | Generisches Fantasy-Thema. Die Grenze von Free zu Premium muss klar kommuniziert werden. |
| **Übertragbare Designprinzipien** | (Ableitung) | 1) **Bewegung als Angriff**. 2) **Deterministische, telegrafierte Gegner** → Fairness. 3) Bildschirmgroße Level = perfektes Phone-Format. 4) Daily Challenge als Kurz-Einstieg. |

---

## 3. Mechanik-Bausteine

Die interessantesten übertragbaren Bausteine aus der Recherche. Spalte „Touch-Gefühl" = **Einschätzung** von B2.

| # | Baustein | Belegt in | Wie es sich auf einem Touchscreen anfühlen könnte |
|---|---|---|---|
| 1 | **Zielen → Loslassen → Physik-Kaskade** | Holedown (2.10), BALL x PIT (2.2) | Drag-Ziellinie plus Loslassen ist eine der natürlichsten Touch-Gesten. Die Zuschauphase gibt dem Daumen Pause und erzeugt „Hoffen"-Spannung. |
| 2 | **Statik & Einsturz** (Stützen entfernen → Struktur fällt) | Holedown: Blöcke fallen, wenn Stützen zerstört sind (2.10) | Ein präziser Treffer löst eine sichtbare Kettenreaktion aus; auf kleinem Screen sehr befriedigend, wenn Haptik und Sound dosiert sind. |
| 3 | **Multiplikatives Scoring** (Basis × Multiplikator + Regelbrecher) | Balatro (2.1) | Eine große Zahl, die sich stufenweise aufbaut, wirkt auch auf 6 Zoll. Risiko: Modifikatortexte sind zu klein. |
| 4 | **Fusion/Evolution** zweier Elemente zu neuem Verhalten | BALL x PIT (2.2) | „A auf B ziehen" erklärt sich selbst; eine Entdeckungsliste (Sammel-Codex) zieht die Spieler zurück. |
| 5 | **Räumliches „1 aus 3"-Drafting** | Blue Prince (2.3); Dorfromantik zeigt die obersten 3 Kacheln (2.4) | Drei Karten in Daumenreichweite, per Drag ins Raster: eine Entscheidung in 2–5 s, ideal für Kurzsessions. |
| 6 | **Kantenabgleich + Quests + Stapel als Timer** | Dorfromantik (2.4) | Tap-to-rotate und Drag-to-place ohne Zeitdruck; einhändig im Hochformat denkbar, wenn das Raster klein bleibt. |
| 7 | **Nachbarschaftsboni beim Stapeln/Packen** | Draftula (2.9); als Packing-Referenz Cats Organized Neatly (Steam 10/2020, 80 Level, 97 % positiv bei 2.279 Reviews – [Steam](https://store.steampowered.com/app/1369340/)) | Snap-Raster mit **Live-Bonusvorschau beim Ziehen**; Polyomino-Drag ist auf Touch bewährt. Die Vorschau löst das Transparenzproblem aus dem Draftula-Feedback. |
| 8 | **Ressourcen-Timer + freiwilliger Ausstieg mit Beutesicherung** | Bore Blasters (2.5) | Ein großer „Jetzt raus!"-Button als Push-your-luck-Moment; passt zu 60–120 s pro Run. |
| 9 | **Spielfeldgrenze als Ressource** | Windowkill (2.7) | Ein Rand, der zuwächst, ist ein Lebensbalken ohne HUD; Taps oder Schüsse gegen den Rand lassen das Feld wieder „atmen". |
| 10 | **Welt dehnen/stauchen** | Stretchmancer (2.6) | Pinch/Spread ist die native Zwei-Finger-Geste. Risiko: Konflikt mit der gewohnten Zoom-Erwartung, daher klar als Spielaktion framen. |
| 11 | **Indirekte Steuerung** (Umgebung formen, Figur autonom) + selbstgewähltes Tempo-Risiko | „Panda" (2.8) | Ziehen = Plattform, Spreizen = skalieren; ein „Gott-Hand"-Gefühl. Ein Objektlimit (max. 2) hält das Bild lesbar. |
| 12 | **Rollentausch** (Spieler = Hindernis/Level eines bekannten Spiels) | Bricker Breaks Free, GMTK 2023 #2: Man spielt die Steine eines Arcade-Automaten ([itch.io](https://angry-armadillo-games.itch.io/bricker-breaks-free)); Pinball Pioneer, GMTK 2023 #7: Man baut den Kurs so, dass der Ball nicht ins Loch fällt ([itch.io](https://alexeckardt.itch.io/pinball-pioneer)) | Bekannte Regeln umzudrehen spart Tutorial; das Umstellen von Hindernissen in Echtzeit per Tap ist touch-freundlich. |
| 13 | **Bewegung = Angriff, deterministische Gegner** | Hoplite (2.12) | Tap auf das Nachbarfeld; jeder Zug ist ein lösbares Mikro-Rätsel – ideal für Unterbrechungen (U-Bahn, Warteschlange). |
| 14 | **Persistenter Einzel-Run ohne Reset** | Desert Golfing (2.11) | Ein Swipe pro Schlag: App öffnen, ein Loch spielen, schließen. Fortschritt zeigt sich als Farb- und Weltwandel. |
| 15 | **Loop-Automatisierung von Fähigkeiten** | Mycelium Mayhem, GMTK 2025 Creativity #1: Fähigkeiten laufen automatisch im Zyklus, der Spieler ordnet sie per Drag ([itch.io](https://ayayun.itch.io/myceliummayhem), [Ergebnisse](https://itch.io/jam/gmtk-2025/results/creativity)) | Planung per Drag statt Reflex: geringe Eingabelast und hohe Tiefe, gut für „zwischendurch". |
| 16 | **Hartes Aktionsbudget statt Uhr** | Holedown (Schüsse pro Level), Blue Prince (50 Schritte/Tag), Balatro (Hände und Abwürfe pro Blind) | Das Session-Ende ist planbar und nicht hektisch – passt direkt in einen 30-s–3-min-Rahmen. |

---

## 4. Mechaniken ohne überzeugendes Mobile-Spiel (Hypothesen)

> **Alle Punkte sind Hypothesen.** Die Suchen waren nicht erschöpfend: Google Play war technisch nicht auswertbar, und App-Store-Suchen erfolgten nur über Websuche. „Nicht gefunden" heißt also: nicht in unserer Suche aufgetaucht. Die Konfidenz bewertet die Stärke des Lückensignals, nicht das Marktpotenzial.

### H1 – Räumliches „1 aus 3"-Drafting als 2-Minuten-Puzzle (Blue-Prince-Prinzip)
- **Hypothese:** Ein kurzes Puzzle, in dem man aus drei Raum- oder Grundrisskarten wählt und damit einen Weg zum Ziel baut (mit Schrittbudget), hat auf Mobile kein starkes Pendant.
- **Indizien:** Blue Prince ist offiziell nicht auf Mobile ([Wikipedia](https://en.wikipedia.org/wiki/Blue_Prince_(video_game))). Laut [MacTech](https://www.mactech.com/2025/04/28/unapproved-ios-version-of-blue-prince-game-pops-up-on-the-apple-app-store/amp/) gibt es das Spiel nur auf Steam, Xbox und PlayStation, und Entwickler und Publisher warnten vor Fake-iOS-Versionen. Ein **inoffizieller iOS-Klon erreichte Platz 8** der App-Store-Kategorie Entertainment, bevor er entfernt wurde ([MacStories nach The Verge](https://www.macstories.net/linked/how-does-this-keep-happening/)) – ein Nachfragesignal. Unsere Suche nach Mobile-Spielen mit diesem Draft-Mechanismus ergab nur Treffer zu Blue Prince selbst.
- **Gegenindizien/Risiken:** Karten-Dungeon-Spiele auf Mobile wurden nicht systematisch geprüft. Die Stärke von Blue Prince liegt teils in der Story- und Rätselebene, die sich nicht in 2 min übertragen lässt.
- **Konfidenz:** mittel.

### H2 – Ruhiges Kantenlegen in Kurzpartien (Dorfromantik-Prinzip)
- **Hypothese:** Ein entspanntes Kachel-Legespiel mit Kantenabgleich und Quests, zugeschnitten auf 2–3-min-Partien im Hochformat, ist auf Mobile noch nicht überzeugend besetzt.
- **Indizien:** Toukana nennt als Antrieb für den ersten Mobile-Anlauf „der starken öffentlichen Nachfrage" und inoffizielle Mobile-Klone, die „täglich" in der Community auftauchten. Der erste eigene Mobile-Anlauf 2022 wurde gestoppt ([appgefahren](https://www.appgefahren.de/dorfromantik-beliebter-spiele-hit-kommt-auf-iphone-und-ipad-378717.html)). Die angekündigte „reimagined" Mobile-Version mit neuem, touch-optimiertem Spielfluss ([GamesMarket](https://www.gamesmarket.global/games-and-products/new-platforms-dorfromantik-comes-to-mobile-phones-and-more-consoles-with-the-help-of-clockstone-and-headup-04f6c37bb4b4e2c646fda3aa72551721)) ist bis 22.10.2026 nicht als veröffentlicht verifiziert ([Wikipedia](https://en.wikipedia.org/wiki/Dorfromantik): „under development").
- **Gegenindizien/Risiken:** Klone existieren laut Toukana bereits, die Lücke betrifft also eher die *Qualität* als die Existenz. Sobald das offizielle Mobile-Dorfromantik erscheint, schließt sich die Lücke weitgehend. Für uns wäre allenfalls eine *mechanisch andere* Variante sinnvoll.
- **Konfidenz:** mittel (die Lücke ist real, schließt sich aber wahrscheinlich).

### H3 – Spielfeldgrenze als Ressource (Windowkill-Prinzip)
- **Hypothese:** Ein Arcade-Spiel, in dem der sichtbare Spielraum schrumpft und der Spieler ihn durch seine Aktionen zurückdrängt, existiert auf Mobile nicht in überzeugender Form.
- **Indizien:** Windowkill ist ein Jam-Spiel (LD54-Jam #2), das zum Steam-Erfolg wurde (96 % positiv), läuft aber nur auf Windows und Linux ([Steam](https://store.steampowered.com/app/2726450/Windowkill/), [itch.io](https://torcado.itch.io/windowkill)). Die Mechanik hängt an Desktop-Fenstern. Die Suche nach einem Mobile-Pendant ergab keinen Treffer; das nächstliegende Gefundene ist *Shrinking Arena* (itch.io, Windows; Suchtreffer, nicht im Detail geprüft: [itch.io](https://jamesbbarrow.itch.io/shrinking-arena)).
- **Gegenindizien/Risiken:** Schrumpfende Zonen sind als Konzept bekannt (z. B. aus Battle Royales); neu wäre nur „Rand zurückschießen bzw. -drücken". Ohne echten Fensterbruch fehlt der Überraschungseffekt des Originals.
- **Konfidenz:** mittel bis niedrig.

### H4 – „Welt dehnen" per Pinch als Kernverb in 2D (Stretchmancer-Prinzip)
- **Hypothese:** Ein Spiel, dessen zentrales Verb das Strecken oder Stauchen der **Umgebung** per Zwei-Finger-Geste ist (Wege verlängern, Lücken schließen, Hindernisse quetschen), fehlt auf Mobile.
- **Indizien:** Stretchmancer gewann LD54 in Overall, Fun und Innovation ([itch.io](https://trianglewave.itch.io/stretchmancer)), die Vollversion ist nur für Windows für 2027 geplant ([Offbrand](https://offbrand.gg/stretchmancer)). Die Mobile-Suche fand nur kleinere Titel mit *Stück-* oder *Arm-*Dehnung (Squish Pop, Stretch Block Match, Stretch Robot – Suchtreffer, nicht im Detail geprüft: [Squish Pop](https://apps.apple.com/us/app/-/id6751881519), [Stretch Block Match](https://apps.apple.com/us/app/stretch-block-match/id6746163246), [Stretch Robot](https://apps.apple.com/app/id6473294292)), aber keinen, in dem das Dehnen der Welt der Kern ist.
- **Gegenindizien/Risiken:** Die Suche umfasste nur den App Store, nicht Google Play. Pinch ist als Zoom-Geste vorbelegt; die Mechanik braucht klares visuelles Framing.
- **Konfidenz:** mittel.

### H5 – Indirekte Echtzeit-Steuerung durch Plattform-Bau und -Skalierung (Panda-Prinzip)
- **Hypothese:** Ein Score-Arcade-Spiel, in dem eine autonome Figur läuft oder rollt und der Spieler nur wenige Plattformen setzen **und in der Größe verändern** darf (inkl. selbstgewähltem Tempo-Risiko), ist auf Mobile nicht prominent besetzt.
- **Indizien:** GMTK-2024-Gesamtsieger (4,689), nur als Windows-Download ([Ergebnisse](https://itch.io/jam/gmtk-2024/results), [itch.io](https://colisan.itch.io/that-time-i-got-reincarnated-as-a-panda-a-h-t-c-c-b-r-a-o-b-t-s-p)).
- **Gegenindizien/Risiken:** Mobile kennt viele „Linie zeichnen, Ball prallt ab"-Spiele (z. B. Rocket Ball – Endless Jump, Suchtreffer: [App Store](https://apps.apple.com/us/app/id1121158477)); neu wäre nur die Kombination aus Skalieren, Objektlimit und Tempo-Scoring. Die Jam-Platzierung ist umstritten und beruht auf nur 30 Ratings.
- **Konfidenz:** niedrig.

### H6 – Turmbau-Roguelite aus fallenden Raum-Teilen mit Nachbarschaftsboni (Draftula-Prinzip)
- **Hypothese:** Eine Kurzrun-Variante von „Teile stapeln + Nachbarschaftssynergien + Freischaltungen zwischen Runs" gibt es auf Mobile noch nicht in starker Form.
- **Indizien:** Draftula (GMTK-2025-Enjoyment #1) existiert nur im Browser bzw. auf Windows, die Steam-Version ist „To be announced" ([Steam](https://store.steampowered.com/app/4598280/Draftula/)). Unsere Suche fand keinen Mobile-Titel mit vertikalem Raum-Stapeln und Nachbarschaftsboni.
- **Gegenindizien/Risiken:** Block-Puzzle-Roguelites entstehen gerade, z. B. *Relic Rows* (laut Beschreibung „built first and foremost as a mobile game"; Suchtreffer, nicht im Detail geprüft: [itch.io](https://definereality.itch.io/relic-rows)). Die Nische füllt sich also. Block-Puzzles an sich sind auf Mobile extrem gesättigt.
- **Konfidenz:** niedrig bis mittel.

### H7 – Treibstoff-Extraktion in 60–120-s-Runs (Bore-Blasters-Prinzip)
- **Hypothese:** Ein kostenloses Kurzformat „graben, sammeln, rechtzeitig aussteigen" mit Ressourcen-Timer und Beutesicherung fehlt als *Free-Short-Session*-Titel.
- **Indizien:** Bore Blasters (Runs von wenigen Minuten bis 10–15 min) ist nur auf dem PC verfügbar ([Steam](https://store.steampowered.com/app/2398170/BORE_BLASTERS/), [PCGamesN](https://www.pcgamesn.com/bore-blasters/steam-launch)). Die Suche nach Mobile-Titeln mit diesem Loop fand nur PC-, Browser- und Konsolentitel (u. a. Depthwell, [itch.io](https://mrjakoblaich.itch.io/depthwell); Suchtreffer).
- **Gegenindizien/Risiken:** Der verwandte Titel *Dome Keeper* ist laut iXBT seit Oktober 2026 auf iOS/Android erhältlich (Premium, ohne Testversion) ([iXBT](https://ixbt.games/en/news/2026/10/12/saxtery-prokopali-put-k-smartfonam-zalipatelnyi-rogalik-dome-keeper-vysel-na-ios-i-android.html)). Mining- und Idle-Spiele sind auf Mobile verbreitet (nicht systematisch geprüft).
- **Konfidenz:** niedrig.

---

## 5. Gegenproben: bereits gut abgedeckte Mechaniken

Diese Mechaniken sind auf Mobile bereits stark vertreten – als Lücke ungeeignet, aber als Qualitätsmaßstab nützlich.

| Mechanik | Mobile-Beleg |
|---|---|
| Multiplikatives Poker-Scoring (Roguelite) | Balatro seit 26.09.2024 auf Android/iOS ([Wikipedia](https://en.wikipedia.org/wiki/Balatro)) |
| Breakout + Ball-Fusion + Basisbau | BALL x PIT seit 12.03.2026 auf iOS/Android, Free-to-try ([Gematsu](https://www.gematsu.com/2026/03/ball-x-pit-now-available-for-ios-android)) |
| Insel-Platzierung mit Punktvorschau | ISLANDERS: Mobile (Coatsink), App-Store-Version 1.0 vom 09.11.2025, 4,99 $, ohne Mikrotransaktionen ([App Store](https://apps.apple.com/app/id6745312000)) |
| Graben + Verteidigen | Dome Keeper laut iXBT seit 10/2026 auf iOS/Android ([iXBT](https://ixbt.games/en/news/2026/10/12/saxtery-prokopali-put-k-smartfonam-zalipatelnyi-rogalik-dome-keeper-vysel-na-ios-i-android.html)) |
| Zielen und Abprallen mit Graben | Holedown (Mobile-nativ seit 2018) |
| Ein-Swipe-Physikgolf, endlos | Desert Golfing (2014) und Golf on Mars (2020) |
| Deterministische Mini-Taktik | Hoplite (seit 2013, laufend gepflegt) |

**Muster (Einschätzung):** Erfolgreiche PC-Indies kommen zunehmend als **Premium-Ports** (oft mit Free-Trial) auf Mobile. Unsere Chance liegt daher weniger im „Port-Gap" als in einer **neuen, touch-nativen Mechanik in Free-Kurzsessions**.

---

## 6. Kurzfazit für das Konzept-Team (Einschätzung)

1. **Die stärksten Touch-Verben aus der Recherche:** Zielen–Loslassen (Holedown), Pinch-Dehnen (Stretchmancer), Drag-to-Zone und Drag-to-Grid (Balatro mobil, Blue Prince, Draftula) sowie Tap-Bewegung als Angriff (Hoplite). Alle sind einhändig oder mit wenigen Fingern bedienbar und ohne Text verständlich.
2. **Besonders vielversprechende, auf Mobile kaum besetzte Kombinationen** (zur Bewertung durch das Konzept-Team):
   - **Arena-Rand als Ressource + Pinch-Dehnen** (H3 + H4): Das Spielfeld schrumpft, der Spieler dehnt es mit zwei Fingern zurück – aber jede Dehnung verändert Wege und Gefahren.
   - **„1 aus 3"-Raum-Drafting mit Schrittbudget + Nachbarschaftsboni** (H1 + H6) in 90-Sekunden-Puzzles mit Daily Seed.
   - **Indirekte Steuerung + Statik-Kettenreaktionen** (H5 + Baustein 2): Man formt die Umgebung, eine autonome Figur oder Kugel löst Einstürze aus.
3. **Lehren aus den Schwächen:** keine Glücksspiel-Optik (Balatro/PEGI); RNG abfedern (Blue Prince); kein Grind als Fortschrittsersatz (BALL x PIT); Regeltransparenz durch Live-Vorschau (Draftula); Screenshake abschaltbar (Holedown, Draftula); Session-Ende über ein **Aktionsbudget** statt einer Uhr (Holedown, Blue Prince, Balatro).
4. **Monetarisierung:** Der faire Weg für ein Free-Android-Spiel mit Premium-Kern ist durch Hoplite (Android: free + einmaliger Premium-Unlock) und BALL x PIT mobil (free-to-try + Einmalkauf) belegt.
