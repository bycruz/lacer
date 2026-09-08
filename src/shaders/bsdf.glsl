struct BsdfSample {
    vec3 direction;
    vec3 reflectance;
    float probability;
};

vec3 sampleHemisphereCosine(vec3 normal) {
    float u1 = randomFloat();
    float u2 = randomFloat();

    float cosTheta = sqrt(u1);
    float sinTheta = sqrt(1.0 - u1);
    float phi = TAU * u2;

    vec3 local = vec3(sinTheta * cos(phi), sinTheta * sin(phi), cosTheta);

    vec3 up = abs(normal.z) > 0.999 ? WORLD_FORWARD : WORLD_UP;
    vec3 tangent = normalize(cross(up, normal));
    vec3 bitangent = cross(normal, tangent);

    return local.x * tangent + local.y * bitangent + local.z * normal;
}

BsdfSample bsdfSample(vec3 normal, vec3 viewDir, Material material) {
    float specularProbability = 1.0 - material.roughness;
    float diffuseProbability = material.roughness;

    if (randomFloat() < specularProbability) {
        return BsdfSample(reflect(-viewDir, normal), material.specular, specularProbability);
    }

    return BsdfSample(sampleHemisphereCosine(normal), material.diffuse / PI, diffuseProbability);
}

vec3 bsdfEvaluate(vec3 normal, vec3 viewDir, vec3 toLight, Material material) {
    float nDotL = dot(normal, toLight);
    if (nDotL <= 0.0) {
        return vec3(0.0);
    }

    vec3 diffuse = material.diffuse * (nDotL / PI);

    vec3 halfVector = normalize(toLight + viewDir);
    float nDotH = max(dot(normal, halfVector), 0.0);
    float shininess = (2.0 / (material.roughness * material.roughness)) - 2.0;
    vec3 specular = material.specular * pow(nDotH, shininess) * nDotL;

    return diffuse + specular;
}
