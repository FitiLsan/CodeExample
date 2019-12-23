Shader "MyUnityBasic/WorldReflectionNormal"
{
    Properties 
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Texture", 2D) = "white" {}
        _NormalMap ("NormalMap", 2D) = "bump" {}
        _ReflectionCube ("Cubemap", CUBE) = "" {}
        _ReflectionIntensity ("_Reflection Intensity", Range(0.0,6.0)) = 1.0
    }

    SubShader 
    {
        Tags { "RenderType" = "Opaque" }
        CGPROGRAM
        #pragma surface surf Lambert

        struct Input 
        {
            float2 uv_MainTex;
            float2 uv_NormalMap;
            float3 worldRefl;
            INTERNAL_DATA
        };

        sampler2D _MainTex;
        sampler2D _NormalMap;
        samplerCUBE _ReflectionCube;

        float _ReflectionIntensity;
        float3 _Color;

        void surf (Input IN, inout SurfaceOutput output) 
        {
            fixed3 albedo = tex2D (_MainTex, IN.uv_MainTex).rgb;
            half3 normal = UnpackNormal (tex2D (_NormalMap, IN.uv_NormalMap));
            fixed3 emission = texCUBE (_ReflectionCube, WorldReflectionVector(IN, normal)).rgb;

            albedo *= _Color;
            emission *= _ReflectionIntensity;

            output.Normal = normal;
            output.Albedo = albedo;            
            output.Emission = emission;
        }
        ENDCG
    } 
    Fallback "Diffuse"
}
