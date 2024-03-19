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
#import "ShaderTypes.h"

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

vertex ColorInOut vertexShader(uint vid [[vertex_id]], constant Vertex* vertices [[buffer(0)]], constant Uniforms & uniforms [[ buffer(BufferIndexUniforms) ]])
{
    ColorInOut out;

    float4 position = float4(vertices[vid].pos, 1);
    float size = .6;
    position.z = .8 * size * (1 - position.z);
    position.x = size * position.x;
    position.y = size * position.y;
    
    float alpha = 0.2;
    float beta = 0.8;
    
    float4x4 m = float4x4(float4(cos(alpha), sin(alpha)*cos(beta), sin(alpha)*sin(beta), 0.0),
                          float4(sin(alpha), cos(alpha)*cos(beta), -sin(beta)*cos(alpha), 0.0),
                          float4(0.0, -sin(beta), cos(beta), 0.0),
                          float4(0.0, 0.0, 0.0, 1.0));
    
    out.position = m * position;
    out.color = vertices[vid].color;

    return out;
}

fragment float4 fragmentShader(ColorInOut in [[stage_in]])
{
    return float4(in.color, 1);
}
