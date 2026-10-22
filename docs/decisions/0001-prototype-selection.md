# ADR 0001 – Auswahl der Prototypen

Status: entschieden · 2026-10-22 · Entscheider: Agent A (Game Director)
Grundlagen: `docs/concepts/CONCEPTS.md`, `CRITIC_REVIEW.md`, `SCORING.md`, `docs/research/00_INNOVATION_MAP.md`

## Entscheidung

Prototypisiert werden **K01 LUNTE (umgebaut, „v2“)** und **K06 ECHO (umgebaut)**. Parallel läuft eine
**Neuideen-Runde** (Agent C2) unter den Leitplanken aus `CRITIC_REVIEW.md` §6. K02 SCHWARM wird geparkt
(bereits gebauter Spike bleibt als Referenz im Prototyp-Labor, wird nicht weiterentwickelt).

## Begründung

- Höchste Entscheidungswerte: LUNTE 6,90, ECHO 6,22 (Mittel aus revidierter Director- und Kritiker-Wertung).
- Die beiden testen **verschiedene Hypothesen**: Echtzeit-Routing unter Druck (LUNTE) vs. Planung über
  Mikro-Läufe (ECHO). SCHWARM hätte dieselbe Hypothese wie LUNTE („Finger als Avatar in Echtzeit“) mit schlechterer
  Kontrolle getestet und hat nachweislich Prior Art (Swarm Multitouch, iOS 2016).
- Die LUNTE-v1-Simulation zeigte: Zeichentempo statt Entscheidungen bestimmt den Score; Gier ist gratis; das
  Rundenende ist eine versteckte Uhr; Böller verursachen 30–45 % der Tode. Das ist ein Design-, kein Balancing-Befund.

## Umbauten LUNTE v2 (verbindlich)

1. **Sichtbare Luntenrolle statt versteckter Uhr.** Zeichnen verbraucht Lunte (px). Rückerstattung erst, wenn der
   Funke ein aufgefädeltes Feuerwerk erreicht. Ein langer Abstand bindet also „Lunte im Transit“, ein kurzer ist
   riskant – beide Extreme kosten etwas. Die Runde endet, wenn die Rolle leer ist und der Funke dich einholt.
2. **Funkentempo hängt an Zündungen, nicht an der Zeit**, klingt ohne Zündungen langsam ab und ist unter bequemem
   Zeichentempo gedeckelt.
3. **Gier kostet:** Hitze ×2/×3 lässt den Funken 15 % / 30 % schneller brennen.
4. **Kurzschluss-Schleife:** Kreuzt die Lunte sich selbst, werden alle freien Feuerwerke innerhalb der Schleife
   eingeschlossen und zünden gemeinsam, wenn das Feuer die Kreuzung erreicht – dafür springt das Feuer näher heran.
5. **Keine unsichtbaren Tode:** Radius aufgefädelter Böller sichtbar; Luntenstücke im Radius glühen rot.
6. **Ergonomie:** Start im mittleren Drittel; Abstandsanzeige oben; Versatz-Cursor und Relativ-Modus als A/B;
   Umgreif-Toleranz (Funke 0,5 s verlangsamt, solange kein Finger die Lunte hält).
7. **Multitouch:** Doppelzünder ist im Kerntest **aus** (Konfiguration `splitter_enabled`). Er bleibt als optionale
   Expertenebene im Code und wird separat gemessen. Begründung des Abweichens vom Kritiker („streichen“): Das Briefing
   verlangt sinnvolle Multitouch-Unterstützung, *wenn* die Mechanik davon profitiert – das soll ein Test zeigen,
   nicht eine Vorab-Meinung. Die Eingabeschicht bleibt vollständig multitouchfähig und getestet.

## Abbruchkriterien (vor jedem Test fixiert, nicht nachträglich änderbar)

**LUNTE v2 – Bot-Abnahme (in dieser Umgebung messbar):**
- B1: Bei gleichem Zeichentempo überlebt das gierige Profil (0,75 s Abstand) im Median **mindestens 15 % kürzer**
  als das vorsichtige (2,2 s). Sonst ist die Risikomechanik gescheitert.
- B2: Zeichentempo 230 → 400 px/s bei gleichem Abstand verändert den Median-Score um **höchstens Faktor 1,6**
  (v1: Faktor 3,2). Sonst dominiert Motorik.
- B3: Unter **15 %** der Tode durch Böller (v1: 30–45 %).
- B4: Median-Rundendauer aller Profile zwischen **45 s und 150 s**.

**LUNTE v2 – Menschen (Gerätetest, nicht in dieser Umgebung möglich):** wie `CRITIC_REVIEW.md` §5.1
(R² Zeichentempo→Score ≤ 0,5; ≤ 20 % unerklärte Tode; ≥ 3/5 spielen nach Runde 10 ungefragt weiter).

**ECHO – Bot-Abnahme:**
- E1: Ein Bot ohne Echo-Nutzung (nur aktueller Lauf) erreicht im Median **höchstens 40 %** des Scores eines Bots mit
  Echo-Planung. Sonst sind Echos nicht nötig.
- E2: Mindestens **zwei** unterschiedliche Bot-Strategien erreichen im Median ≥ 80 % des Bestwerts
  (keine einzelne Rezeptlösung).

**ECHO – Menschen:** wie `CRITIC_REVIEW.md` §5.2.

**Gesamt:** Scheitern beide Prototypen an ihren Kriterien, folgt ein Totalneustart der Ideenphase (kein Rückgriff
auf die Plätze 3–5). Ergebnisse der Neuideen-Runde werden vom Kritiker bewertet, bevor sie Prototypen ersetzen.
