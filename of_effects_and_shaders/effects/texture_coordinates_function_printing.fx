//texture
texture Tex <string uiname="Texture";>;
sampler Samp = sampler_state    //sampler for doing the texture-lookup
{
    Texture   = (Tex);          //apply a texture to the sampler
    MipFilter = LINEAR;         //sampler states
    MinFilter = LINEAR;
    MagFilter = LINEAR;
};
 
//the data structure: "vertexshader to pixelshader"
//used as output data with the VS function
//and as input data with the PS function
struct vs2ps
{
    float4 Pos  : POSITION;
    float2 TexCd : TEXCOORD0;
};

int Frequency = 50;
float Phase = 0;
float Amplitude = 1; 
float4 PS(vs2ps In): COLOR
{
    float2 cord = In.TexCd - 0.5;
	float dist = sqrt(pow(cord.x,2) + pow(cord.y,2));
	float4 col = sin(dist * Frequency + Phase) * Amplitude;
	col.a = 1;
	return col;
}
 
technique TSimpleShader
{
    pass P0
    {
        VertexShader = null;
        PixelShader  = compile ps_2_0 PS();
    }
}