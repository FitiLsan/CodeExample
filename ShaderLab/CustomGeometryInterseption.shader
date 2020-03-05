Shader "MyShaders/Custom Geometry Interseption"
{ 
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color("Color", Color) = (1,1,1,.2) 
    }
    SubShader
    {
        Tags{ "Queue" = "Transparent" "RenderType" = "Transparent" }
        Pass
        {
            Stencil
            {
                Ref 172
                Comp Always
                Pass Replace
                ZFail Zero
            }
            Blend Zero One
            Cull Front
            ZTest  GEqual
            ZWrite Off
            
        }// end stencil pass
        Pass
        {
            Blend SrcAlpha OneMinusSrcAlpha
            Stencil
            {
                Ref 172
                Comp Equal
            }

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            
            #define MAX_STEPS 100
            #define MAX_DIST 100
            #define SURF_DIST 1e-3 // equal to 0.001

            float4 _Color;

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;                
                float4 vertex : SV_POSITION;
                float3 ro : TEXCOORD1; // Ray Origin
                float3 hitPos : TEXCOORD2;
            };

            sampler2D _MainTex;

            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                //o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.ro = mul(unity_WorldToObject, float4(_WorldSpaceCameraPos, 1)); 
                o.hitPos = v.vertex; 
                return o;
            }

            float3 sdCapsule(float3 p, float3 a, float3 b, float r)
            {
                float3 ab = b-a;
                float3 ap = p-a;

                float t = dot(ab, ap) / dot(ab, ab);
                t = clamp(t, 0.0f, 1.0f);

                float3 c = a + t*ab;

                return length(p-c) - r;
            }

            float3 GetDist(float3 p)
            {
                float3 d = length(p) - 0.5f; // sphere

                float3 aSize = float3(-0.25,0,0); 
                float3 bSize = float3(0.25,0,0); 
                float3 myZero =float3(0,0,0); 

                d = sdCapsule(p, aSize, bSize, 0.2f); // Capsule

                return d;
            }

            float Raymarch(float3 ro, float3 rd)
            {
                float dO = 0;
                float dS;

                for(int i = 0; i < MAX_STEPS; i++)
                {
                    float3 p = ro + dO * rd;
                    dS = GetDist(p);
                    dO += dS;

                    if(dS < SURF_DIST || dO > MAX_DIST) break;
                }

                return dO;
            }


            fixed4 frag(v2f i) : SV_Target
            {
                fixed4 col = fixed4(1,1,1,1);
                float3 ro = i.ro;
                float3 rd = normalize(i.hitPos - ro);

                float d = Raymarch(ro, rd);

                if(d >= MAX_DIST) discard;
                else 
                {
                    float3 p = ro + rd * d;
                }

                // float3 p = ro + rd * d;
                // float4 capsule = float4(p.x, p.y, p.z, 1);
                // col *= capsule;
                //   col *= -1;
                // col -= 1;

                // col.xyz *= p;

                return col;
            }
            ENDCG
        }//end color pass
    }
    //FallBack "Diffuse"
}
