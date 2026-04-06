# EX-001 — Filter Dynamics (1st vs 2nd Order)

## Hypothesis

Second-order spring-damper dynamics produce smoother position tracking with
tunable overshoot and settling behavior compared to first-order velocity
relaxation, at the cost of higher peak velocities.

## Independent Variables

- **DYNAMICS_ORDER**: 1 (first-order relaxation) vs 2 (spring-damper)
- **ZETA**: damping ratio (0.2, 1.0, 1.5) — sweep at OMEGA=12.0
- **OMEGA**: natural frequency (2.0, 6.0, 12.0 rad/s) — sweep at ZETA=1.0

## Controlled Baseline

Reference: EX-000_Baseline / CFG-000_baseline.txt
Control signals: Drive=sin(0.5t), Snap=cos(0.25t), Glare=Drive*Snap

## Procedure

1. Run 60s deterministic simulation at 60 FPS
2. Log position, velocity, and control signals per frame
3. Compute RMS, peak, tracking error, and energy metrics
4. Compare across parameter sweeps

## Runs

| Run | Order | OMEGA | ZETA | Purpose |
|-----|-------|-------|------|---------|
| R001 | 1 | - | - | 1st-order baseline |
| R002 | 2 | 12.0 | 1.0 | 2nd-order baseline |
| R003 | 1 | - | - | 1st-order rerun (corrected) |
| R004 | 2 | 12.0 | 0.2 | ZETA sweep: underdamped |
| R005 | 2 | 12.0 | 1.0 | ZETA sweep: critical |
| R006 | 2 | 12.0 | 1.5 | ZETA sweep: overdamped |
| R007 | 2 | 2.0 | 1.0 | OMEGA sweep: low |
| R008 | 2 | 6.0 | 1.0 | OMEGA sweep: mid |
| R009 | 2 | 12.0 | 1.0 | OMEGA sweep: high |

## Results

### ZETA Sweep (R004-R006)

| Run | ZETA | err_pos_rms | vel_energy |
|-----|------|-------------|------------|
| R004 | 0.2 | 0.0547 | 24.25 |
| R005 | 1.0 | 0.1216 | 15.79 |
| R006 | 1.5 | 0.1784 | 14.75 |

Lower ZETA = tighter tracking but much higher velocity energy (overshoot).

### OMEGA Sweep (R007-R009)

| Run | OMEGA | err_pos_rms | vel_peak_abs |
|-----|-------|-------------|-------------|
| R007 | 2.0 | 0.4523 | 0.760 |
| R008 | 6.0 | 0.1612 | 2.254 |
| R009 | 12.0 | 0.0813 | 4.620 |

Higher OMEGA = tighter tracking but increasingly aggressive velocities.

## Interpretation

The spring-damper model (2nd order) provides a rich parameter space for
controlling the visual-temporal character of motion:
- **Underdamped** (low ZETA): springy, energetic, ringing — suitable for percussive/energetic audio
- **Critically damped** (ZETA=1.0): smooth convergence, no overshoot — neutral baseline
- **Overdamped** (high ZETA): sluggish, heavy — suitable for ambient/drone audio
- **OMEGA** controls responsiveness independent of damping character

These dynamics form the foundation for audio-reactive visual control.
