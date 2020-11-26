Shader "MyUnityBasic/Slices" 
{
    Properties 
    {
        _MainTex ("Texture", 2D) = "white" {}
        _NormalMap ("NormalMap", 2D) = "bump" {}
        _Rotation ("Rotation", Range(0.0, 360.0)) = 0.0
    }

    SubShader 
    {
        Tags { "RenderType" = "Opaque" }
        Cull Off
        CGPROGRAM
        #pragma surface surf Lambert

        struct Input 
        {
            float2 uv_MainTex;
            float2 uv_BumpMap;
            float3 worldPos;
        };

        float2 rotateUV(float2 uv, float degrees)
        {
            const float Deg2Rad = (UNITY_PI * 2.0) / 360.0;
            
            float rotationRadians = degrees * Deg2Rad;
            float s = sin(rotationRadians); 
            float c = cos(rotationRadians);
            
            float2x2 rotationMatrix = float2x2( c, -s, s, c);
            
            uv -= 0.5; 
            uv = mul(rotationMatrix, uv); 
            uv += 0.5; 
            
            return uv;
        }

        sampler2D _MainTex;
        sampler2D _NormalMap;
        float _Rotation;

        void surf (Input IN, inout SurfaceOutput output) 
        {
            float2 worldUV;
            worldUV.x = IN.worldPos.y;
            worldUV.y = IN.worldPos.z;
            worldUV = rotateUV(worldUV, _Rotation);

            clip (frac((worldUV.x + worldUV.y* 0.1) * 5) - 0.5);
            output.Albedo = tex2D (_MainTex, IN.uv_MainTex).rgb;
            output.Normal = UnpackNormal (tex2D (_NormalMap, IN.uv_BumpMap));
        }
        ENDCG
    } 
    Fallback "Diffuse"
}