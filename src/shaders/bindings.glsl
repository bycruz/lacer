layout(std430, binding = 0) writeonly buffer OutputBuffer {
    uint pixels[];
};

layout(std430, binding = 1) readonly buffer PrimitiveBuffer {
    Primitive primitives[];
};

layout(std430, binding = 3) readonly buffer MaterialBuffer {
    Material materials[];
};

layout(std430, binding = 4) readonly buffer LightBuffer {
    Light lights[];
};
