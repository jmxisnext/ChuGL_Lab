# EX-000 Harness Spec

## Purpose
Provide deterministic conditions for all experiments (no human input variance).

## Determinism Rules
- Procedural test signal only (sin/cos of time)
- Fixed seed (deterministic — no RNG)
- Fixed run duration (default 60s at 60 FPS)
- No human input during headless runs

## Outputs per Run
- CSV log: Run_ID, t, pos, vel, Drive/Snap/Glare

## Implementation Status
1. Procedural control signals (Drive/Snap/Glare) — DONE (src/main.ck, src/features.ck)
2. Feature extraction from live audio — DONE (src/features.ck, live mode)
3. Dynamics engine (1st + 2nd order) — DONE (src/dynamics.ck)
4. CSV logger — DONE (src/main.ck)
5. ChuGL visual layer — DONE (src/vis_orbits.ck, src/vis_explorer.ck)
6. FM sonification — DONE (src/mx006_phase_organ.ck)
