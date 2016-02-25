//@author: pussinboots
//@help: this is a very basic template. use it to start writing your own effects. if you want effects with lighting start from one of the GouraudXXXX or PhongXXXX effects
//@tags:
//@credits:

// --------------------------------------------------------------------------------------------------
// PARAMETERS:
// --------------------------------------------------------------------------------------------------

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

// --------------------------------------------------------------------------------------------------
// FUNCTIONS:
// --------------------------------------------------------------------------------------------------

float4 ConvertToGray(float4 col)
{
	const float4 lumcoeff = {0.3,0.59,0.11,0};
	return dot(col, lumcoeff);
}

// --------------------------------------------------------------------------------------------------
// PIXELSHADERS:
// --------------------------------------------------------------------------------------------------

float4 PS(vs2ps In): COLOR
{

	float4 col = tex2D(Samp, In.TexCd);
	return ConvertToGray(col);
	//col.rgb = 1 - col.rgb; // invert a texture
	// return col.bgra; // return col w/ mixed up color channels
	// contrast
	//float Contrast = 1;
	//col.rgb -= 0.5;
	//col.rgb *= Contrast;
	//col.rgb += 0.5;
	//return col;
}

// --------------------------------------------------------------------------------------------------
// TECHNIQUES:
// --------------------------------------------------------------------------------------------------

technique TSimpleShader
{
    pass P0
    {
        //Wrap0 = U;  // useful when mesh is round like a sphere
        VertexShader = null;
        PixelShader  = compile ps_2_0 PS();
    }
}
