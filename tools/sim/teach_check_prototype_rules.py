#!/usr/bin/env python3
"""Evidence for ADR 0003: under the PROTOTYPE rules (instant hit on contact, no
recharge), can ONE light hit both teaching shadows that the critic proposed
(two shadows close to the core, opposite sides, arriving together)?
Exhaustive search over pairs of hit times; geometry of the 0.2 teaching wave draft
(distance 230 px, 150 px/s, core radius 40, hit radius 38, light starts 260 px below).
Result: yes at 300, 520 and 900 px/s -> geometry alone cannot make it unsolvable."""
import math
core=(360.0, 130+1130*0.36)
d=230.0; v=150.0; R=40.0; hr=38.0; spawn=1.0
start=(core[0], core[1]+260)
def pos(side,t):
    fx,fy=core[0]+side*d, core[1]-d*0.35
    dx,dy=core[0]-fx, core[1]-fy; L=math.hypot(dx,dy)
    tr=max(0.0,(t-spawn))*v; tr=min(tr,L)
    return (fx+dx/L*tr, fy+dy/L*tr), L
def leak_t():
    _,L=pos(-1,spawn); return spawn+(L-R)/v
tl=leak_t()
for s in (300,520,900):
    ok=False
    ts=[spawn+i*(tl-spawn)/400 for i in range(400)]
    for ta in ts:
        A,_=pos(-1,ta)
        # reach A's hit disk from start by ta
        if math.dist(start,A)-hr > s*ta: continue
        for tb in ts:
            if tb<ta: continue
            B,_=pos(1,tb)
            if math.dist(A,B)-2*hr <= s*(tb-ta):
                ok=True;break
        if ok:break
    print(f"speed {s}: one light solves teaching wave = {ok}  (window {tl-spawn:.2f}s)")
