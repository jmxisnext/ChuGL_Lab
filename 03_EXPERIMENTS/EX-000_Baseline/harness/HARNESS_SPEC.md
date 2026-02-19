# EX-000 Harness Spec

## Purpose
Provide deterministic conditions for all experiments (no human input variance).

## Determinism Rules
- Procedural test signal only (no file I/O)
- Fixed seed
- Fixed run duration (default 60s)
- Autopilot camera + movement (no keyboard/mouse)
- Fixed spawn schedule (no RNG or fixed RNG seed)

## Outputs per Run
- CSV log: t, pos, vel, Drive/Snap/Glare (even if placeholders at first)
- Meta JSON: Run_ID, commit hash, config ID, seed, duration
- Capture MP4: fixed resolution/FPS

## Next Implementation Steps
1) Implement procedural audio generator (DeterministicSignal)
2) Implement feature extraction stubs for Drive/Snap/Glare (or placeholders)
3) Implement autopilot path generator (Spline/Parametric)
4) Wire logger and meta writer to Run_ID paths
