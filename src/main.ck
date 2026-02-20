// -----------------------------
// Invariants
// -----------------------------

60.0          => float RUN_SECONDS;
60.0          => float FPS;
1.0 / FPS     => float DT;
(RUN_SECONDS * FPS) $ int => int TOTAL_FRAMES;

// Run identity (protocol critical)
"EX-001-R006" => string RUN_ID;




<<< RUN_ID + " start", now >>>;
// -----------------------------
// Config (variable isolation)
// -----------------------------
"CFG-001-DYN_ORDER" => string CFG_ID;

// 1 = first-order dynamics, 2 = second-order spring-damper
2 => int DYNAMICS_ORDER;

// 1st-order parameter
2.0 => float VEL_ALPHA;   // relaxation rate

// 2nd-order parameters (spring-damper)
8.0 => float OMEGA;       // natural frequency (rad/s)
1.5 => float ZETA;        // damping ratio
// -----------------------------
// State Variables (deterministic)
// -----------------------------



0.0 => float pos_x;
0.0 => float pos_y;
0.0 => float pos_z;

0.0 => float vel_x;
0.0 => float vel_y;
0.0 => float vel_z;

// Synthetic control signals (NO randomness)
0.0 => float Drive;
0.0 => float Snap;
0.0 => float Glare;

// -----------------------------
// Logging Setup
// -----------------------------

FileIO log;
"log open failed" => string LOG_ERR;

if( !log.open("03_EXPERIMENTS/EX-001_Filter_Dynamics_1st_vs_2nd_Order/EX-001-R006/runs/EX-001-R006/log.csv", FileIO.WRITE ) )
{
    <<< LOG_ERR >>>;
    me.exit();
}

// Write deterministic schema header (overwrite-safe)
log <= "Run_ID,t,pos_x,pos_y,pos_z,vel_x,vel_y,vel_z,Drive,Snap,Glare\n";
// CFG_ID=" + CFG_ID + " DYNAMICS_ORDER=" + DYNAMICS_ORDER + "\n";

// -----------------------------
// Deterministic Control Law
// -----------------------------

fun void update_controls(float time)
{
    // Fully deterministic functions of time
    Math.sin(time * 0.5)  => Drive;
    Math.cos(time * 0.25) => Snap;
    (Drive * Snap)        => Glare;
}

// -----------------------------
// Deterministic Dynamics
// -----------------------------

fun void update_dynamics_first_order()
{
    // vel relaxes toward control (low-pass on velocity)
    // dv/dt = alpha*(u - v)
    (VEL_ALPHA * (Drive - vel_x) * DT) +=> vel_x;
    (VEL_ALPHA * (Snap  - vel_y) * DT) +=> vel_y;
    (VEL_ALPHA * (Glare - vel_z) * DT) +=> vel_z;

    vel_x * DT +=> pos_x;
    vel_y * DT +=> pos_y;
    vel_z * DT +=> pos_z;
}

fun void update_dynamics_second_order()
{
    // spring-damper on position tracking control
    // x'' + 2*zeta*omega*x' + omega^2*x = omega^2*u
    // where u is Drive/Snap/Glare

    // accel = omega^2*(u - x) - 2*zeta*omega*v
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
}// -----------------------------
// Frame Loop (authoritative)
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







