struct Sphere {
    vec3 center;
    float radius;
};

Sphere sphereFromPrimitive(Primitive prim) {
    return Sphere(prim.data2.xyz, prim.data2.w);
}

HitInfo intersectSphere(Ray ray, Primitive prim) {
    Sphere sphere = sphereFromPrimitive(prim);

    vec3 oc = ray.origin - sphere.center;
    float a = dot(ray.direction, ray.direction);
    float b = 2.0 * dot(oc, ray.direction);
    float c = dot(oc, oc) - sphere.radius * sphere.radius;

    float discriminant = b * b - 4.0 * a * c;
    if (discriminant < 0.0) {
        return hitMiss();
    }

    float root = sqrt(discriminant);
    float t1 = (-b - root) / (2.0 * a);
    float t2 = (-b + root) / (2.0 * a);
    float t = t1 > EPSILON ? t1 : t2;

    if (t <= EPSILON) {
        return hitMiss();
    }

    vec3 point = ray.origin + t * ray.direction;
    return hitRecord(t, point, normalize(point - sphere.center), 0u);
}
