uint rngState;

void seedRandom(uint seed) {
    rngState = seed;
}

float randomFloat() {
    rngState = (rngState ^ 61u) ^ (rngState >> 16u);
    rngState *= 9u;
    rngState = rngState ^ (rngState >> 4u);
    rngState *= 0x27d4eb2du;
    rngState = rngState ^ (rngState >> 15u);

    return float(rngState) / float(0xffffffffu);
}

float randomRange(float min, float max) {
    return min + (max - min) * randomFloat();
}
