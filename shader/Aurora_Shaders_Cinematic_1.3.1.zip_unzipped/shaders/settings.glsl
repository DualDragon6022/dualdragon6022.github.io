#define STYLE 1 // [0 1]
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
#define BLOOM
#define ATMOSPHERIC_SCATTER
#define WET_SURFACES
#define FIRELIGHT
#define RAIN_LIGHTING
#define AURORA_RIBBONS
#define FIREFLIES
#define EMISSIVE_BLOOM
#define ANTIALIASING 2 // [0 1 2]
#define SHADOW_QUALITY 4 // [1 2 3 4]
#define VL_SAMPLES 48 // [8 16 32 48]
#define SHAFT_SAMPLES 56 // [12 24 40 56]
#define SSR_STEPS 96 // [16 32 64 96]
#define NEBULA_OCTAVES 7 // [2 3 5 7]
#define CLOUD_OCTAVES 9 // [3 5 7 9]
#define WATER_DETAIL 3 // [1 2 3 4]
#define BLOOM_QUALITY 3 // [1 2 3 4]
#define AURORA_DETAIL 4 // [1 2 3 4]
#define LIGHT_SAMPLES 4 // [1 2 3 4]
/* Iris requires literal const-int directive values. Do not replace with an expression. */
const int shadowMapResolution = 4096;
const float shadowDistance = 160.0;
const float sunPathRotation = -30.0;
const bool colortex7Clear=false;
