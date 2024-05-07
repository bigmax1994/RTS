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
#include "ShaderTypes.h"

using namespace metal;

struct ColorInOut
{
    float4 position [[position]];
    Material material;
    float3 normal;
    
};

struct TextureInOut
{
    float4 position [[position]];
    TexturedMaterial material;
    float3 normal;
    
};

vertex ColorInOut colorVertexShader(uint vid [[vertex_id]], constant CameraTransformation & cameraTransformation [[ buffer(0) ]], constant Transformation & transformation [[ buffer(1) ]], constant Vertex* vertices [[buffer(2)]])
{
    ColorInOut out;
    
    float3 scaledPos = float3(vertices[vid].pos.x * transformation.s.x, vertices[vid].pos.y * transformation.s.y, vertices[vid].pos.z * transformation.s.z);
    
    float3 worldPos = scaledPos * transformation.m + transformation.p;
    float3 transformedNormal =  vertices[vid].normal * transformation.m + transformation.p;
    
    float3 cameraDiff = (-cameraTransformation.position) * cameraTransformation.rotationMatrix;
    float4 position = float4(worldPos * cameraTransformation.rotationMatrix + cameraDiff, 1);
    
    out.position = position * cameraTransformation.clipMatrix;
    out.material = vertices[vid].material;
    out.normal = transformedNormal;

    return out;
}

vertex TextureInOut textureVertexShader(uint vid [[vertex_id]], constant CameraTransformation & cameraTransformation [[ buffer(0) ]], constant Transformation & transformation [[ buffer(1) ]], constant TexturedVertex* vertices [[buffer(2)]])
{
    TextureInOut out;
    
    float3 scaledPos = float3(vertices[vid].pos.x * transformation.s.x, vertices[vid].pos.y * transformation.s.y, vertices[vid].pos.z * transformation.s.z);
    
    float3 worldPos = scaledPos * transformation.m + transformation.p;
    float3 transformedNormal =  vertices[vid].normal * transformation.m + transformation.p;
    
    float3 cameraDiff = (-cameraTransformation.position) * cameraTransformation.rotationMatrix;
    float4 position = float4(worldPos * cameraTransformation.rotationMatrix + cameraDiff, 1);
    
    out.position = position * cameraTransformation.clipMatrix;
    out.material = vertices[vid].material;
    out.normal = transformedNormal;

    return out;
}

fragment float4 colorFragmentShader(constant CameraTransformation & cameraTransformation [[ buffer(0) ]], constant Light & light [[ buffer(1) ]], ColorInOut in [[stage_in]])
{
    
    float3 diffuseLight = dot(in.normal, light.mainPosition) * light.mainColor;
    float3 ambientLight = light.ambientColor;
    
    float3 pos = float3(in.position);
    float3 viewDir = normalize(cameraTransformation.position - pos);
    float3 reflectionDir = reflect(-light.mainPosition, pos);
    float3 specularLight = 0.5 * pow(max(dot(viewDir, reflectionDir), 0.0), in.material.shininess) * light.mainColor;
    
    float3 outColor = (diffuseLight + ambientLight + specularLight) * in.material.color;
    
    return float4(outColor, 1);
    
}

fragment float4 textureFragmentShader(texture2d<float> colorTexture [[ texture(0) ]], constant CameraTransformation & cameraTransformation [[ buffer(0) ]], constant Light & light [[ buffer(1) ]], TextureInOut in [[stage_in]])
{
    
    constexpr sampler textureSampler ( mag_filter::linear,
                                      min_filter::linear);
    float4 color = colorTexture.sample(textureSampler, in.material.texturePosition);
    
    float3 diffuseLight = dot(in.normal, light.mainPosition) * light.mainColor;
    float3 ambientLight = light.ambientColor;
    
    float3 pos = float3(in.position);
    float3 viewDir = normalize(cameraTransformation.position - pos);
    float3 reflectionDir = reflect(-light.mainPosition, pos);
    float3 specularLight = 0.5 * pow(max(dot(viewDir, reflectionDir), 0.0), in.material.shininess) * light.mainColor;
    
    float4 outColor = float4(diffuseLight + ambientLight + specularLight, 1) * color;
    outColor.w = 0;
    
    return outColor;
    
}

vertex ColorInOut planeVertexShader(uint vid [[vertex_id]], constant Vertex* vertices [[buffer(0)]]) {
    
    ColorInOut out;
    
    out.position = float4(vertices[vid].pos, 1);
    out.material = vertices[vid].material;
    out.normal = vertices[vid].normal;

    return out;
    
}
