# ChuGL Lab — Capability Manifest

> A living reference for experiment design. What can we build? What tools do we have?
>
> **ChuGL v0.2.9** (WebGPU) | **ChucK 1.5.x** | **WGSL shaders**
>
> Last updated: 2026-04-06

---

## Table of Contents

1. [ChucK Audio Engine](#1-chuck-audio-engine)
2. [ChuGL Graphics Engine](#2-chugl-graphics-engine)
3. [GPU Compute](#3-gpu-compute)
4. [Input & I/O](#4-input--io)
5. [UI System](#5-ui-system)
6. [AI/ML (ChAI)](#6-aiml-chai)
7. [Known Limitations](#7-known-limitations)
8. [Experiment Ideas](#8-experiment-ideas)
9. [Reference Examples](#9-reference-examples)
10. [External References](#10-external-references)

---

## 1. ChucK Audio Engine

### 1.1 Oscillators

| Class | Type |
|-------|------|
| SinOsc | Sine wave |
| TriOsc | Triangle wave |
| SawOsc | Sawtooth wave |
| SqrOsc | Square wave |
| PulseOsc | Pulse (variable duty cycle) |
| Phasor | Phase ramp (0-1 sawtooth) |
| Blit | Band-limited impulse train |
| BlitSaw | Band-limited sawtooth |
| BlitSquare | Band-limited square |

### 1.2 Noise

| Class | Type |
|-------|------|
| Noise | White noise |
| CNoise | Controlled noise (white, pink, etc.) |
| SubNoise | Sample-and-hold noise |

### 1.3 Filters

| Class | Type |
|-------|------|
| LPF | Resonant low-pass |
| HPF | Resonant high-pass |
| BPF | Band-pass |
| BRF | Band-reject (notch) |
| ResonZ | BiQuad with equal-gain zeros |
| BiQuad | Two-pole, two-zero |
| OnePole / OneZero | Single pole/zero |
| TwoPole / TwoZero | Two pole/zero |
| PoleZero | One-pole, one-zero |

### 1.4 Envelopes

| Class | Type |
|-------|------|
| Envelope | General target/time ramp |
| ADSR | Attack-Decay-Sustain-Release |

### 1.5 Delay & Reverb

| Class | Type |
|-------|------|
| Delay | Non-interpolating delay |
| DelayL | Linear interpolating delay |
| DelayA | Allpass interpolating delay |
| Echo | Delay with feedback |
| JCRev | Chowning reverb (allpass + comb) |
| NRev | CCRMA reverb (6 combs + allpass) |
| PRCRev | Perry Cook reverb (2 allpass + combs) |

### 1.6 Effects

| Class | Type |
|-------|------|
| Chorus | Modulation-based chorus |
| PitShift | Delay-based pitch shifter |
| Dyno | Compressor / limiter / expander / gate |

### 1.7 STK Physical Models

**Wind:** Flute, Clarinet, Saxofony, BlowBotl, BlowHole, Brass
**Bowed:** Bowed
**Plucked:** Mandolin, Sitar, StifKarp
**Struck:** BandedWG, ModalBar, Shakers
**Vocal:** VoicForm (4 formants, 32 phonemes)

### 1.8 STK FM Synthesis

| Class | Instrument |
|-------|-----------|
| BeeThree | Hammond B3 organ |
| FMVoices | FM singing voice |
| HevyMetl | Heavy metal distortion |
| HnkyTonk | Honky-tonk piano |
| FrencHrn | French horn |
| PercFlut | Percussive flute |
| Rhodey | Fender Rhodes |
| TubeBell | Tubular bell |
| Wurley | Wurlitzer |
| KrstlChr | Crystal choir |

### 1.9 Sampling & Wavetables

| Class | Type |
|-------|------|
| SndBuf / SndBuf2 | File playback (WAV, AIFF, FLAC, OGG, raw) |
| WvIn / WaveLoop | STK file input / looper |
| WvOut / WvOut2 | File output (WAV, AIFF, MAT, SND) |
| LiSa (2/6/8/10/16) | Live sampling buffer, multi-voice |
| Gen5/7/9/10/17 | CSound-style wavetable generators |

### 1.10 Analysis (UAna)

| Class | Extracts |
|-------|----------|
| FFT / IFFT | Frequency domain transform |
| DCT / IDCT | Cosine transform |
| Centroid | Spectral center of mass |
| Flux | Frame-to-frame spectral change |
| RMS | Root mean square energy |
| RollOff | Frequency below which N% energy lies |
| ZeroX | Zero-crossing rate |
| MFCC | Mel-frequency cepstral coefficients |
| Kurtosis | Spectral peakedness |
| Chroma | 12-bin pitch class vector |
| SFM | Spectral flatness (tonal vs noise) |
| AutoCorr / XCorr | Auto/cross-correlation |
| Flip / UnFlip | Stream-to-frame / frame-to-stream |
| Windowing | Hamming, Hann, Blackman, etc. |
| FeatureCollector | Aggregates multiple features |

### 1.11 System UGens

| Class | Role |
|-------|------|
| dac | Audio output (speakers) |
| adc | Audio input (microphone) |
| blackhole | Sample sink (drives chains without output) |
| Gain | Linear amplitude scaler |
| Pan2 | Stereo equal-power panner |
| Mix2 | Stereo to mono |

### 1.12 ChuGins (Plugin Library)

| ChuGin | Type |
|--------|------|
| ABSaturator | Soft-clip distortion |
| Bitcrusher | Bit-depth / sample-rate reduction |
| Elliptic | Cascaded IIR elliptic filter |
| ExpDelay | Exponential delay times |
| FIR | General FIR filter |
| FoldbackSaturator | Foldback distortion |
| GVerb | Long-tail reverb (gigaverb) |
| KasFilter | Undersampling resonant lowpass |
| MagicSine | Fast recursive sine (30-40% faster) |
| Mesh2D | 2D waveguide mesh (vibrating plate) |
| PitchTrack | Monophonic autocorrelation pitch tracker |
| PowerADSR | Curved-segment ADSR |
| Sigmund | Sinusoidal analysis + pitch tracking (Puckette) |
| Spectacle | FFT spectral delay + EQ |
| WPDiodeLadder | Virtual analog diode ladder LPF |
| WPKorg35 | Virtual analog Korg35 LPF |

### 1.13 Timing Model

- **`now`** — current time (sample-precise, deterministic)
- **`dur`** — duration type: `samp`, `ms`, `second`, `minute`, `hour`, `day`, `week`
- **Time advance**: `1::second => now;` or `event => now;`
- **`spork ~`** — concurrent shreds, non-preemptive, sample-synchronous
- **`Event`** — inter-shred signaling (`.signal()`, `.broadcast()`)

### 1.14 Concurrency

- `spork ~ func()` — spawn concurrent shred
- `me` — current shred reference (`.id()`, `.yield()`, `.exit()`, `.arg()`)
- `Machine.add("file.ck")` — add file as top-level shred at runtime
- `Machine.eval(code)` — evaluate code string at runtime
- Events for synchronization — MidiIn, OscIn, Hid all extend Event

---

## 2. ChuGL Graphics Engine

### 2.1 Scene Graph

```
GGen (base node — transforms + hierarchy)
├── GScene (root container — background, ambient, lights, camera, envmap)
├── GMesh (geometry + material)
│   ├── GCube, GSphere, GTorus, GCylinder, GCircle, GPlane, GKnot, GSuzanne
│   ├── GPolyhedron (tetrahedron, cube, octahedron, dodecahedron, icosahedron)
│   ├── GLines (2D/3D line rendering)
│   └── GPoints (instanced point cloud / particles)
├── GText (SDF font rendering)
├── GModel (OBJ file loading)
├── GLight → GDirLight, GPointLight, GSpotLight
└── GCamera → GOrbitCamera, GFlyCamera
```

**Operators:** `-->` (attach child to parent), `--<` (detach)

### 2.2 Transforms (on every GGen)

- **Position:** `pos(vec3)`, `posWorld(vec3)`, `translate(vec3)`, `posLocalToWorld(vec3)`
- **Rotation:** `rot(vec3 eulers)`, `rotateOnLocalAxis(vec3, float)`, `lookAt(vec3)`
- **Scale:** `sca(vec3)`, `sca(float)`, `scaWorld(vec3)`
- **Direction:** `right()`, `forward()`, `up()`

### 2.3 Geometry

| Class | Description |
|-------|-------------|
| PlaneGeometry | Subdivided quad |
| SphereGeometry | UV sphere (configurable phi/theta) |
| CubeGeometry | Subdivided box |
| CircleGeometry | Disc with segments |
| TorusGeometry | Donut with arc length |
| CylinderGeometry | Configurable top/bottom radii, open-ended |
| KnotGeometry | Trefoil knot (p,q params) |
| SuzanneGeometry | Blender monkey head |
| PolyhedronGeometry | All 5 Platonic solids |
| PolygonGeometry | Arbitrary polygon with holes (earcut triangulation) |
| LinesGeometry | Line strip with per-vertex color |
| **Geometry** (custom) | Set vertex attributes, normals, UVs, indices directly |

### 2.4 Materials

| Material | Lighting | Key Properties |
|----------|----------|----------------|
| PhongMaterial | Blinn-Phong | diffuse, specular, emission, shine, normal/AO/emissive maps, env map (reflect/refract) |
| PBRMaterial | PBR metallic-roughness | albedo, metallic, roughness, normal/AO/MR/emissive maps |
| FlatMaterial | Unlit | color, alpha, texture offset/scale, emissive |
| NormalMaterial | Debug | visualizes normals as RGB |
| WireframeMaterial | Debug | thickness, alpha cutoff, color |
| UVMaterial | Debug | visualizes UV as color |
| LinesMaterial | Unlit | width, color (for GLines) |
| SkyboxMaterial | N/A | cubemap skybox |
| **Material** (custom) | Custom WGSL | uniforms (float/int/vec2/3/4), storage buffers, textures, blend modes, topology, cull mode |

**Blend modes:** Alpha, Additive, Subtract, Multiply, Screen (or custom src/dst/op)

### 2.5 Lighting & Shadows

| Light | Properties |
|-------|-----------|
| GDirLight | Direction via rotation, shadow bounds (halfWidth, halfHeight, depth) |
| GPointLight | Radius, falloff exponent |
| GSpotLight | Range, falloff, inner/outer cone angle, angular falloff |

All lights support: color, intensity, shadow enable, shadow bias, shadow caster registration.

**Note:** Point light shadows not yet implemented.

### 2.6 Cameras

| Camera | Mode |
|--------|------|
| GCamera | Perspective or orthographic, clip planes, FOV, aspect, screen/world conversion |
| GOrbitCamera | Mouse drag orbit around target point |
| GFlyCamera | WASD + mouse-look FPS style |

### 2.7 Render Graph

Default chain: `ScenePass --> OutputPass`
With bloom: `ScenePass --> BloomPass --> OutputPass`

| Pass | Role |
|------|------|
| ScenePass | Renders GScene with GCamera, MSAA support |
| BloomPass | HDR bloom (threshold, levels 0-16, radius, intensity) |
| OutputPass | Tonemapping (None/Linear/Reinhard/ACES) + gamma, exposure |
| ScreenPass | Full-screen fragment shader (custom post-processing) |
| ComputePass | GPU compute shader dispatch |

Chain with `-->` operator. Each pass feeds into the next.

### 2.8 Textures

| Class | Type |
|-------|------|
| Texture | 2D/Cube/3D, load from file/data, GPU read-back, save to disk |
| TextureSampler | Wrap (repeat/mirror/clamp), filter (nearest/linear), mip filter |
| Video | MPEG1 video playback with audio (UGen_Multi) |
| Webcam | Live camera feed as texture |

### 2.9 Text (GText)

SDF-rendered text with: font loading (TTF/OTF), color, alpha, alignment (left/center/right), max width wrapping, size scaling, texture overlay, antialiasing control.

---

## 3. GPU Compute

### 3.1 WGSL Shaders

ChuGL uses **WGSL** (WebGPU Shading Language) for all custom shaders.

**Creating a shader:**
```
ShaderDesc desc;
"vertex code..." => desc.vertexCode;
"fragment code..." => desc.fragmentCode;
Shader shader(desc);
```

**Built-in uniforms (automatically provided):**
- `@group(0) @binding(0)` FrameUniforms: projection, view, camera_pos, ambient, num_lights, resolution, time, dt, frame_count, mouse, sample_rate
- Per-draw: model matrix, normal matrix, object ID

### 3.2 Compute Shaders

```
ShaderDesc desc;
"compute code..." => desc.computeCode;
Shader shader(desc);
ComputePass compute(shader);
compute.workgroup(x, y, z);
```

**Data transfer:**
- `StorageBuffer` — CPU-to-GPU float array, bindable to ComputePass and Material
- `compute.uniformFloat/2/3/4/Int()` — pass uniforms to compute
- `compute.texture()` / `compute.storageTexture()` — bind textures

### 3.3 Screen-Space Shaders

```
ShaderDesc desc;
"#include SCREEN_PASS_VERTEX_SHADER\n" + fragCode => desc.vertexCode;
fragCode => desc.fragmentCode;
ScreenPass screen(Shader(desc));
```

`ScreenPass` renders a full-screen quad — use for post-processing, raymarching, procedural patterns.

---

## 4. Input & I/O

### 4.1 Real-Time Input

| System | Classes | Capabilities |
|--------|---------|-------------|
| Keyboard | GWindow | key held/down/up per-frame, all key codes |
| Mouse | GWindow | position, delta, left/right click, scroll, lock/hide cursor |
| Gamepad | Gamepad | 16 devices, buttons (A/B/X/Y/bumpers/dpad), axes (sticks/triggers) |
| File drop | GWindow | Drag-and-drop file paths |
| MIDI | MidiIn/Out/Msg, MidiFileIn | Device input/output, SMF reading |
| OSC | OscIn/Out/Msg | Network messaging |
| HID | Hid/HidMsg | Raw USB device input |
| Serial | SerialIO | Arduino etc., binary/ASCII modes |
| Webcam | Webcam | Live video as texture |
| Microphone | adc | Live audio input |

### 4.2 File I/O

| Class | Capabilities |
|-------|-------------|
| FileIO | Read/write text/binary, directory listing, seek |
| SndBuf | Read audio files (WAV, AIFF, FLAC, OGG) |
| WvOut | Write audio files (WAV, AIFF, MAT, SND) |

---

## 5. UI System

Built-in **Dear ImGui** integration. All methods on the static `UI` class.

### Widgets Available

| Category | Widgets |
|----------|---------|
| Windows | begin/end, child windows |
| Text | text, colored, disabled, wrapped, bullet, separator |
| Buttons | button, small, invisible, arrow, image button |
| Toggles | checkbox, radio button |
| Sliders | float/int 1-4 component, angle, vertical |
| Drags | float/int 1-4 component, range |
| Input | text (single/multi/hint), float, int |
| Color | color edit, color picker, color button |
| Trees | tree node, collapsing header |
| Selection | selectable, list box |
| Dropdowns | combo / begin+end combo |
| Knobs | float knob, int knob (multiple variants) |
| Menus | menu bar, main menu bar, menu items |
| Tooltips | begin/end, set tooltip |
| Popups | popup, modal, context menus |
| Tables | full table API with headers, sorting, columns |
| Tabs | tab bar, tab items |
| Plots | line plots, histograms |
| Drawing | UI_DrawList: lines, rects, circles, triangles, quads, ngons, beziers, polylines, ellipses, text |
| Layout | separator, same line, spacing, indent, groups |
| Style | push/pop colors, push/pop style vars, full style object |

---

## 6. AI/ML (ChAI)

| Class | Type |
|-------|------|
| MLP | Multi-layer perceptron (forward, backprop, training) |
| KNN / KNN2 | K-nearest neighbors (unlabeled / with class labels) |
| HMM | Hidden Markov Model (sequence generation) |
| SVM | Support vector machine |
| Word2Vec | Word embeddings (load pre-trained, query similarity) |
| PCA | Principal component analysis |
| Wekinator | Interactive ML (input-to-output mapping, real-time) |

---

## 7. Known Limitations

| Area | Limitation |
|------|-----------|
| Memory | ~500KB/min leak from wgpu texture views (pending wgpu update) |
| Shadows | Point light shadows not implemented (spot + dir only) |
| Models | OBJ only (no glTF yet) |
| Video | MPEG1 + MP2 audio only |
| vec3 buffers | WGSL requires 16-byte alignment; vec3[] needs padding for storage buffers |
| Platforms | Linux: build from source. Raspberry Pi 5: known crash |
| Animation | No skeletal animation system |
| IDE | Command-line only (no MiniAudicle support) |

---

## 8. Experiment Ideas

### Tier 1 — Foundation (build first)

| ID | Name | What | ChuGL Features Used | Effort |
|----|------|------|---------------------|--------|
| VIS-001 | Acceleration Bloom | `|accel|` from spring-damper drives BloomPass intensity; transients glow | BloomPass, dynamics engine | Trivial |
| VIS-002 | 3D State Orbit Trails | Render (pos_x, pos_y, pos_z) as GLines/GPoints trail; Lissajous-like morphing | GLines, GPoints, GOrbitCamera | Low |
| VIS-003 | Phase Portrait | Plot (pos, vel) as trails; spirals (underdamped), collapse (overdamped) | GLines, per-vertex color | Low |
| VIS-004 | Dynamics Microscope | Visualize the filter's impulse/step/frequency response as animated curves | GLines, UI sliders | Low |

### Tier 2 — Signature Pieces

| ID | Name | What | ChuGL Features Used | Effort |
|----|------|------|---------------------|--------|
| VIS-005 | Strange Attractor Morphing | Lorenz/Rossler/Clifford as GPoints trails; audio interpolates attractor params via spring-damper | GPoints, BloomPass | Medium |
| VIS-006 | Velocity-Field Particle Advection | Thousands of GPU particles advected through dynamics velocity field | ComputePass, StorageBuffer, GPoints | Medium |
| VIS-007 | Cymatics / Chladni Shader | Chladni plate nodal patterns; mode frequencies driven by audio features | ScreenPass, WGSL | Medium |
| VIS-008 | Resonance Architecture | Filter bank at different omega; each is a glowing column that vibrates at its resonant frequency | GCylinder array, PhongMaterial emission, BloomPass | Medium |
| VIS-009 | Audio-Reactive Mesh Deformation | Spring-damper per vertex of a GSphere; audio drives target positions; mesh wobbles and rings | Custom Geometry, per-frame vertex update | Medium |

### Tier 3 — Advanced

| ID | Name | What | ChuGL Features Used | Effort |
|----|------|------|---------------------|--------|
| VIS-010 | Reaction-Diffusion | Gray-Scott on GPU; Drive/Snap map to feed/kill rates; spots, stripes, waves evolve | ComputePass, StorageBuffer, ScreenPass | Medium-High |
| VIS-011 | SDF Raymarching | ScreenPass WGSL raymarcher; state vector controls smooth-union blending between SDF shapes | ScreenPass, WGSL | High |
| VIS-012 | Elastic Spacetime | Vertex shader displaces all geometry by velocity field; audio transients create gravity-wave ripples | Custom vertex shader, WGSL | High |
| VIS-013 | Coupled Oscillator Lattice | N x N grid of oscillators; Drive controls coupling; Kuramoto synchronization visualized as color/rotation convergence | GPolyhedron array, PBRMaterial | Medium-High |
| VIS-014 | Domain Warping | Nested noise with dynamics state as warp offsets; audio onsets ripple through warp field | ScreenPass, WGSL | Medium |
| VIS-015 | Voronoi Shatter | Spring-damped Voronoi seed points; cells morph as seeds track audio features | ScreenPass, WGSL | Medium |

### Tier 4 — Audio Synthesis Experiments

| ID | Name | What | ChucK Features Used | Effort |
|----|------|------|---------------------|--------|
| AUD-001 | Live Feature Extraction | Extract Drive/Snap/Glare from real audio (FFT -> Centroid, Flux, RMS) replacing synthetic sin/cos | FFT, Centroid, Flux, RMS, adc | Low |
| AUD-002 | Physical Model Orchestra | STK instruments driven by dynamics state; position -> pitch, velocity -> volume, acceleration -> articulation | StkInstruments, spork | Medium |
| AUD-003 | Filter Bank Sonification | Array of resonant filters matching VIS-008; each column sings its resonant frequency | BPF array, Gain, Pan2 | Medium |
| AUD-004 | Granular Texture from State | LiSa granular synthesis where grain rate/position/pitch are driven by spring-damper state | LiSa, SndBuf | Medium |
| AUD-005 | FM Synthesis from Phase Space | Phase space trajectory drives FM modulation index and carrier/modulator ratio | FM UGens, dynamics state | Medium |

### Tier 5 — Interaction & Game

| ID | Name | What | Features Used | Effort |
|----|------|------|---------------|--------|
| INT-001 | Parameter Space Explorer | UI sliders for omega/zeta/order with real-time visualization; educational tool | UI system, GLines, dynamics | Low |
| INT-002 | Gamepad-Driven Dynamics | Gamepad sticks set target position; triggers modulate omega/zeta; live spring-damper response | Gamepad, dynamics, visuals | Medium |
| INT-003 | OSC Control Surface | Receive omega/zeta/drive from external controller (TouchDesigner, Max, phone app) | OscIn, dynamics, visuals | Low |
| INT-004 | Multi-Shred Ensemble | Multiple sporked shreds each running independent dynamics; cross-coupled via Events | spork, Event, multiple GGen trees | Medium |

### Tier 6 — Mad Scientist Mashups

Cross-tier fusions. Each combines 2-4 ideas into something weirder than any single experiment.

| ID | Name | Sources | What | Effort |
|----|------|---------|------|--------|
| MX-001 | The Flesh Raymarcher | VIS-011 + VIS-009 + AUD-001 | Live mic drives raymarched SDF scene where each shape is a spring-damper. Centroid controls smooth-union blend (high freq = sharp, low = melting). Flux drives surface ripples. RMS = heartbeat. | High |
| MX-002 | Cymatics Orchestra | VIS-007 + VIS-013 + AUD-002 | Chladni plate nodes become Kuramoto-coupled oscillators, each driving an STK instrument. Aggregate spectrum feeds back to shift plate mode frequency. Self-composing system. | High |
| MX-003 | Shattered Warp Choir | VIS-014 + VIS-015 + AUD-003 | Domain-warped Voronoi cells where each cell is a resonant filter voice. Cell area = frequency, velocity = Q. Audio onsets shatter cells; geometry sings and singing reshapes geometry. | Medium-High |
| MX-004 | The Spacetime Instrument | INT-002 + VIS-005 + VIS-012 + AUD-005 | Gamepad morphs between strange attractors. Trajectory drives FM synthesis AND warps all geometry via vertex shader. Stick movements create gravitational wave ripples. Sound = shape of space. | High |
| MX-005 | The Living Substrate | VIS-010 + VIS-006 + VIS-013 + AUD-004 | GPU reaction-diffusion terrain with chemotaxis particles. Kuramoto oscillator lattice controls R-D regime shifts. Particle trajectories seed LiSa grains. System grows its own soundtrack. | Very High |
| MX-006 | Phase Space Organ | VIS-003 + AUD-005 + VIS-001 + INT-001 | Phase portrait as GLines trails. Each point is an FM voice (pos->carrier, vel->modulator, accel->mod index). You hear the spiral's shape. Acceleration drives bloom. UI sliders for exploration. | Medium |
| MX-007 | Boids in a Bottle | VIS-006 + VIS-011 + AUD-001 + VIS-001 | GPU boid flock inside a raymarched SDF container that morphs with audio. Boids bounce off SDF boundary. Container shrinks on loud transients — flock panics, screen erupts in bloom. | High |

**Build order:** MX-006 first (validates core pipeline), then MX-003 (shader + audio), then branch into compute (#5, #7) or SDF (#1, #4).

### Cross-Modal Mapping Principles

| Level | Mapping | Example |
|-------|---------|---------|
| Basic | Pitch -> height, loudness -> brightness, timbre -> texture | Standard perceptual correspondences |
| Dynamic | Acceleration -> visual jerk, overshoot -> wobble, settling time -> trail length | Map dynamics of change, not static values |
| Structural | Motifs -> recurring attractor basins, tension -> increasing zeta, resolution -> release to underdamped | Musical structure drives system regime |

---

## 9. Reference Examples

### Official ChuGL Examples (by category)

**Audio-Visual:**
- `deep/audio-donut.ck` — spectrum on a torus surface
- `deep/sndpeek.ck` — waveform + spectrum + waterfall
- `deep/soundbulb.ck` — audio-reactive light
- `deep/particles.ck` — sonified particle system
- `basic/lissajous.ck` — oscilloscope music visualizer
- `basic/jello.ck` — mic input modulates geometry

**GPU Compute:**
- `rendergraph/boids.ck` — flocking with compute shaders
- `rendergraph/slime.ck` — slime mold (compute)
- `deep/game-of-life.ck` — Conway's GoL (fragment shader)

**Custom Shaders:**
- `deep/custom-material.ck` — WGSL vertex/fragment boilerplate
- `rendergraph/shadertoy.ck` — Shadertoy-style screen pass

**Education:**
- `education/additive.ck` — additive synthesis viz
- `education/fm-synthesis.ck` — FM synthesis viz
- `education/karplus-strong.ck` — KS string synthesis
- `education/vocoder.ck` — vocoder viz
- `education/granular.ck` — granular synthesis

**Games:**
- `games/bullet-hell/` — shooter with Box2D
- `games/suika/` — watermelon game
- `games/sonarc/` — audio-focused game
- `games/guqin-visualizer/` — ink wash shader + OSC

---

## 10. External References

### Documentation
- ChuGL API: https://chuck.stanford.edu/chugl/api/
- ChucK Reference: https://chuck.stanford.edu/doc/reference/
- ChuGL GitHub: https://github.com/ccrma/chugl
- ChucK GitHub: https://github.com/ccrma/chuck

### Papers
- "ChuGL: Unified Audiovisual Programming in ChucK" — NIME 2024 (Aday & Wang)
- "What's up ChucK? Development Update 2024" — NIME 2024 (van Zyl et al.)

### Courses & Workshops
- Stanford Music 256A / CS 476A — audiovisual systems in ChucK/ChuGL
- CCRMA Summer Workshop 2026: Audio-Centric Game Design in ChucK/ChuGL (Aug 3-7)

### Visual Art References
- Inigo Quilez SDF functions: https://iquilezles.org/articles/distfunctions/
- Morphogenesis resources: https://github.com/jasonwebb/morphogenesis-resources
- Strange attractors interactive: https://www.dynamicmath.xyz/strange-attractors/
- Cymatics simulator: https://pettaboy.github.io/cymaticssimulator_chladni
- Audio viz in phase space (Bridges 1999): https://archive.bridgesmathart.org/1999/bridges1999-137.pdf
