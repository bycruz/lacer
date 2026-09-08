bool isOccluded(vec3 pos, vec3 dir, float distance) {
    HitInfo hit = rayTrace(Ray(pos + dir * EPSILON, dir));
    return hit.didHit && length(hit.point - pos) < distance;
}

float computeAttenuation(Light light, float distance) {
    float falloff = distance / light.radius;
    return 1.0 / (1.0 + falloff * falloff);
}

vec3 evaluateDirect(HitInfo hit, vec3 viewDir, Material material) {
    vec3 radiance = vec3(0.0);

    uint count = uint(lights.length());
    for (uint i = 0u; i < count; i++) {
        Light light = lights[i];
        vec3 toLight = normalize(light.pos - hit.point);
        float distance = length(light.pos - hit.point);

        if (isOccluded(hit.point, toLight, distance)) {
            continue;
        }

        vec3 brdf = bsdfEvaluate(hit.normal, viewDir, toLight, material);
        float attenuation = computeAttenuation(light, distance);
        float nDotL = max(dot(hit.normal, toLight), 0.0);
        radiance += brdf * light.color * attenuation * nDotL;
    }

    return radiance;
}

vec3 tracePath(Ray ray, uint maxBounces) {
    vec3 radiance = vec3(0.0);
    vec3 throughput = vec3(1.0);
    Ray currentRay = ray;

    for (uint bounce = 0u; bounce < maxBounces; bounce++) {
        HitInfo hit = rayTrace(currentRay);

        if (!hit.didHit) {
            radiance += skySample(currentRay.direction) * throughput;
            break;
        }

        Material material = materials[hit.materialId];
        vec3 viewDir = -currentRay.direction;

        radiance += evaluateDirect(hit, viewDir, material) * throughput;

        BsdfSample bsdf = bsdfSample(hit.normal, viewDir, material);
        throughput *= bsdf.reflectance / bsdf.probability;

        if (bounce > min(3u, maxBounces / 2u)) {
            float maxComponent = max(max(throughput.x, throughput.y), throughput.z);
            float survivalProbability = min(maxComponent, 0.95);

            if (randomFloat() > survivalProbability) {
                break;
            }

            throughput /= survivalProbability;
        }

        if (max(max(throughput.x, throughput.y), throughput.z) > 10.0) {
            break;
        }

        currentRay = Ray(hit.point + hit.normal * EPSILON, bsdf.direction);
    }

    return radiance;
}
