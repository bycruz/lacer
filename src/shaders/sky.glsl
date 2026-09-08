vec3 skySample(vec3 direction) {
    float t = (-direction.z + 1.0) * 0.5;
    float tSmooth = smoothstep(0.0, 1.0, t);

    vec3 horizonOrange = vec3(0.8, 0.5, 0.2);
    vec3 midSky = vec3(0.4, 0.7, 1.0);
    vec3 zenithBlue = vec3(0.1, 0.3, 0.8);

    vec3 color = tSmooth > 0.5
        ? mix(midSky, zenithBlue, (tSmooth - 0.5) * 2.0)
        : mix(horizonOrange, midSky, tSmooth * 2.0);

    float brightness = 1.0 + 0.3 * sin(direction.x * 2.0) * sin(direction.y * 2.0);

    return color * brightness;
}
