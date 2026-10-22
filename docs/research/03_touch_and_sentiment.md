# Recherche 03: Touch-/Multitouch-Interaktion & Spielerstimmung

*Agent B3 (Touch Interaction & Player Sentiment Researcher) · Stand: 22.10.2026*
*Kontext: originelles, kostenloses Android-Casual-Game für sehr kurze Sessions (30 s bis 3 min), Touch-first, sinnvolles Multitouch ist Pflicht.*

---

## 0. Kurzfazit

- **Die stärksten Multitouch-Vorbilder für Kurz-Sessions arbeiten mit zwei großen Bildschirmhälften statt mit Buttons:** *2 Cars* (jede Hälfte steuert ein eigenes Objekt), *Data Wing* (links/rechts lenken, beide halten = bremsen), *Duet* und *Super Hexagon* (halten = drehen). Dazu kommt *Hundreds*: Hier hält jeder Finger etwas aktiv. Bei 2 Cars entsteht die Schwierigkeit aus geteilter Aufmerksamkeit, nicht aus Treffgenauigkeit.
- **Übernutzt** sind Tap/Timing (laut einer Hyper-Casual-Analyse „the most popular form of mechanics“), Wisch-Spurwechsel, Swerve-Drag, Schleuder-Zielen und virtuelle Joysticks. **Kaum genutzt** werden zwei unabhängige Daumen, „Akkorde“ (beide Zonen gleichzeitig = dritte Aktion), Mehrfinger-Halten, Pinch/Spread als eigentliche Spielhandlung, Zwei-Finger-Rotation sowie die Kombination aus Neigen und Touch.
- **Harte Android-Grenzen:** Die Zurück-Geste liegt am linken und rechten Rand. Die Home-Geste unten lässt sich nicht abschalten, nur über den Immersive Mode umgehen. Ausnahmebereiche für Gesten sind auf **200 dp vertikal** begrenzt. Fehlberührungen durch die Handfläche erkennt Android erst ab **Android 13** zuverlässig. Zwei unabhängig verfolgte Finger lassen sich voraussetzen, fünf und mehr nicht.
- **Spielerstimmung (wiederkehrende Themen):** (1) Störende, zu häufige oder trickreiche Werbung führt zum Abbruch. (2) Irreführende Werbung („Fake Ads“) zerstört Vertrauen. (3) Freiwillige Werbung mit Belohnung (Rewarded Ads) wird akzeptiert. (4) Energie- und Leben-Systeme gelten als Flow-Killer. (5) Gesucht wird ein „fairer Deal“, also Einmalkauf, Freischaltung oder Abo-Katalog. (6) Gelobt wird, was sich jederzeit pausieren lässt, offline läuft und keine Pflicht-Dailies hat.
- **Einschränkung:** Reddit war in dieser Sitzung **nicht abrufbar** (Details in Abschnitt 1). Die Stimmungsbefunde stützen sich deshalb auf Tildes, Hacker News, die Apple Community, Reddit-Aggregatordaten (GummySearch), Fachpresse und Branchenstudien.

---

## 1. Methodik, Quellenlage, Kennzeichnung

**Kennzeichnung in diesem Dokument**
- **[B] Belegt:** Ich habe die Quelle geöffnet und gelesen, die URL ist angegeben.
- **[S] Nur Suchergebnis:** Die Aussage stammt aus einem Suchergebnis-Snippet. Die Seite selbst war blockiert oder wurde nicht geöffnet, deshalb mit Vorsicht behandeln.
- **[A] Anekdotisch:** Einzelstimme (Forenbeitrag, Nutzerbewertung, einzelne Rezension).
- **[E] Einschätzung:** Eigene Analyse ohne direkte Quelle.

**Nicht abrufbar**
- **Reddit:** WebFetch auf `reddit.com` und `old.reddit.com` wurde verweigert („unable to fetch“). WebSearch mit Domainfilter `reddit.com` wurde abgelehnt („domains are not accessible to our user agent“). Allgemeine Suchen nach r/AndroidGaming, r/iosgaming, r/gamedesign und Ähnlichem lieferten keine reddit.com-Treffer. Reddit-Spiegelseiten habe ich bewusst nicht genutzt, um die Sperre nicht zu umgehen.
- **HTTP 403:** toucharcade.com (Artikel und Forum), forums.macrumors.com, androidauthority.com, darkpattern.games, emarketer.com, mi.com.
- **Google-Play-Seiten:** Der Inhalt kam nur abgeschnitten an. Aktuelle Play-Preise und Werbemodelle sind deshalb meist **nicht** verifiziert.

**Ersatzquellen:** Tildes, Hacker News (vier Threads gelesen), Apple Support Community, GummySearch (Reddit-Statistiken als Indiz), Fachpresse (Pocket Gamer, Android Police, Macworld, Engadget u. a.), Branchenstudien (Unity, Tapjoy, Nexters, AppHarbr, Deloitte, GameAnalytics, AppsFlyer), Google-Play-Richtlinien, Android-Entwicklerdokumentation, Forschung (Hoober, Teather et al.).

**Zeitlicher Vorbehalt:** Viele Kritiken stammen aus dem Launch-Zeitraum (2010–2018). Preise, Werbung und Verfügbarkeit können sich seither geändert haben.

**Korrekturen durch Verifikation** (Beispiele, warum nichts aus dem Gedächtnis übernommen wurde):
- Die Kumobius-Aussage, Tilt sei „nicht präzise genug“, betrifft laut Suchergebnis *Bean's Quest / Bean Dreams*, **nicht** *Duet* [S].
- Die Minispiel-Sammlung „YEAH! YOU WANT 'THOSE GAMES,' RIGHT? …“ stammt laut Suchergebnissen von **D3Publisher**, nicht von Square Enix [S].

---

## 2. Teil A: Spiele mit bemerkenswerter Touch-/Multitouch-Eingabe

### 2.1 Übersicht

Die Spalte „Relevanz für uns“ ist eine Einschätzung [E]. „Touchpunkte“ meint gleichzeitig genutzte Finger pro Gerät.

| # | Spiel (Erstrelease) | Android? | Eingabeprinzip | Touchpunkte | Einhändig? [E] | Relevanz [E] |
|---|---|---|---|---|---|---|
| 1 | Duet (2013) | ja | Linke/rechte Hälfte halten = Drehung gegen/im Uhrzeigersinn | 1 aktiv (beide gleichzeitig: nicht dokumentiert) | bedingt | ★★★ |
| 2 | 2 Cars (2014) | ja | Jede Hälfte steuert ein eigenes Auto (Tap = Spurwechsel) | 2 unabhängig | nein | ★★★ |
| 3 | Data Wing (2017) | ja | Links/rechts halten = lenken, beide halten = bremsen | 2 („Akkord“) | nein | ★★★ |
| 4 | Super Hexagon (2012) | ja | Linke/rechte Hälfte halten = drehen | 1 | bedingt | ★★ |
| 5 | Hundreds (2013) | ja (06/2013) | Kreis halten = wachsen; verknüpfte Kreise gleichzeitig halten | ≥ 2 | nein | ★★★ |
| 6 | Fruit Ninja (2010) | ja | Wischen = schneiden, mehrere Finger gleichzeitig möglich | mehrere | ja | ★★ |
| 7 | Badland (2013) | ja | Halten = steigen; Multiplayer: eine Bildschirmzone pro Person | bis 4 (Multiplayer) | ja (solo) | ★★ |
| 8 | Spaceteam (2012) | ja | Eigenes Bedienpanel pro Gerät, dazu Schütteln/Umdrehen | mehrere Geräte | – | ★★ |
| 9 | DUAL! (2015) | ja | Zwei Telefone bilden ein Spielfeld; Neigen, Halten (Laden), Wischen | mehrere Geräte | – | ★★ |
| 10 | Tiny Wings (2011) | **nein** (iOS) | Halten = abtauchen, Loslassen = abheben | 1 | ja | ★★ |
| 11 | Alto's Odyssey (2018) | ja | Tippen = Sprung, Halten = Trick/Wallride | 1 | ja | ★ |
| 12 | Holedown (2018) | ja | Ziehen = zielen, Anheben = feuern | 1 | ja | ★★ |
| 13 | Desert Golfing (2014) | ja | Irgendwo berühren, zurückziehen (Schleuder), loslassen | 1 | ja | ★★ |
| 14 | Mini Metro (mobil 2016) | ja | Linien ziehen (Pfad), Pinch = Zoom | 1–2 | ja | ★★ |
| 15 | Ridiculous Fishing (2013) | ja | Neigen (Haken), Tippen bzw. 1–2 Finger halten (Dauerfeuer) | 1–2 + Neigung | bedingt | ★★ |
| 16 | Two Dots (2014) | ja | Gleichfarbige Punkte verbinden, Quadrat schließen | 1 | ja | ★ |

---

### 2.2 Detailprofile

> Jedes Profil trennt **Belegte Fakten** (mit Quelle) von der **Einschätzung**. Felder ohne Beleg stehen ausdrücklich als „Schätzung“ bzw. [E] da.

#### 2.2.1 Duet (Kumobius)

**Belegte Fakten**
- **Plattform / Zeitraum:** iOS, Android, Linux, OS X, Windows. Infobox-Datum 10.10.2013; Android zuerst im *Humble Mobile Bundle 6* [B] ([Wikipedia](https://en.wikipedia.org/wiki/Duet_(video_game))).
- **Kernmechanik:** Man dreht eine Kreisbahn mit zwei farbigen Kugeln um Hindernisse herum. Trifft eine Kugel ein Hindernis, startet das Level neu; beide Kugeln müssen heil bleiben [B] ([Wikipedia](https://en.wikipedia.org/wiki/Duet_(video_game))).
- **Steuerungsprinzip:** Rechte Bildschirmseite = im Uhrzeigersinn, linke = gegen den Uhrzeigersinn. Die Drehung läuft, solange man hält, und stoppt „on a dime the instant you release“ [B] ([Android Police 2014](https://www.androidpolice.com/2014/08/11/duet-review-i-love-to-hate-this-game)). Store-Text: „Touch either side of the screen to twist your vessels“ [B] ([App Store](https://apps.apple.com/app/duet-game/id634235735)). Gespielt wird beidhändig oder einhändig, es zählt immer nur eine Seite. Was beim gleichzeitigen Halten beider Seiten passiert, steht in keiner geöffneten Quelle.
- **Typische Sessionlänge:** Ein Level „lasts no more than a couple of seconds“ [B] ([Pocket Gamer 2013](https://www.pocketgamer.com/articles/054390/r/)) bzw. „only 20 seconds or so“ [B] ([Android Police](https://www.androidpolice.com/2014/08/11/duet-review-i-love-to-hate-this-game)). Es gibt 50 Level und einen Endlosmodus [B] (Pocket Gamer).
- **Spielerfeedback:**
  - Metacritic 79 (Stand Aug. 2014). Kritiker loben Steuerung und Design, kritisieren aber die „notorious difficulty“ [B] (Wikipedia).
  - Pocket Gamer: „starts cruelly and ends up punching you over and over in the face“ [B].
  - Android Police: „brutally difficult“, aber „amazingly entertaining“ [B].
  - Kotaku „Mobile Game of the Year 2013“; mehr als 20 Mio. Downloads [B] (Wikipedia).
  - App Store aktuell 4,9 aus 2,1 Tsd. Bewertungen; ein Nutzerreview von 2022 lobt die Werbefreiheit der iOS-Version [B/A] ([App Store](https://apps.apple.com/app/duet-game/id634235735)).
- **Monetarisierung:**
  - iOS-Launch £2,99 / $4,99 [B] (Pocket Gamer 2013); heute iOS $2,99 plus zwei Kapitel-IAPs à $0,99 [B] (App Store).
  - Android 2014: kostenlos testbar, $3-IAP für alles jenseits des Story-Modus, „un-skippable video ads every now and then“, die nach dem Kauf verschwinden [B] (Android Police).
  - Aktuelles Play-Modell laut Snippet: Werbung zwischen den Runden, Premium per Einmalkauf [S].
- **Visuelles / Audio:** Der Soundtrack von Tim Shiel wird mehrfach hervorgehoben [B] (Wikipedia, Android Police).
- **Schwächen:** Sehr hohe Schwierigkeit; „splat“-Sound als Fehlerfeedback wird als nervig empfunden [B] (Android Police); nach einer einzigen Kollision geht es zurück an den Levelanfang [S] (Game Revolution).

**Einschätzung [E]**
- **Visuell:** Minimalistisch, zwei Farben, hoher Kontrast; die Lesbarkeit im Bruchteil einer Sekunde steht im Vordergrund.
- **Wiederspielwert:** Hoch durch sekundenkurze Level und den Endlosmodus, aber mit Frustgrenze.
- **Übertragbare Designprinzipien:**
  - Zwei riesige Touch-Zonen statt Buttons erlauben „blindes“ Spielen ohne Zielen.
  - „Halten = kontinuierliche Bewegung, Loslassen = sofortiger Stopp“ macht analoge Präzision mit binärer Eingabe möglich.
  - Mikro-Level von 5–20 s passen exakt zu 30-s-Sessions.
  - Warnsignal: Zwangsvideos und harter Reset erzeugen Ablehnung.

#### 2.2.2 2 Cars (Ketchapp)

**Belegte Fakten**
- **Plattform / Zeitraum:** iOS und Android, Ketchapp, Ende 2014. Leserkommentare bei iphones.ru stammen vom 29./30.11.2014 [B] ([iphones.ru](https://www.iphones.ru/iNotes/391092)); französischer Bericht vom 01.12.2014 [S] ([iphonesoft.fr](https://iphonesoft.fr/2014/12/01/2-cars-nouveau-jeu-course-arcade-createur-2048)).
- **Kernmechanik:** Ein rotes Auto (links) und ein blaues Auto (rechts) fahren auf je zwei Spuren. Kreise einsammeln, Quadrate meiden [B] (iphones.ru) [S] (iphonesoft.fr).
- **Steuerungsprinzip:** Ein Tipp links lässt das rote Auto die Spur wechseln, ein Tipp rechts das blaue [B] (iphones.ru). Gespielt wird mit zwei Daumen und zwei unabhängigen Touch-Zonen.
- **Spielerfeedback:**
  - iphones.ru nennt es eine „вполне добротная бесконечная аркада“ (solide Endlos-Arcade), lobt die Musik und findet die Grafik „простовата“ (schlicht, aber klar) [B].
  - Der Blick wandert zum jeweils anderen Auto, und genau das führt zum Game Over [B].
  - Windows Central (Windows-Phone-Version): macht in kurzen Schüben süchtig, taugt aber kaum für Marathon-Sessions [S] ([Windows Central](https://www.windowscentral.com/2-cars-windows-phone-game-review)).
- **Monetarisierung:** Kostenlos mit gelegentlich „nervenden“ Pop-up-Anzeigen; Werbefreiheit per IAP (69 Rubel) [B] (iphones.ru).
- **Typische Sessionlänge:** nicht belegt.

**Einschätzung [E]**
- **Sessionlänge (Schätzung):** 10–60 s pro Lauf.
- **Wiederspielwert:** Rein Highscore-getrieben, eher kurzlebig.
- **Visuell:** Flach, klare Farbcodierung je Hälfte (rot/blau).
- **Übertragbare Designprinzipien:**
  - Echte Zwei-Daumen-Unabhängigkeit („Gehirn-Split“) ist eine der stärksten Multitouch-Ideen für kurze Sessions.
  - Robust wird sie durch diskrete Aktionen (Tap = Spurwechsel) statt analoger Steuerung.
  - Die Hauptschwierigkeit ist die Aufmerksamkeitsteilung. Beide Fokuspunkte sollten nahe der Bildschirmmitte liegen, wo Blick und Touch am sichersten sind (vgl. Hoober, Abschnitt 3.1).

#### 2.2.3 Data Wing (Dan Vogt)

**Belegte Fakten**
- **Plattform / Zeitraum:** iOS und Android [S] ([Pocket Gamer](https://www.pocketgamer.co.uk/data-wing/data-wing-is-a-minimalist-arcade-racer-out-now-for-ios-and-android/)). Älteste App-Store-Version 1.0.3 vom 16.08.2017 [B] ([App Store](https://apps.apple.com/us/app/-/id1206723870)).
- **Kernmechanik:** Minimalistischer Top-down-Racer. Das Dreiecksschiff hat Trägheit, und wer Streckenkanten streift, bekommt einen kleinen Speed-Boost [B] ([Gamezebo](https://www.gamezebo.com/the-best/data-wing-review-sheer-delight/)). „A +2 hour story“, „over 40 levels“ [B] (App Store).
- **Steuerungsprinzip:** Linke Seite berühren = links lenken, rechte = rechts; beide Seiten halten = bremsen [B] (Gamezebo). Store: „Intuitive two-touch controls with an arcade feel“ [B]. Also zwei Daumen, bis zu zwei gleichzeitige Touchpunkte, und der „Akkord“ aus beiden ist eine dritte Aktion.
- **Spielerfeedback:**
  - Gamezebo 90/100: „It takes a little time to get used to, and then it clicks and it's wonderful“. Kritik: manche Ziele sind „quite tightly timed“ [B].
  - App Store 4,9 aus 24 Tsd. Bewertungen [B].
  - Ein App-Store-Nutzer fand die Steuerung „finicky“ [S/A].
- **Monetarisierung:** Komplett kostenlos, ohne Werbung und ohne IAP. Gamezebo: „I don't mean free as in ad-supported either“ [B]; ebenso Pocket Gamer [S].
- **Visuelles:** „a minimalist top down racing game“, „a wonderfully stylish and pure experience“ [B] (Gamezebo).

**Einschätzung [E]**
- **Sessionlänge (Schätzung):** 30–120 s pro Level.
- **Wiederspielwert:** Mittel. Story und Zusatzziele binden, danach ist der Inhalt erschöpft.
- **Übertragbare Designprinzipien:**
  - Das Zwei-Zonen-Schema lässt sich ohne zusätzliche Buttons um eine dritte Aktion erweitern: **beide gleichzeitig = Spezialaktion**.
  - Trägheit verlangt Vorausplanen statt reiner Reflexe und holt so mehr Tiefe aus minimaler Eingabe.
  - „Wände streifen = Bonus“ belohnt riskantes Spiel.

#### 2.2.4 Super Hexagon (Terry Cavanagh)

**Belegte Fakten**
- **Plattform / Zeitraum:** iOS 06.09.2012, Android 19.01.2013, PC/Mac 27.11.2012; Musik von Chipzel [B] ([Wikipedia](https://en.wikipedia.org/wiki/Super_Hexagon)). Ein Android-Update 2021 behob Defekte unter Android 11/12 [S] ([Android Police](https://www.androidpolice.com/indie-gaming-classic-super-hexagon-is-back-and-better-than-ever/)).
- **Kernmechanik:** Ein Dreieck wird um ein zentrales Sechseck in Öffnungen gedreht [B] (Wikipedia).
- **Steuerungsprinzip:** Linke Hälfte berühren = nach links, rechte = nach rechts; Wandkontakt bedeutet sofortigen Tod. „When you lift off your thumbs the triangle tends to overshoot your intended point“ [B] ([DroidGamers 2013](https://www.droidgamers.com/reviews/super-hexagon-review-a-devilishly-hard-game-that-s-not-meant-for-the-faint-hearted/)).
- **Typische Sessionlänge:** Ein Level gilt nach etwa 60 s Überleben als geschafft, Läufe dauern meist Sekunden, und der Neustart erfolgt sofort [B] (DroidGamers). Wer länger als 60 s überlebt, schaltet Hyper-Varianten frei [B] (Wikipedia).
- **Spielerfeedback:**
  - Metacritic 86 (iOS) / 88 (PC); TouchArcade 4,5/5; Runner-up beim App-Store-„Game of the Year“ 2012 [B] (Wikipedia).
  - DroidGamers 4,5/5, „a masterpiece“. Kritik: gelegentliche Framedrops unter Android, unerbittliches Timing [B].
  - In einem Tildes-Thread 2025 als Spiel für kurze Sessions empfohlen [A] ([Tildes](https://tildes.net/~games/1of0/favorite_mobile_games_for_short_play_sessions)).
- **Monetarisierung:** Premium. Android-Launch für $0,99 (Sale) [B] (DroidGamers); 2021 laut Snippet 2,99 € [S].

**Einschätzung [E]**
- **Visuell:** Rotierendes, pulsierendes Spielfeld mit starkem Musik-Bezug (allgemeine Kenntnis, nicht quellengeprüft).
- **Wiederspielwert:** Sehr hoch („one more time“). Sofortiger Neustart plus 60-s-Ziel bilden die ideale Kurzsession-Schleife.
- **Übertragbare Designprinzipien:**
  - Ein klares Zeitziel (60 s) als Session-Rahmen.
  - Neustart ohne Menü.
  - Das „Overshoot beim Loslassen“-Problem gehört in die Eingabelogik: Einrasten auf Positionen bzw. Hysterese gegen Touch-Latenz beim Loslassen.

#### 2.2.5 Hundreds (Semi Secret Software & Greg Wohlwend)

**Belegte Fakten**
- **Plattform / Zeitraum:** iOS 07.01.2013, Android 28.06.2013 [B] ([Wikipedia](https://en.wikipedia.org/wiki/Hundreds_(video_game))).
- **Kernmechanik:** Berührte Kreise wachsen und ihre Zahl steigt, berühren dürfen sie sich nicht. Ergibt die Summe 100, ist das Level geschafft. 100 Level; verknüpfte Kreise müssen gleichzeitig gehalten werden; Kreissägen setzen zurück, Schneeflocken frieren ein [B] (Wikipedia).
- **Steuerungsprinzip:** Halten lässt einen Kreis rot werden und wachsen, Loslassen macht ihn wieder sicher. „Some levels require you to tap on two circles at the same time“ [B] ([Macworld](https://www.macworld.com/article/220786/review-hundreds-for-ios-is-a-maddening-challenge-of-a-puzzler-game.html)). Gamasutra hebt die „restrained but impactful use of multitouch“ hervor; das Spiel „can respond to two inputs at once“ [B] ([Game Developer 2013](https://gamedeveloper.com/design/why-they-re-playing-i-hundreds-i-)). Je nach Level ein Finger oder mehrere.
- **Spielerfeedback:**
  - Metacritic 85 [B] (Wikipedia).
  - Game Informer 8/10: „one of the stronger examples of a mobile title making great use of a touchscreen device“. Kritik: „bumping into circles that your hand is blocking is a problem“; verschwindende Kreise seien „a massive pain“ [B] ([Game Informer](https://gameinformer.com/games/hundreds/b/ios/archive/2013/01/08/hundreds-review.aspx)).
  - Macworld: „difficult but never approaching fun“; das Menü hat nicht einmal einen Play-Button [B].
  - GamesRadar: auf dem iPhone schwerer zu spielen als auf dem iPad [S].
- **Monetarisierung:** Premium. iOS in der ersten Woche $2,99, danach $4,99; eine F2P-Version wurde erwogen und verworfen; über 100.000 Verkäufe (Jan. 2013) [B] ([PocketGamer.biz](http://www.pocketgamer.biz/gaming-by-numbers-the-making-of-hundreds/)). Android $3,14 [S] (Game Informer News).
- **Visuelles:** „handsomely austere“ (*Edge*, zitiert bei Wikipedia) [B].

**Einschätzung [E]**
- **Sessionlänge (Schätzung):** 10 s bis 2 min pro Rätsel.
- **Wiederspielwert:** Mittel, weil die Rätsel nach dem Lösen „verbraucht“ sind. Einen Endlosmodus gibt es nach Level 100 [B].
- **Übertragbare Designprinzipien:**
  - Multitouch als **Ressource** (jeder Finger hält einen Zustand aktiv) statt als Geste.
  - Die eigene Hand verdeckt Spielobjekte (Okklusion), auf Phones noch stärker. Deshalb Objekte groß, Gefahren nicht unterhalb des haltenden Daumens platzieren und als Basis höchstens zwei gleichzeitige Finger vorsehen.

#### 2.2.6 Fruit Ninja (Halfbrick)

**Belegte Fakten**
- **Plattform / Zeitraum:** iOS 20.04.2010, Android 13.05.2010, danach viele weitere Plattformen [B] ([Wikipedia](https://en.wikipedia.org/wiki/Fruit_Ninja)).
- **Kernmechanik / Steuerung:** Geworfenes Obst wird per Wischen zerschnitten, Bomben sind zu meiden. „Multiple fingers can slice simultaneously“; mehrere Früchte in einem Wisch ergeben eine Combo [B] (Wikipedia).
- **Typische Sessionlänge:**
  - Zen-Modus: 90 s ohne Bomben [B] (Wikipedia, [Pocket Gamer 2010](https://www.pocketgamer.com/fruit-ninja/review/)).
  - Classic: bis zu drei Fehlern bzw. einer Bombe [B].
  - Arcade: 60 s laut mehreren Rezensions-Snippets [S].
- **Spielerfeedback:**
  - Metacritic 75 (iOS); IGN 8,5 („an instantly pleasurable experience“). Kritik: zufällige Bonusobjekte erschweren Highscores; Wunsch nach steilerer Schwierigkeit [B] (Wikipedia).
  - Pocket Gamer 4/5: „sheer tactile joy“, aber „There's no great depth to Fruit Ninja“ [B].
  - 1 Mrd. Downloads bis 2015 [B] (Wikipedia).
- **Monetarisierung:**
  - Anfangs kostenpflichtig, mit Lite-Demos; Ingame-Währung (Starfruit) [B] (Wikipedia).
  - Heute F2P mit IAP inkl. „Remove Popup Ads“ für $1,99 [S] (App-Store-Snippet).
  - Abo „Halfbrick+“ ohne Werbung und IAP [S].
- **Visuelles:** „finely modelled fruit“; das Schneiden „feels so good“ [B] (Pocket Gamer).

**Einschätzung [E]**
- **Wiederspielwert:** Hoch durch Highscore und kurze, klar begrenzte Runden.
- **Übertragbare Designprinzipien:**
  - Die Geste ist eine **physische Metapher** (Wischen = Schneiden) mit sattem Feedback (Saft, Partikel, Sound).
  - Multitouch als **optionale Skill-Decke** statt Pflicht.
  - Zeitlich fixe Modi (60–90 s) als Blaupause für unsere Sessionlänge.

#### 2.2.7 Badland (Frogmind)

**Belegte Fakten**
- **Plattform / Zeitraum:** iOS 04.04.2013, Android 29.11.2013 [B] ([Wikipedia](https://en.wikipedia.org/wiki/Badland_(video_game))).
- **Steuerungsprinzip (solo):** Halten lässt die Figur steigen, Loslassen sinken [B] ([Macworld 2013](https://www.macworld.com/article/220780/review-badland-for-ios-is-nonstop-side-scrolling-fun.html)).
- **Steuerungsprinzip (Multiplayer auf einem Gerät):**
  - Koop-/Versus-Modus für bis zu vier Personen an einem Gerät, per Touch oder Controller.
  - „each person gets a section of the screen to tap in order to control their color“ [B].
  - „While you can play on a phone, this user experience makes more sense on a tablet“ [B] ([Android Police 2014](https://www.androidpolice.com/2014/06/12/badland-gets-an-update-with-four-player-co-op-mode-on-a-single-device/)).
- **Spielerfeedback:** Metacritic 85 (iOS) und Apples „iPad Game of the Year“ 2013 [B] (Wikipedia); Macworld: „a tightly executed affair“ [B].
- **Monetarisierung:** 2013 als „$4“-App [B] (Macworld). Unter Android 2014 gab es die Vollversion per IAP [B] (Android Police), dazu optionale Levelpakete per IAP [B] (Wikipedia).

**Einschätzung [E]**
- **Sessionlänge (Schätzung):** 1–3 min pro Level.
- **Übertragbare Designprinzipien:**
  - Eine Bildschirmzone pro Person macht Multitouch sozial.
  - Auf Phones im Hochformat realistisch höchstens zwei Personen (oben/unten), weil Phones dafür zu klein sind (siehe Android-Police-Zitat).
  - Für unser Spiel: optionaler „Zwei-Spieler-auf-einem-Handy“-Modus als Bonus.

#### 2.2.8 Spaceteam (Henry Smith / Sleeping Beast Games)

**Belegte Fakten**
- **Plattform / Zeitraum:** iOS und Android 01.12.2012, Apple TV 2015 [B] ([Wikipedia](https://en.wikipedia.org/wiki/Spaceteam)).
- **Kernmechanik / Steuerung:**
  - 2–8 Personen, jede mit eigenem Gerät. Jede hat ein eigenes Bedienpanel mit „Technobabble“-Beschriftung.
  - Befehle werden laut ausgerufen und müssen ausgeführt werden, bevor der Timer abläuft.
  - Wurmloch = Gerät umdrehen, Asteroiden = Gerät schütteln [B] (Wikipedia).
  - Die Panels enthalten Kippschalter, Knöpfe, Drehregler und Wahlschalter [B] ([Common Sense Media](https://www.commonsensemedia.org/app-reviews/spaceteam)).
- **Spielerfeedback:**
  - Metacritic 91, TouchArcade 5/5, mehr als 3 Mio. Downloads (Nov. 2015), IndieCade Interaction Award [B] (Wikipedia).
  - Common Sense Media: „family-friendly, chaotic, silly fun“. Kritik: kein Tutorial (z. B. zum Umdrehen), für manche zu stressig, laut [B].
  - Henry Smith: „you can't play it on the bus“ [B] ([Cult MTL](https://cultmtl.com/2012/12/where-no-iphone-game-has-gone-before/)).
- **Monetarisierung:** Kostenlos mit IAP (Modi, Challenges, Kosmetik) [B] (Wikipedia, Common Sense).
- **Typische Sessionlänge:** Für die App nicht belegt. Das Kartenspiel-Spin-off gibt 5 Minuten an [B] (Wikipedia).

**Einschätzung [E]**
- **Sessionlänge (Schätzung):** 2–5 min pro Partie.
- **Übertragbare Designprinzipien:**
  - **Physische Gesten (Schütteln, Umdrehen) als seltene Ereignisse**, die die Routine brechen.
  - Informationsasymmetrie erzeugt Kommunikation.
  - Für Solo-Toilettensessions ungeeignet, weil Gruppe und Lärm nötig sind. Die Idee „Hardware-Aktion als Überraschung“ ist aber übertragbar.

#### 2.2.9 DUAL! (Seabaa, Inc.)

**Belegte Fakten**
- **Plattform / Zeitraum:** iOS und Android. Version 1.0 vom 31.03.2015 [B] ([App Store](https://apps.apple.com/us/app/-/id918902604)); Android-Bericht vom 07.04.2015 [B] ([TuttoAndroid](https://www.tuttoandroid.net/giochi/dual-uno-shooter-game-da-giocare-in-multiplayer-con-amici-267988/)). Siliconera nennt als Entwickler Sebastian Gosztyla [B] ([Siliconera](https://www.siliconera.com/?p=472694)).
- **Kernmechanik:** Jedes Telefon ist die Hälfte des Spielfelds; nur nebeneinander gelegt sieht man alles. Wer das eigene Display abdeckt, versteckt seine Schüsse [B] (Siliconera).
- **Steuerungsprinzip:** DUEL: Neigen zum Ausweichen, Halten zum Aufladen, Schießen. DEFLECT: Wischen gibt dem Ball Schub, abhängig von der Ladezeit [B] (App Store). TuttoAndroid: „inclinare“ (neigen) und „tappare“ (tippen) [B].
- **Spielerfeedback:** App Store 4,1 aus ~2,4 Tsd. Bewertungen [B]; Siliconera nennt die Zwei-Telefon-Idee „the cool thing here“ [B].
- **Monetarisierung:** Kostenlos plus einmaliger Full-Unlock für $2,99. Für DEFEND/DEFLECT muss nur ein Spieler freigeschaltet haben [B] (App Store).
- **Technik:** Lokales Spiel über WLAN oder Bluetooth [B] (App Store); zum Android-Start nur WLAN [B] (TuttoAndroid).

**Einschätzung [E]**
- **Sessionlänge (Schätzung):** 1–3 min pro Duell.
- **Übertragbare Designprinzipien:**
  - Der Raum *zwischen* Geräten wird Mechanik.
  - Ein großzügiger Unlock (einer zahlt, beide spielen) senkt die Hürde.
  - Für unser Solo-Kurzspiel höchstens als späterer Modus relevant.

#### 2.2.10 Tiny Wings (Andreas Illiger), nur iOS

**Belegte Fakten**
- **Plattform / Zeitraum:** iOS 18.02.2011, HD 2012, tvOS 2016, Apple Arcade 2021. Eine Android-Version wird nicht erwähnt [B] ([Wikipedia](https://en.wikipedia.org/wiki/Tiny_Wings)).
- **Steuerungsprinzip:** Tippen und Halten lässt den Vogel fallen. Mit gutem Timing gleitet er den Hang hinunter und hebt am nächsten Hang ab [B] (Wikipedia). Pocket Gamer beschreibt es als „Tapping … will retract those wings“ [B] ([Pocket Gamer 2011](https://www.pocketgamer.com/tiny-wings/review/)). Ein Finger, einhändig.
- **Sessionlänge:** Ein Tag-Nacht-Zyklus beendet den Lauf („when the screen finally goes dark it's time for Tiny to stop“) [B] (Pocket Gamer); eine Dauer ist nicht beziffert.
- **Spielerfeedback:**
  - Metacritic 85 (HD: 92); zwei Wochen Top-Grossing 2011; mindestens 10,5 Mio. iPhone-Kopien laut Game-Center-Statistik [B] (Wikipedia).
  - Pocket Gamer 4/5: „charming presentation, tight rhythmic gameplay, and keen replayability“. Kritik: „one-trick bird“, braucht anfangs Geduld [B].
- **Monetarisierung:** In den geöffneten Quellen nicht belegt.

**Einschätzung [E]**
- **Sessionlänge (Schätzung):** 1–3 min.
- **Übertragbare Designprinzipien:**
  - Ein einzelnes Halten wird durch Physik (Hügelrhythmus) tief.
  - Der Lauf endet durch die **Zeit** (Sonnenuntergang) statt durch einen Tod, eine natürliche, wenig frustrierende Sessiongrenze.

#### 2.2.11 Alto's Odyssey (Snowman / Team Alto)

**Belegte Fakten**
- **Plattform / Zeitraum:** iOS 21.02.2018, Android 25.07.2018 [B] ([Wikipedia](https://en.wikipedia.org/wiki/Alto%27s_Odyssey)).
- **Steuerungsprinzip:** Tippen = springen, halten = Trick (Flip), halten an Canyonwänden = Wallride [B] (Wikipedia, [Android Police 2018](https://www.androidpolice.com/2018/07/26/altos-odyssey-slides-onto-play-store/)). Zen-Modus mit Unverwundbarkeit [B] (Wikipedia).
- **Spielerfeedback:** Metacritic 88; Pocket Gamer 4,5/5 lobt die „gorgeous atmosphere“. Kritik: zu nah am Vorgänger; TouchArcade bemängelt den Münz-Grind [B] (Wikipedia).
- **Monetarisierung:**
  - iOS Premium für $4,99. Android als F2P, **weil Premium-Umsätze auf Android enttäuschend waren** [B] (Wikipedia).
  - Android-IAP zwischen $0,99 und $9,99; Android Police empfiehlt „$1.99 to remove the pop-up ads“ [B].
  - Laut Snippet nach einem Crash ein optionales 30-s-Video zum Weiterfahren, gelegentlich automatische Werbung zwischen den Läufen [S].

**Einschätzung [E]**
- **Sessionlänge (Schätzung):** 1–5 min pro Lauf.
- **Übertragbare Designprinzipien:**
  - Tippen vs. Halten auf derselben Fläche ergibt zwei Verben mit einem Finger.
  - Ein **Zen-Modus** passt für stressfreie Kurzpausen.
  - Geschäftlicher Warnhinweis für Android: Premium allein trägt sich dort schwer.

#### 2.2.12 Holedown (grapefrukt)

**Belegte Fakten**
- **Plattform / Zeitraum:** iOS und Android, Entwickler grapefrukt („the rymdkapsel dev“) [B] ([Pocket Gamer](https://www.pocketgamer.com/holedown/)). Release 2018; das genaue Datum ist widersprüchlich (25.07. bzw. 31.07.2018) [S].
- **Steuerungsprinzip:** Mit dem Finger ziehen = zielen; „lift your finger and the balls go careening across the screen“ [B] ([MacStories](https://www.macstories.net/reviews/game-day-holedown/)). Ein Finger, einhändig.
- **Meta / Sessions:**
  - Kristalle werden in Upgrades getauscht, z. B. mehr Bälle pro Zug.
  - „you can quit at any time and pick up where you left off later without losing any progress“.
  - Die regulären Level waren an einem Samstagnachmittag durch, danach folgt ein Endlos-Level [B] (MacStories).
- **Spielerfeedback:** Pocket Gamer 4/5 [B]; MacStories: „a perfect example of a well-designed mobile game“ [B]. Nutzer bemängeln begrenzte Inhalte [S/A] (WorldsApps).
- **Monetarisierung:** $3,99 Einmalkauf ohne IAP [B] (MacStories); auch bei Google Play $3,99 [S] (Tom's Guide).

**Einschätzung [E]**
- **Sessionlänge (Schätzung):** 1–3 min pro Zugfolge, jederzeit unterbrechbar.
- **Übertragbare Designprinzipien:**
  - Zielen ohne Zeitdruck, Commit erst beim Loslassen: einhändig und fehlertolerant.
  - **Speichern beim Verlassen** als Kernfeature für Toiletten-Sessions.

#### 2.2.13 Desert Golfing (Justin Smith / Blinkbat Games)

**Belegte Fakten**
- **Plattform / Zeitraum:** iOS und Android 06.08.2014, PC/Mac 2017 [B] ([Wikipedia](https://en.wikipedia.org/wiki/Desert_Golfing)).
- **Steuerungsprinzip:** „You drag back your finger to make an arrow stretch in the opposite direction“; beim Loslassen fliegt der Ball „in a slingshot motion“ [B] ([Reverse Shot](https://reverseshot.org/features/1927/desert_golfing)). Laut Wikipedia ein Ein-Finger-Swipe für Richtung und Kraft [B]. Man kann den Schlag irgendwo auf dem Bildschirm beginnen [S] (Giant Bomb / TouchArcade-Forum).
- **Regeln:** Keine Neustarts, kein Üben, die Schläge stehen „on your score forever“. Die Löcher folgen nahtlos aufeinander [B] (Reverse Shot). Später kam ein Ende bei Loch 10.001 hinzu [B] (Wikipedia).
- **Spielerfeedback:**
  - Eurogamer 9/10: „wonderfully sparse“, Steuerung und Physik „superb“; Ars Technica: „addictive“ [B] (Wikipedia).
  - Kritik: Die Physik „will drive you up the wall“ [B] ([WWAC 2015](https://womenwriteaboutcomics.com/2015/01/phone-game-review-desert-golfing/)); der Ball rutscht auf Sand oder Gefälle weg [B] ([MobileSyrup 2018](https://mobilesyrup.com/2018/01/06/desert-golfing-minimalist-golfing-game/)).
- **Monetarisierung:** $1,99 [B] (WWAC 2015); Google Play $1,99 CAD, iOS $2,79 (2018) [B] (MobileSyrup). Werbung: nicht belegt.
- **Visuelles:** „a beautiful minimalistic piece of art“ [B] (WWAC).

**Einschätzung [E]**
- **Sessionlänge (Schätzung):** frei wählbar. Ein Schlag dauert 5–10 s und ist damit eine perfekte Mikro-Session.
- **Wiederspielwert:** Sehr hoch durch die endlose Progression.
- **Übertragbare Designprinzipien:**
  - **Irgendwo berühren statt am Objekt:** Der Finger verdeckt den Ball nicht (relative Eingabe).
  - Permanenz (keine Resets) gibt jedem Schlag Gewicht.
  - Keine Menüs zwischen den Löchern.

#### 2.2.14 Mini Metro (Dinosaur Polo Club), mobil

**Belegte Fakten**
- **Plattform / Zeitraum:** iOS und Android 18.10.2016; Android-Publisher ist Playdigious [B] ([Wikipedia](https://en.wikipedia.org/wiki/Mini_Metro_(video_game))).
- **Steuerungsprinzip:** Routen mit dem Finger ziehen ist „intuitive and fun“. Löschen und Umrouten ist anfangs „a little trickier“. Pinch-Zoom kann „accidentally reroute tracks if you're not careful where you put your fingers!“ [B] ([Transit Maps 2016](https://transitmap.net/mini-metro-review)).
- **Typische Sessionlänge:** „Average game time for me at the moment is 15 to 20 minutes per game“ [B/A] (Transit Maps, ein Rezensent).
- **Spielerfeedback:** Metacritic 89 (iOS); Gamezebo 5/5 lobt die Touch-Steuerung; Pocket Gamer 8/10 [B] (Wikipedia). Kritik: Auf dem kleinen Bildschirm wird es „a bit fiddly“ [B] (Transit Maps).
- **Monetarisierung:** $4,99, „No ads, no micro-transactions“ [B] (Transit Maps).
- **Visuelles:** Geometrische Formen vereinfachen komplexe Aufgaben (Gamezebo laut Wikipedia) [B].

**Einschätzung [E]**
- **Übertragbare Designprinzipien:**
  - Zeichnen als planendes, präzises Verb.
  - Gesten müssen sich klar trennen lassen (Zoom vs. Zeichnen), sonst entstehen Fehleingaben; Pausieren beim Umbauen hilft.
  - Die Sessionlänge (15–20 min) ist für unser Ziel zu lang.

#### 2.2.15 Ridiculous Fishing (Vlambeer)

**Belegte Fakten**
- **Plattform / Zeitraum:** iOS 13.03.2013, Android 19.11.2013 [B] ([Wikipedia](https://en.wikipedia.org/wiki/Ridiculous_Fishing)).
- **Kernmechanik:** Der Haken sinkt, Fische werden beim Hochziehen eingesammelt, über Wasser geschleudert und abgeschossen [B] (Wikipedia).
- **Steuerungsprinzip:** Neigen steuert den Haken. Über Wasser gilt: „tap to fire a single shot, or hold one or two fingers on the screen to rapid fire“ [B] ([Engadget 2013](https://www.engadget.com/2013-03-14-ridiculous-fishing-review.html)).
- **Spielerfeedback:**
  - Metacritic 91; Apple Design Award; Apples iPhone-Spiel des Jahres [B] (Wikipedia).
  - Engadget lobt die Neigungssteuerung als „natural, responsive, and extremely quick“ [B].
  - Android Police: keine Frustration mit der Neigungssteuerung, aber hoher Akkuverbrauch [S].
- **Monetarisierung:** Premium ($2,99 iOS laut Engadget) [B], keine IAP [B] (Wikipedia).
- **Visuelles:** Kunst von Greg Wohlwend; „Any screenshot you take of this game would make an amazing wallpaper“ [B] (Engadget).

**Einschätzung [E]**
- **Sessionlänge (Schätzung):** 1–2 min pro Wurf-Zyklus.
- **Übertragbare Designprinzipien:**
  - **Die Eingabe wechselt innerhalb eines Laufs die Phase** (Neigen → Schießen), das bringt Abwechslung ohne neue Lernlast.
  - Neigen plus Touch kombiniert. In einer Studie war „Tilt+Touch“ nach reinem Touch die zweitbeliebteste Kombination (Teather et al. 2017, Abschnitt 3.1).

#### 2.2.16 Two Dots (Playdots)

**Belegte Fakten**
- **Plattform / Zeitraum:** iOS 29.05.2014, Android 12.11.2014 [B] ([Wikipedia](https://en.wikipedia.org/wiki/Two_Dots_(game))).
- **Steuerungsprinzip:** Gleichfarbige Punkte horizontal oder vertikal verbinden, „never diagonally“. Eine geschlossene Schleife räumt die ganze Farbe ab [B] (Wikipedia, [Gamezebo 2014](https://www.gamezebo.com/reviews/twodots-review-brother-can-you-spare-a-dot/)). Ein Finger zeichnet einen Pfad.
- **Monetarisierung:** 5 Leben, je 20 min Regeneration; Booster per IAP; Items alternativ gegen Werbung [B] (Wikipedia).
- **Spielerfeedback:**
  - Metacritic 79. Kritik am langsamen Leben-System; manche Level „nearly impossible“ [B] (Wikipedia).
  - Gamezebo 60/100: „four hours of waiting for lives to refill“, aber „Breathtaking design from start to finish“ [B].

**Einschätzung [E]**
- **Übertragbare Designprinzipien:**
  - Rasterbasiertes Verbinden ist auf kleinen Displays robust.
  - Das **Leben-System widerspricht Kurz-Sessions direkt**: Nach dem Scheitern darf man nicht „noch mal“.

---

### 2.3 Weitere Referenzen (Kurzprofile)

| Spiel | Eingabeprinzip | Beleg / Anmerkung |
|---|---|---|
| Pinchworm (Unity&Variety, 2016, iOS) | Pinch zusammen = springen, auseinander = graben. Die Gesten sind horizontal, die Hindernisse vertikal, deshalb „harder than you'd think“ | [B] [TechCrunch](https://techcrunch.com/2016/05/24/pinchworm/amp/). Kostenlos mit IAP |
| Pinch (Coatsink, 2010) | Norbs per Pinch kombinieren; Pinch-Zoom und Drag zur Übersicht | [B] [Macworld](https://www.macworld.com/article/208094/pinchreview.html) |
| Shadowmatic (Triada, 2015) | Ein Finger rotiert das Objekt, zwei Finger drehen es um die Achse | [S] Pocket Gamer / Gamezebo; Apple Design Award 2015 [S] |
| Osmos | Tippen stößt Masse aus (Antrieb in Gegenrichtung), Pinch = Zoom, Wischen/Flick = Zeitwarp | [S] App-Store-Text, Macworld |
| Magic Touch: Wizard for Hire (Nitrome) | Runen auf Ballons nachzeichnen | [S] Gamezebo / Pocket Gamer; Werbung per Einmal-IAP entfernbar [S] |
| Blek (kunabi brother, 2013) | Gezeichnete Linie wird samt Tempo wiederholt | [S] Wikipedia-Snippet; Apple Design Award 2014 [S] |
| Stick Hero (Ketchapp, 2014) | Halten lässt den Stab wachsen, Loslassen legt ihn ab | [S] iphonesoft.fr; Kritik an viel Werbung [S] |
| Smash Hit (Mediocre, 2014) | Metallkugeln auf Glas schießen. F2P plus Einmalkauf (Checkpoints, Modi, Cloud-Sync); über 280 Mio. Downloads (Okt. 2024) | [B] [Wikipedia](https://en.wikipedia.org/wiki/Smash_Hit). Werbung widersprüchlich: GSMArena 2014 „won't annoy you with ads“ [S] vs. Wikipedia: Die Apple-Arcade-Version entfernte „purchase and ads“ [B] |
| Flight Control (Firemint, 2009) | Pfade zeichnen, die Flugzeuge zur Landebahn lenken; 3,8 Mio. Verkäufe | [B] [Wikipedia](https://en.wikipedia.org/wiki/Flight_Control_(video_game)) |
| Doodle Jump (Lima Sky, 2009) | Neigen = links/rechts, Tippen = schießen | [B] [Wikipedia](https://en.wikipedia.org/wiki/Doodle_Jump) |
| Glow Hockey 2 | Zwei Personen an einem Gerät per Multitouch, je eine Bildschirmhälfte | [S] AddictiveTips |
| Severed (DrinkBox, 2016) | Schwert schlägt in Wischrichtung; Multitouch-Drag dreht die Kamera | [S] Pocket Gamer; Metacritic iOS 88, **kein Android** [B] [Wikipedia](https://en.wikipedia.org/wiki/Severed_(video_game)) |

**Geprüft, aber nicht aufgenommen:** *Archero*. Die Steuerung ließ sich nicht verifizieren; das Energie-System kenne ich nur aus einem Blog-Snippet [S]. *Fingle* und *Bounden* habe ich aus Zeitgründen nicht recherchiert (offen).

---

## 3. Eingabemethoden-Landkarte

### 3.1 Ergonomische und technische Grundlagen (belegt)

**Haltung und Reichweite**
- **Hoober 2013** (1.333 Beobachtungen, davon 780 mit Touch) [B] ([UXmatters](https://www.uxmatters.com/mt/archives/2013/02/how-do-users-really-hold-mobile-devices.php)):
  - Griffe: 49 % einhändig, 36 % „cradled“ (in einer Hand gehalten, mit der anderen bedient), 15 % beidhändig.
  - Von den beidhändigen Griffen sind 90 % Hochformat.
  - „Users change the way they're holding their phone very often—sometimes every few seconds.“
  - Hoober hat seine Reichweiten-Grafiken 2017 selbst widerrufen („People touch the center of the screen“).
- **Hoober 2017** [B] ([UXmatters](https://www.uxmatters.com/mt/archives/2017/03/design-for-fingers-touch-and-people-part-1.php)):
  - 75 % tippen nur mit einem Daumen; weniger als 50 % halten das Gerät einhändig; 36 % „cradle“; 10 % halten mit einer Hand und tippen mit dem Finger der anderen.
  - Menschen bevorzugen die Bildschirmmitte. Ziele können dort ~7 mm klein sein, in den Ecken sind ~12 mm nötig.
  - Die bekannten Daumen-Reichweiten-Grafiken seien „incorrect“.
- **Bergstrom-Lehtovirta & Oulasvirta (CHI 2014):** Der Arbeitsbereich des Daumens hängt von Handgröße, Displaygröße und der Position des Zeigefingers auf der Rückseite ab [S] (Abstract, Uni-Portal).

**Haptik und Neigung**
- **Teather, Roth & MacKenzie 2017** (16 Personen, Twin-Stick-Shooter, Tablet) [B] ([yorku.ca](https://yorku.ca/mack/ec2017.html)):
  - „The absence of tactile feedback yields a noticeable performance cost.“
  - „Fingers can easily miss buttons and slide off virtual joysticks.“
  - Virtuelle Bedienelemente verdecken das Bild. Neigen verdeckt nichts, nutzt aber weniger geschickte Gelenke und ermüdet den Arm.
  - Präferenz: „Touch+Touch“ vor „Tilt+Touch“ (Platz 2, signifikant vor „Tilt-only“ und „Touch+Tilt“). Neigen für die Bewegung „works well“.
- **Entwicklersicht (Birkett / Grey Alien Games 2013):** „the biggest problem for me is when my thumb slips off the joystick“. Als Alternativen nennt er Slider über die volle Breite, „Finger folgen“ und Gesten [B] ([PocketGamer.biz](https://www.pocketgamer.biz/best-of-british-grey-alien-games-talks-the-pros-and-cons-of-touchscreen-controls/)).

**Android-Plattform**
- **Systemgesten** [B] ([Android Developers: Gesture Navigation](https://developer.android.com/develop/ui/views/touch-and-input/gestures/gesturenav)):
  - Die Zurück-Geste ist ein Wisch vom linken oder rechten Rand nach innen.
  - Home und Quick-Switch liegen unten; „Apps can't opt out of these gestures“.
  - Spiele sollen Ausnahmebereiche (Exclusion-Rects) „only … when necessary, such as during gameplay“ setzen.
  - Wer nahe der Home-Geste wischen lassen muss, kann den Immersive Mode nutzen.
- **Limit für Ausnahmebereiche:** „the system will put a limit of 200dp on the vertical extent of the exclusions“; das Limit gilt nicht, solange die Navigationsleiste per *immersive sticky* ausgeblendet ist [B] ([AOSP-Doku, gespiegelt bei Microsoft Learn](https://learn.microsoft.com/dotnet/api/android.views.view.systemgestureexclusionrects)). Das Google-Codelab spricht von „200 dp limit per side“ [B] ([Codelab](https://codelabs.developers.google.com/codelabs/gesture-navigation)).
- **Immersive Mode:** „helps users avoid accidental exits during a game“. Die Systemleisten lassen sich per Randwisch vorübergehend einblenden [B] ([Android Developers: Immersive](https://developer.android.com/develop/ui/views/layout/immersive)).
- **Android 15:** Apps mit targetSdk 35 sind standardmäßig edge-to-edge; Insets müssen behandelt werden [B] ([Behavior changes 15](https://developer.android.com/about/versions/15/behavior-changes-15)).
- **Touch-Ziele:** Mindestens 48 × 48 dp [B] ([Android Accessibility](https://developer.android.com/guide/topics/ui/accessibility/apps)).
- **Handflächen-Erkennung:** `FLAG_CANCELED` auf `ACTION_POINTER_UP`/`ACTION_CANCEL` gibt es erst ab Android 13 (API 33). Darunter ist nicht zuverlässig erkennbar, ob eine Berührung beabsichtigt war [S] ([Android Developers Palm Rejection](https://developer.android.com/develop/ui/compose/quick-guides/content/reject-stylus-palm-touches), Seite beim Abruf 404).
- **Gebogene Ränder:** Xiaomi bietet pro Spiel eine einstellbare Kanten-Empfindlichkeit gegen Fehl-Touches; Huawei ignoriert beim Mate 30 Pro Berührungen an den Seitenrändern [S].
- **Multitouch-Fähigkeiten** [B] ([PackageManager-Doku, Spiegel](https://spot.pcc.edu/~mgoodman/developer.android.com/reference/android/content/pm/PackageManager.html)):
  - `multitouch`: „sufficient for basic two-finger gesture detection“.
  - `multitouch.distinct`: „tracking two or more fingers fully independently“.
  - `multitouch.jazzhand`: „a full hand of fingers“.
- **Sensoren:** Gyroskop und Beschleunigungssensor sind eigene, optionale Features [B] (ebd.). Manche Budget-Phones haben kein Gyroskop [S] (TechRadar, Moto G4 Play). Im Liegen (Display zur Decke) kehrt sich die Neigungsauswertung leicht um [S] (Unreal-Forum).

**Barrierefreiheit**
- **Game Accessibility Guidelines:** „Ensure that multiple simultaneous actions (eg. click/drag or swipe) are not required“ und „Avoid / provide alternatives to requiring buttons to be held down“ (beide Intermediate/Motor) [B] ([GAG](https://gameaccessibilityguidelines.com/full-list/)).

### 3.2 Übernutzte Eingaben

| Eingabe | Belegte Beispiele | Ergonomie Hochformat, 1 Hand / 2 Hände [E] | Fehleingabe-Risiko [E, wo nicht belegt] | Bemerkung |
|---|---|---|---|---|
| **Einzel-Tap / Timing-Tap** | Flappy Bird: „only ascends when the player taps“ [B] ([Wikipedia](https://en.wikipedia.org/wiki/Flappy_Bird)); „Tap and Timing games are the most popular form of mechanics for hyper casual games“ [B] ([mobilefreetoplay 2018](https://mobilefreetoplay.com/top-10-game-mechanics-for-hyper-casual-games/)) | 1 Hand: ideal. 2 Hände: unnötig | Gering bis mittel: Griffwechsel „every few seconds“ (Hoober) kann Taps auslösen | Kaum Differenzierung, Austauschbarkeit |
| **Wisch-Spurwechsel (4-Wege-Swipe)** | Subway Surfers: „swipe up, down, left, or right“, erstes Spiel mit 1 Mrd. Google-Play-Downloads [B] ([Wikipedia](https://en.wikipedia.org/wiki/Subway_Surfers)) | 1 Hand: gut | Mittel: Diagonalen mehrdeutig; Randwische kollidieren mit der Zurück-Geste; Wisch vom oberen Rand öffnet Systemleisten [B] (Android-Doku) | Etabliertes Genre-Muster |
| **Swerve / Finger folgen** | „Swerve: Players drag a finger to avoid obstacles“ [B] (mobilefreetoplay) | 1 Hand: gut | Mittel: Der Finger verdeckt die Figur (Okklusion, Hoober 2013), Abrutschen über den Rand | Sehr verbreitet im Hyper-Casual |
| **Ziehen zum Zielen / Schleuder** | Angry Birds: „slingshot controlled via the touchscreen“ [B] ([Wikipedia](https://en.wikipedia.org/wiki/Angry_Birds_(video_game))); Desert Golfing, Holedown [B] | 1 Hand: sehr gut | Gering: Der Commit erfolgt erst beim Loslassen | Langsam, eher Puzzle als Action |
| **Virtueller Joystick / Buttons** | Teather 2017; Birkett 2013 [B] | 1 Hand: schwach. 2 Hände: Querformat-Standard | Hoch: Abrutschen, kein Tastgefühl, Bildverdeckung [B] | HN-Stimme: „inadequate input method that is a touch without tactility“ [A] ([HN 2021](https://news.ycombinator.com/item?id=29089175)) |
| **Tippen auf Ziel / Tap-to-shoot** | Smash Hit, Ridiculous Fishing (über Wasser) [B] | 1 Hand: gut | Gering bis mittel: Die Fingerkuppe verdeckt das Ziel | Solide, aber Standard |

### 3.3 Unterausgeschöpfte Eingaben (Chancen)

| Eingabe | Belegte Beispiele | Ergonomie Hochformat [E] | Fehleingabe-Risiko | Praktische Constraints | Potenzial für 30-s-Sessions [E] |
|---|---|---|---|---|---|
| **Zwei unabhängige Daumen-Zonen** (inkl. „Akkord“: beide = dritte Aktion) | 2 Cars, Duet, Super Hexagon; Data Wing: beide = bremsen [B] | Nur mit 2 Händen. Laut Hoober 15 % beidhändig, davon 90 % Hochformat; für 30–60-s-Phasen zumutbar [E] | Gering bei Halbbild-Zonen (riesige Ziele). Kognitiv hoch: Blick wandert zum anderen Objekt (2 Cars) [B] | Seitenränder: Zurück-Geste nur bei Wischen, nicht bei Taps [E]. Bei Wisch-Eingaben Exclusion-Rects ≤ 200 dp oder immersive sticky [B]. Gebogene Kanten [S]. `multitouch.distinct` voraussetzen [B] | **Hoch** |
| **Mehrfinger-Halten** („jeder Finger hält etwas“) | Hundreds (verknüpfte Kreise) [B]; Ridiculous Fishing (1–2 Finger Dauerfeuer) [B]; Fruit Ninja (mehrere Finger) [B] | 2 Hände nötig; auf dem Phone eng | Okklusion: „circles that your hand is blocking“ [B] (Game Informer); auf dem iPhone schwerer als auf dem iPad [S] | Auf 2 gleichzeitige Pointer begrenzen; mehr als 3 nur optional (jazzhand nicht garantiert) [B/E] | **Hoch** (bei max. 2 Fingern) |
| **Halten-und-Loslassen / Aufladen** | Tiny Wings, Badland, Alto (Trick), Stick Hero [S], DUAL! (Laden) [B] | 1 Hand: ideal | Gering | Barrierefreiheit: Alternative zum Halten anbieten [B] (GAG) | **Mittel**: im One-Touch-Genre etabliert, aber **selten als zwei parallele Ladungen** (unterausgeschöpft) [E] |
| **Pinch/Spread als eigentliche Spielhandlung** | Pinchworm, Pinch [B]; Osmos und Mini Metro nur als Zoom [S/B] | 1 Hand: Daumen und Zeigefinger kaum ohne Ablage [E]. 2 Hände: Daumen spreizen möglich [E] | Mittel bis hoch: Konflikt mit Ziehen (Mini Metro: Zoom routet Linien um) [B]; Kreuz-Mapping horizontale Geste vs. vertikale Gefahr ist schwer [B] (Pinchworm) | Gestenerkennung braucht klare Schwellen (Zwei-Finger-Start → Modus fixieren) [E] | **Mittel bis hoch** (Neuheit) |
| **Zwei-Finger-Rotation** | Shadowmatic [S] | Meist zwei Hände oder Ablage [E] | Mittel: Verwechslung von Rotation und Pinch [E] | Rotation und Skalierung getrennt erkennen [E] | **Mittel** |
| **Pfad oder Glyphe zeichnen** | Flight Control, Mini Metro, Two Dots [B]; Magic Touch, Blek [S] | 1 Hand: Daumen ok; Zeigefinger präziser | Mittel: Fehlerkennung; Start am Rand löst die Zurück-Geste aus [B] | Zeichenfläche ≥ 16–24 dp vom Seitenrand starten lassen (Richtwert) [E] | **Mittel** |
| **Neigen (Tilt), am besten mit Touch kombiniert** | Doodle Jump [B], Ridiculous Fishing [B], DUAL! [B] | 1 Hand: gut, **keine Okklusion** [B] (Teather) | Mittel: Haltung und Kalibrierung (Liegen, Sitzen) [S]; Ermüdung [B] | Gyroskop nicht garantiert [S], Akku [S] → Accelerometer-Fallback, Auto-Kalibrierung beim Start [E] | **Mittel** (als Hybrid) |
| **Schütteln / Umdrehen** | Spaceteam [B] | Kurzer Ruck | Risiko, das Gerät fallen zu lassen [E]; laut / sozial | Seltener Event statt Dauerinput [E] | **Niedrig** (Toilette!) |
| **Geteilter Bildschirm** (mehrere Personen auf einem Gerät) | Badland (bis 4 Zonen) [B], Glow Hockey 2 [S] | Phone zu klein: „makes more sense on a tablet“ [B] | Mittel: Hände kreuzen sich | Hochformat: oben/unten | **Bonusmodus** |
| **Mehrere Geräte** | Spaceteam, DUAL! [B] | – | Verbindungsprobleme [S] | WLAN/Bluetooth | **Niedrig** für Solo-Kurzspiel |

### 3.4 Praktische Constraints: Checkliste für unser Spiel

1. **Ränder meiden:** Spielrelevante *Wisch*-Gesten nicht am linken oder rechten Rand beginnen lassen (Zurück-Geste) und nicht am unteren Rand (Home-Geste, nicht abschaltbar) [B]. Taps nahe am Rand sind unkritisch [E].
2. **Exclusion-Rects** nur während des aktiven Laufs setzen, höchstens 200 dp vertikal; alternativ *immersive sticky* während der Runde [B].
3. **Edge-to-edge (Android 15):** Insets einplanen, und kritische Touch-Zonen nicht unter Kamera-Ausschnitt oder Gestenleiste legen [B/E].
4. **Große Zonen statt kleiner Buttons:** mindestens 48 dp [B]. Besser Halbbild-Zonen (Duet, 2 Cars, Data Wing). Die Mitte ist präziser als die Ecken (7 vs. ~12 mm) [B].
5. **Okklusion:** Gesteuertes Objekt nicht unter den Daumen legen; relative Eingabe nach dem Prinzip „irgendwo berühren“ (Desert Golfing) [B/E].
6. **Pointer-Budget:** Basis sind 2 unabhängige Pointer (`uses-feature android.hardware.touchscreen.multitouch.distinct`), 3 und mehr nur optional [B/E]. Pointer-IDs sauber verfolgen und `ACTION_CANCEL` bzw. `FLAG_CANCELED` (ab API 33) behandeln [S/E].
7. **Fehl-Touches an Kanten und Handfläche:** Berührungen, die sehr nahe am Rand beginnen, mit Verzögerung oder Schwelle werten. Ab Android 13 die Handflächen-Erkennung des Systems nutzen [S/E].
8. **Loslass-Latenz:** Bei „Halten = Bewegung“ gegen Überschwingen mit Einrasten bzw. Hysterese arbeiten (Super-Hexagon-Kritik) [B/E].
9. **Barrierefreiheit:** Einen Assist-Modus ohne gleichzeitige Eingaben bzw. ohne Halten anbieten, z. B. sequenzielle Steuerung [B: GAG].
10. **Neigen nur hybrid:** Kalibrierung zu Rundenbeginn, Touch-Alternative anbieten, Gyroskop nicht voraussetzen [S/E].

---

## 4. Teil B: Spielerstimmung zu Kurz-Session-Mobile-Games

### 4.1 Quellenlage

- **Reddit (r/AndroidGaming, r/iosgaming, r/patientgamers, r/gamedesign, r/MobileGaming):** In dieser Sitzung nicht abrufbar (siehe Abschnitt 1). Thread-Titel oder Zitate von dort werden hier **nicht** behauptet.
- **Indirekte Reddit-Indizien** über den Aggregator GummySearch [B], als **Indiz, nicht als Beleg**:
  - **r/AndroidGaming** (433 Tsd. Mitglieder, Stand 18.10.2026): 25 Posts zum Thema „Annoying“, 19 zu „Ads“, 110 „Request“ ([GummySearch](https://gummysearch.com/r/AndroidGaming/)).
  - **r/iosgaming** (~270 Tsd., Stand 01.10.2026): unter anderem der Thread-Titel „Is there a way to stop in-game ads from opening the App Store, safari, or YouTube?“; Stichworte „Tired“ (14), „Hate“ (13) ([GummySearch](https://gummysearch.com/r/iosgaming/)). Den Thread selbst konnte ich nicht öffnen.
  - **r/MobileGaming** (~134 Tsd., Stand 12.10.2026): „Annoying“ (12), „Frustrating“ (9), „Tired Of“ (9), „Ads“ (7) ([GummySearch](https://gummysearch.com/r/MobileGaming/)).
- **Gelesene Community-Threads (alle [A], anekdotisch):**
  - [Tildes 2025: „Favorite mobile games for short play sessions?“](https://tildes.net/~games/1of0/favorite_mobile_games_for_short_play_sessions)
  - [HN 2023: „Ask HN: How do you find high quality mobile games?“](https://news.ycombinator.com/item?id=36468335)
  - [HN 2025: „Ask HN: Why aren't there actual games similar to those mobile game ads?“](https://news.ycombinator.com/item?id=43024359)
  - [HN 2018: „Ask HN: Are there any mobile games that are good rather than purely addictive?“](https://news.ycombinator.com/item?id=18310805)
  - [HN 2021: „Ask HN: Do you play any mobile games?“](https://news.ycombinator.com/item?id=29089175)
  - [Apple Community 2024: „WHY ARE THERE SO MANY ADS ON I PHONE GAMES“](https://discussions.apple.com/thread/255757292)

### 4.2 Wiederkehrende Themen

#### T1: Störende, zu häufige oder trickreiche Werbung führt zu Abbruch und Deinstallation
- **AppHarbr-Bericht „Player Sentiment on In-Game Ads“** (über PocketGamer.biz 04/2025) [B] ([PocketGamer.biz](http://www.pocketgamer.biz/bad-ads-are-killing-the-mobile-gaming-experience-heres-how-we-fix-it/)):
  - 58 % brechen ein Spiel wegen störender Werbung sofort ab; 84 % deinstallieren nach wiederholter Störung.
  - 45 % löschen ein Spiel wegen zu häufiger Interstitials.
  - 93 % geben Spiele mit täuschenden „X“-Buttons auf.
  - 61 % raten Freunden wegen schlechter Werbung ab.
  - Einschränkung: Hersteller-Studie, Stichprobe im Artikel nicht genannt.
- **AppHarbr 03/2026:** „one in five interstitial ads and one in ten rewarded video ads are unskippable, with some running as long as 80 seconds“ [B] ([PocketGamer.biz](http://www.pocketgamer.biz/mobile-games-host-three-times-more-malicious-ads-than-other-apps-says-appharbr/)).
- **Deloitte-Studie** (Umfrage unter 7.000 Spielern in fünf Ländern plus Tagebuchstudie mit 50 Personen; Datum nicht angegeben, PDF-Pfad deutet auf 2025) [B] ([Deloitte](https://www.deloitte.com/us/en/industries/tmt/articles/improve-mobile-game-advertising.html)):
  - Als störend identifiziert: „Obscure close 'X' buttons“, „Non-functional ad controls that mimic gameplay“ und „Forced redirects“. Sie führen zu kürzeren Sessions und mehr Abbrüchen.
  - „72% of gamers who see high-quality ad experiences continue playing the game“.
- **Einzelstimmen aus Rezensionen [A]:** Duet (Android 2014): „un-skippable video ads … Yeah, it's lame“ [B]. 2 Cars: Pop-up-Werbung „nervt“ [B]. Stick Hero: Kritik an viel Werbung [S].
- **Regulatorischer Rahmen bei Google Play** [B] ([Play-Richtlinie Ads](https://support.google.com/googleplay/android-developer/answer/9857753?hl=en), [Better Ads Experiences](https://support.google.com/googleplay/android-developer/answer/12271244)):
  - Verboten sind unerwartete Vollbild-Interstitials, Werbung „during game play at the beginning of a level“, Vollbild-Interstitials, die sich nach 15 s nicht schließen lassen, und falsche Schließen-Buttons.
  - Erlaubt sind natürliche Pausen, z. B. „after the score screen“. Opt-in-Rewarded-Ads sind ausgenommen.
- **Implikation [E]:** Bei 30-s-Runden wäre Werbung nach jeder Runde ein extremes Verhältnis von Werbung zu Spielzeit. Nie zum Rundenstart, nie mit Weiterleitung, nie mit verstecktem X.

#### T2: Irreführende Werbung („Fake Ads“) zerstört Vertrauen
- **Nexters-Umfrage 2023** (5.212 Spieler aus Nexters-Spielen) [B] ([GameDev Reports](https://gamedevreports.substack.com/p/nexters-misleading-ads-survey-2023), [PocketGamer.biz](https://www.PocketGamer.biz/news/81231/35-to-46-of-gamers-will-accept-misleading-advertising/)):
  - 91 % (USA) bzw. 71–77,2 % (andere Regionen) haben irreführende Werbung bemerkt.
  - Fast 75 % (USA/Europa) finden die Werbung „more fascinating than the actual game“.
  - Nur 35–46 % geben dem Spiel trotzdem eine Chance.
  - Die meisten glauben, Entwickler setzten diese Werbung bewusst für Downloads und IAP-Umsatz ein.
- **ASA-Urteil vom 30.09.2020** (UK): Playrix-Anzeigen für *Homescapes* und *Gardenscapes* wurden verboten, weil die Spiele „in large part consisted of gameplay that did not represent the ad content“ [B] ([PocketGamer.biz](https://www.pocketgamer.biz/news/74862/master-the-meta-why-playrixs-misleading-ads-finally-got-banned/)).
- **IAB:** 56 % haben Werbung gesehen, die das Gameplay falsch darstellt [B] (zitiert in PocketGamer.biz 04/2025).
- **Spielerstimme [A]** ([HN 2025](https://news.ycombinator.com/item?id=43024359)):
  - „people are interested in the gameplay shown in the ad, but the deception is frustrating“.
  - Antwort eines Entwicklers: „I've prototyped similar mechanics - they get boring after 15 minutes.“
- **Implikation [E]:** Werbung nur mit echtem Gameplay. Die Neugier auf „Ad-Mechaniken“ ist real, trägt aber kaum über Minuten hinaus; nötig ist Tiefe statt Gimmick.

#### T3: Opt-in-Rewarded-Ads werden akzeptiert, wenn sie wirklich freiwillig sind
- **Unity 2016** (mehr als 2.000 Entwickler und Spieler): 71 % der Spieler bevorzugen Videowerbung als Art, für Inhalte zu „zahlen“; 54 % wählten Rewarded Video; fast 80 % sind offen für Werbung gegen Belohnung [B] ([Unity](https://unity.com/en/news/new-industry-study-reveals-more-half-game-developers-identify-video-ads)).
- **Tapjoy 2017** (USA, Stichprobengröße unbekannt) [B] ([MediaPost](https://www.mediapost.com/publications/article/302685/mobile-gamers-prefer-rewarded-video-ads.html)):
  - 54 % bevorzugen Opt-in-Rewarded-Ads, 32 % Pflichtwerbung, 14 % Bezahl-Downloads; gegenüber Pre-Roll-Werbung 4:1.
  - Einschränkung: Beide Studien sind von Anbietern finanziert und mittlerweile alt.
- **Vampire Survivors (mobil, 12/2022)** [B]:
  - Werbung nur optional (Revive, Gold-Bonus). Galante: „I'm personally not a fan of microtransactions“, „This is the full game, for free, for real.“ ([PocketGamer.biz](https://www.pocketgamer.biz/news/80396/vampire-survivors-surprise-launches-to-mobile/))
  - iMore: „there are ads, but they're entirely optional“. Einziger Einwand: Die Werbung entwertet das teure Revival-Upgrade ([iMore](https://www.imore.com/gaming/the-best-iphone-game-of-2022-skipped-apple-arcade-and-its-totally-free)).
- **Tildes [A]:** Über *Angry Birds Dream Blast* heißt es: „There are no forced ads but it does offer watching ads for a few extra goes or a boost before starting a level.“ Über *Sliding Seas*: „1470 levels in and never needed to buy anything or watch an ad.“
- **Deloitte [B]:** Belohnungen als „fair value exchange“; „50% of gamers rank skip features as a top feature“.
- **Implikation [E]:** Rewarded Ads nur als echtes Angebot, z. B. „zweite Chance“ oder kosmetischer Bonus. Kein Druck, keine Entwertung von Fortschritt, gut begrenzt.

#### T4: Energie-, Leben- und Wartesysteme gelten als Flow-Killer
- **Two Dots:** Gamezebo kritisiert „four hours of waiting for lives to refill“ [B]; Wikipedia nennt das langsame Leben-System als Hauptkritik [B].
- **Jon Jordan (Pocket Gamer 2018)**, der Energie-Systeme eigentlich verteidigt: „You were playing happily and now your flow is broken“; „a classic case of the negative impact of having something you feel is yours taken away from you“ [B] ([Pocket Gamer](https://www.pocketgamer.com/harry-potter-hogwarts-mystery/making-the-case-for-harry-potter-hogwarts-mysterys-energy-system/)).
- **Ed Biden (2015):** Energie-Systeme „rarely blend well with the setting of the game, and this disconnect makes them disliked by players“ [B] ([mobilefreetoplay](https://mobilefreetoplay.com/eliminating-energy/)).
- **HN 2023 [A]:** „Nearly all mobile games are designed to get you addicted and then monetize you via micro transactions.“
- **Implikation [E]:** Bei 30-s-Runden ist „sofort noch mal“ der Kern. Ein Energie-System zerstört genau diese Schleife.

#### T5: Wunsch nach einem „fairen Deal“ (Einmalkauf, Freischaltung, Abo-Kataloge)
- **Tildes-Ausgangspost [A]:** „Preferably without ads or in app purchases.“ und „(I'll consider a one-time payment if it seems to be a great fit.)“. Viele Empfehlungen sind Testversion plus Einmal-Freischaltung (Hoplite, Bullpen, Smash Hit) oder Einmalkauf (Golf On Mars, Alto auf iOS).
- **HN 2023 [A]:**
  - „I just want to play some high quality, low bullshit (no ads, spam, loot boxes, etc.) games.“
  - „Pay for Apple Arcade. Games in there are guaranteed not to have ads, spam, or microtransactions.“
  - „Netflix Games have higher quality than usual and no ads, no in-app purchases, and no predatory tactics“.
  - Hinweis auf Filter im Play Store: „Premium“, „No Ads“, „No in-app Purchases“.
- **Community-Kuratierung:** *No-Bullshit Games* hilft beim Finden von Spielen ohne „crappy mobile games full of ads“ und ohne IAP-Abzocke [B] ([nobsgames](https://nobsgames.stavros.io/)).
- **Lob in Rezensionen:** Data Wing („not … ad-supported either“) [B]; Mini Metro („No ads, no micro-transactions“) [B].
- **Gegenstimmen und Realität:**
  - Apple Community: „Developers are not just creating those for you to play out of the goodness of their heart.“ [A] ([Apple Community](https://discussions.apple.com/thread/255757292)).
  - **Alto's Odyssey wurde auf Android F2P, weil Premium-Umsätze dort enttäuschten** [B] (Wikipedia).
- **Implikation [E]:** Für ein kostenloses Android-Spiel bietet sich an: vollständig kostenlos spielbar, optionale Rewarded Ads plus ein günstiger Einmalkauf „Werbefrei/Supporter“, ohne Energie und Pay-to-win. Das ist am nächsten an dem, was Spieler als fair loben.

#### T6: Kurz, jederzeit pausierbar, offline, ohne Pflicht-Dailies
- **Tildes [A]:**
  - Ausgangspost: „kill 10-20 minutes of time“.
  - Hoplite: „You can pause the round at any moment and continue later.“
  - I Love Hue: „No timer so you can pause anytime. Can play offline.“
  - FarmRPG: „no loading screens whatsoever“.
- **HN 2021 [A]:** „Ideally I'd play a few minutes and whenever I feel like it. No long sessions required.“ und „Hoplite, easy to pick up and put down.“ In HN 2023 wird kritisiert, dass Netflix Games einen Online-Check beim Start brauchen [B, Thread-Zusammenfassung].
- **Holedown:** „you can quit at any time and pick up where you left off later without losing any progress“ [B] (MacStories).
- **Branchendaten:**
  - GameAnalytics H1 2019: Durchschnittliche Sessionlänge im Median 4–5 min, Top-25 % 7–8 min. Im Jahresvergleich etwa 1 min kürzer, die meisten Genres etwa −30 s; Trend zu „bite-sized“ [B] ([AppDeveloperMagazine](https://appdevelopermagazine.com/mobile-gaming-industry-benchmarks-offer-fresh-look-on-industry/), [GameRefinery](https://www.gamerefinery.com/5-key-takeaways-from-gameanalytics-h1-2019-mobile-benchmarks-report/)).
  - Idle-Spiele: ~8 min pro Session und 5,3 Sessions pro Tag gegenüber 4,6 bei Hyper-Casual [B] ([Game World Observer](https://gameworldobserver.com/2020/12/22/gameanalytics-names-benchmark-engagement-metrics-idle-games)).
- **„Toilettenspiel“ als bekanntes Designziel:** Laut einem PocketGamer.biz-Artikel (2013) sagte Donald Mustard (*Infinity Blade*) auf der GDC 2011, „everyone was playing these games while going to the bathroom“. Das Team habe die Balance daran ausgerichtet, wie lange man sitzen kann, bis das Bein einschläft [B] ([PocketGamer.biz](https://www.pocketgamer.biz/feature/52981/opinion-mobile-gamings-throne-of-power-is-the-toilet-not-the-sofa/)).

#### T7: Qualität statt „Sucht-Design“; Klonflut; Spiele mit Ende werden geschätzt
- **HN 2023 [A]:** „Every time something just slightly nice is made, it is quickly drowned out by the 1000s of clones“.
- **HN 2021 [A]:** „mind numbing one button auto scrollers, crappy money extraction attempts, and boredom“. Das betrifft direkt das übernutzte Ein-Tap-Muster.
- **HN 2018 [A]:** Geschätzt werden Spiele, die enden (Monument Valley), oder Durchgänge, die jedes Mal anders sind (Polytopia, FTL).
- **Implikation [E]:** Originalität der Eingabe ist ein echtes Unterscheidungsmerkmal gegen die „One-Button“-Müdigkeit.

#### T8: Kontext Deinstallation: Spiele sind „Wegwerf-Apps“
- **AppsFlyer** (Jan. 2021 bis Okt. 2022): 66 % aller Deinstallationen betrafen Spiele [B] ([PocketGamer.biz](https://pocketgamer.biz/news/80716/why-are-people-uninstalling-games-ahead-of-other-apps/)). Gründe wie Speicherplatz oder Aufräumen sind dort nur die Vermutung des Autors, nicht belegt.
- **Implikation [E]:** Kleine Installationsgröße und sofortiger Spaß in den ersten 30 Sekunden.

### 4.3 Die 6 wichtigsten Stimmungsbefunde (priorisiert)

1. **Werbung zum falschen Zeitpunkt oder mit Tricks ist der Deinstallationsgrund Nr. 1.** Belege: AppHarbr (58 % sofortiger Abbruch, 84 % Deinstallation, 45 % wegen zu vieler Interstitials, 93 % bei Fake-X) und Deloitte (Redirects, Fake-Controls). Google Play verbietet Werbung am Levelstart. Evidenz: Industriestudien plus Richtlinie.
2. **Fake Ads erzeugen Misstrauen.** Nexters: 91 % (USA) haben sie bemerkt, nur 35–46 % geben dem Spiel eine Chance. Dazu das ASA-Verbot 2020 gegen Playrix.
3. **Freiwillige Rewarded Ads gelten als fair** (Unity 2016: 71 % / 54 %; Tapjoy 2017: 54 % vs. 32 % vs. 14 %; Lob für Vampire Survivors). Die Studien sind allerdings alt und von Anbietern finanziert.
4. **Energie-, Leben- und Wartesysteme brechen den Flow** (Two Dots: „four hours of waiting“; Jordan 2018). Für Sekunden-Runden sind sie fatal.
5. **Gesucht wird ein fairer Deal:** Einmal-Freischaltung, Premium oder Abo-Kataloge; Curation-Seiten und Store-Filter werden aktiv genutzt (Tildes, HN, nobsgames). Auf Android trägt Premium allein jedoch schwer (Alto's Odyssey).
6. **Jederzeit pausierbar, offline, ohne Ladezeiten und Dailies** ist das Qualitätsmerkmal für kurze Sessions. Belegt durch Tildes, HN und MacStories; die mittlere Sessionlänge liegt bei 4–5 min mit Trend zu „bite-sized“ (GameAnalytics 2019).

---

## 5. Ableitungen für unser Spiel (Einschätzung [E])

1. **Kern-Eingabe:** zwei große, unabhängige Daumen-Zonen im Hochformat (Muster 2 Cars / Data Wing). Dazu ein **Akkord** (beide Zonen gleichzeitig) als dritte Aktion und optional ein **Halten-Laden** pro Zone. Das ist echtes, sinnvolles Multitouch, ohne dass der Spieler zielen muss.
2. **Zielkonflikt Multitouch vs. Einhand-Nutzung:** Viele Spieler bedienen das Telefon mit einem Daumen (Hoober 2017: 75 %). Runden sollten deshalb höchstens 30–60 s dauern, damit der beidhändige Griff zumutbar bleibt. Dazu ein Assist-Modus, z. B. Einhand- oder Sequenz-Variante (GAG).
3. **Relative Eingabe:** Irgendwo in der Zone berühren statt das Objekt selbst. Kein Verdecken, robuster bei Griffwechseln.
4. **Spielfeld-Fokus in der Mitte:** Beide Aufmerksamkeitspunkte nahe der Bildmitte, um das 2-Cars-Problem der wandernden Augen zu entschärfen.
5. **Plattform-Hygiene:** Keine Wisch-Gesten am Rand, *immersive sticky* während der Runde, Exclusion-Rects ≤ 200 dp nur im Lauf, Pointer-Abbrüche behandeln, Einrasten gegen Überschwingen.
6. **Session-Struktur:** Neustart in unter 1 s, klares Rundenende (Zeit- oder Ziel-Limit wie Super Hexagon 60 s bzw. Tiny Wings Sonnenuntergang), Zustand beim Verlassen speichern (Holedown), offline spielbar.
7. **Monetarisierung:** Keine Energie, kein Pay-to-win. Rewarded Ads nur als echtes Angebot, Interstitials höchstens selten nach dem Ergebnis-Screen und nie zum Rundenstart (Play-Richtlinie). Dazu ein günstiger Einmalkauf „Werbefrei/Supporter“. Store-Werbung nur mit echtem Gameplay.
8. **Haptik und Feedback:** Fehlendes Tastgefühl durch Feedback kompensieren: Vibration, Sound und Partikel wie bei Fruit Ninja („tactile joy“). Das gilt gerade für Zonen-Steuerung ohne sichtbare Buttons.
9. **Optional später:** Ein Zwei-Spieler-Modus auf einem Handy (oben/unten, Muster Badland/Glow Hockey). Neigen höchstens als Hybrid-Zusatz.

---

## 6. Offene Punkte / nicht verifiziert

- **Reddit-Threads:** Nicht einsehbar, keine Titel oder Zitate behauptet. Empfehlung: manuell prüfen, ggf. mit Reddit-Login oder API.
- **Aktuelle Google-Play-Konditionen** (Preis, Werbung) für Duet, Alto's Odyssey, Fruit Ninja, Super Hexagon, Hundreds, Spaceteam: Die Play-Seiten ließen sich nicht auslesen. Ob Hundreds und Spaceteam noch gelistet sind, ist offen.
- **Gleichzeitiges Halten beider Seiten** bei Duet und Super Hexagon: Verhalten nicht dokumentiert.
- **Daten aus Snippets:** Die Fruit-Ninja-Arcade-Dauer (60 s), die Shadowmatic-, Osmos-, Magic-Touch-, Blek- und Stick-Hero-Details sowie die Handflächen- und Kanten-Hinweise von Android, Xiaomi und Huawei stammen nur aus Snippets [S].
- **Nicht recherchiert:** Fingle und Bounden (Zwei-Personen-Touch); Archero (Steuerung nicht verifiziert).

---

## 7. Quellenverzeichnis

### 7.1 Geöffnete und gelesene Quellen [B]

**Spiele**
- Duet: https://en.wikipedia.org/wiki/Duet_(video_game) · https://www.pocketgamer.com/articles/054390/r/ · https://www.androidpolice.com/2014/08/11/duet-review-i-love-to-hate-this-game · https://apps.apple.com/app/duet-game/id634235735
- 2 Cars: https://www.iphones.ru/iNotes/391092
- Data Wing: https://www.gamezebo.com/the-best/data-wing-review-sheer-delight/ · https://apps.apple.com/us/app/-/id1206723870
- Super Hexagon: https://en.wikipedia.org/wiki/Super_Hexagon · https://www.droidgamers.com/reviews/super-hexagon-review-a-devilishly-hard-game-that-s-not-meant-for-the-faint-hearted/
- Hundreds: https://en.wikipedia.org/wiki/Hundreds_(video_game) · https://gameinformer.com/games/hundreds/b/ios/archive/2013/01/08/hundreds-review.aspx · https://www.macworld.com/article/220786/review-hundreds-for-ios-is-a-maddening-challenge-of-a-puzzler-game.html · https://gamedeveloper.com/design/why-they-re-playing-i-hundreds-i- · http://www.pocketgamer.biz/gaming-by-numbers-the-making-of-hundreds/
- Fruit Ninja: https://en.wikipedia.org/wiki/Fruit_Ninja · https://www.pocketgamer.com/fruit-ninja/review/
- Badland: https://en.wikipedia.org/wiki/Badland_(video_game) · https://www.androidpolice.com/2014/06/12/badland-gets-an-update-with-four-player-co-op-mode-on-a-single-device/ · https://www.macworld.com/article/220780/review-badland-for-ios-is-nonstop-side-scrolling-fun.html
- Spaceteam: https://en.wikipedia.org/wiki/Spaceteam · https://www.commonsensemedia.org/app-reviews/spaceteam · https://cultmtl.com/2012/12/where-no-iphone-game-has-gone-before/
- DUAL!: https://apps.apple.com/us/app/-/id918902604 · https://www.siliconera.com/?p=472694 · https://www.tuttoandroid.net/giochi/dual-uno-shooter-game-da-giocare-in-multiplayer-con-amici-267988/
- Tiny Wings: https://en.wikipedia.org/wiki/Tiny_Wings · https://www.pocketgamer.com/tiny-wings/review/
- Alto's Odyssey: https://en.wikipedia.org/wiki/Alto%27s_Odyssey · https://www.androidpolice.com/2018/07/26/altos-odyssey-slides-onto-play-store/
- Holedown: https://www.macstories.net/reviews/game-day-holedown/ · https://www.pocketgamer.com/holedown/
- Desert Golfing: https://en.wikipedia.org/wiki/Desert_Golfing · https://reverseshot.org/features/1927/desert_golfing · https://mobilesyrup.com/2018/01/06/desert-golfing-minimalist-golfing-game/ · https://womenwriteaboutcomics.com/2015/01/phone-game-review-desert-golfing/
- Mini Metro: https://en.wikipedia.org/wiki/Mini_Metro_(video_game) · https://transitmap.net/mini-metro-review
- Ridiculous Fishing: https://en.wikipedia.org/wiki/Ridiculous_Fishing · https://www.engadget.com/2013-03-14-ridiculous-fishing-review.html
- Two Dots: https://en.wikipedia.org/wiki/Two_Dots_(game) · https://www.gamezebo.com/reviews/twodots-review-brother-can-you-spare-a-dot/
- Weitere: https://en.wikipedia.org/wiki/Smash_Hit · https://techcrunch.com/2016/05/24/pinchworm/amp/ · https://www.macworld.com/article/208094/pinchreview.html · https://en.wikipedia.org/wiki/Flight_Control_(video_game) · https://en.wikipedia.org/wiki/Doodle_Jump · https://en.wikipedia.org/wiki/Subway_Surfers · https://en.wikipedia.org/wiki/Flappy_Bird · https://en.wikipedia.org/wiki/Angry_Birds_(video_game) · https://en.wikipedia.org/wiki/Severed_(video_game) · https://mobilefreetoplay.com/top-10-game-mechanics-for-hyper-casual-games/

**Ergonomie und Plattform**
- https://www.uxmatters.com/mt/archives/2013/02/how-do-users-really-hold-mobile-devices.php
- https://www.uxmatters.com/mt/archives/2017/03/design-for-fingers-touch-and-people-part-1.php
- https://yorku.ca/mack/ec2017.html (Teather, Roth & MacKenzie 2017, *Entertainment Computing* 21)
- https://www.pocketgamer.biz/best-of-british-grey-alien-games-talks-the-pros-and-cons-of-touchscreen-controls/
- https://developer.android.com/develop/ui/views/touch-and-input/gestures/gesturenav
- https://learn.microsoft.com/dotnet/api/android.views.view.systemgestureexclusionrects (Spiegel der AOSP-Doku)
- https://codelabs.developers.google.com/codelabs/gesture-navigation
- https://developer.android.com/develop/ui/views/layout/immersive
- https://developer.android.com/about/versions/15/behavior-changes-15
- https://developer.android.com/guide/topics/ui/accessibility/apps
- https://spot.pcc.edu/~mgoodman/developer.android.com/reference/android/content/pm/PackageManager.html (Spiegel der PackageManager-Doku)
- https://gameaccessibilityguidelines.com/full-list/

**Spielerstimmung, Studien, Richtlinien**
- https://tildes.net/~games/1of0/favorite_mobile_games_for_short_play_sessions
- https://news.ycombinator.com/item?id=36468335 · https://news.ycombinator.com/item?id=43024359 · https://news.ycombinator.com/item?id=18310805 · https://news.ycombinator.com/item?id=29089175
- https://discussions.apple.com/thread/255757292
- https://gummysearch.com/r/MobileGaming/ · https://gummysearch.com/r/AndroidGaming/ · https://gummysearch.com/r/iosgaming/
- https://nobsgames.stavros.io/
- https://unity.com/en/news/new-industry-study-reveals-more-half-game-developers-identify-video-ads
- https://www.mediapost.com/publications/article/302685/mobile-gamers-prefer-rewarded-video-ads.html
- https://gamedevreports.substack.com/p/nexters-misleading-ads-survey-2023 · https://www.PocketGamer.biz/news/81231/35-to-46-of-gamers-will-accept-misleading-advertising/
- https://www.pocketgamer.biz/news/74862/master-the-meta-why-playrixs-misleading-ads-finally-got-banned/
- http://www.pocketgamer.biz/bad-ads-are-killing-the-mobile-gaming-experience-heres-how-we-fix-it/ · http://www.pocketgamer.biz/mobile-games-host-three-times-more-malicious-ads-than-other-apps-says-appharbr/
- https://www.deloitte.com/us/en/industries/tmt/articles/improve-mobile-game-advertising.html
- https://support.google.com/googleplay/android-developer/answer/9857753?hl=en · https://support.google.com/googleplay/android-developer/answer/12271244
- https://pocketgamer.biz/news/80716/why-are-people-uninstalling-games-ahead-of-other-apps/
- https://appdevelopermagazine.com/mobile-gaming-industry-benchmarks-offer-fresh-look-on-industry/ · https://www.gamerefinery.com/5-key-takeaways-from-gameanalytics-h1-2019-mobile-benchmarks-report/ · https://gameworldobserver.com/2020/12/22/gameanalytics-names-benchmark-engagement-metrics-idle-games
- https://www.pocketgamer.biz/feature/52981/opinion-mobile-gamings-throne-of-power-is-the-toilet-not-the-sofa/
- https://www.pocketgamer.biz/news/80396/vampire-survivors-surprise-launches-to-mobile/ · https://www.imore.com/gaming/the-best-iphone-game-of-2022-skipped-apple-arcade-and-its-totally-free
- https://www.pocketgamer.com/harry-potter-hogwarts-mystery/making-the-case-for-harry-potter-hogwarts-mysterys-energy-system/ · https://mobilefreetoplay.com/eliminating-energy/

### 7.2 Nur als Suchergebnis gesehen bzw. blockiert [S]

- iphonesoft.fr (2 Cars, Stick Hero) · Windows Central (2 Cars) · Pocket Gamer UK (Data Wing) · TouchArcade (Data Wing, Duet-/Bean's-Quest-Forum, 403) · Game Revolution (Duet)
- Android Police (Super-Hexagon-Update 2021, Ridiculous-Fishing-Akku) · GamesRadar und Game Informer News (Hundreds) · App Store Fruit Ninja und Halfbrick+
- Android Authority und Android Central (Alto's Odyssey, Werbedetails) · Tom's Guide, Android Authority und WorldsApps (Holedown) · Giant Bomb (Desert Golfing)
- Pocket Gamer, Gamezebo und Trusted Reviews (Shadowmatic) · App Store und Macworld (Osmos) · Gamezebo und Pocket Gamer (Magic Touch) · Wikipedia-Snippet (Blek) · GSMArena und Common Sense Media (Smash Hit) · AddictiveTips (Glow Hockey 2) · Pocket Gamer (Severed)
- Bergstrom-Lehtovirta & Oulasvirta 2014 (Uni-Portal-Abstract) · Android Palm Rejection Quick Guide (beim Abruf 404) · Xiaomi-FAQ (403) · GSMArena (Huawei Mate 30 Pro) · TechRadar (Moto G4 Play) · Unreal-Engine-Forum (Tilt-Kalibrierung)
- Automaton und Siliconera (D3Publisher-Sammlung „YEAH! YOU WANT 'THOSE GAMES,' RIGHT?…“) · Udonis-Blog (Archero-Energie)
