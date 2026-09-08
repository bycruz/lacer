struct HitInfo {
    bool didHit;

    float distance;
    vec3 point;
    vec3 normal;

    uint materialId;
};

HitInfo hitMiss() {
    return HitInfo(false, 0.0, vec3(0.0), vec3(0.0), 0u);
}

HitInfo hitRecord(float distance, vec3 point, vec3 normal, uint materialId) {
    return HitInfo(true, distance, point, normal, materialId);
}
