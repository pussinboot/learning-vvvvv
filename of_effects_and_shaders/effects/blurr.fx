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
float4 PSHorizontalBlur(vs2ps In): COLOR
{
    float4 sum = 0;
	int weightSum = 0;
	// weights of neighboring pixels
	int weights[15] = {1,2,3,4,5,6,7,8,7,6,5,4,3,2,1};
	for (int i = 0; i < 15; i++)
	{
		float2 cord = float2(In.TexCd.x + PixelSize.x * (i-7), In.TexCd.y);
		sum += tex2D(Samp, cord) * weights[i];
		weightSum += weights[i];
	}
	sum /= weightSum;
	return float4(sum.rgb, 1);
}
float4 PSVerticalBlur(vs2ps In): COLOR
{
    float4 sum = 0;
	int weightSum = 0;
	// weights of neighboring pixels
	int weights[15] = {1,2,3,4,5,6,7,8,7,6,5,4,3,2,1};
	for (int i = 0; i < 15; i++)
	{
		float2 cord = float2(In.TexCd.x, In.TexCd.y + PixelSize.y * (i-7));
		sum += tex2D(Samp, cord) * weights[i];
		weightSum += weights[i];
	}
	sum /= weightSum;
	return float4(sum.rgb, 1);
} 
technique THorizontalBlur
{
    pass P0
    {
        VertexShader = null;
        PixelShader  = compile ps_2_0 PSHorizontalBlur();
    }
}

technique TVerticalBlur
{
    pass P0
    {
        PixelShader  = compile ps_2_0 PSVerticalBlur();
    }
	
}