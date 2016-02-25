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
float4 ConvertToGray(float4 col)
{
    const float4 lumcoeff = {0.3, 0.59, 0.11, 0};
    return dot(col, lumcoeff);
}
float2 PixelSize; // where .x will be width and .y will be the height of pixels
float Threshold = 0.2;
float4 PS(vs2ps In): COLOR
{
    float2 x_off = float2(PixelSize.x,0);
	float2 y_off = float2(0, PixelSize.y);

	// sample the left and the right neighboring pixels
	float4 left = tex2D(Samp, In.TexCd - x_off);
	float4 right = tex2D(Samp, In.TexCd + x_off);
	//sample the upper and the lower neighboring pixels
	float4 upper = tex2D(Samp, In.TexCd - y_off);
	float4 lower = tex2D(Samp, In.TexCd + y_off);
	if (abs(ConvertToGray(left).x - ConvertToGray(right).x) > Threshold
	||abs(ConvertToGray(upper) - ConvertToGray(lower)).x > Threshold)
	  return 1;
	else
	  return float4(0,0,0,1);
}
 
technique TSimpleShader
{
    pass P0
    {
        VertexShader = null;
        PixelShader  = compile ps_2_0 PS();
    }
}