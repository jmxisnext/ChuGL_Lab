import csv, math, os

RUNS = [
    ("EX-001-R007", 2.0),
    ("EX-001-R008", 6.0),
    ("EX-001-R009", 12.0),
]

BASE = "03_EXPERIMENTS/EX-001_Filter_Dynamics_1st_vs_2nd_Order/{rid}/runs/{rid}/log.csv"
OUT  = "01_PLANNING/omega_sweep_metrics.csv"

FIELDS = [
    "Run_ID","OMEGA",
    "n_rows","t_start","t_end","dt_mean",
    "pos_rms","vel_rms","pos_peak_abs","vel_peak_abs",
    "ctrl_rms",
    "err_pos_rms","err_vel_rms",
    "vel_energy",
]

def rms(vals):
    return math.sqrt(sum(v*v for v in vals)/len(vals)) if vals else float("nan")

def mag3(x,y,z):
    return math.sqrt(x*x + y*y + z*z)

def analyze_one(run_id):
    path = BASE.format(rid=run_id)
    if not os.path.exists(path):
        raise FileNotFoundError(path)

    t = []
    pos_mag = []
    vel_mag = []
    ctrl_mag = []
    err_pos_mag = []
    err_vel_mag = []

    with open(path, newline="", encoding="utf-8") as f:
        r = csv.DictReader(f)
        required = ["Run_ID","t","pos_x","pos_y","pos_z","vel_x","vel_y","vel_z","Drive","Snap","Glare"]
        for k in required:
            if k not in r.fieldnames:
                raise ValueError(f"{run_id}: missing column {k}")

        for row in r:
            if not row.get("t"):
                continue

            ti = float(row["t"])
            px,py,pz = float(row["pos_x"]), float(row["pos_y"]), float(row["pos_z"])
            vx,vy,vz = float(row["vel_x"]), float(row["vel_y"]), float(row["vel_z"])
            d,s,g    = float(row["Drive"]), float(row["Snap"]), float(row["Glare"])

            t.append(ti)

            pm = mag3(px,py,pz)
            vm = mag3(vx,vy,vz)
            cm = mag3(d,s,g)

            pos_mag.append(pm)
            vel_mag.append(vm)
            ctrl_mag.append(cm)

            err_pos_mag.append(mag3(px - d, py - s, pz - g))
            err_vel_mag.append(mag3(vx - d, vy - s, vz - g))

    dts = [t[i+1] - t[i] for i in range(len(t)-1)]
    dt_mean = sum(dts) / len(dts)

    vel_energy = sum((vel_mag[i]**2) * dt_mean for i in range(len(vel_mag)))

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
        "vel_energy": vel_energy,
    }

def main():
    rows = []
    for rid, omega in RUNS:
        row = analyze_one(rid)
        row["OMEGA"] = omega
        rows.append(row)

    os.makedirs(os.path.dirname(OUT), exist_ok=True)
    with open(OUT, "w", newline="", encoding="utf-8") as f:
        w = csv.DictWriter(f, fieldnames=FIELDS)
        w.writeheader()
        for row in rows:
            w.writerow(row)

    print(f"Wrote: {OUT}")
    for row in rows:
        print(f"{row['Run_ID']} OMEGA={row['OMEGA']}: err_pos_rms={row['err_pos_rms']:.6f} pos_peak_abs={row['pos_peak_abs']:.6f} vel_peak_abs={row['vel_peak_abs']:.6f} vel_energy={row['vel_energy']:.6f}")

if __name__ == "__main__":
    main()
