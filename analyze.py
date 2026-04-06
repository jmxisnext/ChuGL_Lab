"""
Unified analysis script for EX-001 experiment runs.

Usage:
    python analyze.py compare R002 R003
    python analyze.py sweep zeta R004:0.2 R005:1.0 R006:1.5
    python analyze.py sweep omega R007:2.0 R008:6.0 R009:12.0

Output CSV is written to 01_PLANNING/<name>_metrics.csv
"""

import csv, math, os, sys

BASE = "03_EXPERIMENTS/EX-001_Filter_Dynamics_1st_vs_2nd_Order"

METRIC_FIELDS = [
    "n_rows", "t_start", "t_end", "dt_mean",
    "pos_rms", "vel_rms", "pos_peak_abs", "vel_peak_abs",
    "ctrl_rms", "err_pos_rms", "err_vel_rms", "vel_energy",
]


def rms(vals):
    return math.sqrt(sum(v * v for v in vals) / len(vals)) if vals else float("nan")


def mag3(x, y, z):
    return math.sqrt(x * x + y * y + z * z)


def analyze(run_id):
    path = os.path.join(BASE, run_id, "runs", run_id, "log.csv")
    if not os.path.exists(path):
        raise FileNotFoundError(path)

    t, pos_mag, vel_mag, ctrl_mag = [], [], [], []
    err_pos_mag, err_vel_mag = [], []

    with open(path, newline="", encoding="utf-8") as f:
        reader = csv.DictReader(f)
        for row in reader:
            if not row.get("t"):
                continue
            ti = float(row["t"])
            px, py, pz = float(row["pos_x"]), float(row["pos_y"]), float(row["pos_z"])
            vx, vy, vz = float(row["vel_x"]), float(row["vel_y"]), float(row["vel_z"])
            d, s, g = float(row["Drive"]), float(row["Snap"]), float(row["Glare"])

            t.append(ti)
            pos_mag.append(mag3(px, py, pz))
            vel_mag.append(mag3(vx, vy, vz))
            ctrl_mag.append(mag3(d, s, g))
            err_pos_mag.append(mag3(px - d, py - s, pz - g))
            err_vel_mag.append(mag3(vx - d, vy - s, vz - g))

    if len(t) < 2:
        raise ValueError(f"{run_id}: insufficient rows in {path}")

    dts = [t[i + 1] - t[i] for i in range(len(t) - 1)]
    dt_mean = sum(dts) / len(dts)

    return {
        "Run_ID": run_id,
        "n_rows": len(t) + 1,
        "t_start": t[0],
        "t_end": t[-1],
        "dt_mean": dt_mean,
        "pos_rms": rms(pos_mag),
        "vel_rms": rms(vel_mag),
        "pos_peak_abs": max(pos_mag),
        "vel_peak_abs": max(vel_mag),
        "ctrl_rms": rms(ctrl_mag),
        "err_pos_rms": rms(err_pos_mag),
        "err_vel_rms": rms(err_vel_mag),
        "vel_energy": sum(vel_mag[i] ** 2 * dt_mean for i in range(len(vel_mag))),
    }


def write_csv(rows, fields, out_path):
    os.makedirs(os.path.dirname(out_path), exist_ok=True)
    with open(out_path, "w", newline="", encoding="utf-8") as f:
        w = csv.DictWriter(f, fieldnames=fields)
        w.writeheader()
        for row in rows:
            w.writerow(row)
    print(f"Wrote: {out_path}")


def cmd_compare(args):
    run_ids = [f"EX-001-{r}" for r in args]
    rows = [analyze(rid) for rid in run_ids]
    fields = ["Run_ID"] + METRIC_FIELDS
    tag = "_vs_".join(r.lower() for r in args)
    write_csv(rows, fields, f"01_PLANNING/{tag}_metrics.csv")
    for row in rows:
        print(f"  {row['Run_ID']}: pos_rms={row['pos_rms']:.6f} vel_rms={row['vel_rms']:.6f} "
              f"err_pos_rms={row['err_pos_rms']:.6f}")


def cmd_sweep(args):
    param_name = args[0].upper()
    entries = []
    for entry in args[1:]:
        label, val = entry.split(":")
        run_id = f"EX-001-{label}"
        entries.append((run_id, float(val)))

    rows = []
    for rid, val in entries:
        row = analyze(rid)
        row[param_name] = val
        rows.append(row)

    fields = ["Run_ID", param_name] + METRIC_FIELDS
    write_csv(rows, fields, f"01_PLANNING/{param_name.lower()}_sweep_metrics.csv")
    for row in rows:
        print(f"  {row['Run_ID']} {param_name}={row[param_name]}: "
              f"err_pos_rms={row['err_pos_rms']:.6f} vel_energy={row['vel_energy']:.6f}")


def main():
    if len(sys.argv) < 3:
        print(__doc__)
        sys.exit(1)

    cmd = sys.argv[1]
    args = sys.argv[2:]

    if cmd == "compare":
        cmd_compare(args)
    elif cmd == "sweep":
        cmd_sweep(args)
    else:
        print(f"Unknown command: {cmd}")
        print(__doc__)
        sys.exit(1)


if __name__ == "__main__":
    main()
