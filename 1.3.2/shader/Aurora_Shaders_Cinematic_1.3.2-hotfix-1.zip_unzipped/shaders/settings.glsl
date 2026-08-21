#define STYLE 0 // [0 1]
#define WAVING_PLANTS
#define CUSTOM_FOG
#define UNDERWATER_FX
#define DYNAMIC_SHADOWS
#define VOLUMETRIC_LIGHT
#define COLORED_BLOCKLIGHT
#define LIGHT_SHAFTS
#define NIGHT_NEBULA
#define CUSTOM_CLOUDS
#define REFLECTIONS
#define ANTIALIASING 2 // [0 1 2]
#define SHADOW_QUALITY 2 // [1 2 3]
#define VL_SAMPLES 12 // [6 12 24]
#define SHAFT_SAMPLES 16 // [8 16 32]
#define SSR_STEPS 24 // [12 24 48]
#define NEBULA_OCTAVES 3 // [2 3 5]
const int shadowMapResolution = 1024 + SHADOW_QUALITY*1024;
const float shadowDistance = 128.0;
const float sunPathRotation = -30.0;
const bool colortex7Clear=false;
