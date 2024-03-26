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
    float3 normal;
    float3 color;
    
} Vertex;

typedef struct
{
    float4 position [[position]];
    float3 color;
    float3 normal;
    
} ColorInOut;

typedef struct
{
    matrix_float3x3 m;
    float3 p;
    float3 s;
    
} Transformation;

typedef struct
{
    matrix_float4x4 rotationMatrix;
    
} CameraTransformation;

typedef struct {
    float3 sunPosition;
    float3 sunColor;
} WorldSettings;

vertex ColorInOut vertexShader(uint vid [[vertex_id]], constant CameraTransformation & cameraTransformation [[ buffer(0) ]], constant Transformation & transformation [[ buffer(1) ]], constant Vertex* vertices [[buffer(2)]])
{
    ColorInOut out;
    
    float3 scaledPos = float3(vertices[vid].pos.x * transformation.s.x, vertices[vid].pos.y * transformation.s.y, vertices[vid].pos.z * transformation.s.z);
    
    float3 worldPos = scaledPos * transformation.m + transformation.p;
    float3 transformedNormal =  vertices[vid].normal * transformation.m + transformation.p;
    
    float4 position = float4(worldPos, 1);  
    position.z = position.z / 2;
    
    out.position = position * cameraTransformation.rotationMatrix;
    out.color = vertices[vid].color;
    out.normal = transformedNormal;

    return out;
}

fragment float4 fragmentShader(constant WorldSettings & worldState, ColorInOut in [[stage_in]])
{
    
    float3 directedColor = dot(in.normal, worldState.sunPosition) * worldState.sunColor * in.color;
    return float4(directedColor, 1);
    
}
