//texture
texture Tex <string uiname="Texture";>;
sampler Samp = sampler_state    //sampler for doing the texture-lookup
{
    Texture   = (Tex);          //apply a texture to the sampler
    MipFilter = LINEAR;         //sampler states
    MinFilter = LINEAR;
    MagFilter = LINEAR;
	AddressU = WRAP; // makes it so addressing beyond 0/1 in u-coord (x) wraps 
	// rather than mirrors (default behavior)
};
 
//the data structure: "vertexshader to pixelshader"
//used as output data with the VS function
//and as input data with the PS function
struct vs2ps
{
    float4 Pos  : POSITION;
    float2 TexCd : TEXCOORD0;
};
float Frequency = 10;
float Phase = 0;
float Amplitude = 0.1; 
float4 PS(vs2ps In): COLOR
{	//return float4(In.TexCd, 1, 1); // visualize texture coordinates
	float2 cord = In.TexCd;
	cord.x += sin(cord.y * Frequency + Phase) * Amplitude;
	//cord.x += .5; // wrap
	//cord.y -= 0.5; // mirror
    return tex2D(Samp, cord);
}
 
technique TSimpleShader
{
    pass P0
    {
        VertexShader = null;
        PixelShader  = compile ps_2_0 PS();
    }
}