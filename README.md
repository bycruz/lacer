# lacer

A GPU path tracer written in LuaJIT for [lde](https://lde.sh) and [hood](https://github.com/bycruz/hood),
ported from [tracer](https://github.com/bycruz/tracer) (Rust + wgpu + WESL) with the compute shaders
rewritten in GLSL.

It traces the same Cornell box: white walls, a red left wall, a green right wall, a polished metal
sphere and a bronze dragon, lit by a single spherical light, with 8 samples per pixel and 3 bounces.

## Requirements

- [lde](https://lde.sh/docs/general/getting-started/installation)
- A Vulkan driver (default backend) or an OpenGL 4.3+ driver
- `glslc` from the [Vulkan SDK](https://vulkan.lunarg.com/sdk/home) to build the SPIR-V shaders

## Running

```bash
lde run                                     # 1920x1080 to output.png
lde run -- --width 320 --height 180         # quick preview
lde run -- --output small.png               # pick the output file
```

| Option      | Default      | Description              |
| ----------- | ------------ | ------------------------ |
| `--width`   | `1920`       | Render width in pixels   |
| `--height`  | `1080`       | Render height in pixels  |
| `--output`  | `output.png` | Output PNG path          |
| `--backend` | `vulkan`     | `vulkan` or `opengl`     |

The backend can also be set with the `LACER_BACKEND` environment variable; `--backend` wins.

## Testing

```bash
lde test
```

The suite covers the vector and matrix math, the OBJ parser, the PNG encoder, the shader include
resolver, the scene description, option parsing, and a headless GPU render (skipped without Vulkan).

## Layout

```
build.lua                     compiles shaders/*.comp.glsl to SPIR-V with glslc
shaders/
  path.comp.glsl              compute entry point: camera rays, sampling, output
  bindings.glsl               storage and uniform buffers
  camera.glsl                 camera uniform block
  primitive.glsl              primitive tags and intersection dispatch
  primitive/*.glsl            sphere, cube and triangle intersections
  bsdf.glsl                   specular/diffuse sampling and evaluation
  path.glsl                   path tracing, direct lighting, russian roulette
  trace.glsl                  closest hit traversal
  ray.glsl                    camera ray generation
  sky.glsl                    sky gradient
  random.glsl                 per-invocation RNG
src/
  init.lua                    entry point: parse options, render, write the PNG
  scene.lua                   the Cornell box scene
  renderer.lua                device, buffers, compute pipeline, readback
  shader.lua                  shader loading and GLSL include resolution
  model.lua                   OBJ parsing and transforms
  primitive/                  sphere, cube and triangle constructors
  camera.lua material.lua light.lua primitive.lua
  vec3.lua mat4.lua           CPU side math for scene construction
  png.lua                     PNG encoder (stored deflate, no native dependencies)
```

## Notes

- The shaders are a single GLSL source set that works on both backends: `glslc` compiles them to
  SPIR-V for Vulkan, and the OpenGL backend consumes the same source with `#include` resolved in Lua.
- Primitives are packed into a 48-byte struct and intersected in a flat loop, like the original
  tracer, so a full resolution render takes on the order of a minute on a discrete GPU.
- `hood` is consumed as a path dependency (`../hood`).
