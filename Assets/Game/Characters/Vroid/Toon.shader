Shader "Toon/Toon"
{
Properties {
    _Color("Color", Color) = (1,1,1,1)
    _MainTex ("Base (RGB) Trans (A)", 2D) = "white" {}
    [HDR]
	_AmbientColor("Ambient Color", Color) = (0.4,0.4,0.4,1)
	[HDR]
	_SpecularColor("Specular Color", Color) = (0.9,0.9,0.9,1)
	_Glossiness("Glossiness", Float) = 32
	[HDR]
    _ShadowColor("ShadowColor", Color) = (0.1,0.1,0.1,1)
    [HDR]
    _RimColor("Rim Color", Color) = (1,1,1,1)
	_RimAmount("Rim Amount", Range(0, 1)) = 0.716
	_RimThreshold("Rim Threshold", Range(0, 1)) = 0.1
    _Cutoff ("Alpha cutoff", Range(0,1)) = 0.5

}
    SubShader
    {
        Tags { "RenderType"="Opaque" "RenderType"="TransparentCutout" "LightMode" = "UniversalForward"}
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "AutoLight.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
				float3 normal : NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 worldNormal : NORMAL;
				float3 viewDir : TEXCOORD1;	
                UNITY_FOG_COORDS(1)
                UNITY_VERTEX_OUTPUT_STEREO
                SHADOW_COORDS(2)
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            fixed _Cutoff;


            v2f vert (appdata v)
            {
                v2f o;
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.viewDir = WorldSpaceViewDir(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                TRANSFER_SHADOW(o);
                return o;
            }

            float4 _Color;
			float4 _AmbientColor;
			float4 _SpecularColor;
			float _Glossiness;		
			float4 _RimColor;
			float _RimAmount;
			float _RimThreshold;
            float4 _ShadowColor;

            fixed4 frag (v2f i) : SV_Target
            {
                float3 normal = normalize(i.worldNormal);
				float3 viewDir = normalize(i.viewDir);

				float NdotL = dot(_WorldSpaceLightPos0, normal);

				float shadow = SHADOW_ATTENUATION(i);

				float lightIntensity = smoothstep(0, 0.01, NdotL * shadow);
				float4 light = lightIntensity * _LightColor0;
                
				float3 halfVector = normalize(_WorldSpaceLightPos0 + viewDir);
				float NdotH = dot(normal, halfVector);

				float specularIntensity = pow(NdotH * lightIntensity, _Glossiness * _Glossiness);
				float specularIntensitySmooth = smoothstep(0.005, 0.01, specularIntensity);
				float4 specular = specularIntensitySmooth * _SpecularColor;

				float rimDot = 1 - dot(viewDir, normal);

				float rimIntensity = rimDot * pow(NdotL, _RimThreshold);
				rimIntensity = smoothstep(_RimAmount - 0.01, _RimAmount + 0.01, rimIntensity);
				float4 rim = rimIntensity * _RimColor;

				float4 sample = tex2D(_MainTex, i.uv);

                fixed4 col = tex2D(_MainTex, i.uv);
                clip(col.a - _Cutoff);
                UNITY_APPLY_FOG(i.fogCoord, col);
                return (light + _AmbientColor + specular + rim + ( (1-light) * _ShadowColor)) * _Color * col;
            }
            ENDCG
        }

    UsePass "Legacy Shaders/VertexLit/SHADOWCASTER"
    }
}
