//@author: misak
//@credits: AMD RenderMonkey Source 

// --------------------------------------------------------------------------------------------------
// PARAMETERS:
// --------------------------------------------------------------------------------------------------

//transforms
float4x4 tW: WORLD;        //the models world matrix
float4x4 tV: VIEW;         //view matrix as set via Renderer (EX9)
float4x4 tP: PROJECTION;
float4x4 tWVP: WORLDVIEWPROJECTION;
float4 layer_speed = {0.68753, 0.52, 0.7534, 1} ;
float time_0_X = 81.261 ;

//texture
texture TexFB <string uiname="Fire Base";>;
sampler fire_base = sampler_state    //sampler for doing the texture-lookup
{
    Texture   = (TexFB);          //apply a texture to the sampler
    MipFilter = LINEAR;         //sampler states
    MinFilter = LINEAR;
    MagFilter = LINEAR;
};

//texture transformation marked with semantic TEXTUREMATRIX to achieve symmetric transformations
float4x4 tTex: TEXTUREMATRIX <string uiname="Texture Transform";>;

texture TexFD <string uiname="Fire Distortion";>;
sampler fire_distortion = sampler_state    //sampler for doing the texture-lookup
{
    Texture   = (TexFD);          //apply a texture to the sampler
    MipFilter = LINEAR;         //sampler states
    MinFilter = LINEAR;
    MagFilter = LINEAR;
};

texture TexFO <string uiname="Fire Opacity";>;
sampler fire_opacity = sampler_state    //sampler for doing the texture-lookup
{
    Texture   = (TexFO);          //apply a texture to the sampler
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
 /////   float2 TexCd : TEXCOORD0;
	float3 TexCd0 : TEXCOORD0;
   	float3 TexCd1 : TEXCOORD1;
   	float3 TexCd2 : TEXCOORD2;
   	float3 TexCd3 : TEXCOORD3;
};

// --------------------------------------------------------------------------------------------------
// VERTEXSHADERS
// --------------------------------------------------------------------------------------------------
vs2ps VS(
    float4 PosO  : POSITION,
    float3 vTexCd : TEXCOORD0)
{
    //declare output struct
    vs2ps Out = (vs2ps) 0;
	

   // Output TexCoord0 directly
	vTexCd = mul(float4(vTexCd.x, vTexCd.y, 0, 1), tTex);


   // Base texture coordinates plus scaled time
	Out.TexCd1.x = vTexCd.x;
	Out.TexCd1.y = vTexCd.y + layer_speed.x * time_0_X;

   // Base texture coordinates plus scaled time
	Out.TexCd2.x = vTexCd.x;
	Out.TexCd2.y = vTexCd.y + layer_speed.y * time_0_X;

   // Base texture coordinates plus scaled time
	Out.TexCd3.x = vTexCd.x;
	Out.TexCd3.y = vTexCd.y + layer_speed.z * time_0_X;
	
    Out.TexCd0 = mul(vTexCd, tTex);
   	
	Out.Pos = mul(PosO, tWVP);	


	
    return Out;
}

// --------------------------------------------------------------------------------------------------
// PIXELSHADERS:
// --------------------------------------------------------------------------------------------------


float4 height_attenuation = {0.44, 0.29, 0, 1};
float distortion_amount0 = 0.123;
float distortion_amount1 = 0.091;
float distortion_amount2 = 0.0723;

// Bias and double a value to take it from 0..1 range to -1..1 range
float4 bx2(float x)
{
   return 2.0f * x - 1.0f;
}


float4 PS(float4 tc0 : TEXCOORD0, float4 tc1 : TEXCOORD1,
             float4 tc2 : TEXCOORD2, float4 tc3 : TEXCOORD3): COLOR
{
	
	  // Sample noise map three times with different texture coordinates
   float4 noise0 = tex2D(fire_distortion, tc1);
   float4 noise1 = tex2D(fire_distortion, tc2);
   float4 noise2 = tex2D(fire_distortion, tc3);

   // Weighted sum of signed noise
   float4 noiseSum = bx2(noise0.r) * distortion_amount0 + bx2(noise1.r) * distortion_amount1 + bx2(noise2.r) * distortion_amount2;

   // Perturb base coordinates in direction of noiseSum as function of height (y)
   float4 perturbedBaseCoords = tc0 + noiseSum * (tc0.y * height_attenuation.x + height_attenuation.y);

   // Sample base and opacity maps with perturbed coordinates
   float4 base = tex2D(fire_base, perturbedBaseCoords);
   float4 opacity = tex2D(fire_opacity, perturbedBaseCoords);

   return base * opacity;

}


// --------------------------------------------------------------------------------------------------
// TECHNIQUES:
// --------------------------------------------------------------------------------------------------

technique TTorchFire
{
    pass P0
    {
        //Wrap0 = U;  // useful when mesh is round like a sphere
        VertexShader = compile vs_2_0 VS();
        PixelShader  = compile ps_2_0 PS();
    }
}