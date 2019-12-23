Shader "MyUnityBasic/ScreenSpaceTexture"
{
    Properties
    {
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _Detail ("Detail", 2D) = "gray" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        CGPROGRAM

        #pragma surface surf Lambert  

        struct Input
        {
            float4 screenPos;
            float2 uv_MainTex;
        };

        sampler2D _MainTex;
        sampler2D _Detail; 

        void surf (Input IN, inout SurfaceOutput output)
        {
            fixed3 albedo = tex2D (_MainTex, IN.uv_MainTex);

            float2 screenUV = IN.screenPos.xy / IN.screenPos.w;
            screenUV *= float2(8,6);
            
            fixed3 detail = tex2D (_Detail, screenUV).rgb * 2;
            albedo.rgb *= detail;

            output.Albedo = albedo.rgb;
        }
        ENDCG
    }
    FallBack "Diffuse"
}

