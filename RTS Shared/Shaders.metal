//
//  Shaders.metal
//  RTS Shared
//
//  Created by Max Gasslitter Strobl on 05.03.24.
//

// File for Metal kernel and shader functions

#include <metal_stdlib>
#include <simd/simd.h>
#include <metal_geometric>

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

typedef struct
{
    matrix_float4x4 rotationMatrix;
    float3 position;
} Uniforms;

typedef struct
{
    matrix_float4x4 rotationMatrix;
    
} CameraTransformation;

vertex ColorInOut vertexShader(uint vid [[vertex_id]], constant CameraTransformation & cameraTransformation [[ buffer(0) ]], constant Uniforms & uniforms [[ buffer(1) ]], constant Vertex* vertices [[buffer(2)]])
{
    ColorInOut out;
    
    float4 position = float4(vertices[vid].pos, 1);
    float4 moveBy = float4(uniforms.position, 0);
    position.z = 1 - position.z;
    
    out.position = cameraTransformation.rotationMatrix * (uniforms.rotationMatrix * position + moveBy);
    out.color = vertices[vid].color;

    return out;
}

fragment float4 fragmentShader(ColorInOut in [[stage_in]])
{
    return float4(in.color, 1);
}
