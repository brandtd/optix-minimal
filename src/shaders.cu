#include "params.h"

#include <OptiXToolkit/ShaderUtil/vec_math.h>
#include <optix.h>

#include <cfloat>

extern "C" {
    extern __constant__ ExampleParams params;
}

__device__ inline
void computeRay(uint3 idx, uint3 dim, float3& origin, float3& direction) {
  const float3 U = params.cam_u;
  const float3 V = params.cam_v;
  const float3 W = params.cam_w;
  const float2 d = 2.0f * make_float2(
                              static_cast<float>(idx.x) / static_cast<float>(dim.x),
                              static_cast<float>(idx.y) / static_cast<float>(dim.y)) -
                   1.0f;

  origin = params.cam_eye;
  direction = normalize(d.x * U + d.y * V + W);
}

extern "C" __global__
void __raygen__entry_point()
{
    // Lookup our location within the launch grid
    const uint3 idx = optixGetLaunchIndex();
    const uint3 dim = optixGetLaunchDimensions();

    // Map our launch idx to a screen location and create a ray from the camera
    // location through the screen
    float3 ray_origin, ray_direction;
    computeRay(idx, dim, ray_origin, ray_direction);

    // Trace the ray against our scene hierarchy
    unsigned int p0;
    optixTrace(
        params.handle,
        ray_origin,
        ray_direction,
        0.0f,                       // Min intersection distance
        FLT_MAX,                    // Max intersection distance
        0.0f,                       // rayTime -- used for motion blur
        OptixVisibilityMask(255),   // Specify always visible
        OPTIX_RAY_FLAG_NONE,
        0,                          // SBT offset
        1,                          // SBT stride
        0,                          // missSBT Index
        p0);                        // output payload 0

    // Record results in our output raster
    params.image[idx.y * dim.x + idx.x] = p0;
}

extern "C" __global__ 
void __miss__entry_point()
{
    optixSetPayload_0( 0 );
}

extern "C" __global__
void __closesthit__entry_point()
{
    optixSetPayload_0( 1 );
}
