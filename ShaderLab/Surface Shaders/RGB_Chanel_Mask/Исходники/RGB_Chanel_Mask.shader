Shader"MyShaders/RGB_Chanel_Mask"
{
    Properties
    {
        _MaskTex ("Mask Texture", 2D) = "yellow" {}

        _MainTex1 ("Blue chanel", 2D) = "yellow" {}
        _MainTex2 ("Green chanel", 2D) = "yellow" {}
        _MainTex3 ("Red chanel", 2D) = "yellow" {}

        _EmissionColor ("Emission Color", Color) = (1,1,1,1)
        _VectorParam ("Vector Parameter", Vector) = (1,1,1,1)

        _FloatParam ("Float Param", Float) = 1.5
        _IntegerParam ("Integer Param", Float) = 1
        _RangeParam ("Range Param", Range(0, 1)) = 1        
    }

    SubShader 
    {
        CGPROGRAM

        #pragma surface surf Lambert

        struct Input
        {
            half2 uv_MainTex1,
            uv_MainTex2,
            uv_MainTex3;
            half2 uv_MaskTex;
        };

        sampler2D _MainTex1,
        _MainTex2,
        _MainTex3;
        
        sampler2D _MaskTex;
        fixed3 _EmissionColor;

        void surf(Input IN, inout SurfaceOutput o)
        {    
            fixed3 masks = tex2D(_MaskTex, IN.uv_MaskTex);
            fixed3 clr = tex2D(_MainTex1, IN.uv_MainTex1) * masks.b;
            clr += tex2D(_MainTex2, IN.uv_MainTex2) * masks.g;
            clr += tex2D(_MainTex3, IN.uv_MainTex3) * masks.r;

            o.Emission = _EmissionColor;

            o.Albedo = clr; //tex2D(_MainTex, IN.uv_MainTex);    
        }

        ENDCG
    }

    Fallback "Diffuse" 
}