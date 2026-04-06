// =============================================================================
// mx006_phase_organ.ck — MX-006: Phase Space Organ
//
// Phase portrait rendered as GLines trails. Each trail point drives an FM
// voice: position -> carrier freq, velocity -> modulator freq,
// acceleration -> modulation index. You HEAR the shape of the spiral.
//
// Acceleration magnitude drives bloom — underdamped overshoot glows hot.
//
// Usage:
//   chuck src/dynamics.ck src/features.ck src/mx006_phase_organ.ck
//
// Controls:
//   UI panel = adjust omega, zeta, dynamics order
//   Mouse drag = orbit camera
// =============================================================================

// --- Dynamics + Features ---
Dynamics dyn;
Features feat;

// --- Audio: FM Synthesis from Phase Space ---
// Carrier + Modulator -> dac
SinOsc mod => SinOsc car => Gain master => dac;
2 => mod.sync;  // FM mode: modulator output controls carrier frequency

// Base frequencies
220.0 => float BASE_CARRIER;
110.0 => float BASE_MOD;

// Master volume (keep it manageable)
0.15 => master.gain;

// --- Scene ---
GG.windowTitle("MX-006: Phase Space Organ");
GG.scene().backgroundColor(@(0.02, 0.02, 0.04));

GOrbitCamera cam;
cam.pos(@(3.0, 2.0, 3.0));
cam.target(@(0.0, 0.0, 0.0));
GG.scene().camera(cam);

GG.bloom(true);
GG.bloomPass().threshold(0.4);
GG.bloomPass().intensity(0.3);
GG.bloomPass().levels(5);
GG.outputPass().tonemap(OutputPass.ToneMap_ACES);

// --- Phase portrait trail (pos_x vs vel_x as primary, pos_y vs vel_y as depth) ---
1024 => int TRAIL_LEN;

GPoints trail --> GG.scene();
trail.size(0.015);

vec3 positions[TRAIL_LEN];
vec3 colors[TRAIL_LEN];
0 => int head;
0 => int count;

// --- Reference axes ---
GLines axisH --> GG.scene();
GLines axisV --> GG.scene();
axisH.positions([@(-3.0, 0.0), @(3.0, 0.0)]);
axisH.color(@(0.1, 0.1, 0.1));
axisH.width(0.5);
axisV.positions([@(0.0, -3.0), @(0.0, 3.0)]);
axisV.color(@(0.1, 0.1, 0.1));
axisV.width(0.5);

// --- Labels ---
GText labelX --> GG.scene();
labelX.text("pos");
labelX.pos(@(3.2, 0.0, 0.0));
labelX.sca(0.3);
labelX.color(@(0.3, 0.3, 0.3));

GText labelY --> GG.scene();
labelY.text("vel");
labelY.pos(@(0.0, 3.2, 0.0));
labelY.sca(0.3);
labelY.color(@(0.3, 0.3, 0.3));

// --- Current state indicator ---
GSphere state_dot --> GG.scene();
state_dot.sca(0.05);

// --- UI data holders ---
UI_Float ui_omega;
UI_Float ui_zeta;
UI_Float ui_alpha;
UI_Int   ui_order;
UI_Float ui_volume;
UI_Float ui_carrier_base;
UI_Float ui_mod_base;

dyn.omega  => ui_omega.val;
dyn.zeta   => ui_zeta.val;
dyn.alpha  => ui_alpha.val;
(dyn.order - 1) => ui_order.val;
0.15 => ui_volume.val;
BASE_CARRIER => ui_carrier_base.val;
BASE_MOD => ui_mod_base.val;

// Color from acceleration magnitude
fun vec3 accColor(float amag)
{
    Math.min(amag * 0.3, 1.0) => float t;
    if( t < 0.5 )
    {
        t / 0.5 => float s;
        return @(0.05 + 0.35*s, 0.1 + 0.4*s, 0.6 + 0.4*s);  // dark blue -> cyan
    }
    else
    {
        (t - 0.5) / 0.5 => float s;
        return @(0.4 + 0.6*s, 0.5 + 0.5*s, 1.0 - 0.2*s);  // cyan -> hot white
    }
}

// --- Main loop ---
0.0 => float time;

while( true )
{
    GG.nextFrame() => now;
    GG.dt() => float dt;
    time + dt => time;

    // --- UI ---
    if( UI.begin("Phase Space Organ") )
    {
        UI.separatorText("Dynamics");
        if( UI.radioButton("1st Order", ui_order, 0) ) { }
        UI.sameLine();
        if( UI.radioButton("2nd Order", ui_order, 1) ) { }

        UI.slider("Omega", ui_omega, 0.5, 30.0);
        UI.slider("Zeta", ui_zeta, 0.05, 3.0);
        UI.slider("Alpha", ui_alpha, 0.1, 10.0);

        UI.separatorText("FM Synthesis");
        UI.slider("Volume", ui_volume, 0.0, 0.5);
        UI.slider("Carrier Base Hz", ui_carrier_base, 55.0, 880.0);
        UI.slider("Mod Base Hz", ui_mod_base, 20.0, 440.0);

        UI.separatorText("State");
        UI.text("pos: (" + dyn.pos_x$string + ", " + dyn.pos_y$string + ")");
        UI.text("vel: (" + dyn.vel_x$string + ", " + dyn.vel_y$string + ")");
        UI.text("|accel|: " + dyn.accMag()$string);

        if( UI.button("Reset") )
        {
            dyn.reset();
            for( 0 => int i; i < TRAIL_LEN; i++ )
            {
                @(0.0, 0.0, 0.0) => positions[i];
                @(0.0, 0.0, 0.0) => colors[i];
            }
            0 => head => count;
        }
    }
    UI.end();

    // Apply UI
    (ui_order.val() + 1) => dyn.order;
    ui_omega.val() => dyn.omega;
    ui_zeta.val()  => dyn.zeta;
    ui_alpha.val() => dyn.alpha;
    ui_volume.val() => master.gain;
    ui_carrier_base.val() => BASE_CARRIER;
    ui_mod_base.val() => BASE_MOD;

    // --- Update dynamics ---
    feat.update(time);
    dyn.step(feat.Drive, feat.Snap, feat.Glare, dt);

    // --- FM Synthesis from phase space ---
    // Position magnitude -> carrier frequency offset
    // Velocity magnitude -> modulator frequency
    // Acceleration magnitude -> modulation index (depth)
    dyn.posMag() => float pmag;
    dyn.velMag() => float vmag;
    dyn.accMag() => float amag;

    BASE_CARRIER + pmag * 200.0 => car.freq;
    BASE_MOD * (1.0 + vmag * 0.5) => mod.freq;
    amag * 300.0 => mod.gain;  // mod index = mod.gain / mod.freq

    // --- Phase portrait: plot (pos_x, vel_x, pos_y) ---
    // X axis = position, Y axis = velocity, Z axis = second position component
    @(dyn.pos_x, dyn.vel_x, dyn.pos_y) => vec3 phase_pt;
    phase_pt => positions[head];
    accColor(amag) => colors[head];

    // Fade old points
    for( 0 => int i; i < TRAIL_LEN; i++ )
    {
        if( i != head ) colors[i] * 0.996 => colors[i];
    }

    (head + 1) % TRAIL_LEN => head;
    if( count < TRAIL_LEN ) count + 1 => count;

    trail.positions(positions);
    trail.colors(colors);

    // Current state dot — color from acceleration
    state_dot.pos(phase_pt);
    accColor(amag) => vec3 dot_col;
    state_dot.color(dot_col);

    // --- Acceleration-driven bloom ---
    Math.min(0.15 + amag * 0.2, 2.5) => float bloom_i;
    GG.bloomPass().intensity(bloom_i);

    cam.update(dt);
}
