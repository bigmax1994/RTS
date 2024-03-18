//
//  Shaders.metal
//  RTS Shared
//
//  Created by Max Gasslitter Strobl on 05.03.24.
//

// File for Metal kernel and shader functions

#include <metal_stdlib>
#include <simd/simd.h>

// Including header shared between this Metal shader code and Swift/C code executing Metal API commands
//#import "ShaderTypes.h"

using namespace metal;

typedef struct
{
    float3 pos;
    float3 color;
} Vertex;

typedef struct
{
    float4 position [[position]];
    float3 color;
} ColorInOut;

vertex ColorInOut vertexShader(uint vid [[vertex_id]], constant Vertex* vertices [[buffer(0)]])
{
    ColorInOut out;

    float4 position = float4(vertices[vid].pos, 1.0);
    out.position = position;
    out.color = vertices[vid].color;

    return out;
}

fragment float4 fragmentShader(ColorInOut in [[stage_in]])
{
    return float4(in.color, 1);
}
