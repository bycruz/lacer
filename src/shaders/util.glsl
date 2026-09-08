uint packColor(vec3 color) {
    uint r = uint(clamp(color.r * 255.0, 0.0, 255.0));
    uint g = uint(clamp(color.g * 255.0, 0.0, 255.0));
    uint b = uint(clamp(color.b * 255.0, 0.0, 255.0));
    return r | (g << 8u) | (b << 16u) | (0xFFu << 24u);
}
