// =============================================================================
// dynamics.ck — Reusable spring-damper / first-order dynamics engine
//
// Public class. Spork or instantiate from any visualization.
// =============================================================================

public class Dynamics
{
    // Config
    2   => int order;       // 1 = first-order, 2 = spring-damper
    12.0 => float omega;    // natural frequency (rad/s)
    1.0  => float zeta;     // damping ratio
    2.0  => float alpha;    // 1st-order relaxation rate

    // State
    0.0 => float pos_x;
    0.0 => float pos_y;
    0.0 => float pos_z;

    0.0 => float vel_x;
    0.0 => float vel_y;
    0.0 => float vel_z;

    // Acceleration (computed each step, useful for bloom etc.)
    0.0 => float acc_x;
    0.0 => float acc_y;
    0.0 => float acc_z;

    // Step the simulation given control targets and dt
    fun void step(float ux, float uy, float uz, float dt)
    {
        if( order == 1 ) step1(ux, uy, uz, dt);
        else             step2(ux, uy, uz, dt);
    }

    // First-order: velocity relaxes toward control
    fun void step1(float ux, float uy, float uz, float dt)
    {
        alpha * (ux - vel_x) => acc_x;
        alpha * (uy - vel_y) => acc_y;
        alpha * (uz - vel_z) => acc_z;

        acc_x * dt +=> vel_x;
        acc_y * dt +=> vel_y;
        acc_z * dt +=> vel_z;

        vel_x * dt +=> pos_x;
        vel_y * dt +=> pos_y;
        vel_z * dt +=> pos_z;
    }

    // Second-order: spring-damper position tracking
    // x'' + 2*zeta*omega*x' + omega^2*x = omega^2*u
    fun void step2(float ux, float uy, float uz, float dt)
    {
        (omega*omega*(ux - pos_x) - 2.0*zeta*omega*vel_x) => acc_x;
        (omega*omega*(uy - pos_y) - 2.0*zeta*omega*vel_y) => acc_y;
        (omega*omega*(uz - pos_z) - 2.0*zeta*omega*vel_z) => acc_z;

        acc_x * dt +=> vel_x;
        acc_y * dt +=> vel_y;
        acc_z * dt +=> vel_z;

        vel_x * dt +=> pos_x;
        vel_y * dt +=> pos_y;
        vel_z * dt +=> pos_z;
    }

    // Acceleration magnitude (for bloom, transient detection)
    fun float accMag()
    {
        return Math.sqrt(acc_x*acc_x + acc_y*acc_y + acc_z*acc_z);
    }

    // Position magnitude
    fun float posMag()
    {
        return Math.sqrt(pos_x*pos_x + pos_y*pos_y + pos_z*pos_z);
    }

    // Velocity magnitude
    fun float velMag()
    {
        return Math.sqrt(vel_x*vel_x + vel_y*vel_y + vel_z*vel_z);
    }

    // Reset state to zero
    fun void reset()
    {
        0.0 => pos_x => pos_y => pos_z;
        0.0 => vel_x => vel_y => vel_z;
        0.0 => acc_x => acc_y => acc_z;
    }
}
