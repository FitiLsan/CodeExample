Shader "TestWorks/PhotoGradientShader"
{
    Properties 
    {
        _MaskTex ("Base Texture", 2D) = "yellow" {}
        _Contrast ("Contrast ", Range(0, 1)) = 1
        _IntensityR ("_IntensityR", Range(0, 1)) = 1
        _IntensityG ("_IntensityG", Range(0, 1)) = 1
        _IntensityB ("_IntensityB", Range(0, 1)) = 1

        _GroundTex ("Ground tile", 2D) = "yellow" {}
        _GroundThreshold ("Ground threshold", Range(0, 1)) = 1

        _GrassTex ("Grass", 2D) = "yellow" {}
        _GrassThreshold ("Grass threshold", Range(0, 1)) = 1
        
        _RoadTex ("Road tile", 2D) = "yellow" {}
        _RoadThreshold ("Road threshold", Range(0, 1)) = 1

        radius ("Radius", Range(0,30)) = 15
        resolution ("Resolution", float) = 800  
        hstep("HorizontalStep", Range(0,1)) = 0.5
        vstep("VerticalStep", Range(0,1)) = 0.5  
    }
    
    SubShader
    {
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv0 : TEXCOORD0;
                float2 uv1 : TEXCOORD1;
                float2 uv2 : TEXCOORD2;
                float2 uv3 : TEXCOORD3;
            };

            struct v2f
            {
                float4 vertex : POSITION;
                float2 uv0 : TEXCOORD0;
                float2 uv1 : TEXCOORD1;
                float2 uv2 : TEXCOORD2;
                float2 uv3 : TEXCOORD3;
            };

            struct textureMask
            {
                float4 color : POSITION;
                float2 uv : TEXCOORD0;
            };

            float _GroundThreshold;
            float _GrassThreshold;
            float _RoadThreshold;
            float _IntensityR;
            float _IntensityG;
            float _IntensityB;
            float _Contrast;

            float3 ColorNormalize(float3 color)
            {
                float sum = 0;
                sum += color.r;
                sum += color.g;
                sum += color.b;

                color.r = color.r / sum;
                color.g = (color.g / sum) * _IntensityG;
                color.b = color.b / sum;

                return color;
            }

            float3 GetTextureMask(float3 baseTexture)
            {
                float3 texSmoothed = baseTexture;
                float3 texClamped = baseTexture;

                texSmoothed.r = smoothstep(_GroundThreshold, _IntensityR, baseTexture.r);
                texSmoothed.g = smoothstep(_GrassThreshold, _IntensityG, baseTexture.g); 
                texSmoothed.b = smoothstep(_RoadThreshold, _IntensityB, baseTexture.b);

                texClamped = ColorNormalize(texSmoothed);

                return texClamped;
            }

            sampler2D _MaskTex,
            _GroundTex,
            _GrassTex,
            _RoadTex;

            float4 _MaskTex_ST;

            float4 _GroundTex_ST;
            float4 _GrassTex_ST;
            float4 _RoadTex_ST;
            
            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv0 = TRANSFORM_TEX(v.uv0, _MaskTex);
                o.uv1 = TRANSFORM_TEX(v.uv1, _GroundTex);
                o.uv2 = TRANSFORM_TEX(v.uv2, _GrassTex);
                o.uv3 = TRANSFORM_TEX(v.uv3, _RoadTex);
                
                return o;
            }


// Раньше тут был гаус, но справился и без него. Без гауса шейдер дешевле.

            // float radius;
            // float resolution;
            // float hstep;
            // float vstep;     
            
            // float3 Bluring(v2f i)
            // {
            //     float4 sum = float4(0.0, 0.0, 0.0, 0.0);
            //     float3 col = float3(0.0, 0.0, 0.0);
            //     float2 tc = i.uv0;

            //     float blur = radius/resolution/4;

            //     sum += tex2D(_MaskTex, float2(tc.x - 4.0*blur*hstep, tc.y - 4.0*blur*vstep)) * 0.0162162162;
            //     sum += tex2D(_MaskTex, float2(tc.x - 3.0*blur*hstep, tc.y - 3.0*blur*vstep)) * 0.0540540541;
            //     sum += tex2D(_MaskTex, float2(tc.x - 2.0*blur*hstep, tc.y - 2.0*blur*vstep)) * 0.1216216216;
            //     sum += tex2D(_MaskTex, float2(tc.x - 1.0*blur*hstep, tc.y - 1.0*blur*vstep)) * 0.1945945946;
            //     col += GetTextureMask(sum.rgb);

            //     sum += tex2D(_MaskTex, float2(tc.x, tc.y)) * 0.2270270270;

            //     sum += tex2D(_MaskTex, float2(tc.x + 1.0*blur*hstep, tc.y + 1.0*blur*vstep)) * 0.1945945946;
            //     sum += tex2D(_MaskTex, float2(tc.x + 2.0*blur*hstep, tc.y + 2.0*blur*vstep)) * 0.1216216216;
            //     sum += tex2D(_MaskTex, float2(tc.x + 3.0*blur*hstep, tc.y + 3.0*blur*vstep)) * 0.0540540541;
            //     sum += tex2D(_MaskTex, float2(tc.x + 4.0*blur*hstep, tc.y + 4.0*blur*vstep)) * 0.0162162162;
            //     col += GetTextureMask(sum.rgb);

            //     col = ColorNormalize(col);

            //     return col;
            // }

            fixed4 frag(v2f i) : SV_Target
            {
                fixed4 masks = tex2D(_MaskTex, i.uv0);

                float3 groundTex = tex2D(_GroundTex, i.uv1);
                float3 grassTex = tex2D(_GrassTex, i.uv2);
                float3 roadTex = tex2D(_RoadTex, i.uv3);
                float3 clr = float3(0,0,0);

                float3 pixelMask = GetTextureMask(masks);       

                clr += groundTex * pixelMask.r;
                clr += grassTex * pixelMask.g;
                clr += roadTex * pixelMask.b;

                return fixed4(clr.rgb, 1.0f);
            }
            ENDCG
        }
    }
}