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



//texture
texture TexFlame <string uiname="Texture Flame";>;
sampler Flame = sampler_state    //sampler for doing the texture-lookup
{
    Texture   = (TexFlame);          //apply a texture to the sampler
    MipFilter = LINEAR;         //sampler states
    MinFilter = LINEAR;
    MagFilter = LINEAR;
};

//texture
texture TexNoise <string uiname="Texture Noise";>;
sampler Noise = sampler_state    //sampler for doing the texture-lookup
{
    Texture   = (TexNoise);          //apply a texture to the sampler
    MipFilter = LINEAR;         //sampler states
    MinFilter = LINEAR;
    MagFilter = LINEAR;
};



//texture transformation marked with semantic TEXTUREMATRIX to achieve symmetric transformations
float4x4 tTex: TEXTUREMATRIX <string uiname="Texture Transform";>;


float time_0_X;
float timeSampleDist = 0.3;


float colorDistribution = 2.76;
float fade = 2.4;
float flameSpeed = 0.22;
float spread = 0.5;
float flamability = 1.74;

float x, px, ppx ;
float y, py, ppy ;

bool state ;

//the data structure: "vertexshader to pixelshader"
//used as output data with the VS function
//and as input data with the PS function
struct vs2ps
{
   float4 Pos:   POSITION;
   float2 pos:   TEXCOORD0;
   float2 fPos:  TEXCOORD1;
   float2 pPos:  TEXCOORD2;
   float2 ppPos: TEXCOORD3;
};

// --------------------------------------------------------------------------------------------------
// VERTEXSHADERS
// --------------------------------------------------------------------------------------------------
vs2ps VS(
    float4 PosO  : POSITION )
{
    //declare output struct
    vs2ps Out;

	
   // Clean up inaccuracies
   PosO.xy = sign(PosO.xy);
	
   //transform position
  	
	
   
	Out.Pos = float4(PosO.xy, 0, 1);
	Out.pos = PosO.xy;
	
	Out.Pos = mul( Out.Pos, tWVP);	


if (state) {	
   // Current fire ball position
   // Current fire ball position
   Out.fPos.x = x;
   Out.fPos.y = y;

   // Fire ball position not too long ago
   time_0_X -= timeSampleDist;
   Out.pPos.x = 0.8 * px ;
   Out.pPos.y = 0.8 * py;

   // Fire ball position some time ago
   time_0_X -= timeSampleDist;
   Out.ppPos.x =  ppx ;
   Out.ppPos.y =  ppy ;
} 
	
  else 	{

	
   // Current fire ball position
   Out.fPos.x = 0.8 * sin(0.71 * time_0_X);
   Out.fPos.y = 0.8 * cos(0.93 * time_0_X);

   // Fire ball position not too long ago
   time_0_X -= timeSampleDist;
   Out.pPos.x = 0.8 * sin(0.71 * time_0_X);
   Out.pPos.y = 0.8 * cos(0.93 * time_0_X);

   // Fire ball position some time ago
   time_0_X -= timeSampleDist;
   Out.ppPos.x = 0.8 * sin(0.71 * time_0_X);
   Out.ppPos.y = 0.8 * cos(0.93 * time_0_X);

} 
	
   return Out;
	
    
    //transform texturecoordinates
 /////   Out.pos = mul(TexCd, tTex);

	
}

// --------------------------------------------------------------------------------------------------
// PIXELSHADERS:
// --------------------------------------------------------------------------------------------------

float4 PS(   float2 pos:   TEXCOORD0, 
             float2 fPos:  TEXCOORD1, 
             float2 pPos:  TEXCOORD2, 
             float2 ppPos: TEXCOORD3): COLOR
{
    
	 // Distance to three points on the path, streches fire ball along the path
   float dist = distance(pos, fPos) + 0.7 * distance(pos, pPos) + 0.5 * distance(pos, ppPos);

   // Grab some noise and make a flame
   float noisy = tex3D(Noise, float3(pos, spread * dist - flameSpeed * time_0_X)).r;
   float flame = saturate(1 - fade * dist + flamability * noisy);

   // Map flame into a color
   return tex1D(Flame, pow(flame, colorDistribution));
	
	
	
}

// --------------------------------------------------------------------------------------------------
// TECHNIQUES:
// --------------------------------------------------------------------------------------------------

technique TFireBall
{
    pass P0
    {
        //Wrap0 = U;  // useful when mesh is round like a sphere
        VertexShader = compile vs_1_1 VS();
        PixelShader  = compile ps_2_0 PS();
    }
}

