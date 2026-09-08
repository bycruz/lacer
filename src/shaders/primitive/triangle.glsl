struct Triangle {
    vec3 v0;
    vec3 v1;
    vec3 v2;
};

Triangle triangleFromPrimitive(Primitive prim) {
    return Triangle(
        vec3(prim.data0, prim.data1, prim.data2.x),
        prim.data2.yzw,
        prim.data3.xyz
    );
}

HitInfo intersectTriangle(Ray ray, Primitive prim) {
    Triangle triangle = triangleFromPrimitive(prim);

    vec3 edge1 = triangle.v1 - triangle.v0;
    vec3 edge2 = triangle.v2 - triangle.v0;
    vec3 h = cross(ray.direction, edge2);
    float a = dot(edge1, h);

    if (abs(a) < 0.00001) {
        return hitMiss();
    }

    float f = 1.0 / a;
    vec3 s = ray.origin - triangle.v0;
    float u = f * dot(s, h);

    if (u < 0.0 || u > 1.0) {
        return hitMiss();
    }

    vec3 q = cross(s, edge1);
    float v = f * dot(ray.direction, q);

    if (v < 0.0 || u + v > 1.0) {
        return hitMiss();
    }

    float t = f * dot(edge2, q);

    if (t <= EPSILON) {
        return hitMiss();
    }

    vec3 point = ray.origin + t * ray.direction;
    return hitRecord(t, point, normalize(cross(edge1, edge2)), 0u);
}
