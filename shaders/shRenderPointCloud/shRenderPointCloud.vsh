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

struct VS {
    float4 Position : COLOR0;
};

struct PS {
    float4 Position : SV_Position0;
    float4 Texcoord : TEXCOORD0;
};

PS main(VS In) {
    float3 p = float3(1. * (In.Position.x * 2. - 1.), 
                      1. *  In.Position.z, 
                      1. * (In.Position.y * 2. - 1.));
    
    PS Out;
        Out.Position = mul(gm_Matrices[MATRIX_WORLD_VIEW_PROJECTION], float4(p, 1.));
        Out.Texcoord = Out.Position;
    return Out;
}
