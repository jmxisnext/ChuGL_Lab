// =============================================================================
// vis_explorer.ck — INT-001: Parameter Space Explorer
//
// Interactive tool with UI sliders for omega, zeta, and dynamics order.
// Visualizes state orbit trails in real-time as you tweak parameters.
//
// Usage:
//   chuck src/dynamics.ck src/features.ck src/vis_explorer.ck
//
// Controls:
//   UI panel = adjust dynamics parameters
//   Mouse drag = orbit camera
//   Scroll = zoom
// =============================================================================

// --- Config ---
2048 => int TRAIL_LENGTH;

// --- Dynamics + Features ---
Dynamics dyn;
Features feat;

// --- Scene ---
GG.windowTitle("Parameter Space Explorer");
GG.scene().backgroundColor(@(0.02, 0.02, 0.04));

GOrbitCamera cam;
cam.pos(@(3.0, 2.0, 3.0));
cam.target(@(0.0, 0.0, 0.0));
GG.scene().camera(cam);

GG.bloom(true);
GG.bloomPass().threshold(0.5);
GG.bloomPass().intensity(0.3);
GG.bloomPass().levels(4);
GG.outputPass().tonemap(OutputPass.ToneMap_ACES);

// --- Trail ---
GPoints trail --> GG.scene();
trail.size(0.02);

vec3 positions[TRAIL_LENGTH];
vec3 colors[TRAIL_LENGTH];
0 => int head;
0 => int count;

// --- Target indicator ---
GSphere target_sphere --> GG.scene();
target_sphere.sca(0.03);
target_sphere.color(@(1.0, 1.0, 1.0));

// --- UI data holders ---
UI_Float ui_omega;
UI_Float ui_zeta;
UI_Float ui_alpha;
UI_Int   ui_order;
UI_Bool  ui_reset;
UI_Bool  ui_live;

dyn.omega  => ui_omega.val;
dyn.zeta   => ui_zeta.val;
dyn.alpha  => ui_alpha.val;
(dyn.order - 1) => ui_order.val;  // 0-indexed for radio

fun vec3 velColor(float vmag)
{
    Math.min(vmag * 0.5, 1.0) => float t;
    if( t < 0.33 )
    {
        t / 0.33 => float s;
        return @(0.1, 0.2 + 0.6*s, 0.8 + 0.2*s);
    }
    else if( t < 0.66 )
    {
        (t - 0.33) / 0.33 => float s;
        return @(0.1 + 0.9*s, 0.8 + 0.2*s, 1.0);
    }
    else
    {
        (t - 0.66) / 0.34 => float s;
        return @(1.0, 1.0 - 0.4*s, 1.0 - 0.8*s);
    }
}

// --- Main loop ---
0.0 => float time;

while( true )
{
    GG.nextFrame() => now;
    GG.dt() => float dt;
    time + dt => time;

    // --- UI Panel ---
    if( UI.begin("Dynamics") )
    {
        UI.separatorText("Model");
        if( UI.radioButton("1st Order", ui_order, 0) ) { }
        UI.sameLine();
        if( UI.radioButton("2nd Order", ui_order, 1) ) { }

        UI.separatorText("2nd Order Params");
        UI.slider("Omega", ui_omega, 0.5, 30.0);
        UI.slider("Zeta", ui_zeta, 0.05, 3.0);

        UI.separatorText("1st Order Params");
        UI.slider("Alpha", ui_alpha, 0.1, 10.0);

        UI.separatorText("Actions");
        if( UI.button("Reset State") )
        {
            dyn.reset();
            for( 0 => int i; i < TRAIL_LENGTH; i++ )
            {
                @(0.0, 0.0, 0.0) => positions[i];
                @(0.0, 0.0, 0.0) => colors[i];
            }
            0 => head => count;
        }

        // Info
        UI.separatorText("State");
        UI.text("pos: " + dyn.pos_x$string + ", " + dyn.pos_y$string + ", " + dyn.pos_z$string);
        UI.text("vel_mag: " + dyn.velMag()$string);
        UI.text("acc_mag: " + dyn.accMag()$string);
    }
    UI.end();

    // Apply UI to dynamics
    (ui_order.val() + 1) => dyn.order;
    ui_omega.val() => dyn.omega;
    ui_zeta.val()  => dyn.zeta;
    ui_alpha.val() => dyn.alpha;

    // Update
    feat.update(time);
    dyn.step(feat.Drive, feat.Snap, feat.Glare, dt);

    // Trail
    @(dyn.pos_x, dyn.pos_y, dyn.pos_z) => positions[head];
    velColor(dyn.velMag()) => colors[head];

    for( 0 => int i; i < TRAIL_LENGTH; i++ )
    {
        if( i != head ) colors[i] * 0.997 => colors[i];
    }

    (head + 1) % TRAIL_LENGTH => head;
    if( count < TRAIL_LENGTH ) count + 1 => count;

    trail.positions(positions);
    trail.colors(colors);

    target_sphere.pos(@(feat.Drive, feat.Snap, feat.Glare));

    // Bloom from acceleration
    Math.min(0.1 + dyn.accMag() * 0.15, 2.0) => float bi;
    GG.bloomPass().intensity(bi);

    cam.update(dt);
}
