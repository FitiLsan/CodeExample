Shader "MyShaders/Outline"
{
    Properties 
    {
        _Color ("Main Color", Color) = (.5,.5,.5,1)
        _OutlineColor ("Outline Color", Color) = (0,0,0,1)
        _Outline ("Outline width", Range (1, 3)) = 1
        _Multipliyer ("Multipliyer", Range (0, 2)) = 1
        _MainTex ("Base (RGB)", 2D) = "white" { }
    }
    
    SubShader {
        Tags { "Queue" = "Transparent" }
        
        Pass 
        {
            Name "OUTLINE"
            Tags { "LightMode" = "Always" }
            Cull Off
            ZWrite Off
            ZTest Always
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata 
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 color : COLOR;
            };

            struct v2f 
            {
                float4 pos : POSITION;
                float4 color : COLOR;
            };

            uniform float _Outline;
            uniform float _Multipliyer;
            uniform float4 _OutlineColor;

            v2f vert(appdata v) 
            {
                v2f o;
                v.vertex.xyz += v.normal * _Outline * _Multipliyer; // *= _Outline; // Hard surface
                o.pos = UnityObjectToClipPos(v.vertex);
                o.color = _OutlineColor;
                return o;
            }

            half4 frag(v2f i) :COLOR 
            {
                return i.color;
            }
            ENDCG
        }
        
        Pass 
        {
            Name "BASE"
            ZWrite On
            ZTest LEqual
            Lighting On

            Material 
            {
                Diffuse [_Color]
                Ambient [_Color]
            }
            SetTexture [_MainTex] 
            {
                ConstantColor [_Color]
                Combine texture * constant
            }
            SetTexture [_MainTex] 
            {
                Combine previous * primary DOUBLE
            }
        }
    } 
    Fallback "Diffuse"
}
