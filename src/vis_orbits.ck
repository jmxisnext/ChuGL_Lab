// =============================================================================
// vis_orbits.ck — VIS-002: 3D State Orbit Trails
//
// Renders the dynamics engine's (pos_x, pos_y, pos_z) trajectory as a
// fading GPoints trail in 3D space. Acceleration magnitude drives bloom.
//
// Usage:
//   chuck src/dynamics.ck src/features.ck src/vis_orbits.ck
//   chuck src/dynamics.ck src/features.ck src/vis_orbits.ck:live  (mic input)
//
// Controls:
//   Mouse drag = orbit camera
//   Scroll = zoom
// =============================================================================

// --- Config ---
1024 => int TRAIL_LENGTH;
0.02 => float POINT_SIZE;

// --- Dynamics + Features ---
Dynamics dyn;
Features feat;

// Check for live mode arg
if( me.args() >= 1 && me.arg(0) == "live" )
{
    feat.goLive();
    <<< "LIVE AUDIO MODE" >>>;
}

// --- Scene setup ---
GG.windowTitle("VIS-002: State Orbit Trails");
GG.scene().backgroundColor(@(0.02, 0.02, 0.04));

// Orbit camera
GOrbitCamera cam;
cam.pos(@(3.0, 2.0, 3.0));
cam.target(@(0.0, 0.0, 0.0));
GG.scene().camera(cam);

// Bloom
GG.bloom(true);
GG.bloomPass().threshold(0.6);
GG.bloomPass().intensity(0.3);
GG.bloomPass().levels(4);

// Output pass
GG.outputPass().tonemap(OutputPass.ToneMap_ACES);

// --- Trail points ---
GPoints trail --> GG.scene();
trail.size(POINT_SIZE);

vec3 positions[TRAIL_LENGTH];
vec3 colors[TRAIL_LENGTH];
0 => int head;
0 => int count;

// Color palette: map velocity magnitude to warm->cool gradient
fun vec3 velColor(float vmag)
{
    // Low vel = cool blue, high vel = hot orange/white
    Math.min(vmag * 0.5, 1.0) => float t;
    // Blue -> Cyan -> White -> Orange
    if( t < 0.33 )
    {
        t / 0.33 => float s;
        return @(0.1, 0.2 + 0.6*s, 0.8 + 0.2*s);  // blue -> cyan
    }
    else if( t < 0.66 )
    {
        (t - 0.33) / 0.33 => float s;
        return @(0.1 + 0.9*s, 0.8 + 0.2*s, 1.0);  // cyan -> white
    }
    else
    {
        (t - 0.66) / 0.34 => float s;
        return @(1.0, 1.0 - 0.4*s, 1.0 - 0.8*s);  // white -> orange
    }
}

// --- Axis lines (subtle reference) ---
GLines xAxis --> GG.scene();
GLines yAxis --> GG.scene();
GLines zAxis --> GG.scene();

xAxis.positions([@(-2.0, 0.0), @(2.0, 0.0)]);
xAxis.color(@(0.15, 0.05, 0.05));
xAxis.width(0.5);

yAxis.positions([@(0.0, -2.0), @(0.0, 2.0)]);
yAxis.color(@(0.05, 0.15, 0.05));
yAxis.width(0.5);

// Z axis as separate GLines in the XZ plane for depth reference
GLines zAxisLine --> GG.scene();
zAxisLine.positions([@(-2.0, 0.0), @(2.0, 0.0)]);
zAxisLine.color(@(0.05, 0.05, 0.15));
zAxisLine.width(0.5);
zAxisLine.rotX(Math.PI / 2.0);

// --- Control target indicator ---
GSphere target_sphere --> GG.scene();
target_sphere.sca(0.03);
target_sphere.color(@(1.0, 1.0, 1.0));

// --- Main render loop ---
0.0 => float time;

while( true )
{
    // Frame sync
    GG.nextFrame() => now;
    GG.dt() => float dt;
    time + dt => time;

    // Update features and dynamics
    feat.update(time);
    dyn.step(feat.Drive, feat.Snap, feat.Glare, dt);

    // Record trail point
    @(dyn.pos_x, dyn.pos_y, dyn.pos_z) => positions[head];
    velColor(dyn.velMag()) => colors[head];

    // Fade older points
    for( 0 => int i; i < TRAIL_LENGTH; i++ )
    {
        if( i == head ) continue;
        colors[i] * 0.998 => colors[i];  // gradual fade
    }

    (head + 1) % TRAIL_LENGTH => head;
    if( count < TRAIL_LENGTH ) count + 1 => count;

    // Update GPoints
    trail.positions(positions);
    trail.colors(colors);

    // Move target indicator
    target_sphere.pos(@(feat.Drive, feat.Snap, feat.Glare));

    // Acceleration-driven bloom (VIS-001)
    dyn.accMag() => float amag;
    Math.min(0.1 + amag * 0.15, 2.0) => float bloom_intensity;
    GG.bloomPass().intensity(bloom_intensity);

    // Update camera
    cam.update(dt);
}
