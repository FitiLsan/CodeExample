Shader "MyUnityBasic/RimNormal"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _NormalMap ("NormalMap", 2D) = "bump" {}
        _EmissionMap ("EmissionMap", 2D) = "black" {}
        _EmissionIntensity ("EmissionIntensity", Float) = 1

        _RimColor ("Rim Color", Color) = (0.26,0.19,0.16,0.0)
        _RimPower ("Rim Power", Range(0.0,4.0)) = 1.0
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

        fixed4 _Color;
        sampler2D _MainTex;
        sampler2D _NormalMap;
        sampler2D _EmissionMap;
        float _EmissionIntensity;

        float4 _RimColor;
        float _RimPower;

        void surf (Input IN, inout SurfaceOutput output)
        {
            // Albedo comes from a texture tinted by color
            fixed3 albedo = tex2D(_MainTex, IN.uv_MainTex);
            fixed3 emission = tex2D(_EmissionMap, IN.uv_EmissionMap);
            half3 normal = UnpackNormal(tex2D (_NormalMap, IN.uv_NormalMap));

            albedo *= _Color;
            emission *= _EmissionIntensity;

            half rim = 1.0 -  dot(normalize(IN.viewDir), output.Normal);
            fixed3 rimEffect = _RimColor.rgb * (rim * _RimPower); 
            emission += rimEffect;

            output.Albedo = albedo.rgb;
            output.Normal = normal;
            output.Emission = emission;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
