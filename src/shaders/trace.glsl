HitInfo rayTrace(Ray ray) {
    HitInfo closest = HitInfo(false, 999999.0, vec3(0.0), vec3(0.0), 0u);

    uint count = uint(primitives.length());
    for (uint i = 0u; i < count; i++) {
        HitInfo hit = intersectPrimitive(ray, primitives[i]);

        if (hit.didHit && hit.distance < closest.distance) {
            closest = hit;
        }
    }

    return closest;
}
