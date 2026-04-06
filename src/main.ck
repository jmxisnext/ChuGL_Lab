// =============================================================================
// main.ck — Headless dynamics simulation with CSV logging
//
// Usage:
//   chuck src/main.ck:RUN_ID:DYNAMICS_ORDER:OMEGA:ZETA
//
// Examples:
//   chuck src/main.ck:EX-001-R010:2:12.0:1.0
//   chuck src/main.ck:EX-001-R011:1:0:2.0     (1st-order ignores OMEGA)
//
// If no args provided, defaults are used (useful for quick testing).
// =============================================================================

// -----------------------------
// Invariants
// -----------------------------

60.0          => float RUN_SECONDS;
60.0          => float FPS;
1.0 / FPS     => float DT;
(RUN_SECONDS * FPS) $ int => int TOTAL_FRAMES;

// -----------------------------
// Config — from args or defaults
// -----------------------------

// Defaults
"EX-TEST" => string RUN_ID;
2         => int    DYNAMICS_ORDER;
12.0      => float  OMEGA;
1.0       => float  ZETA;
2.0       => float  VEL_ALPHA;   // 1st-order relaxation rate

if( me.args() >= 1 ) me.arg(0) => RUN_ID;
if( me.args() >= 2 ) Std.atoi(me.arg(1)) => DYNAMICS_ORDER;
if( me.args() >= 3 ) Std.atof(me.arg(2)) => OMEGA;
if( me.args() >= 4 ) Std.atof(me.arg(3)) => ZETA;

<<< "RUN_ID=" + RUN_ID + " ORDER=" + DYNAMICS_ORDER +
    " OMEGA=" + OMEGA + " ZETA=" + ZETA >>>;
<<< RUN_ID + " start", now >>>;

// -----------------------------
// Log path (auto-generated from RUN_ID)
// -----------------------------

"03_EXPERIMENTS/EX-001_Filter_Dynamics_1st_vs_2nd_Order/" +
    RUN_ID + "/runs/" + RUN_ID + "/log.csv" => string LOG_PATH;

FileIO log;
if( !log.open(LOG_PATH, FileIO.WRITE) )
{
    <<< "ERROR: cannot open " + LOG_PATH >>>;
    me.exit();
}

log <= "Run_ID,t,pos_x,pos_y,pos_z,vel_x,vel_y,vel_z,Drive,Snap,Glare\n";

// -----------------------------
// State Variables (deterministic)
// -----------------------------

0.0 => float pos_x;
0.0 => float pos_y;
0.0 => float pos_z;

0.0 => float vel_x;
0.0 => float vel_y;
0.0 => float vel_z;

0.0 => float Drive;
0.0 => float Snap;
0.0 => float Glare;

// -----------------------------
// Deterministic Control Law
// -----------------------------

fun void update_controls(float time)
{
    Math.sin(time * 0.5)  => Drive;
    Math.cos(time * 0.25) => Snap;
    (Drive * Snap)        => Glare;
}

// -----------------------------
// Dynamics
// -----------------------------

fun void update_dynamics_first_order()
{
    (VEL_ALPHA * (Drive - vel_x) * DT) +=> vel_x;
    (VEL_ALPHA * (Snap  - vel_y) * DT) +=> vel_y;
    (VEL_ALPHA * (Glare - vel_z) * DT) +=> vel_z;

    vel_x * DT +=> pos_x;
    vel_y * DT +=> pos_y;
    vel_z * DT +=> pos_z;
}

fun void update_dynamics_second_order()
{
    // x'' + 2*zeta*omega*x' + omega^2*x = omega^2*u
    (OMEGA*OMEGA*(Drive - pos_x) - 2.0*ZETA*OMEGA*vel_x) => float ax;
    (OMEGA*OMEGA*(Snap  - pos_y) - 2.0*ZETA*OMEGA*vel_y) => float ay;
    (OMEGA*OMEGA*(Glare - pos_z) - 2.0*ZETA*OMEGA*vel_z) => float az;

    ax * DT +=> vel_x;
    ay * DT +=> vel_y;
    az * DT +=> vel_z;

    vel_x * DT +=> pos_x;
    vel_y * DT +=> pos_y;
    vel_z * DT +=> pos_z;
}

fun void update_dynamics()
{
    if( DYNAMICS_ORDER == 1 ) update_dynamics_first_order();
    else                      update_dynamics_second_order();
}

// -----------------------------
// Frame Loop
// -----------------------------

for( 0 => int frame; frame < TOTAL_FRAMES; frame++ )
{
    frame / FPS => float t;
    update_controls(t);
    update_dynamics();

    log <= RUN_ID + "," +
           t + "," +
           pos_x + "," + pos_y + "," + pos_z + "," +
           vel_x + "," + vel_y + "," + vel_z + "," +
           Drive + "," + Snap + "," + Glare + "\n";

    DT::second => now;
}

<<< RUN_ID + " end", now >>>;
log.close();
