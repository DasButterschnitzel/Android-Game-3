# Audio-Prüfbericht (automatisch)

Erzeugt von `tools/audio/analyze_audio.py`. Objektive Messwerte – ersetzen kein Anhören auf echten Geräten.

Regeln: Peak ≤ −0,9 dBFS, kein Clipping, |DC| ≤ 0,005, < 35 % Energie unter 80 Hz, kein isolierter Klick (≤ 15 dB über den Nachbar-Frames oberhalb 9 kHz), Loop-Naht ≤ 25× typischer Sampleschritt.

| Datei | Dauer s | Peak dBFS | RMS dBFS | <80 Hz | Schwerpunkt Hz | Klick dB | Loop-Naht |
|---|---|---|---|---|---|---|---|
| music/heat_loop.ogg | 23.50 | -16.0 | -27.8 | 0 % | 249 | 0 | 1.0× |
| music/night_loop.ogg | 24.00 | -16.0 | -30.4 | 0 % | 383 | 1 | 0.9× |
| sfx/banger_0.wav | 0.97 | -2.5 | -18.5 | 0 % | 171 | 3 | – |
| sfx/banger_1.wav | 0.99 | -2.5 | -17.6 | 0 % | 165 | 1 | – |
| sfx/burst_0.wav | 1.18 | -4.0 | -29.5 | 0 % | 2005 | 9 | – |
| sfx/burst_1.wav | 1.18 | -4.0 | -28.9 | 0 % | 2014 | 10 | – |
| sfx/burst_2.wav | 1.18 | -4.0 | -30.0 | 0 % | 2058 | 6 | – |
| sfx/caught.wav | 2.10 | -2.5 | -18.1 | 1 % | 238 | 2 | – |
| sfx/dawn.wav | 4.12 | -2.5 | -15.9 | 0 % | 601 | 0 | – |
| sfx/draw_loop.wav | 2.00 | -14.0 | -28.1 | 0 % | 3820 | 2 | 0.0× |
| sfx/flare.wav | 0.45 | -6.0 | -19.5 | 0 % | 846 | 2 | – |
| sfx/fuse_loop.wav | 2.25 | -14.0 | -32.2 | 0 % | 2671 | 3 | 0.0× |
| sfx/loop_closed.wav | 2.32 | -4.0 | -21.0 | 0 % | 1265 | 0 | 0.0× |
| sfx/nh_crack_0.wav | 0.25 | -6.0 | -24.0 | 0 % | 5543 | 0 | – |
| sfx/nh_crack_1.wav | 0.25 | -6.0 | -24.4 | 0 % | 4699 | 0 | – |
| sfx/nh_dawn.wav | 5.25 | -2.5 | -17.9 | 0 % | 838 | 1 | – |
| sfx/nh_echo_0.wav | 2.84 | -6.0 | -20.1 | 0 % | 653 | 0 | – |
| sfx/nh_echo_1.wav | 2.72 | -6.0 | -22.1 | 0 % | 860 | 3 | – |
| sfx/nh_echo_2.wav | 2.74 | -6.0 | -22.5 | 0 % | 1057 | 3 | – |
| sfx/nh_echo_3.wav | 2.60 | -6.0 | -24.4 | 0 % | 1241 | 3 | – |
| sfx/nh_echo_4.wav | 2.82 | -6.0 | -24.7 | 0 % | 1394 | 5 | – |
| sfx/nh_echo_5.wav | 2.44 | -6.0 | -21.8 | 0 % | 1424 | 8 | – |
| sfx/nh_flame_out.wav | 1.80 | -4.0 | -25.7 | 0 % | 1071 | 2 | – |
| sfx/nh_lantern_out.wav | 4.04 | -2.5 | -17.0 | 0 % | 880 | 1 | – |
| sfx/nh_leak.wav | 1.55 | -4.0 | -22.2 | 2 % | 229 | 2 | – |
| sfx/nh_live_0.wav | 1.58 | -6.0 | -18.3 | 0 % | 1082 | 0 | – |
| sfx/nh_live_1.wav | 1.63 | -6.0 | -19.1 | 0 % | 1644 | 0 | – |
| sfx/nh_live_2.wav | 1.75 | -6.0 | -19.0 | 0 % | 1706 | 0 | – |
| sfx/nh_live_3.wav | 1.74 | -6.0 | -18.7 | 0 % | 1892 | 0 | – |
| sfx/nh_live_4.wav | 1.61 | -6.0 | -18.8 | 0 % | 2626 | 0 | – |
| sfx/nh_live_5.wav | 1.69 | -6.0 | -20.2 | 0 % | 3144 | 0 | – |
| sfx/nh_perfect.wav | 2.19 | -4.0 | -22.3 | 0 % | 1160 | 1 | – |
| sfx/nh_puff_0.wav | 0.71 | -6.0 | -28.7 | 2 % | 742 | 1 | – |
| sfx/nh_puff_1.wav | 0.74 | -6.0 | -25.4 | 1 % | 708 | 0 | – |
| sfx/nh_puff_2.wav | 0.75 | -6.0 | -26.9 | 2 % | 707 | 0 | – |
| sfx/nh_ready.wav | 0.16 | -18.0 | -33.0 | 0 % | 2592 | 0 | – |
| sfx/nh_run_start.wav | 0.58 | -9.0 | -25.5 | 0 % | 1267 | 3 | – |
| sfx/nh_second_light.wav | 0.66 | -6.0 | -19.6 | 0 % | 1956 | 2 | – |
| sfx/nh_tick_0.wav | 0.08 | -18.0 | -36.7 | 0 % | 4787 | 0 | – |
| sfx/nh_tick_1.wav | 0.08 | -18.0 | -34.2 | 0 % | 4106 | 0 | – |
| sfx/nh_twin_link.wav | 3.12 | -4.0 | -20.0 | 0 % | 1108 | 0 | – |
| sfx/nh_twin_ping.wav | 0.25 | -9.0 | -22.1 | 0 % | 2581 | 7 | – |
| sfx/nh_wave_bell.wav | 3.23 | -4.0 | -22.1 | 0 % | 341 | 0 | – |
| sfx/note_0.wav | 2.00 | -6.0 | -20.8 | 0 % | 1658 | 0 | – |
| sfx/note_1.wav | 1.94 | -6.0 | -19.8 | 0 % | 1483 | 0 | – |
| sfx/note_2.wav | 1.82 | -6.0 | -21.9 | 0 % | 2332 | 0 | – |
| sfx/note_3.wav | 1.74 | -6.0 | -19.3 | 0 % | 2001 | 0 | – |
| sfx/note_4.wav | 1.90 | -6.0 | -19.2 | 0 % | 2072 | 0 | – |
| sfx/note_5.wav | 1.87 | -6.0 | -20.5 | 0 % | 3089 | 0 | – |
| sfx/note_6.wav | 1.80 | -6.0 | -19.6 | 0 % | 3255 | 0 | – |
| sfx/note_7.wav | 1.70 | -6.0 | -19.0 | 0 % | 3367 | 0 | – |
| sfx/note_8.wav | 1.83 | -6.0 | -18.9 | 0 % | 3849 | 0 | – |
| sfx/note_9.wav | 1.72 | -6.0 | -18.1 | 0 % | 4004 | 0 | – |
| sfx/rocket.wav | 0.75 | -6.0 | -12.1 | 0 % | 1073 | 2 | – |
| sfx/short_circuit.wav | 1.85 | -2.5 | -18.6 | 0 % | 1774 | 2 | – |
| sfx/spool_low.wav | 0.18 | -9.0 | -21.3 | 0 % | 880 | 0 | – |
| sfx/thread_0.wav | 0.35 | -9.0 | -23.5 | 0 % | 1818 | 0 | – |
| sfx/thread_1.wav | 0.35 | -9.0 | -23.2 | 0 % | 2033 | 0 | – |
| sfx/thread_2.wav | 0.35 | -9.0 | -22.1 | 0 % | 2293 | 0 | – |
| sfx/ui_back.wav | 0.06 | -9.0 | -25.2 | 0 % | 2064 | 0 | – |
| sfx/ui_tap.wav | 0.20 | -9.0 | -23.8 | 0 % | 2049 | 0 | – |

Keine Regelverletzungen.
