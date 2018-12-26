#region
#ifndef MATRICES_MAX

#define	MATRIX_VIEW                  0
#define	MATRIX_PROJECTION            1
#define	MATRIX_WORLD                 2
#define	MATRIX_WORLD_VIEW            3
#define	MATRIX_WORLD_VIEW_PROJECTION 4
#define	MATRICES_MAX                 5 
#define	MAX_VS_LIGHTS                8

cbuffer gm_VSTransformBuffer
{
	float4x4 gm_Matrices[MATRICES_MAX];
};

cbuffer gm_VSMaterialConstantBuffer
{
	bool  gm_LightingEnabled;
	bool  gm_VS_FogEnabled;
	float gm_FogStart;
	float gm_RcpFogRange;
};

cbuffer gm_VSLightingConstantBuffer
{
	float4 gm_AmbientColour;                    // rgb=colour, a=1
	float3 gm_Lights_Direction[MAX_VS_LIGHTS];  // normalised direction
	float4 gm_Lights_PosRange [MAX_VS_LIGHTS];  // X,Y,Z position,  W range
	float4 gm_Lights_Colour   [MAX_VS_LIGHTS];  // rgb=colour, a=1
};

#endif
#endregion

#define MAX_JOINTS 3
#define MAX_MATRICES 50
#define GETFORMAT(max) float##max 

struct VS {
    float4 Position : POSITION0;
    float3 Normal   : NORMAL0;
    float2 Texcoord : TEXCOORD0;
    /*float3 Tangent  : TANGENT0;
    float3 BiNormal : BINORMAL0;*/
    //GETFORMAT(MAX_JOINTS) Indices : TEXCOORD1;
    //GETFORMAT(MAX_JOINTS) Weights : TEXCOORD2;
};

struct PS {
    float4 Position : SV_Position0;
    float2 Texcoord : TEXCOORD0;
    float4 ClipSpace : TEXCOORD1;
};

float _Time;
float4x4 _Transforms[MAX_MATRICES];

PS main(VS In) {
    /*float4 TotalPos = 0.;
    
    for( int i = 0; i < MAX_JOINTS; i++ ) {
        TotalPos += mul(_Transforms[int(In.Indices[i])], In.Position) * In.Weights[i];
        
        // Same for normals
    }*/
    
    PS Out;
        Out.Position = mul(gm_Matrices[MATRIX_WORLD_VIEW_PROJECTION], In.Position);
        Out.Texcoord = In.Texcoord;
        Out.ClipSpace = Out.Position;
    return Out;
}
