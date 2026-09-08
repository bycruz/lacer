#version 430 core

#include "constants.glsl"
#include "random.glsl"
#include "util.glsl"
#include "camera.glsl"
#include "hit.glsl"
#include "ray.glsl"
#include "primitive.glsl"
#include "material.glsl"
#include "light.glsl"
#include "bindings.glsl"
#include "trace.glsl"
#include "primitive/sphere.glsl"
#include "primitive/cube.glsl"
#include "primitive/triangle.glsl"
#include "bsdf.glsl"
#include "sky.glsl"
#include "path.glsl"

const uint MAX_BOUNCES = 3u;
const uint SAMPLES_PER_PIXEL = 8u;

layout(local_size_x = 8, local_size_y = 8) in;

void main() {
    uvec2 pixel = gl_GlobalInvocationID.xy;
    uvec2 screen = camera.resolution;

    if (pixel.x >= screen.x || pixel.y >= screen.y) {
        return;
    }

    seedRandom(pixel.x * 73856093u + pixel.y * 19349663u + 1u);

    vec3 accumulated = vec3(0.0);
    for (uint i = 0u; i < SAMPLES_PER_PIXEL; i++) {
        accumulated += tracePath(rayGenerate(vec2(pixel), vec2(screen)), MAX_BOUNCES);
    }

    vec3 color = pow(accumulated / float(SAMPLES_PER_PIXEL), vec3(1.0 / 2.2));
    pixels[pixel.y * screen.x + pixel.x] = packColor(color);
}
