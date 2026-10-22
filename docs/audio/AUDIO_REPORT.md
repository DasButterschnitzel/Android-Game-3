# Audio-Prüfbericht (automatisch)

Erzeugt von `tools/audio/analyze_audio.py`. Objektive Messwerte – ersetzen kein Anhören auf echten Geräten.

Regeln: Peak ≤ −0,9 dBFS, kein Clipping, |DC| ≤ 0,005, < 35 % Energie unter 80 Hz, Loop-Naht ≤ 25× typischer Sampleschritt.

| Datei | Dauer s | Peak dBFS | RMS dBFS | <80 Hz | Schwerpunkt Hz | Loop-Naht |
|---|---|---|---|---|---|---|
| music/heat_loop.ogg | 23.50 | -16.0 | -27.8 | 0 % | 249 | 1.0× |
| music/night_loop.ogg | 24.00 | -16.0 | -30.4 | 0 % | 383 | 0.9× |
| sfx/banger_0.wav | 1.00 | -2.5 | -18.6 | 0 % | 171 | – |
| sfx/banger_1.wav | 0.99 | -2.5 | -17.6 | 0 % | 165 | – |
| sfx/burst_0.wav | 1.21 | -4.0 | -29.7 | 0 % | 2005 | – |
| sfx/burst_1.wav | 1.21 | -4.0 | -29.0 | 0 % | 2014 | – |
| sfx/burst_2.wav | 1.20 | -4.0 | -30.1 | 0 % | 2058 | – |
| sfx/caught.wav | 2.10 | -2.5 | -18.1 | 1 % | 238 | – |
| sfx/dawn.wav | 4.12 | -2.5 | -15.9 | 0 % | 601 | – |
| sfx/draw_loop.wav | 2.00 | -14.0 | -28.1 | 0 % | 3820 | 0.0× |
| sfx/flare.wav | 0.45 | -6.0 | -19.5 | 0 % | 846 | – |
| sfx/fuse_loop.wav | 2.25 | -14.0 | -32.2 | 0 % | 2671 | 0.0× |
| sfx/loop_closed.wav | 2.36 | -4.0 | -21.1 | 0 % | 1265 | 0.0× |
| sfx/note_0.wav | 2.03 | -6.0 | -20.9 | 0 % | 1657 | – |
| sfx/note_1.wav | 1.97 | -6.0 | -19.9 | 0 % | 1482 | – |
| sfx/note_2.wav | 1.85 | -6.0 | -21.9 | 0 % | 2331 | – |
| sfx/note_3.wav | 1.84 | -6.0 | -19.5 | 0 % | 2001 | – |
| sfx/note_4.wav | 1.93 | -6.0 | -19.3 | 0 % | 2071 | – |
| sfx/note_5.wav | 1.94 | -6.0 | -20.6 | 0 % | 3089 | – |
| sfx/note_6.wav | 1.84 | -6.0 | -19.7 | 0 % | 3254 | – |
| sfx/note_7.wav | 1.82 | -6.0 | -19.3 | 0 % | 3365 | – |
| sfx/note_8.wav | 1.93 | -6.0 | -19.1 | 0 % | 3848 | – |
| sfx/note_9.wav | 1.75 | -6.0 | -18.1 | 0 % | 4003 | – |
| sfx/rocket.wav | 0.75 | -6.0 | -12.1 | 0 % | 1073 | – |
| sfx/short_circuit.wav | 1.83 | -2.5 | -18.6 | 0 % | 1774 | – |
| sfx/spool_low.wav | 0.18 | -9.0 | -21.3 | 0 % | 880 | – |
| sfx/thread_0.wav | 0.35 | -9.0 | -23.5 | 0 % | 1816 | – |
| sfx/thread_1.wav | 0.35 | -9.0 | -23.2 | 0 % | 2031 | – |
| sfx/thread_2.wav | 0.35 | -9.0 | -22.1 | 0 % | 2291 | – |
| sfx/ui_back.wav | 0.06 | -9.0 | -25.2 | 0 % | 2064 | – |
| sfx/ui_tap.wav | 0.20 | -9.0 | -23.7 | 0 % | 2048 | – |

Keine Regelverletzungen.
