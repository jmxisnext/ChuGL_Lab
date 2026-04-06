# Experiment Protocol

## Run Duration
- Default: 60s (unless experiment overrides)

## Variable Isolation
- Change ONE variable class per experiment.
- Record baseline reference for every run.

## Naming Conventions
- Experiment: EX-###
- Run: EX-###-R###
- Config: passed via CLI args (see src/main.ck)
- Visualization: VIS-### (visual experiments), MX-### (mashups)

## Headless Simulation Runs
- Use `chuck src/main.ck:RUN_ID:ORDER:OMEGA:ZETA`
- Output: CSV log at `03_EXPERIMENTS/.../RUN_ID/runs/RUN_ID/log.csv`

## ChuGL Visual Runs
- Use `chuck src/dynamics.ck src/features.ck src/vis_<name>.ck`
- Real-time rendering at native FPS
- Optional live audio via `:live` arg

## Logging
- CSV schema: Run_ID, t, pos_x, pos_y, pos_z, vel_x, vel_y, vel_z, Drive, Snap, Glare

## Analysis
- Use `python analyze.py compare R002 R003` or `python analyze.py sweep zeta R004:0.2 R005:1.0 R006:1.5`
- Output: CSV metrics to `01_PLANNING/`
