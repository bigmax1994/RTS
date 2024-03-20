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
    matrix_float4x4 m;
    float3 p;
    float3 s;
    
} Transformation;

typedef struct
{
    matrix_float4x4 rotationMatrix;
    
} CameraTransformation;

vertex ColorInOut vertexShader(uint vid [[vertex_id]], constant CameraTransformation & cameraTransformation [[ buffer(0) ]], constant Transformation & transformation [[ buffer(1) ]], constant Vertex* vertices [[buffer(2)]])
{
    ColorInOut out;
    
    float3x3 scaleMatrix = float3x3(float3(transformation.s.x, 0, 0),
                                    float3(0, transformation.s.y, 0),
                                    float3(0, 0, transformation.s.z));
    
    float3 scaledPos = vertices[vid].pos * scaleMatrix;
    
    float4 position = float4(scaledPos, 1);
    float4 moveBy = float4(transformation.p, 0);
    position.z = 1 - position.z;
    
    out.position = (position * transformation.m + moveBy) * cameraTransformation.rotationMatrix;
    
    out.color = vertices[vid].color;

    return out;
}

fragment float4 fragmentShader(ColorInOut in [[stage_in]])
{
    return float4(in.color, 1);
}
