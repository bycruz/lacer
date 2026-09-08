struct Ray {
    vec3 origin;
    vec3 direction;
};

Ray rayGenerate(vec2 pixel, vec2 screen) {
    vec2 uv = (pixel + 0.5) / screen;
    vec2 ndc = vec2(uv.x * 2.0 - 1.0, -(uv.y * 2.0 - 1.0));

    float aspectRatio = screen.x / screen.y;
    float halfHeight = tan(radians(camera.up.w) / 2.0);
    float halfWidth = halfHeight * aspectRatio;

    vec3 target = camera.pos.xyz
        + camera.forward.xyz
        + ndc.x * halfWidth * camera.right.xyz
        + ndc.y * halfHeight * camera.up.xyz;

    return Ray(camera.pos.xyz, normalize(target - camera.pos.xyz));
}
