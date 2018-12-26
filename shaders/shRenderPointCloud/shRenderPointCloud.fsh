Texture2D gm_BaseTextureObject : register(t0);
SamplerState gm_BaseTexture    : register(s0);

struct PS {
    float4 Position : SV_Position0;
    float4 Texcoord : TEXCOORD0;
};

float4 main(PS In) : SV_Target0 {
    // Normalized Device Coords
    In.Texcoord.xy /= In.Texcoord.w;
    In.Texcoord.xy *= .5f;
    In.Texcoord.xy += .5f;
    In.Texcoord.y *= -1.f;
    
    float4 Out = gm_BaseTextureObject.Sample(gm_BaseTexture, In.Texcoord.xy);
    
    return float4(In.Texcoord.zzz / 64., 1.);;
}

