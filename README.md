# ChuGL_lab

A personal lab / sketchbook for experimenting with [ChuGL](https://chuck.stanford.edu/chugl/) — the unified audiovisual programming framework built on top of [ChucK](https://chuck.stanford.edu/).

## About

ChuGL (ChucK Graphics Library) extends ChucK's strongly-timed, concurrent audio synthesis with real-time 2D/3D hardware-accelerated graphics. This repo collects experiments, patches, and mini-projects that explore the intersection of sound and visuals.

## Repository layout

```
ChuGL_lab/
├── examples/     # Self-contained ChuGL sketches and experiments
├── assets/       # Shared media (textures, audio samples, fonts …)
└── docs/         # Notes, diagrams, and references
```

## Prerequisites

- [ChucK ≥ 1.5.2.1](https://chuck.stanford.edu/release/) (ChuGL is bundled on macOS and Windows)
- On Linux, build ChuGL from source: `git clone https://github.com/ccrma/chugl.git`

## Running an example

```bash
chuck examples/hello_chugl.ck
```

## Resources

- ChuGL homepage & API docs: <https://chuck.stanford.edu/chugl/>
- ChuGL source code: <https://github.com/ccrma/chugl>
- ChucK language reference: <https://chuck.stanford.edu/doc/reference/>
