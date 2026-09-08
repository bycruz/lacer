struct Cube {
    vec3 min;
    vec3 max;
};

Cube cubeFromPrimitive(Primitive prim) {
    return Cube(vec3(prim.data0, prim.data1, prim.data2.x), prim.data2.yzw);
}

HitInfo intersectCube(Ray ray, Primitive prim) {
    Cube cube = cubeFromPrimitive(prim);

    vec3 invDir = 1.0 / ray.direction;
    vec3 t1 = (cube.min - ray.origin) * invDir;
    vec3 t2 = (cube.max - ray.origin) * invDir;

    vec3 tMin = min(t1, t2);
    vec3 tMax = max(t1, t2);

    float tNear = max(max(tMin.x, tMin.y), tMin.z);
    float tFar = min(min(tMax.x, tMax.y), tMax.z);

    if (tNear > tFar || tFar <= EPSILON) {
        return hitMiss();
    }

    float t = tNear > EPSILON ? tNear : tFar;
    vec3 point = ray.origin + t * ray.direction;

    vec3 center = (cube.min + cube.max) * 0.5;
    vec3 size = cube.max - cube.min;
    vec3 local = point - center;
    vec3 d = abs(local) / (size * 0.5);

    vec3 normal;
    if (d.x >= d.y && d.x >= d.z) {
        normal = vec3(sign(local.x), 0.0, 0.0);
    } else if (d.y >= d.z) {
        normal = vec3(0.0, sign(local.y), 0.0);
    } else {
        normal = vec3(0.0, 0.0, sign(local.z));
    }

    return hitRecord(t, point, normal, 0u);
}
