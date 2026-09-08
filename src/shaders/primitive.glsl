const uint PRIMITIVE_TRIANGLE = 0u;
const uint PRIMITIVE_SPHERE = 1u;
const uint PRIMITIVE_CUBE = 2u;

struct Primitive {
    uint tag;
    uint materialId;
    float data0;
    float data1;
    vec4 data2;
    vec4 data3;
};

HitInfo intersectSphere(Ray ray, Primitive prim);
HitInfo intersectCube(Ray ray, Primitive prim);
HitInfo intersectTriangle(Ray ray, Primitive prim);

HitInfo intersectPrimitive(Ray ray, Primitive prim) {
    HitInfo hit = hitMiss();

    if (prim.tag == PRIMITIVE_SPHERE) {
        hit = intersectSphere(ray, prim);
    } else if (prim.tag == PRIMITIVE_TRIANGLE) {
        hit = intersectTriangle(ray, prim);
    } else if (prim.tag == PRIMITIVE_CUBE) {
        hit = intersectCube(ray, prim);
    }

    if (hit.didHit) {
        hit.materialId = prim.materialId;
    }

    return hit;
}
