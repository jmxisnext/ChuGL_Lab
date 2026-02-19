# Experiment Protocol

## Run Duration
- Default: 60s (unless experiment overrides)

## Variable Isolation
- Change ONE variable class per experiment.
- Record baseline reference for every run.

## Naming Conventions
- Experiment: EX-###
- Run: EX-###-R###
- Config: CFG-###-*

## Capture Protocol
- Resolution: 1920x1080
- FPS: 60
- Start offset: +3s (optional)
- Input: autopilot/no-input for baseline experiments

## Logging
- Write CSV log with Run_ID, t, pos, vel, and control fields (Drive/Snap/Glare).
