# ADR 0002 – Finales Konzept: ECHO (Arbeitstitel „NACHHALL“)

Status: entschieden · 2026-10-22 · Entscheider: Agent A (Game Director)
Grundlagen: ADR 0001 (vorab fixierte Kriterien), `docs/playtests/LUNTE_V2_SIM.md`, `docs/playtests/ECHO_SIM.md`,
`docs/playtests/PROTOTYPE_COMPARISON_CRITIC.md` (unabhängige Nachmessung durch Agent D).

## Entscheidung

**ECHO wird das Spiel.** LUNTE v2 wird nicht weiterentwickelt (Code bleibt als geparkter Prototyp im Debug-Labor).
Kein Neustart der Ideenphase: Ein Prototyp hat seine vorab festgelegten Kriterien ehrlich bestanden.

## Warum – und was ich falsch gemacht habe

1. **LUNTE v2 besteht die ADR-0001-Kriterien nicht, korrekt gemessen.**
   - **B3:** Mein Simulationsskript teilte Böller-Tode durch *alle Runden* statt durch *Tode*, wie in ADR 0001
     formuliert. Nachgemessen (Agent D, ich habe den Code geprüft): 23–26 % der Tode durch Böller → **nicht bestanden**.
     Mein Protokoll `LUNTE_V2_SIM.md` meldete fälschlich „bestanden“; es ist korrigiert.
   - **B1:** formal bestanden, aber mit falsch benannten Bot-Profilen (der Bot zeichnete erst bei Ziel+0,4 s weiter
     und spielte so in einer anderen Hitzestufe als behauptet). Ein Profil, das Stufe 2 hält, erzielt 2,6× „vorsichtig“
     und erreicht fast immer das Morgengrauen: Gier ist wieder gratis. Stufe 3 ist eine Falle.
   - **B2:** an einer Stelle gemessen, an der Tempo nicht unterscheiden kann (beide Testtempi über der Funken-Obergrenze);
     nah am Funken entscheidet Zeichentempo bis Faktor 13.
   - **B4:** durch das Morgengrauen-Limit konstruktionsbedingt erfüllt – keine Aussage.
   - Acht Iterationen haben ~12 Regeln aufgehäuft, mehrere nur, um einen perfekten Bot zu bestrafen. Während der
     Iterationen wurde auch der Bot verändert – das Messinstrument driftete.
2. **ECHO besteht ehrlich.** Ein reaktiver Bot ohne Planung erreicht 15 % des Bestwerts und verliert den Kern in jeder
   Runde, bei jedem Tempo. Die gefürchtete „Tortenstück“-Rezeptlösung erzielt nur 43–45 %. (E2 ist schwächer als
   formuliert: die zwei Strategien sind ein Planer mit zwei Bank-Schwellen.)
3. **Anker und Sunk Cost:** Ich hatte LUNTE bevorzugt, bereits Art Direction, Audio und eine Produktionsszene dafür gebaut
   und eine vorläufige Entscheidung getroffen. Genau davor hatte Agent D gewarnt. Die vorab fixierten Kriterien entscheiden,
   nicht die investierte Arbeit.

## Was wiederverwendet wird
Spiel-Hülle (Menü, Einstellungen, Datenschutz, Credits, Pause/Ergebnis-Muster, Szenenwechsel), Speicherstand,
Audio-Director, Haptik, Theme/Schrift, Partikelsystem, Himmel-Shader, Skyline, Glow, Werbe-Frequenzlogik,
Test-/Smoke-/Capture-Werkzeuge, Glockentöne, Morgengrauen-Akkord, Musik-Pad, UI-Sounds.
Die Bildsprache „Papiernacht“ passt: Der Kern wird eine Papierlaterne über der schlafenden Stadt, die Schatten werden
Tuschegeister, die Echos werden Laternenlichter – und **jedes Echo singt eine eigene Stimme eines Kanons**.

## Bedingungen vor dem Gerätetest (aus der Kritik, verbindlich)
1. Zwischen den Läufen darf ein Wackeln des Fingers keinen neuen Lauf starten; Kassieren und Weiter sind zwei
   klare, getrennte Aktionen.
2. Die Lehr-Welle muss für ein einzelnes Licht **nachweislich unlösbar** sein (Simulationstest).
3. Keine Schwierigkeitsklippe bei Zwillingen: späterer Einstieg, größeres Zeitfenster, Einführung mit Ankündigung.
4. Echo-Bahnen und Lauf-Zeitleiste bleiben lesbar, auch bei Lauf 4–6 (ältere Echos blasser).
5. Gleichbehandlung im Vergleich: Werden LUNTE und ECHO noch einmal am Gerät verglichen, dann beide mit oder beide ohne Ton.

## Menschliche Abbruchkriterien (unverändert aus ADR 0001 / CRITIC_REVIEW §5.2)
- < 4/5 Tester erklären die Echo-Regel nach Runde 1 richtig → Umbau des Onboardings oder Stopp.
- Median bis zur ersten absichtlichen Echo-Nutzung > 20 s.
- Nach 5 Runden spielen alle dasselbe Rezept.
- < 3/5 spielen ungefragt ≥ 3 weitere Runden.
