Shader "MyUnityBasic/SimpleNormal"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _NormalMap ("NormalMap", 2D) = "bump" {}
        _EmissionMap ("EmissionMap", 2D) = "black" {}
        _EmissionIntensity ("EmissionIntensity", Float) = 1
    }
    
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        CGPROGRAM
        #pragma surface surf Lambert
        
        struct Input
        {
            float2 uv_MainTex;
            float2 uv_NormalMap;
            float2 uv_EmissionMap;
            float3 viewDir;
        };

        sampler2D _MainTex;
        sampler2D _NormalMap;
        sampler2D _EmissionMap;
        fixed4 _Color;

        float _EmissionIntensity;

        void surf (Input IN, inout SurfaceOutput output)
        {
            // Albedo comes from a texture tinted by color
            fixed3 albedo = tex2D(_MainTex, IN.uv_MainTex);
            fixed3 emission = tex2D(_EmissionMap, IN.uv_EmissionMap);
            half3 normal = UnpackNormal(tex2D (_NormalMap, IN.uv_NormalMap));

            albedo *= _Color;
            emission *= _EmissionIntensity;

            output.Albedo = albedo.rgb;
            output.Normal = normal;
            output.Emission = emission;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
