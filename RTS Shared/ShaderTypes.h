//
//  ShaderTypes.h
//  RTS Shared
//
//  Created by Max Gasslitter Strobl on 05.03.24.
//

//
//  Header containing types and enum constants shared between Metal shaders and Swift/ObjC source
//
#ifndef ShaderTypes_h
#define ShaderTypes_h

#ifdef __METAL_VERSION__
#define NS_ENUM(_type, _name) enum _name : _type _name; enum _name : _type
typedef metal::int32_t EnumBackingType;
#else
#import <Foundation/Foundation.h>
typedef NSInteger EnumBackingType;
#endif

#include <simd/simd.h>

typedef NS_ENUM(EnumBackingType, BufferIndex)
{
    BufferIndexMeshPositions = 0,
    BufferIndexMeshGenerics  = 1,
    BufferIndexUniforms      = 2
};

typedef NS_ENUM(EnumBackingType, VertexAttribute)
{
    VertexAttributePosition  = 0,
    VertexAttributeTexcoord  = 1,
};

typedef NS_ENUM(EnumBackingType, TextureIndex)
{
    TextureIndexColor    = 0,
};

typedef struct
{
    matrix_float4x4 projectionMatrix;
    matrix_float4x4 modelViewMatrix;
} Uniforms;

typedef struct {
    simd_float3 color;
    float opacity;
    float shininess;
} Material;

typedef struct {
    simd_float2 texturePosition;
    float opacity;
    float shininess;
} TexturedMaterial;

typedef struct
{
    simd_float3 pos;
    simd_float3 normal;
    Material material;
    
} Vertex;

typedef struct
{
    simd_float3 pos;
    simd_float3 normal;
    TexturedMaterial material;
    
} TexturedVertex;

typedef struct
{
    matrix_float3x3 m;
    simd_float3 p;
    simd_float3 s;
    
} Transformation;

typedef struct
{
    simd_float3 position;
    matrix_float3x3 rotationMatrix;
    matrix_float4x4 clipMatrix;
} CameraTransformation;

typedef struct
{
    simd_float3 mainPosition;
    simd_float3 mainColor;
    simd_float3 ambientColor;
} Light;

#endif /* ShaderTypes_h */

