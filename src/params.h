#pragma once

#include <optix.h>
#include <vector_types.h>

struct ExampleParams {
    float3 cam_eye {0.0f, 0.0f, 0.0f};
    float3 cam_u {0.0f, 0.0f, 0.0f};
    float3 cam_v {0.0f, 0.0f, 0.0f};
    float3 cam_w {0.0f, 0.0f, 0.0f};
    char* image{nullptr};
    OptixTraversableHandle handle{0};
};
