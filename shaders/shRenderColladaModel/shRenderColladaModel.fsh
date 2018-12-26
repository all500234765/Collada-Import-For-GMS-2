/*Texture2D gm_BaseTextureObject : register(t0);
SamplerState gm_BaseTexture    : register(s0);

cbuffer gm_PSMaterialConstantBuffer
{
	bool   gm_PS_FogEnabled;
	float4 gm_FogColour;
	bool   gm_AlphaTestEnabled;
	float4 gm_AlphaRefValue;
};*/

struct PS {
    float4 Position : SV_Position0;
    float2 Texcoord : TEXCOORD0;
    float4 ClipSpace : TEXCOORD1;
};

float4 main(PS In) : SV_Target0 {
    float4 Out = gm_BaseTextureObject.Sample(gm_BaseTexture, In.Texcoord);
    
    return float4(Out.rgb, 1.);
}
