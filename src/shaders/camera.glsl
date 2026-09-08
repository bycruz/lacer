layout(std140, binding = 2) uniform CameraBuffer {
    vec4 pos;
    vec4 forward;
    vec4 right;
    vec4 up;
    uvec2 resolution;
} camera;
