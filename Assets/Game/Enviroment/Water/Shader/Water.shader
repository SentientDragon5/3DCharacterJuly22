Shader "Water Logan S/Multi Water"
    {
        Properties
        {
             [KeywordEnum(Script Controlled, Indiviual Material Inspector)]_IsControlledByScript("Inspector", Float) = 1
            
            [Header(Depth Settings)][Space(5)]
            _DepthOffset("DepthOffset", Range(-2, 2)) = 0
            _Strength("Strength", Range(0, 1)) = 0.4

            [Space(20)][Header(Color Settings)][Space(5)]
            _DeepWaterColor("Deep Color", Color) = (0.215, 0.3, 0.4, 1)
            _ShallowWaterColor("Shallow Color", Color) = (0.6, 0.725, 0.775, 0.5)
            _Metallic("Metalic", Range(0, 1)) = 0.1
            
            [Header(Texture Settings)][Space(5)]
            _Tiling("Tiling", Vector) = (10, 10, 0, 0)
            [KeywordEnum(River, Ocean)]_IsOcean("Water Type", Float) = 0

            [Header(Ocean Settings)][Space(5)]
            [NoScaleOffset]_OceanNormal2("Ocean Normal 2", 2D) = "bump" {}
            [NoScaleOffset]_OceanNormal1("Ocean Normal 1", 2D) = "bump" {}
            _GradientNoise("Noise Scale", Range(0, 100)) = 0
            _OceanSpeed("Ocean Speed", Vector) = (50, -25, 0, 0)

            [Header(LOD Settings)][Space(5)]
            _LODdistance("LOD distance", Range(0, 10000)) = 2500
            [NoScaleOffset]_FarNormal("Far Normal", 2D) = "bump" {}


            [Header(River Settings)][Space(5)]
            [NoScaleOffset]_RiverNormal("Rushing Water Normal", 2D) = "bump" {}
            _RiverNormalRotAdjustment("Rushing Normal Rotation", Range(0, 360)) = 210
            [NoScaleOffset]_LevelRiverNormal("Still Water Normal", 2D) = "bump" {}
            _RiverSpeed("Rushing Speed Scalar", Float) = -5


            [Header(Shore Settings)][Space(5)]
            [NoScaleOffset]_ShallowNormal("Shallow Normal", 2D) = "bump" {}
            _TranceparencyStrength("Trancparency Strength", Float) = 0.001
            _DownAlphaStrength("Down Alpha Strength", Range(0, 1)) = 0.7
            

            [Header(Shore Settings)][Space(5)]
            _ShoreIntersectionStrength("Shore Strength", Range(0, 10)) = 5
            ShoreColor("Shore Color", Color) = (0.8726415, 0.9530143, 1, 0.8235294)
            
            
            [HideInInspector][NoScaleOffset]unity_Lightmaps("unity_Lightmaps", 2DArray) = "" {}
            [HideInInspector][NoScaleOffset]unity_LightmapsInd("unity_LightmapsInd", 2DArray) = "" {}
            [HideInInspector][NoScaleOffset]unity_ShadowMasks("unity_ShadowMasks", 2DArray) = "" {}
        }
        SubShader
        {
            Tags
            {
                "RenderPipeline"="UniversalPipeline"
                "RenderType"="Transparent"
                "UniversalMaterialType" = "Lit"
                "Queue"="Transparent"
            }
            Pass
            {
                Name "Universal Forward"
                Tags
                {
                    "LightMode" = "UniversalForward"
                }
    
                // Render State
                Cull Off
                Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
                ZTest LEqual
                ZWrite Off
    
                // Debug
                // <None>
    
                // --------------------------------------------------
                // Pass
    
                HLSLPROGRAM
    
                // Pragmas
                #pragma target 4.5
                #pragma exclude_renderers gles gles3 glcore
                #pragma multi_compile_instancing
                #pragma multi_compile_fog
                #pragma multi_compile _ DOTS_INSTANCING_ON
                #pragma vertex vert
                #pragma fragment frag
    
                // DotsInstancingOptions: <None>
                // HybridV1InjectedBuiltinProperties: <None>
    
                // Keywords
                #pragma multi_compile _ _SCREEN_SPACE_OCCLUSION
                #pragma multi_compile _ LIGHTMAP_ON
                #pragma multi_compile _ DIRLIGHTMAP_COMBINED
                #pragma multi_compile _ _MAIN_LIGHT_SHADOWS
                #pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
                #pragma multi_compile _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS _ADDITIONAL_OFF
                #pragma multi_compile _ _ADDITIONAL_LIGHT_SHADOWS
                #pragma multi_compile _ _SHADOWS_SOFT
                #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
                #pragma multi_compile _ SHADOWS_SHADOWMASK
                // GraphKeywords: <None>
    
                // Defines
                #define _SURFACE_TYPE_TRANSPARENT 1
                #define _NORMALMAP 1
                #define _NORMAL_DROPOFF_TS 1
                #define ATTRIBUTES_NEED_NORMAL
                #define ATTRIBUTES_NEED_TANGENT
                #define ATTRIBUTES_NEED_TEXCOORD0
                #define ATTRIBUTES_NEED_TEXCOORD1
                #define VARYINGS_NEED_POSITION_WS
                #define VARYINGS_NEED_NORMAL_WS
                #define VARYINGS_NEED_TANGENT_WS
                #define VARYINGS_NEED_TEXCOORD0
                #define VARYINGS_NEED_VIEWDIRECTION_WS
                #define VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
                #define FEATURES_GRAPH_VERTEX
                /* WARNING: $splice Could not find named fragment 'PassInstancing' */
                #define SHADERPASS SHADERPASS_FORWARD
                #define REQUIRE_DEPTH_TEXTURE
                /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
    
                // Includes
                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
    
                // --------------------------------------------------
                // Structs and Packing
    
                struct Attributes
                {
                    float3 positionOS : POSITION;
                    float3 normalOS : NORMAL;
                    float4 tangentOS : TANGENT;
                    float4 uv0 : TEXCOORD0;
                    float4 uv1 : TEXCOORD1;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    uint instanceID : INSTANCEID_SEMANTIC;
                    #endif
                };
                struct Varyings
                {
                    float4 positionCS : SV_POSITION;
                    float3 positionWS;
                    float3 normalWS;
                    float4 tangentWS;
                    float4 texCoord0;
                    float3 viewDirectionWS;
                    #if defined(LIGHTMAP_ON)
                    float2 lightmapUV;
                    #endif
                    #if !defined(LIGHTMAP_ON)
                    float3 sh;
                    #endif
                    float4 fogFactorAndVertexLight;
                    float4 shadowCoord;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    uint instanceID : CUSTOM_INSTANCE_ID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                    #endif
                };
                struct SurfaceDescriptionInputs
                {
                    float3 WorldSpaceNormal;
                    float3 TangentSpaceNormal;
                    float3 WorldSpacePosition;
                    float4 ScreenPosition;
                    float4 uv0;
                    float3 TimeParameters;
                };
                struct VertexDescriptionInputs
                {
                    float3 ObjectSpaceNormal;
                    float3 ObjectSpaceTangent;
                    float3 ObjectSpacePosition;
                };
                struct PackedVaryings
                {
                    float4 positionCS : SV_POSITION;
                    float3 interp0 : TEXCOORD0;
                    float3 interp1 : TEXCOORD1;
                    float4 interp2 : TEXCOORD2;
                    float4 interp3 : TEXCOORD3;
                    float3 interp4 : TEXCOORD4;
                    #if defined(LIGHTMAP_ON)
                    float2 interp5 : TEXCOORD5;
                    #endif
                    #if !defined(LIGHTMAP_ON)
                    float3 interp6 : TEXCOORD6;
                    #endif
                    float4 interp7 : TEXCOORD7;
                    float4 interp8 : TEXCOORD8;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    uint instanceID : CUSTOM_INSTANCE_ID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                    #endif
                };
    
                PackedVaryings PackVaryings (Varyings input)
                {
                    PackedVaryings output;
                    output.positionCS = input.positionCS;
                    output.interp0.xyz =  input.positionWS;
                    output.interp1.xyz =  input.normalWS;
                    output.interp2.xyzw =  input.tangentWS;
                    output.interp3.xyzw =  input.texCoord0;
                    output.interp4.xyz =  input.viewDirectionWS;
                    #if defined(LIGHTMAP_ON)
                    output.interp5.xy =  input.lightmapUV;
                    #endif
                    #if !defined(LIGHTMAP_ON)
                    output.interp6.xyz =  input.sh;
                    #endif
                    output.interp7.xyzw =  input.fogFactorAndVertexLight;
                    output.interp8.xyzw =  input.shadowCoord;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    output.instanceID = input.instanceID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    output.cullFace = input.cullFace;
                    #endif
                    return output;
                }
                Varyings UnpackVaryings (PackedVaryings input)
                {
                    Varyings output;
                    output.positionCS = input.positionCS;
                    output.positionWS = input.interp0.xyz;
                    output.normalWS = input.interp1.xyz;
                    output.tangentWS = input.interp2.xyzw;
                    output.texCoord0 = input.interp3.xyzw;
                    output.viewDirectionWS = input.interp4.xyz;
                    #if defined(LIGHTMAP_ON)
                    output.lightmapUV = input.interp5.xy;
                    #endif
                    #if !defined(LIGHTMAP_ON)
                    output.sh = input.interp6.xyz;
                    #endif
                    output.fogFactorAndVertexLight = input.interp7.xyzw;
                    output.shadowCoord = input.interp8.xyzw;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    output.instanceID = input.instanceID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    output.cullFace = input.cullFace;
                    #endif
                    return output;
                }
    
                // --------------------------------------------------
                // Graph
    
                // Graph Properties
                CBUFFER_START(UnityPerMaterial)
                float _DepthOffset;
                float _Strength;
                float4 _DeepWaterColor;
                float4 _ShallowWaterColor;
                float _Metallic;
                float2 _Tiling;
                float4 _OceanNormal2_TexelSize;
                float4 _OceanNormal1_TexelSize;
                float _GradientNoise;
                float2 _OceanSpeed;
                float _LODdistance;
                float4 _FarNormal_TexelSize;
                float4 _ShallowNormal_TexelSize;
                float _TranceparencyStrength;
                float _DownAlphaStrength;
                float _IsOcean;
                float4 _RiverNormal_TexelSize;
                float _RiverNormalRotAdjustment;
                float4 _LevelRiverNormal_TexelSize;
                float _RiverSpeed;
                float _ShoreIntersectionStrength;
                float4 Color_701f2c2f40b34b87975a0e85a71325dc;
                CBUFFER_END
                
                // Object and Global properties
                SAMPLER(SamplerState_Linear_Repeat);
                TEXTURE2D(_OceanNormal2);
                SAMPLER(sampler_OceanNormal2);
                TEXTURE2D(_OceanNormal1);
                SAMPLER(sampler_OceanNormal1);
                TEXTURE2D(_FarNormal);
                SAMPLER(sampler_FarNormal);
                TEXTURE2D(_ShallowNormal);
                SAMPLER(sampler_ShallowNormal);
                TEXTURE2D(_RiverNormal);
                SAMPLER(sampler_RiverNormal);
                TEXTURE2D(_LevelRiverNormal);
                SAMPLER(sampler_LevelRiverNormal);
                float _StretchScalar;
    
                // Graph Functions
                
                void Unity_SceneDepth_Linear01_float(float4 UV, out float Out)
                {
                    Out = Linear01Depth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
                }
                
                void Unity_Multiply_float(float A, float B, out float Out)
                {
                    Out = A * B;
                }
                
                void Unity_Add_float(float A, float B, out float Out)
                {
                    Out = A + B;
                }
                
                void Unity_Subtract_float(float A, float B, out float Out)
                {
                    Out = A - B;
                }
                
                void Unity_Sine_float(float In, out float Out)
                {
                    Out = sin(In);
                }
                
                void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
                {
                    Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
                }
                
                void Unity_Branch_float(float Predicate, float True, float False, out float Out)
                {
                    Out = Predicate ? True : False;
                }
                
                void Unity_Clamp_float(float In, float Min, float Max, out float Out)
                {
                    Out = clamp(In, Min, Max);
                }
                
                void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
                {
                    Out = lerp(A, B, T);
                }
                
                void Unity_Normalize_float3(float3 In, out float3 Out)
                {
                    Out = normalize(In);
                }
                
                void Unity_DotProduct_float3(float3 A, float3 B, out float Out)
                {
                    Out = dot(A, B);
                }
                
                void Unity_Add_float4(float4 A, float4 B, out float4 Out)
                {
                    Out = A + B;
                }
                
                void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
                {
                    Out = UV * Tiling + Offset;
                }
                
                void Unity_Divide_float(float A, float B, out float Out)
                {
                    Out = A / B;
                }
                
                
                float2 Unity_GradientNoise_Dir_float(float2 p)
                {
                    // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
                    p = p % 289;
                    // need full precision, otherwise half overflows when p > 1
                    float x = float(34 * p.x + 1) * p.x % 289 + p.y;
                    x = (34 * x + 1) * x % 289;
                    x = frac(x / 41) * 2 - 1;
                    return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
                }
                
                void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
                { 
                    float2 p = UV * Scale;
                    float2 ip = floor(p);
                    float2 fp = frac(p);
                    float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
                    float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
                    float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
                    float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
                    fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
                    Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
                }
                
                void Unity_Comparison_Greater_float(float A, float B, out float Out)
                {
                    Out = A > B ? 1 : 0;
                }
                
                void Unity_Normalize_float2(float2 In, out float2 Out)
                {
                    Out = normalize(In);
                }
                
                void Unity_DotProduct_float2(float2 A, float2 B, out float Out)
                {
                    Out = dot(A, B);
                }
                
                void Unity_Arccosine_float(float In, out float Out)
                {
                    Out = acos(In);
                }
                
                void Unity_Rotate_Radians_float(float2 UV, float2 Center, float Rotation, out float2 Out)
                {
                    //rotation matrix
                    UV -= Center;
                    float s = sin(Rotation);
                    float c = cos(Rotation);
                
                    //center rotation matrix
                    float2x2 rMatrix = float2x2(c, -s, s, c);
                    rMatrix *= 0.5;
                    rMatrix += 0.5;
                    rMatrix = rMatrix*2 - 1;
                
                    //multiply the UVs by the rotation matrix
                    UV.xy = mul(UV.xy, rMatrix);
                    UV += Center;
                
                    Out = UV;
                }
                
                void Unity_Lerp_float(float A, float B, float T, out float Out)
                {
                    Out = lerp(A, B, T);
                }
                
                void Unity_Rotate_Degrees_float(float2 UV, float2 Center, float Rotation, out float2 Out)
                {
                    //rotation matrix
                    Rotation = Rotation * (3.1415926f/180.0f);
                    UV -= Center;
                    float s = sin(Rotation);
                    float c = cos(Rotation);
                
                    //center rotation matrix
                    float2x2 rMatrix = float2x2(c, -s, s, c);
                    rMatrix *= 0.5;
                    rMatrix += 0.5;
                    rMatrix = rMatrix*2 - 1;
                
                    //multiply the UVs by the rotation matrix
                    UV.xy = mul(UV.xy, rMatrix);
                    UV += Center;
                
                    Out = UV;
                }
                
                void Unity_Branch_float4(float Predicate, float4 True, float4 False, out float4 Out)
                {
                    Out = Predicate ? True : False;
                }
                
                void Unity_Distance_float3(float3 A, float3 B, out float Out)
                {
                    Out = distance(A, B);
                }
    
                // Graph Vertex
                struct VertexDescription
                {
                    float3 Position;
                    float3 Normal;
                    float3 Tangent;
                };
                
                VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                {
                    VertexDescription description = (VertexDescription)0;
                    description.Position = IN.ObjectSpacePosition;
                    description.Normal = IN.ObjectSpaceNormal;
                    description.Tangent = IN.ObjectSpaceTangent;
                    return description;
                }
    
                // Graph Pixel
                struct SurfaceDescription
                {
                    float3 BaseColor;
                    float3 NormalTS;
                    float3 Emission;
                    float Metallic;
                    float Smoothness;
                    float Occlusion;
                    float Alpha;
                };
                
                SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                {
                    SurfaceDescription surface = (SurfaceDescription)0;
                    float4 _Property_231c0d262d3a466d85dfd53b116086ca_Out_0 = Color_701f2c2f40b34b87975a0e85a71325dc;
                    float _SceneDepth_3137d738aa0149fb8a54d88a60826a60_Out_1;
                    Unity_SceneDepth_Linear01_float(float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0), _SceneDepth_3137d738aa0149fb8a54d88a60826a60_Out_1);
                    float _Multiply_8ec8e0a1878e494ca0d6d16678168741_Out_2;
                    Unity_Multiply_float(_SceneDepth_3137d738aa0149fb8a54d88a60826a60_Out_1, _ProjectionParams.z, _Multiply_8ec8e0a1878e494ca0d6d16678168741_Out_2);
                    float4 _ScreenPosition_3840c0fb20fc4eb58387cd54ee7e2b18_Out_0 = IN.ScreenPosition;
                    float _Split_578ef5cadaac40969c114c4d1ae870d8_R_1 = _ScreenPosition_3840c0fb20fc4eb58387cd54ee7e2b18_Out_0[0];
                    float _Split_578ef5cadaac40969c114c4d1ae870d8_G_2 = _ScreenPosition_3840c0fb20fc4eb58387cd54ee7e2b18_Out_0[1];
                    float _Split_578ef5cadaac40969c114c4d1ae870d8_B_3 = _ScreenPosition_3840c0fb20fc4eb58387cd54ee7e2b18_Out_0[2];
                    float _Split_578ef5cadaac40969c114c4d1ae870d8_A_4 = _ScreenPosition_3840c0fb20fc4eb58387cd54ee7e2b18_Out_0[3];
                    float _Property_cedd17331b16484abf1a4ce8eb0e5a72_Out_0 = _DepthOffset;
                    float _Add_e04e1bc3087745d898c282f10a0f43e3_Out_2;
                    Unity_Add_float(_Split_578ef5cadaac40969c114c4d1ae870d8_A_4, _Property_cedd17331b16484abf1a4ce8eb0e5a72_Out_0, _Add_e04e1bc3087745d898c282f10a0f43e3_Out_2);
                    float _Subtract_bd4ff2ba7ce04051b10b968b020d06df_Out_2;
                    Unity_Subtract_float(_Multiply_8ec8e0a1878e494ca0d6d16678168741_Out_2, _Add_e04e1bc3087745d898c282f10a0f43e3_Out_2, _Subtract_bd4ff2ba7ce04051b10b968b020d06df_Out_2);
                    float _Property_90205b2f827548b295dc151171bc164c_Out_0 = _IsOcean;
                    float _Sine_24a173ac1d9d40b5b43bd7c8169386e4_Out_1;
                    Unity_Sine_float(IN.TimeParameters.x, _Sine_24a173ac1d9d40b5b43bd7c8169386e4_Out_1);
                    float _Remap_9ed3ea235fdc44d7a8c762cbe7ff6d0e_Out_3;
                    Unity_Remap_float(_Sine_24a173ac1d9d40b5b43bd7c8169386e4_Out_1, float2 (-1, 1), float2 (0.5, 1), _Remap_9ed3ea235fdc44d7a8c762cbe7ff6d0e_Out_3);
                    float _Branch_fcfcb84348fb4a5a90417124dc9ee3a2_Out_3;
                    Unity_Branch_float(_Property_90205b2f827548b295dc151171bc164c_Out_0, _Remap_9ed3ea235fdc44d7a8c762cbe7ff6d0e_Out_3, 1, _Branch_fcfcb84348fb4a5a90417124dc9ee3a2_Out_3);
                    float _Property_866bbbbe2a484e2eae1ad77ed223a577_Out_0 = _ShoreIntersectionStrength;
                    float _Multiply_cb7f54f30fb348b4a7f109f458e38b17_Out_2;
                    Unity_Multiply_float(_Branch_fcfcb84348fb4a5a90417124dc9ee3a2_Out_3, _Property_866bbbbe2a484e2eae1ad77ed223a577_Out_0, _Multiply_cb7f54f30fb348b4a7f109f458e38b17_Out_2);
                    float _Multiply_dcdae92bb4dd401a89df781ec062cecc_Out_2;
                    Unity_Multiply_float(_Subtract_bd4ff2ba7ce04051b10b968b020d06df_Out_2, _Multiply_cb7f54f30fb348b4a7f109f458e38b17_Out_2, _Multiply_dcdae92bb4dd401a89df781ec062cecc_Out_2);
                    float _Clamp_33ee6da80fc14439b6d7bab14be7ab07_Out_3;
                    Unity_Clamp_float(_Multiply_dcdae92bb4dd401a89df781ec062cecc_Out_2, 0.5, 1, _Clamp_33ee6da80fc14439b6d7bab14be7ab07_Out_3);
                    float4 _Lerp_f0669e92de0b409893955d23347ac238_Out_3;
                    Unity_Lerp_float4(_Property_231c0d262d3a466d85dfd53b116086ca_Out_0, float4(0, 0, 0, 0), (_Clamp_33ee6da80fc14439b6d7bab14be7ab07_Out_3.xxxx), _Lerp_f0669e92de0b409893955d23347ac238_Out_3);
                    float _Float_c4cf30aef9464dda83de90c7e790a9ba_Out_0 = 1.5;
                    float4 _Property_c854872c24e048c0aa372f0be547f07c_Out_0 = _ShallowWaterColor;
                    float4 _Property_dde44c4f61534e08a917dd16bcf5ebca_Out_0 = _DeepWaterColor;
                    float _Property_d328dfa89c674e67bffe73ef574a2d58_Out_0 = _Strength;
                    float _Multiply_4eb7822d949844e38f2bb60067662a47_Out_2;
                    Unity_Multiply_float(_Subtract_bd4ff2ba7ce04051b10b968b020d06df_Out_2, _Property_d328dfa89c674e67bffe73ef574a2d58_Out_0, _Multiply_4eb7822d949844e38f2bb60067662a47_Out_2);
                    float _Clamp_0f7ac1e483384940a0714a9e608d50b4_Out_3;
                    Unity_Clamp_float(_Multiply_4eb7822d949844e38f2bb60067662a47_Out_2, 0, 1, _Clamp_0f7ac1e483384940a0714a9e608d50b4_Out_3);
                    float4 _Lerp_3f9225ad7cdc45509b625268ef70e29c_Out_3;
                    Unity_Lerp_float4(_Property_c854872c24e048c0aa372f0be547f07c_Out_0, _Property_dde44c4f61534e08a917dd16bcf5ebca_Out_0, (_Clamp_0f7ac1e483384940a0714a9e608d50b4_Out_3.xxxx), _Lerp_3f9225ad7cdc45509b625268ef70e29c_Out_3);
                    float3 _Normalize_415b503188e443458e4172309aa4cb18_Out_1;
                    Unity_Normalize_float3(IN.WorldSpaceNormal, _Normalize_415b503188e443458e4172309aa4cb18_Out_1);
                    float _DotProduct_b3f1b90b273a4b2b99f07acbc4565dcb_Out_2;
                    Unity_DotProduct_float3(float3(0, 1, 0), _Normalize_415b503188e443458e4172309aa4cb18_Out_1, _DotProduct_b3f1b90b273a4b2b99f07acbc4565dcb_Out_2);
                    float _Remap_669938a90f934b9bab86d586a6917aca_Out_3;
                    Unity_Remap_float(_DotProduct_b3f1b90b273a4b2b99f07acbc4565dcb_Out_2, float2 (-1, 1), float2 (0, 1), _Remap_669938a90f934b9bab86d586a6917aca_Out_3);
                    float4 _Lerp_4536ba8c658e4f11aaefc80660368304_Out_3;
                    Unity_Lerp_float4((_Float_c4cf30aef9464dda83de90c7e790a9ba_Out_0.xxxx), _Lerp_3f9225ad7cdc45509b625268ef70e29c_Out_3, (_Remap_669938a90f934b9bab86d586a6917aca_Out_3.xxxx), _Lerp_4536ba8c658e4f11aaefc80660368304_Out_3);
                    float4 _Add_f8fda8450f33454d96a6212c8ebfdc62_Out_2;
                    Unity_Add_float4(_Lerp_f0669e92de0b409893955d23347ac238_Out_3, _Lerp_4536ba8c658e4f11aaefc80660368304_Out_3, _Add_f8fda8450f33454d96a6212c8ebfdc62_Out_2);
                    float _Split_17c957ee33bc4e28a994b8b8dd20a89f_R_1 = _Add_f8fda8450f33454d96a6212c8ebfdc62_Out_2[0];
                    float _Split_17c957ee33bc4e28a994b8b8dd20a89f_G_2 = _Add_f8fda8450f33454d96a6212c8ebfdc62_Out_2[1];
                    float _Split_17c957ee33bc4e28a994b8b8dd20a89f_B_3 = _Add_f8fda8450f33454d96a6212c8ebfdc62_Out_2[2];
                    float _Split_17c957ee33bc4e28a994b8b8dd20a89f_A_4 = _Add_f8fda8450f33454d96a6212c8ebfdc62_Out_2[3];
                    float3 _Vector3_3b779f158e6f4ba8ac091e620cd4bd1c_Out_0 = float3(_Split_17c957ee33bc4e28a994b8b8dd20a89f_R_1, _Split_17c957ee33bc4e28a994b8b8dd20a89f_G_2, _Split_17c957ee33bc4e28a994b8b8dd20a89f_B_3);
                    UnityTexture2D _Property_98dcadd153784e00b3d99c72c66a28b9_Out_0 = UnityBuildTexture2DStructNoScale(_ShallowNormal);
                    float2 _TilingAndOffset_e057885e86584dea86f94cfc76e1e048_Out_3;
                    Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), float2 (0, 0), _TilingAndOffset_e057885e86584dea86f94cfc76e1e048_Out_3);
                    float4 _SampleTexture2D_0121a928620142938ff635ec1ff89401_RGBA_0 = SAMPLE_TEXTURE2D(_Property_98dcadd153784e00b3d99c72c66a28b9_Out_0.tex, _Property_98dcadd153784e00b3d99c72c66a28b9_Out_0.samplerstate, _TilingAndOffset_e057885e86584dea86f94cfc76e1e048_Out_3);
                    _SampleTexture2D_0121a928620142938ff635ec1ff89401_RGBA_0.rgb = UnpackNormal(_SampleTexture2D_0121a928620142938ff635ec1ff89401_RGBA_0);
                    float _SampleTexture2D_0121a928620142938ff635ec1ff89401_R_4 = _SampleTexture2D_0121a928620142938ff635ec1ff89401_RGBA_0.r;
                    float _SampleTexture2D_0121a928620142938ff635ec1ff89401_G_5 = _SampleTexture2D_0121a928620142938ff635ec1ff89401_RGBA_0.g;
                    float _SampleTexture2D_0121a928620142938ff635ec1ff89401_B_6 = _SampleTexture2D_0121a928620142938ff635ec1ff89401_RGBA_0.b;
                    float _SampleTexture2D_0121a928620142938ff635ec1ff89401_A_7 = _SampleTexture2D_0121a928620142938ff635ec1ff89401_RGBA_0.a;
                    float _Property_c92104f8c9d245dbb796f54a2386b2fa_Out_0 = _IsOcean;
                    float2 _Property_0165785b858447e9be7aeae88e49b876_Out_0 = _Tiling;
                    float _Divide_40fd94b5668f4354bc4f097174879071_Out_2;
                    Unity_Divide_float(IN.TimeParameters.x, 25, _Divide_40fd94b5668f4354bc4f097174879071_Out_2);
                    float2 _TilingAndOffset_dd58a4e4d2f44f4692185d84f037be72_Out_3;
                    Unity_TilingAndOffset_float(IN.uv0.xy, _Property_0165785b858447e9be7aeae88e49b876_Out_0, (_Divide_40fd94b5668f4354bc4f097174879071_Out_2.xx), _TilingAndOffset_dd58a4e4d2f44f4692185d84f037be72_Out_3);
                    float _Property_dcf2fdcb8f824668b8a6e8c81f6e182d_Out_0 = _GradientNoise;
                    float _GradientNoise_2c52090e5ac5473ba4d45f48de31694f_Out_2;
                    Unity_GradientNoise_float(_TilingAndOffset_dd58a4e4d2f44f4692185d84f037be72_Out_3, _Property_dcf2fdcb8f824668b8a6e8c81f6e182d_Out_0, _GradientNoise_2c52090e5ac5473ba4d45f48de31694f_Out_2);
                    float _Remap_fe18556f20a1429782d5401a4e93f4ff_Out_3;
                    Unity_Remap_float(_GradientNoise_2c52090e5ac5473ba4d45f48de31694f_Out_2, float2 (0, 1), float2 (-1, 1), _Remap_fe18556f20a1429782d5401a4e93f4ff_Out_3);
                    UnityTexture2D _Property_1aa6808f044b4d20b816c793ef91056c_Out_0 = UnityBuildTexture2DStructNoScale(_OceanNormal1);
                    float2 _Property_6dc7633668bb4df38e93ccda13f0e850_Out_0 = _OceanSpeed;
                    float _Split_35918e73b31d4ab383b2221ebc8e73c7_R_1 = _Property_6dc7633668bb4df38e93ccda13f0e850_Out_0[0];
                    float _Split_35918e73b31d4ab383b2221ebc8e73c7_G_2 = _Property_6dc7633668bb4df38e93ccda13f0e850_Out_0[1];
                    float _Split_35918e73b31d4ab383b2221ebc8e73c7_B_3 = 0;
                    float _Split_35918e73b31d4ab383b2221ebc8e73c7_A_4 = 0;
                    float _Divide_320942700ecd49068a4d2fac0bbcd012_Out_2;
                    Unity_Divide_float(IN.TimeParameters.x, _Split_35918e73b31d4ab383b2221ebc8e73c7_R_1, _Divide_320942700ecd49068a4d2fac0bbcd012_Out_2);
                    float2 _TilingAndOffset_2c0d1a11da414db2972d2b0e6e6eead7_Out_3;
                    Unity_TilingAndOffset_float(IN.uv0.xy, _Property_0165785b858447e9be7aeae88e49b876_Out_0, (_Divide_320942700ecd49068a4d2fac0bbcd012_Out_2.xx), _TilingAndOffset_2c0d1a11da414db2972d2b0e6e6eead7_Out_3);
                    float4 _SampleTexture2D_95cbac09786f4d9f877a32a692103c63_RGBA_0 = SAMPLE_TEXTURE2D(_Property_1aa6808f044b4d20b816c793ef91056c_Out_0.tex, _Property_1aa6808f044b4d20b816c793ef91056c_Out_0.samplerstate, _TilingAndOffset_2c0d1a11da414db2972d2b0e6e6eead7_Out_3);
                    _SampleTexture2D_95cbac09786f4d9f877a32a692103c63_RGBA_0.rgb = UnpackNormal(_SampleTexture2D_95cbac09786f4d9f877a32a692103c63_RGBA_0);
                    float _SampleTexture2D_95cbac09786f4d9f877a32a692103c63_R_4 = _SampleTexture2D_95cbac09786f4d9f877a32a692103c63_RGBA_0.r;
                    float _SampleTexture2D_95cbac09786f4d9f877a32a692103c63_G_5 = _SampleTexture2D_95cbac09786f4d9f877a32a692103c63_RGBA_0.g;
                    float _SampleTexture2D_95cbac09786f4d9f877a32a692103c63_B_6 = _SampleTexture2D_95cbac09786f4d9f877a32a692103c63_RGBA_0.b;
                    float _SampleTexture2D_95cbac09786f4d9f877a32a692103c63_A_7 = _SampleTexture2D_95cbac09786f4d9f877a32a692103c63_RGBA_0.a;
                    UnityTexture2D _Property_fab5aef84b23441fbfd40281cf1ada82_Out_0 = UnityBuildTexture2DStructNoScale(_OceanNormal2);
                    float _Divide_dbf1715fe11a470fb42e9a29bb351a9d_Out_2;
                    Unity_Divide_float(IN.TimeParameters.x, _Split_35918e73b31d4ab383b2221ebc8e73c7_G_2, _Divide_dbf1715fe11a470fb42e9a29bb351a9d_Out_2);
                    float2 _TilingAndOffset_bc9854cad9a042cfb0ebc3bb5b4792e4_Out_3;
                    Unity_TilingAndOffset_float(IN.uv0.xy, _Property_0165785b858447e9be7aeae88e49b876_Out_0, (_Divide_dbf1715fe11a470fb42e9a29bb351a9d_Out_2.xx), _TilingAndOffset_bc9854cad9a042cfb0ebc3bb5b4792e4_Out_3);
                    float4 _SampleTexture2D_7f1b3f3ae5d243f9b432299bdc4f7b97_RGBA_0 = SAMPLE_TEXTURE2D(_Property_fab5aef84b23441fbfd40281cf1ada82_Out_0.tex, _Property_fab5aef84b23441fbfd40281cf1ada82_Out_0.samplerstate, _TilingAndOffset_bc9854cad9a042cfb0ebc3bb5b4792e4_Out_3);
                    _SampleTexture2D_7f1b3f3ae5d243f9b432299bdc4f7b97_RGBA_0.rgb = UnpackNormal(_SampleTexture2D_7f1b3f3ae5d243f9b432299bdc4f7b97_RGBA_0);
                    float _SampleTexture2D_7f1b3f3ae5d243f9b432299bdc4f7b97_R_4 = _SampleTexture2D_7f1b3f3ae5d243f9b432299bdc4f7b97_RGBA_0.r;
                    float _SampleTexture2D_7f1b3f3ae5d243f9b432299bdc4f7b97_G_5 = _SampleTexture2D_7f1b3f3ae5d243f9b432299bdc4f7b97_RGBA_0.g;
                    float _SampleTexture2D_7f1b3f3ae5d243f9b432299bdc4f7b97_B_6 = _SampleTexture2D_7f1b3f3ae5d243f9b432299bdc4f7b97_RGBA_0.b;
                    float _SampleTexture2D_7f1b3f3ae5d243f9b432299bdc4f7b97_A_7 = _SampleTexture2D_7f1b3f3ae5d243f9b432299bdc4f7b97_RGBA_0.a;
                    float4 _Add_3f6c04238c1f459eb8e6300b9eb1f842_Out_2;
                    Unity_Add_float4(_SampleTexture2D_95cbac09786f4d9f877a32a692103c63_RGBA_0, _SampleTexture2D_7f1b3f3ae5d243f9b432299bdc4f7b97_RGBA_0, _Add_3f6c04238c1f459eb8e6300b9eb1f842_Out_2);
                    float4 _Add_3e553e4abf784d7799c718cfe7d51b68_Out_2;
                    Unity_Add_float4((_Remap_fe18556f20a1429782d5401a4e93f4ff_Out_3.xxxx), _Add_3f6c04238c1f459eb8e6300b9eb1f842_Out_2, _Add_3e553e4abf784d7799c718cfe7d51b68_Out_2);
                    float _Comparison_8f4fb954760447e8b0db8924e20fd1d0_Out_2;
                    Unity_Comparison_Greater_float(_Remap_669938a90f934b9bab86d586a6917aca_Out_3, 0, _Comparison_8f4fb954760447e8b0db8924e20fd1d0_Out_2);
                    UnityTexture2D _Property_ab131e76fa9e4575850bad711d6bc112_Out_0 = UnityBuildTexture2DStructNoScale(_RiverNormal);
                    float3 _Normalize_62a13fd33141482da88d8a4f6cbbc589_Out_1;
                    Unity_Normalize_float3(IN.WorldSpaceNormal, _Normalize_62a13fd33141482da88d8a4f6cbbc589_Out_1);
                    float _Split_0d3686f12540443e91f7387b6f77c10d_R_1 = _Normalize_62a13fd33141482da88d8a4f6cbbc589_Out_1[0];
                    float _Split_0d3686f12540443e91f7387b6f77c10d_G_2 = _Normalize_62a13fd33141482da88d8a4f6cbbc589_Out_1[1];
                    float _Split_0d3686f12540443e91f7387b6f77c10d_B_3 = _Normalize_62a13fd33141482da88d8a4f6cbbc589_Out_1[2];
                    float _Split_0d3686f12540443e91f7387b6f77c10d_A_4 = 0;
                    float _Comparison_e88851318be2459db93159ca801db3b8_Out_2;
                    Unity_Comparison_Greater_float(_Split_0d3686f12540443e91f7387b6f77c10d_B_3, 0, _Comparison_e88851318be2459db93159ca801db3b8_Out_2);
                    float2 _Vector2_cd982aedb6df469f81c94d251afa4ef4_Out_0 = float2(_Split_0d3686f12540443e91f7387b6f77c10d_R_1, _Split_0d3686f12540443e91f7387b6f77c10d_B_3);
                    float2 _Normalize_029f1f95e8854efe8413e4f0e8266c57_Out_1;
                    Unity_Normalize_float2(_Vector2_cd982aedb6df469f81c94d251afa4ef4_Out_0, _Normalize_029f1f95e8854efe8413e4f0e8266c57_Out_1);
                    float _DotProduct_ebf7ce672ca34ebaaa92a71bef863e84_Out_2;
                    Unity_DotProduct_float2(float2(1, 0), _Normalize_029f1f95e8854efe8413e4f0e8266c57_Out_1, _DotProduct_ebf7ce672ca34ebaaa92a71bef863e84_Out_2);
                    float _Arccosine_4b874182f6a14874840ee7586e79f531_Out_1;
                    Unity_Arccosine_float(_DotProduct_ebf7ce672ca34ebaaa92a71bef863e84_Out_2, _Arccosine_4b874182f6a14874840ee7586e79f531_Out_1);
                    float _Multiply_2cb80113cd264bd684265987dfc99fdc_Out_2;
                    Unity_Multiply_float(_DotProduct_ebf7ce672ca34ebaaa92a71bef863e84_Out_2, -1, _Multiply_2cb80113cd264bd684265987dfc99fdc_Out_2);
                    float _Arccosine_4402c39ae97e427eb6a05c3ec6df8476_Out_1;
                    Unity_Arccosine_float(_Multiply_2cb80113cd264bd684265987dfc99fdc_Out_2, _Arccosine_4402c39ae97e427eb6a05c3ec6df8476_Out_1);
                    float Constant_2af68751986845ed87773c58bfc03190 = 3.141593;
                    float _Add_db22dd4581f6401c9b151c2d904fb1fd_Out_2;
                    Unity_Add_float(_Arccosine_4402c39ae97e427eb6a05c3ec6df8476_Out_1, Constant_2af68751986845ed87773c58bfc03190, _Add_db22dd4581f6401c9b151c2d904fb1fd_Out_2);
                    float _Branch_5fd995eba4cc4a4c8abe7fca6cd0c1c8_Out_3;
                    Unity_Branch_float(_Comparison_e88851318be2459db93159ca801db3b8_Out_2, _Arccosine_4b874182f6a14874840ee7586e79f531_Out_1, _Add_db22dd4581f6401c9b151c2d904fb1fd_Out_2, _Branch_5fd995eba4cc4a4c8abe7fca6cd0c1c8_Out_3);
                    float2 _Rotate_e2dc059678654897947c4905d958d640_Out_3;
                    Unity_Rotate_Radians_float(IN.uv0.xy, float2 (0.5, 0.5), _Branch_5fd995eba4cc4a4c8abe7fca6cd0c1c8_Out_3, _Rotate_e2dc059678654897947c4905d958d640_Out_3);
                    float2 _Property_409975023fe344e4969558e96ae8b3fe_Out_0 = _Tiling;
                    float _Property_fe8bd49591be4d8493cd9d1aef424249_Out_0 = _RiverSpeed;
                    float _Multiply_11dac49a52be47e2accb8b9de45dab52_Out_2;
                    Unity_Multiply_float(IN.TimeParameters.x, _Property_fe8bd49591be4d8493cd9d1aef424249_Out_0, _Multiply_11dac49a52be47e2accb8b9de45dab52_Out_2);
                    float _Lerp_8be4d289e2cb484489c128e89e81cbd7_Out_3;
                    Unity_Lerp_float(_Multiply_11dac49a52be47e2accb8b9de45dab52_Out_2, IN.TimeParameters.x, _Remap_669938a90f934b9bab86d586a6917aca_Out_3, _Lerp_8be4d289e2cb484489c128e89e81cbd7_Out_3);
                    float2 _Vector2_d7594f71adcb4015bc07aa3fac73b0cf_Out_0 = float2(_Lerp_8be4d289e2cb484489c128e89e81cbd7_Out_3, 0);
                    float2 _TilingAndOffset_5a892791744c4205818e4162cba3a833_Out_3;
                    Unity_TilingAndOffset_float(_Rotate_e2dc059678654897947c4905d958d640_Out_3, _Property_409975023fe344e4969558e96ae8b3fe_Out_0, _Vector2_d7594f71adcb4015bc07aa3fac73b0cf_Out_0, _TilingAndOffset_5a892791744c4205818e4162cba3a833_Out_3);
                    float _Property_61f2533f1f0f4b2e9a39165110a6d8cb_Out_0 = _RiverNormalRotAdjustment;
                    float2 _Rotate_f20c70501e6a4e1e946bb31f6bd852f4_Out_3;
                    Unity_Rotate_Degrees_float(_TilingAndOffset_5a892791744c4205818e4162cba3a833_Out_3, float2 (0.5, 0.5), _Property_61f2533f1f0f4b2e9a39165110a6d8cb_Out_0, _Rotate_f20c70501e6a4e1e946bb31f6bd852f4_Out_3);
                    float4 _SampleTexture2D_66835b651206479b8da548ce63cec2a2_RGBA_0 = SAMPLE_TEXTURE2D(_Property_ab131e76fa9e4575850bad711d6bc112_Out_0.tex, _Property_ab131e76fa9e4575850bad711d6bc112_Out_0.samplerstate, _Rotate_f20c70501e6a4e1e946bb31f6bd852f4_Out_3);
                    _SampleTexture2D_66835b651206479b8da548ce63cec2a2_RGBA_0.rgb = UnpackNormal(_SampleTexture2D_66835b651206479b8da548ce63cec2a2_RGBA_0);
                    float _SampleTexture2D_66835b651206479b8da548ce63cec2a2_R_4 = _SampleTexture2D_66835b651206479b8da548ce63cec2a2_RGBA_0.r;
                    float _SampleTexture2D_66835b651206479b8da548ce63cec2a2_G_5 = _SampleTexture2D_66835b651206479b8da548ce63cec2a2_RGBA_0.g;
                    float _SampleTexture2D_66835b651206479b8da548ce63cec2a2_B_6 = _SampleTexture2D_66835b651206479b8da548ce63cec2a2_RGBA_0.b;
                    float _SampleTexture2D_66835b651206479b8da548ce63cec2a2_A_7 = _SampleTexture2D_66835b651206479b8da548ce63cec2a2_RGBA_0.a;
                    UnityTexture2D _Property_3ac158951f79428685aa829dd82f0bc3_Out_0 = UnityBuildTexture2DStructNoScale(_LevelRiverNormal);
                    float2 _TilingAndOffset_5e717e1b97944a55bc66662a06d78ea7_Out_3;
                    Unity_TilingAndOffset_float(IN.uv0.xy, _Property_409975023fe344e4969558e96ae8b3fe_Out_0, float2 (0, 0), _TilingAndOffset_5e717e1b97944a55bc66662a06d78ea7_Out_3);
                    float4 _SampleTexture2D_e5aebb8d1445433bacf47e39067cb0a0_RGBA_0 = SAMPLE_TEXTURE2D(_Property_3ac158951f79428685aa829dd82f0bc3_Out_0.tex, _Property_3ac158951f79428685aa829dd82f0bc3_Out_0.samplerstate, _TilingAndOffset_5e717e1b97944a55bc66662a06d78ea7_Out_3);
                    _SampleTexture2D_e5aebb8d1445433bacf47e39067cb0a0_RGBA_0.rgb = UnpackNormal(_SampleTexture2D_e5aebb8d1445433bacf47e39067cb0a0_RGBA_0);
                    float _SampleTexture2D_e5aebb8d1445433bacf47e39067cb0a0_R_4 = _SampleTexture2D_e5aebb8d1445433bacf47e39067cb0a0_RGBA_0.r;
                    float _SampleTexture2D_e5aebb8d1445433bacf47e39067cb0a0_G_5 = _SampleTexture2D_e5aebb8d1445433bacf47e39067cb0a0_RGBA_0.g;
                    float _SampleTexture2D_e5aebb8d1445433bacf47e39067cb0a0_B_6 = _SampleTexture2D_e5aebb8d1445433bacf47e39067cb0a0_RGBA_0.b;
                    float _SampleTexture2D_e5aebb8d1445433bacf47e39067cb0a0_A_7 = _SampleTexture2D_e5aebb8d1445433bacf47e39067cb0a0_RGBA_0.a;
                    float4 _Branch_7d4a670ae12240ccbe8bdb249a237644_Out_3;
                    Unity_Branch_float4(_Comparison_8f4fb954760447e8b0db8924e20fd1d0_Out_2, _SampleTexture2D_66835b651206479b8da548ce63cec2a2_RGBA_0, _SampleTexture2D_e5aebb8d1445433bacf47e39067cb0a0_RGBA_0, _Branch_7d4a670ae12240ccbe8bdb249a237644_Out_3);
                    float4 _Branch_5225751f0aaf4e5885184101068828b5_Out_3;
                    Unity_Branch_float4(_Property_c92104f8c9d245dbb796f54a2386b2fa_Out_0, _Add_3e553e4abf784d7799c718cfe7d51b68_Out_2, _Branch_7d4a670ae12240ccbe8bdb249a237644_Out_3, _Branch_5225751f0aaf4e5885184101068828b5_Out_3);
                    float4 _Lerp_b501d8723a3b46369b51759c91fb6f3c_Out_3;
                    Unity_Lerp_float4(_SampleTexture2D_0121a928620142938ff635ec1ff89401_RGBA_0, _Branch_5225751f0aaf4e5885184101068828b5_Out_3, (_Clamp_0f7ac1e483384940a0714a9e608d50b4_Out_3.xxxx), _Lerp_b501d8723a3b46369b51759c91fb6f3c_Out_3);
                    UnityTexture2D _Property_d6241559ab474e5782a32fe991893c23_Out_0 = UnityBuildTexture2DStructNoScale(_FarNormal);
                    float2 _TilingAndOffset_bdb4faaa2ebc4eb990d5202f25946a55_Out_3;
                    Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), float2 (0, 0), _TilingAndOffset_bdb4faaa2ebc4eb990d5202f25946a55_Out_3);
                    float4 _SampleTexture2D_4e9f3a96a6da4e8bac8f2aa7059e160c_RGBA_0 = SAMPLE_TEXTURE2D(_Property_d6241559ab474e5782a32fe991893c23_Out_0.tex, _Property_d6241559ab474e5782a32fe991893c23_Out_0.samplerstate, _TilingAndOffset_bdb4faaa2ebc4eb990d5202f25946a55_Out_3);
                    _SampleTexture2D_4e9f3a96a6da4e8bac8f2aa7059e160c_RGBA_0.rgb = UnpackNormal(_SampleTexture2D_4e9f3a96a6da4e8bac8f2aa7059e160c_RGBA_0);
                    float _SampleTexture2D_4e9f3a96a6da4e8bac8f2aa7059e160c_R_4 = _SampleTexture2D_4e9f3a96a6da4e8bac8f2aa7059e160c_RGBA_0.r;
                    float _SampleTexture2D_4e9f3a96a6da4e8bac8f2aa7059e160c_G_5 = _SampleTexture2D_4e9f3a96a6da4e8bac8f2aa7059e160c_RGBA_0.g;
                    float _SampleTexture2D_4e9f3a96a6da4e8bac8f2aa7059e160c_B_6 = _SampleTexture2D_4e9f3a96a6da4e8bac8f2aa7059e160c_RGBA_0.b;
                    float _SampleTexture2D_4e9f3a96a6da4e8bac8f2aa7059e160c_A_7 = _SampleTexture2D_4e9f3a96a6da4e8bac8f2aa7059e160c_RGBA_0.a;
                    float _Distance_44875152cc614e5ba9d5c699495f08ab_Out_2;
                    Unity_Distance_float3(IN.WorldSpacePosition, _WorldSpaceCameraPos, _Distance_44875152cc614e5ba9d5c699495f08ab_Out_2);
                    float _Property_aebc16f7283a467a8048e6bb509da7c6_Out_0 = _LODdistance;
                    float _Divide_32fb228b5d524f178b884f2adaa8e599_Out_2;
                    Unity_Divide_float(_Distance_44875152cc614e5ba9d5c699495f08ab_Out_2, _Property_aebc16f7283a467a8048e6bb509da7c6_Out_0, _Divide_32fb228b5d524f178b884f2adaa8e599_Out_2);
                    float4 _Lerp_2e0a60782cb64960ac783789c38969b5_Out_3;
                    Unity_Lerp_float4(_Lerp_b501d8723a3b46369b51759c91fb6f3c_Out_3, _SampleTexture2D_4e9f3a96a6da4e8bac8f2aa7059e160c_RGBA_0, (_Divide_32fb228b5d524f178b884f2adaa8e599_Out_2.xxxx), _Lerp_2e0a60782cb64960ac783789c38969b5_Out_3);
                    float _Property_d642bbaad222433b9f2ebb353b53909f_Out_0 = _Metallic;
                    float _DotProduct_fb1cbb38204242edbadb0a15bc95b04e_Out_2;
                    Unity_DotProduct_float3(-1 * mul((float3x3)UNITY_MATRIX_M, transpose(mul(UNITY_MATRIX_I_M, UNITY_MATRIX_I_V)) [2].xyz), IN.WorldSpaceNormal, _DotProduct_fb1cbb38204242edbadb0a15bc95b04e_Out_2);
                    float _Remap_bde541d934954ce5b99314edcbcd70e5_Out_3;
                    Unity_Remap_float(_DotProduct_fb1cbb38204242edbadb0a15bc95b04e_Out_2, float2 (-1, 0), float2 (0, 1), _Remap_bde541d934954ce5b99314edcbcd70e5_Out_3);
                    float _Multiply_6330a2a6c69948a5aacc174b9da1d2f0_Out_2;
                    Unity_Multiply_float(_Split_17c957ee33bc4e28a994b8b8dd20a89f_A_4, _Remap_bde541d934954ce5b99314edcbcd70e5_Out_3, _Multiply_6330a2a6c69948a5aacc174b9da1d2f0_Out_2);
                    float _Property_bc84cef440384b15875875c65e907453_Out_0 = _DownAlphaStrength;
                    float _Property_f604cf40fc3249839fb755ab1c9d8eb2_Out_0 = _TranceparencyStrength;
                    float _Multiply_c4a5b4f21dfe45d2a2f78cc50eba3ec8_Out_2;
                    Unity_Multiply_float(_Subtract_bd4ff2ba7ce04051b10b968b020d06df_Out_2, _Property_f604cf40fc3249839fb755ab1c9d8eb2_Out_0, _Multiply_c4a5b4f21dfe45d2a2f78cc50eba3ec8_Out_2);
                    float _Clamp_61028b06dbf14a6092a617f0d8a7ac32_Out_3;
                    Unity_Clamp_float(_Multiply_c4a5b4f21dfe45d2a2f78cc50eba3ec8_Out_2, 0, 1, _Clamp_61028b06dbf14a6092a617f0d8a7ac32_Out_3);
                    float _Lerp_106a757383d0403399452dcbb99cc72a_Out_3;
                    Unity_Lerp_float(_Property_bc84cef440384b15875875c65e907453_Out_0, 0, _Clamp_61028b06dbf14a6092a617f0d8a7ac32_Out_3, _Lerp_106a757383d0403399452dcbb99cc72a_Out_3);
                    float _Lerp_729c45b3c3014bdbb92bb4198e06bd92_Out_3;
                    Unity_Lerp_float(1, 0, _Remap_bde541d934954ce5b99314edcbcd70e5_Out_3, _Lerp_729c45b3c3014bdbb92bb4198e06bd92_Out_3);
                    float _Multiply_a80cb3307cd746d7a1bb5f699c9423f3_Out_2;
                    Unity_Multiply_float(_Lerp_106a757383d0403399452dcbb99cc72a_Out_3, _Lerp_729c45b3c3014bdbb92bb4198e06bd92_Out_3, _Multiply_a80cb3307cd746d7a1bb5f699c9423f3_Out_2);
                    float _Lerp_b12dda477cf14695add7f2de406dd644_Out_3;
                    Unity_Lerp_float(_Split_17c957ee33bc4e28a994b8b8dd20a89f_A_4, _Multiply_6330a2a6c69948a5aacc174b9da1d2f0_Out_2, _Multiply_a80cb3307cd746d7a1bb5f699c9423f3_Out_2, _Lerp_b12dda477cf14695add7f2de406dd644_Out_3);
                    surface.BaseColor = _Vector3_3b779f158e6f4ba8ac091e620cd4bd1c_Out_0;
                    surface.NormalTS = (_Lerp_2e0a60782cb64960ac783789c38969b5_Out_3.xyz);
                    surface.Emission = float3(0, 0, 0);
                    surface.Metallic = _Property_d642bbaad222433b9f2ebb353b53909f_Out_0;
                    surface.Smoothness = 0.5;
                    surface.Occlusion = 1;
                    surface.Alpha = _Lerp_b12dda477cf14695add7f2de406dd644_Out_3;
                    return surface;
                }
    
                // --------------------------------------------------
                // Build Graph Inputs
    
                VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                {
                    VertexDescriptionInputs output;
                    ZERO_INITIALIZE(VertexDescriptionInputs, output);
                
                    output.ObjectSpaceNormal =           input.normalOS;
                    output.ObjectSpaceTangent =          input.tangentOS.xyz;
                    output.ObjectSpacePosition =         input.positionOS;
                
                    return output;
                }
                
                SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                {
                    SurfaceDescriptionInputs output;
                    ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
                
                	// must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
                	float3 unnormalizedNormalWS = input.normalWS;
                    const float renormFactor = 1.0 / length(unnormalizedNormalWS);
                
                
                    output.WorldSpaceNormal =            renormFactor*input.normalWS.xyz;		// we want a unit length Normal Vector node in shader graph
                    output.TangentSpaceNormal =          float3(0.0f, 0.0f, 1.0f);
                
                
                    output.WorldSpacePosition =          input.positionWS;
                    output.ScreenPosition =              ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
                    output.uv0 =                         input.texCoord0;
                    output.TimeParameters =              _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                #else
                #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                #endif
                #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                
                    return output;
                }
                
    
                // --------------------------------------------------
                // Main
    
                #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBRForwardPass.hlsl"
    
                ENDHLSL
            }
            Pass
            {
                Name "GBuffer"
                Tags
                {
                    "LightMode" = "UniversalGBuffer"
                }
    
                // Render State
                Cull Off
                Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
                ZTest LEqual
                ZWrite Off
    
                // Debug
                // <None>
    
                // --------------------------------------------------
                // Pass
    
                HLSLPROGRAM
    
                // Pragmas
                #pragma target 4.5
                #pragma exclude_renderers gles gles3 glcore
                #pragma multi_compile_instancing
                #pragma multi_compile_fog
                #pragma multi_compile _ DOTS_INSTANCING_ON
                #pragma vertex vert
                #pragma fragment frag
    
                // DotsInstancingOptions: <None>
                // HybridV1InjectedBuiltinProperties: <None>
    
                // Keywords
                #pragma multi_compile _ LIGHTMAP_ON
                #pragma multi_compile _ DIRLIGHTMAP_COMBINED
                #pragma multi_compile _ _MAIN_LIGHT_SHADOWS
                #pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
                #pragma multi_compile _ _SHADOWS_SOFT
                #pragma multi_compile _ _MIXED_LIGHTING_SUBTRACTIVE
                #pragma multi_compile _ _GBUFFER_NORMALS_OCT
                // GraphKeywords: <None>
    
                // Defines
                #define _SURFACE_TYPE_TRANSPARENT 1
                #define _NORMALMAP 1
                #define _NORMAL_DROPOFF_TS 1
                #define ATTRIBUTES_NEED_NORMAL
                #define ATTRIBUTES_NEED_TANGENT
                #define ATTRIBUTES_NEED_TEXCOORD0
                #define ATTRIBUTES_NEED_TEXCOORD1
                #define VARYINGS_NEED_POSITION_WS
                #define VARYINGS_NEED_NORMAL_WS
                #define VARYINGS_NEED_TANGENT_WS
                #define VARYINGS_NEED_TEXCOORD0
                #define VARYINGS_NEED_VIEWDIRECTION_WS
                #define VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
                #define FEATURES_GRAPH_VERTEX
                /* WARNING: $splice Could not find named fragment 'PassInstancing' */
                #define SHADERPASS SHADERPASS_GBUFFER
                #define REQUIRE_DEPTH_TEXTURE
                /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
    
                // Includes
                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
    
                // --------------------------------------------------
                // Structs and Packing
    
                struct Attributes
                {
                    float3 positionOS : POSITION;
                    float3 normalOS : NORMAL;
                    float4 tangentOS : TANGENT;
                    float4 uv0 : TEXCOORD0;
                    float4 uv1 : TEXCOORD1;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    uint instanceID : INSTANCEID_SEMANTIC;
                    #endif
                };
                struct Varyings
                {
                    float4 positionCS : SV_POSITION;
                    float3 positionWS;
                    float3 normalWS;
                    float4 tangentWS;
                    float4 texCoord0;
                    float3 viewDirectionWS;
                    #if defined(LIGHTMAP_ON)
                    float2 lightmapUV;
                    #endif
                    #if !defined(LIGHTMAP_ON)
                    float3 sh;
                    #endif
                    float4 fogFactorAndVertexLight;
                    float4 shadowCoord;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    uint instanceID : CUSTOM_INSTANCE_ID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                    #endif
                };
                struct SurfaceDescriptionInputs
                {
                    float3 WorldSpaceNormal;
                    float3 TangentSpaceNormal;
                    float3 WorldSpacePosition;
                    float4 ScreenPosition;
                    float4 uv0;
                    float3 TimeParameters;
                };
                struct VertexDescriptionInputs
                {
                    float3 ObjectSpaceNormal;
                    float3 ObjectSpaceTangent;
                    float3 ObjectSpacePosition;
                };
                struct PackedVaryings
                {
                    float4 positionCS : SV_POSITION;
                    float3 interp0 : TEXCOORD0;
                    float3 interp1 : TEXCOORD1;
                    float4 interp2 : TEXCOORD2;
                    float4 interp3 : TEXCOORD3;
                    float3 interp4 : TEXCOORD4;
                    #if defined(LIGHTMAP_ON)
                    float2 interp5 : TEXCOORD5;
                    #endif
                    #if !defined(LIGHTMAP_ON)
                    float3 interp6 : TEXCOORD6;
                    #endif
                    float4 interp7 : TEXCOORD7;
                    float4 interp8 : TEXCOORD8;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    uint instanceID : CUSTOM_INSTANCE_ID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                    #endif
                };
    
                PackedVaryings PackVaryings (Varyings input)
                {
                    PackedVaryings output;
                    output.positionCS = input.positionCS;
                    output.interp0.xyz =  input.positionWS;
                    output.interp1.xyz =  input.normalWS;
                    output.interp2.xyzw =  input.tangentWS;
                    output.interp3.xyzw =  input.texCoord0;
                    output.interp4.xyz =  input.viewDirectionWS;
                    #if defined(LIGHTMAP_ON)
                    output.interp5.xy =  input.lightmapUV;
                    #endif
                    #if !defined(LIGHTMAP_ON)
                    output.interp6.xyz =  input.sh;
                    #endif
                    output.interp7.xyzw =  input.fogFactorAndVertexLight;
                    output.interp8.xyzw =  input.shadowCoord;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    output.instanceID = input.instanceID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    output.cullFace = input.cullFace;
                    #endif
                    return output;
                }
                Varyings UnpackVaryings (PackedVaryings input)
                {
                    Varyings output;
                    output.positionCS = input.positionCS;
                    output.positionWS = input.interp0.xyz;
                    output.normalWS = input.interp1.xyz;
                    output.tangentWS = input.interp2.xyzw;
                    output.texCoord0 = input.interp3.xyzw;
                    output.viewDirectionWS = input.interp4.xyz;
                    #if defined(LIGHTMAP_ON)
                    output.lightmapUV = input.interp5.xy;
                    #endif
                    #if !defined(LIGHTMAP_ON)
                    output.sh = input.interp6.xyz;
                    #endif
                    output.fogFactorAndVertexLight = input.interp7.xyzw;
                    output.shadowCoord = input.interp8.xyzw;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    output.instanceID = input.instanceID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    output.cullFace = input.cullFace;
                    #endif
                    return output;
                }
    
                // --------------------------------------------------
                // Graph
    
                // Graph Properties
                CBUFFER_START(UnityPerMaterial)
                float _DepthOffset;
                float _Strength;
                float4 _DeepWaterColor;
                float4 _ShallowWaterColor;
                float _Metallic;
                float2 _Tiling;
                float4 _OceanNormal2_TexelSize;
                float4 _OceanNormal1_TexelSize;
                float _GradientNoise;
                float2 _OceanSpeed;
                float _LODdistance;
                float4 _FarNormal_TexelSize;
                float4 _ShallowNormal_TexelSize;
                float _TranceparencyStrength;
                float _DownAlphaStrength;
                float _IsOcean;
                float4 _RiverNormal_TexelSize;
                float _RiverNormalRotAdjustment;
                float4 _LevelRiverNormal_TexelSize;
                float _RiverSpeed;
                float _ShoreIntersectionStrength;
                float4 Color_701f2c2f40b34b87975a0e85a71325dc;
                CBUFFER_END
                
                // Object and Global properties
                SAMPLER(SamplerState_Linear_Repeat);
                TEXTURE2D(_OceanNormal2);
                SAMPLER(sampler_OceanNormal2);
                TEXTURE2D(_OceanNormal1);
                SAMPLER(sampler_OceanNormal1);
                TEXTURE2D(_FarNormal);
                SAMPLER(sampler_FarNormal);
                TEXTURE2D(_ShallowNormal);
                SAMPLER(sampler_ShallowNormal);
                TEXTURE2D(_RiverNormal);
                SAMPLER(sampler_RiverNormal);
                TEXTURE2D(_LevelRiverNormal);
                SAMPLER(sampler_LevelRiverNormal);
                float _StretchScalar;
    
                // Graph Functions
                
                void Unity_SceneDepth_Linear01_float(float4 UV, out float Out)
                {
                    Out = Linear01Depth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
                }
                
                void Unity_Multiply_float(float A, float B, out float Out)
                {
                    Out = A * B;
                }
                
                void Unity_Add_float(float A, float B, out float Out)
                {
                    Out = A + B;
                }
                
                void Unity_Subtract_float(float A, float B, out float Out)
                {
                    Out = A - B;
                }
                
                void Unity_Sine_float(float In, out float Out)
                {
                    Out = sin(In);
                }
                
                void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
                {
                    Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
                }
                
                void Unity_Branch_float(float Predicate, float True, float False, out float Out)
                {
                    Out = Predicate ? True : False;
                }
                
                void Unity_Clamp_float(float In, float Min, float Max, out float Out)
                {
                    Out = clamp(In, Min, Max);
                }
                
                void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
                {
                    Out = lerp(A, B, T);
                }
                
                void Unity_Normalize_float3(float3 In, out float3 Out)
                {
                    Out = normalize(In);
                }
                
                void Unity_DotProduct_float3(float3 A, float3 B, out float Out)
                {
                    Out = dot(A, B);
                }
                
                void Unity_Add_float4(float4 A, float4 B, out float4 Out)
                {
                    Out = A + B;
                }
                
                void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
                {
                    Out = UV * Tiling + Offset;
                }
                
                void Unity_Divide_float(float A, float B, out float Out)
                {
                    Out = A / B;
                }
                
                
                float2 Unity_GradientNoise_Dir_float(float2 p)
                {
                    // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
                    p = p % 289;
                    // need full precision, otherwise half overflows when p > 1
                    float x = float(34 * p.x + 1) * p.x % 289 + p.y;
                    x = (34 * x + 1) * x % 289;
                    x = frac(x / 41) * 2 - 1;
                    return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
                }
                
                void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
                { 
                    float2 p = UV * Scale;
                    float2 ip = floor(p);
                    float2 fp = frac(p);
                    float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
                    float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
                    float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
                    float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
                    fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
                    Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
                }
                
                void Unity_Comparison_Greater_float(float A, float B, out float Out)
                {
                    Out = A > B ? 1 : 0;
                }
                
                void Unity_Normalize_float2(float2 In, out float2 Out)
                {
                    Out = normalize(In);
                }
                
                void Unity_DotProduct_float2(float2 A, float2 B, out float Out)
                {
                    Out = dot(A, B);
                }
                
                void Unity_Arccosine_float(float In, out float Out)
                {
                    Out = acos(In);
                }
                
                void Unity_Rotate_Radians_float(float2 UV, float2 Center, float Rotation, out float2 Out)
                {
                    //rotation matrix
                    UV -= Center;
                    float s = sin(Rotation);
                    float c = cos(Rotation);
                
                    //center rotation matrix
                    float2x2 rMatrix = float2x2(c, -s, s, c);
                    rMatrix *= 0.5;
                    rMatrix += 0.5;
                    rMatrix = rMatrix*2 - 1;
                
                    //multiply the UVs by the rotation matrix
                    UV.xy = mul(UV.xy, rMatrix);
                    UV += Center;
                
                    Out = UV;
                }
                
                void Unity_Lerp_float(float A, float B, float T, out float Out)
                {
                    Out = lerp(A, B, T);
                }
                
                void Unity_Rotate_Degrees_float(float2 UV, float2 Center, float Rotation, out float2 Out)
                {
                    //rotation matrix
                    Rotation = Rotation * (3.1415926f/180.0f);
                    UV -= Center;
                    float s = sin(Rotation);
                    float c = cos(Rotation);
                
                    //center rotation matrix
                    float2x2 rMatrix = float2x2(c, -s, s, c);
                    rMatrix *= 0.5;
                    rMatrix += 0.5;
                    rMatrix = rMatrix*2 - 1;
                
                    //multiply the UVs by the rotation matrix
                    UV.xy = mul(UV.xy, rMatrix);
                    UV += Center;
                
                    Out = UV;
                }
                
                void Unity_Branch_float4(float Predicate, float4 True, float4 False, out float4 Out)
                {
                    Out = Predicate ? True : False;
                }
                
                void Unity_Distance_float3(float3 A, float3 B, out float Out)
                {
                    Out = distance(A, B);
                }
    
                // Graph Vertex
                struct VertexDescription
                {
                    float3 Position;
                    float3 Normal;
                    float3 Tangent;
                };
                
                VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                {
                    VertexDescription description = (VertexDescription)0;
                    description.Position = IN.ObjectSpacePosition;
                    description.Normal = IN.ObjectSpaceNormal;
                    description.Tangent = IN.ObjectSpaceTangent;
                    return description;
                }
    
                // Graph Pixel
                struct SurfaceDescription
                {
                    float3 BaseColor;
                    float3 NormalTS;
                    float3 Emission;
                    float Metallic;
                    float Smoothness;
                    float Occlusion;
                    float Alpha;
                };
                
                SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                {
                    SurfaceDescription surface = (SurfaceDescription)0;
                    float4 _Property_231c0d262d3a466d85dfd53b116086ca_Out_0 = Color_701f2c2f40b34b87975a0e85a71325dc;
                    float _SceneDepth_3137d738aa0149fb8a54d88a60826a60_Out_1;
                    Unity_SceneDepth_Linear01_float(float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0), _SceneDepth_3137d738aa0149fb8a54d88a60826a60_Out_1);
                    float _Multiply_8ec8e0a1878e494ca0d6d16678168741_Out_2;
                    Unity_Multiply_float(_SceneDepth_3137d738aa0149fb8a54d88a60826a60_Out_1, _ProjectionParams.z, _Multiply_8ec8e0a1878e494ca0d6d16678168741_Out_2);
                    float4 _ScreenPosition_3840c0fb20fc4eb58387cd54ee7e2b18_Out_0 = IN.ScreenPosition;
                    float _Split_578ef5cadaac40969c114c4d1ae870d8_R_1 = _ScreenPosition_3840c0fb20fc4eb58387cd54ee7e2b18_Out_0[0];
                    float _Split_578ef5cadaac40969c114c4d1ae870d8_G_2 = _ScreenPosition_3840c0fb20fc4eb58387cd54ee7e2b18_Out_0[1];
                    float _Split_578ef5cadaac40969c114c4d1ae870d8_B_3 = _ScreenPosition_3840c0fb20fc4eb58387cd54ee7e2b18_Out_0[2];
                    float _Split_578ef5cadaac40969c114c4d1ae870d8_A_4 = _ScreenPosition_3840c0fb20fc4eb58387cd54ee7e2b18_Out_0[3];
                    float _Property_cedd17331b16484abf1a4ce8eb0e5a72_Out_0 = _DepthOffset;
                    float _Add_e04e1bc3087745d898c282f10a0f43e3_Out_2;
                    Unity_Add_float(_Split_578ef5cadaac40969c114c4d1ae870d8_A_4, _Property_cedd17331b16484abf1a4ce8eb0e5a72_Out_0, _Add_e04e1bc3087745d898c282f10a0f43e3_Out_2);
                    float _Subtract_bd4ff2ba7ce04051b10b968b020d06df_Out_2;
                    Unity_Subtract_float(_Multiply_8ec8e0a1878e494ca0d6d16678168741_Out_2, _Add_e04e1bc3087745d898c282f10a0f43e3_Out_2, _Subtract_bd4ff2ba7ce04051b10b968b020d06df_Out_2);
                    float _Property_90205b2f827548b295dc151171bc164c_Out_0 = _IsOcean;
                    float _Sine_24a173ac1d9d40b5b43bd7c8169386e4_Out_1;
                    Unity_Sine_float(IN.TimeParameters.x, _Sine_24a173ac1d9d40b5b43bd7c8169386e4_Out_1);
                    float _Remap_9ed3ea235fdc44d7a8c762cbe7ff6d0e_Out_3;
                    Unity_Remap_float(_Sine_24a173ac1d9d40b5b43bd7c8169386e4_Out_1, float2 (-1, 1), float2 (0.5, 1), _Remap_9ed3ea235fdc44d7a8c762cbe7ff6d0e_Out_3);
                    float _Branch_fcfcb84348fb4a5a90417124dc9ee3a2_Out_3;
                    Unity_Branch_float(_Property_90205b2f827548b295dc151171bc164c_Out_0, _Remap_9ed3ea235fdc44d7a8c762cbe7ff6d0e_Out_3, 1, _Branch_fcfcb84348fb4a5a90417124dc9ee3a2_Out_3);
                    float _Property_866bbbbe2a484e2eae1ad77ed223a577_Out_0 = _ShoreIntersectionStrength;
                    float _Multiply_cb7f54f30fb348b4a7f109f458e38b17_Out_2;
                    Unity_Multiply_float(_Branch_fcfcb84348fb4a5a90417124dc9ee3a2_Out_3, _Property_866bbbbe2a484e2eae1ad77ed223a577_Out_0, _Multiply_cb7f54f30fb348b4a7f109f458e38b17_Out_2);
                    float _Multiply_dcdae92bb4dd401a89df781ec062cecc_Out_2;
                    Unity_Multiply_float(_Subtract_bd4ff2ba7ce04051b10b968b020d06df_Out_2, _Multiply_cb7f54f30fb348b4a7f109f458e38b17_Out_2, _Multiply_dcdae92bb4dd401a89df781ec062cecc_Out_2);
                    float _Clamp_33ee6da80fc14439b6d7bab14be7ab07_Out_3;
                    Unity_Clamp_float(_Multiply_dcdae92bb4dd401a89df781ec062cecc_Out_2, 0.5, 1, _Clamp_33ee6da80fc14439b6d7bab14be7ab07_Out_3);
                    float4 _Lerp_f0669e92de0b409893955d23347ac238_Out_3;
                    Unity_Lerp_float4(_Property_231c0d262d3a466d85dfd53b116086ca_Out_0, float4(0, 0, 0, 0), (_Clamp_33ee6da80fc14439b6d7bab14be7ab07_Out_3.xxxx), _Lerp_f0669e92de0b409893955d23347ac238_Out_3);
                    float _Float_c4cf30aef9464dda83de90c7e790a9ba_Out_0 = 1.5;
                    float4 _Property_c854872c24e048c0aa372f0be547f07c_Out_0 = _ShallowWaterColor;
                    float4 _Property_dde44c4f61534e08a917dd16bcf5ebca_Out_0 = _DeepWaterColor;
                    float _Property_d328dfa89c674e67bffe73ef574a2d58_Out_0 = _Strength;
                    float _Multiply_4eb7822d949844e38f2bb60067662a47_Out_2;
                    Unity_Multiply_float(_Subtract_bd4ff2ba7ce04051b10b968b020d06df_Out_2, _Property_d328dfa89c674e67bffe73ef574a2d58_Out_0, _Multiply_4eb7822d949844e38f2bb60067662a47_Out_2);
                    float _Clamp_0f7ac1e483384940a0714a9e608d50b4_Out_3;
                    Unity_Clamp_float(_Multiply_4eb7822d949844e38f2bb60067662a47_Out_2, 0, 1, _Clamp_0f7ac1e483384940a0714a9e608d50b4_Out_3);
                    float4 _Lerp_3f9225ad7cdc45509b625268ef70e29c_Out_3;
                    Unity_Lerp_float4(_Property_c854872c24e048c0aa372f0be547f07c_Out_0, _Property_dde44c4f61534e08a917dd16bcf5ebca_Out_0, (_Clamp_0f7ac1e483384940a0714a9e608d50b4_Out_3.xxxx), _Lerp_3f9225ad7cdc45509b625268ef70e29c_Out_3);
                    float3 _Normalize_415b503188e443458e4172309aa4cb18_Out_1;
                    Unity_Normalize_float3(IN.WorldSpaceNormal, _Normalize_415b503188e443458e4172309aa4cb18_Out_1);
                    float _DotProduct_b3f1b90b273a4b2b99f07acbc4565dcb_Out_2;
                    Unity_DotProduct_float3(float3(0, 1, 0), _Normalize_415b503188e443458e4172309aa4cb18_Out_1, _DotProduct_b3f1b90b273a4b2b99f07acbc4565dcb_Out_2);
                    float _Remap_669938a90f934b9bab86d586a6917aca_Out_3;
                    Unity_Remap_float(_DotProduct_b3f1b90b273a4b2b99f07acbc4565dcb_Out_2, float2 (-1, 1), float2 (0, 1), _Remap_669938a90f934b9bab86d586a6917aca_Out_3);
                    float4 _Lerp_4536ba8c658e4f11aaefc80660368304_Out_3;
                    Unity_Lerp_float4((_Float_c4cf30aef9464dda83de90c7e790a9ba_Out_0.xxxx), _Lerp_3f9225ad7cdc45509b625268ef70e29c_Out_3, (_Remap_669938a90f934b9bab86d586a6917aca_Out_3.xxxx), _Lerp_4536ba8c658e4f11aaefc80660368304_Out_3);
                    float4 _Add_f8fda8450f33454d96a6212c8ebfdc62_Out_2;
                    Unity_Add_float4(_Lerp_f0669e92de0b409893955d23347ac238_Out_3, _Lerp_4536ba8c658e4f11aaefc80660368304_Out_3, _Add_f8fda8450f33454d96a6212c8ebfdc62_Out_2);
                    float _Split_17c957ee33bc4e28a994b8b8dd20a89f_R_1 = _Add_f8fda8450f33454d96a6212c8ebfdc62_Out_2[0];
                    float _Split_17c957ee33bc4e28a994b8b8dd20a89f_G_2 = _Add_f8fda8450f33454d96a6212c8ebfdc62_Out_2[1];
                    float _Split_17c957ee33bc4e28a994b8b8dd20a89f_B_3 = _Add_f8fda8450f33454d96a6212c8ebfdc62_Out_2[2];
                    float _Split_17c957ee33bc4e28a994b8b8dd20a89f_A_4 = _Add_f8fda8450f33454d96a6212c8ebfdc62_Out_2[3];
                    float3 _Vector3_3b779f158e6f4ba8ac091e620cd4bd1c_Out_0 = float3(_Split_17c957ee33bc4e28a994b8b8dd20a89f_R_1, _Split_17c957ee33bc4e28a994b8b8dd20a89f_G_2, _Split_17c957ee33bc4e28a994b8b8dd20a89f_B_3);
                    UnityTexture2D _Property_98dcadd153784e00b3d99c72c66a28b9_Out_0 = UnityBuildTexture2DStructNoScale(_ShallowNormal);
                    float2 _TilingAndOffset_e057885e86584dea86f94cfc76e1e048_Out_3;
                    Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), float2 (0, 0), _TilingAndOffset_e057885e86584dea86f94cfc76e1e048_Out_3);
                    float4 _SampleTexture2D_0121a928620142938ff635ec1ff89401_RGBA_0 = SAMPLE_TEXTURE2D(_Property_98dcadd153784e00b3d99c72c66a28b9_Out_0.tex, _Property_98dcadd153784e00b3d99c72c66a28b9_Out_0.samplerstate, _TilingAndOffset_e057885e86584dea86f94cfc76e1e048_Out_3);
                    _SampleTexture2D_0121a928620142938ff635ec1ff89401_RGBA_0.rgb = UnpackNormal(_SampleTexture2D_0121a928620142938ff635ec1ff89401_RGBA_0);
                    float _SampleTexture2D_0121a928620142938ff635ec1ff89401_R_4 = _SampleTexture2D_0121a928620142938ff635ec1ff89401_RGBA_0.r;
                    float _SampleTexture2D_0121a928620142938ff635ec1ff89401_G_5 = _SampleTexture2D_0121a928620142938ff635ec1ff89401_RGBA_0.g;
                    float _SampleTexture2D_0121a928620142938ff635ec1ff89401_B_6 = _SampleTexture2D_0121a928620142938ff635ec1ff89401_RGBA_0.b;
                    float _SampleTexture2D_0121a928620142938ff635ec1ff89401_A_7 = _SampleTexture2D_0121a928620142938ff635ec1ff89401_RGBA_0.a;
                    float _Property_c92104f8c9d245dbb796f54a2386b2fa_Out_0 = _IsOcean;
                    float2 _Property_0165785b858447e9be7aeae88e49b876_Out_0 = _Tiling;
                    float _Divide_40fd94b5668f4354bc4f097174879071_Out_2;
                    Unity_Divide_float(IN.TimeParameters.x, 25, _Divide_40fd94b5668f4354bc4f097174879071_Out_2);
                    float2 _TilingAndOffset_dd58a4e4d2f44f4692185d84f037be72_Out_3;
                    Unity_TilingAndOffset_float(IN.uv0.xy, _Property_0165785b858447e9be7aeae88e49b876_Out_0, (_Divide_40fd94b5668f4354bc4f097174879071_Out_2.xx), _TilingAndOffset_dd58a4e4d2f44f4692185d84f037be72_Out_3);
                    float _Property_dcf2fdcb8f824668b8a6e8c81f6e182d_Out_0 = _GradientNoise;
                    float _GradientNoise_2c52090e5ac5473ba4d45f48de31694f_Out_2;
                    Unity_GradientNoise_float(_TilingAndOffset_dd58a4e4d2f44f4692185d84f037be72_Out_3, _Property_dcf2fdcb8f824668b8a6e8c81f6e182d_Out_0, _GradientNoise_2c52090e5ac5473ba4d45f48de31694f_Out_2);
                    float _Remap_fe18556f20a1429782d5401a4e93f4ff_Out_3;
                    Unity_Remap_float(_GradientNoise_2c52090e5ac5473ba4d45f48de31694f_Out_2, float2 (0, 1), float2 (-1, 1), _Remap_fe18556f20a1429782d5401a4e93f4ff_Out_3);
                    UnityTexture2D _Property_1aa6808f044b4d20b816c793ef91056c_Out_0 = UnityBuildTexture2DStructNoScale(_OceanNormal1);
                    float2 _Property_6dc7633668bb4df38e93ccda13f0e850_Out_0 = _OceanSpeed;
                    float _Split_35918e73b31d4ab383b2221ebc8e73c7_R_1 = _Property_6dc7633668bb4df38e93ccda13f0e850_Out_0[0];
                    float _Split_35918e73b31d4ab383b2221ebc8e73c7_G_2 = _Property_6dc7633668bb4df38e93ccda13f0e850_Out_0[1];
                    float _Split_35918e73b31d4ab383b2221ebc8e73c7_B_3 = 0;
                    float _Split_35918e73b31d4ab383b2221ebc8e73c7_A_4 = 0;
                    float _Divide_320942700ecd49068a4d2fac0bbcd012_Out_2;
                    Unity_Divide_float(IN.TimeParameters.x, _Split_35918e73b31d4ab383b2221ebc8e73c7_R_1, _Divide_320942700ecd49068a4d2fac0bbcd012_Out_2);
                    float2 _TilingAndOffset_2c0d1a11da414db2972d2b0e6e6eead7_Out_3;
                    Unity_TilingAndOffset_float(IN.uv0.xy, _Property_0165785b858447e9be7aeae88e49b876_Out_0, (_Divide_320942700ecd49068a4d2fac0bbcd012_Out_2.xx), _TilingAndOffset_2c0d1a11da414db2972d2b0e6e6eead7_Out_3);
                    float4 _SampleTexture2D_95cbac09786f4d9f877a32a692103c63_RGBA_0 = SAMPLE_TEXTURE2D(_Property_1aa6808f044b4d20b816c793ef91056c_Out_0.tex, _Property_1aa6808f044b4d20b816c793ef91056c_Out_0.samplerstate, _TilingAndOffset_2c0d1a11da414db2972d2b0e6e6eead7_Out_3);
                    _SampleTexture2D_95cbac09786f4d9f877a32a692103c63_RGBA_0.rgb = UnpackNormal(_SampleTexture2D_95cbac09786f4d9f877a32a692103c63_RGBA_0);
                    float _SampleTexture2D_95cbac09786f4d9f877a32a692103c63_R_4 = _SampleTexture2D_95cbac09786f4d9f877a32a692103c63_RGBA_0.r;
                    float _SampleTexture2D_95cbac09786f4d9f877a32a692103c63_G_5 = _SampleTexture2D_95cbac09786f4d9f877a32a692103c63_RGBA_0.g;
                    float _SampleTexture2D_95cbac09786f4d9f877a32a692103c63_B_6 = _SampleTexture2D_95cbac09786f4d9f877a32a692103c63_RGBA_0.b;
                    float _SampleTexture2D_95cbac09786f4d9f877a32a692103c63_A_7 = _SampleTexture2D_95cbac09786f4d9f877a32a692103c63_RGBA_0.a;
                    UnityTexture2D _Property_fab5aef84b23441fbfd40281cf1ada82_Out_0 = UnityBuildTexture2DStructNoScale(_OceanNormal2);
                    float _Divide_dbf1715fe11a470fb42e9a29bb351a9d_Out_2;
                    Unity_Divide_float(IN.TimeParameters.x, _Split_35918e73b31d4ab383b2221ebc8e73c7_G_2, _Divide_dbf1715fe11a470fb42e9a29bb351a9d_Out_2);
                    float2 _TilingAndOffset_bc9854cad9a042cfb0ebc3bb5b4792e4_Out_3;
                    Unity_TilingAndOffset_float(IN.uv0.xy, _Property_0165785b858447e9be7aeae88e49b876_Out_0, (_Divide_dbf1715fe11a470fb42e9a29bb351a9d_Out_2.xx), _TilingAndOffset_bc9854cad9a042cfb0ebc3bb5b4792e4_Out_3);
                    float4 _SampleTexture2D_7f1b3f3ae5d243f9b432299bdc4f7b97_RGBA_0 = SAMPLE_TEXTURE2D(_Property_fab5aef84b23441fbfd40281cf1ada82_Out_0.tex, _Property_fab5aef84b23441fbfd40281cf1ada82_Out_0.samplerstate, _TilingAndOffset_bc9854cad9a042cfb0ebc3bb5b4792e4_Out_3);
                    _SampleTexture2D_7f1b3f3ae5d243f9b432299bdc4f7b97_RGBA_0.rgb = UnpackNormal(_SampleTexture2D_7f1b3f3ae5d243f9b432299bdc4f7b97_RGBA_0);
                    float _SampleTexture2D_7f1b3f3ae5d243f9b432299bdc4f7b97_R_4 = _SampleTexture2D_7f1b3f3ae5d243f9b432299bdc4f7b97_RGBA_0.r;
                    float _SampleTexture2D_7f1b3f3ae5d243f9b432299bdc4f7b97_G_5 = _SampleTexture2D_7f1b3f3ae5d243f9b432299bdc4f7b97_RGBA_0.g;
                    float _SampleTexture2D_7f1b3f3ae5d243f9b432299bdc4f7b97_B_6 = _SampleTexture2D_7f1b3f3ae5d243f9b432299bdc4f7b97_RGBA_0.b;
                    float _SampleTexture2D_7f1b3f3ae5d243f9b432299bdc4f7b97_A_7 = _SampleTexture2D_7f1b3f3ae5d243f9b432299bdc4f7b97_RGBA_0.a;
                    float4 _Add_3f6c04238c1f459eb8e6300b9eb1f842_Out_2;
                    Unity_Add_float4(_SampleTexture2D_95cbac09786f4d9f877a32a692103c63_RGBA_0, _SampleTexture2D_7f1b3f3ae5d243f9b432299bdc4f7b97_RGBA_0, _Add_3f6c04238c1f459eb8e6300b9eb1f842_Out_2);
                    float4 _Add_3e553e4abf784d7799c718cfe7d51b68_Out_2;
                    Unity_Add_float4((_Remap_fe18556f20a1429782d5401a4e93f4ff_Out_3.xxxx), _Add_3f6c04238c1f459eb8e6300b9eb1f842_Out_2, _Add_3e553e4abf784d7799c718cfe7d51b68_Out_2);
                    float _Comparison_8f4fb954760447e8b0db8924e20fd1d0_Out_2;
                    Unity_Comparison_Greater_float(_Remap_669938a90f934b9bab86d586a6917aca_Out_3, 0, _Comparison_8f4fb954760447e8b0db8924e20fd1d0_Out_2);
                    UnityTexture2D _Property_ab131e76fa9e4575850bad711d6bc112_Out_0 = UnityBuildTexture2DStructNoScale(_RiverNormal);
                    float3 _Normalize_62a13fd33141482da88d8a4f6cbbc589_Out_1;
                    Unity_Normalize_float3(IN.WorldSpaceNormal, _Normalize_62a13fd33141482da88d8a4f6cbbc589_Out_1);
                    float _Split_0d3686f12540443e91f7387b6f77c10d_R_1 = _Normalize_62a13fd33141482da88d8a4f6cbbc589_Out_1[0];
                    float _Split_0d3686f12540443e91f7387b6f77c10d_G_2 = _Normalize_62a13fd33141482da88d8a4f6cbbc589_Out_1[1];
                    float _Split_0d3686f12540443e91f7387b6f77c10d_B_3 = _Normalize_62a13fd33141482da88d8a4f6cbbc589_Out_1[2];
                    float _Split_0d3686f12540443e91f7387b6f77c10d_A_4 = 0;
                    float _Comparison_e88851318be2459db93159ca801db3b8_Out_2;
                    Unity_Comparison_Greater_float(_Split_0d3686f12540443e91f7387b6f77c10d_B_3, 0, _Comparison_e88851318be2459db93159ca801db3b8_Out_2);
                    float2 _Vector2_cd982aedb6df469f81c94d251afa4ef4_Out_0 = float2(_Split_0d3686f12540443e91f7387b6f77c10d_R_1, _Split_0d3686f12540443e91f7387b6f77c10d_B_3);
                    float2 _Normalize_029f1f95e8854efe8413e4f0e8266c57_Out_1;
                    Unity_Normalize_float2(_Vector2_cd982aedb6df469f81c94d251afa4ef4_Out_0, _Normalize_029f1f95e8854efe8413e4f0e8266c57_Out_1);
                    float _DotProduct_ebf7ce672ca34ebaaa92a71bef863e84_Out_2;
                    Unity_DotProduct_float2(float2(1, 0), _Normalize_029f1f95e8854efe8413e4f0e8266c57_Out_1, _DotProduct_ebf7ce672ca34ebaaa92a71bef863e84_Out_2);
                    float _Arccosine_4b874182f6a14874840ee7586e79f531_Out_1;
                    Unity_Arccosine_float(_DotProduct_ebf7ce672ca34ebaaa92a71bef863e84_Out_2, _Arccosine_4b874182f6a14874840ee7586e79f531_Out_1);
                    float _Multiply_2cb80113cd264bd684265987dfc99fdc_Out_2;
                    Unity_Multiply_float(_DotProduct_ebf7ce672ca34ebaaa92a71bef863e84_Out_2, -1, _Multiply_2cb80113cd264bd684265987dfc99fdc_Out_2);
                    float _Arccosine_4402c39ae97e427eb6a05c3ec6df8476_Out_1;
                    Unity_Arccosine_float(_Multiply_2cb80113cd264bd684265987dfc99fdc_Out_2, _Arccosine_4402c39ae97e427eb6a05c3ec6df8476_Out_1);
                    float Constant_2af68751986845ed87773c58bfc03190 = 3.141593;
                    float _Add_db22dd4581f6401c9b151c2d904fb1fd_Out_2;
                    Unity_Add_float(_Arccosine_4402c39ae97e427eb6a05c3ec6df8476_Out_1, Constant_2af68751986845ed87773c58bfc03190, _Add_db22dd4581f6401c9b151c2d904fb1fd_Out_2);
                    float _Branch_5fd995eba4cc4a4c8abe7fca6cd0c1c8_Out_3;
                    Unity_Branch_float(_Comparison_e88851318be2459db93159ca801db3b8_Out_2, _Arccosine_4b874182f6a14874840ee7586e79f531_Out_1, _Add_db22dd4581f6401c9b151c2d904fb1fd_Out_2, _Branch_5fd995eba4cc4a4c8abe7fca6cd0c1c8_Out_3);
                    float2 _Rotate_e2dc059678654897947c4905d958d640_Out_3;
                    Unity_Rotate_Radians_float(IN.uv0.xy, float2 (0.5, 0.5), _Branch_5fd995eba4cc4a4c8abe7fca6cd0c1c8_Out_3, _Rotate_e2dc059678654897947c4905d958d640_Out_3);
                    float2 _Property_409975023fe344e4969558e96ae8b3fe_Out_0 = _Tiling;
                    float _Property_fe8bd49591be4d8493cd9d1aef424249_Out_0 = _RiverSpeed;
                    float _Multiply_11dac49a52be47e2accb8b9de45dab52_Out_2;
                    Unity_Multiply_float(IN.TimeParameters.x, _Property_fe8bd49591be4d8493cd9d1aef424249_Out_0, _Multiply_11dac49a52be47e2accb8b9de45dab52_Out_2);
                    float _Lerp_8be4d289e2cb484489c128e89e81cbd7_Out_3;
                    Unity_Lerp_float(_Multiply_11dac49a52be47e2accb8b9de45dab52_Out_2, IN.TimeParameters.x, _Remap_669938a90f934b9bab86d586a6917aca_Out_3, _Lerp_8be4d289e2cb484489c128e89e81cbd7_Out_3);
                    float2 _Vector2_d7594f71adcb4015bc07aa3fac73b0cf_Out_0 = float2(_Lerp_8be4d289e2cb484489c128e89e81cbd7_Out_3, 0);
                    float2 _TilingAndOffset_5a892791744c4205818e4162cba3a833_Out_3;
                    Unity_TilingAndOffset_float(_Rotate_e2dc059678654897947c4905d958d640_Out_3, _Property_409975023fe344e4969558e96ae8b3fe_Out_0, _Vector2_d7594f71adcb4015bc07aa3fac73b0cf_Out_0, _TilingAndOffset_5a892791744c4205818e4162cba3a833_Out_3);
                    float _Property_61f2533f1f0f4b2e9a39165110a6d8cb_Out_0 = _RiverNormalRotAdjustment;
                    float2 _Rotate_f20c70501e6a4e1e946bb31f6bd852f4_Out_3;
                    Unity_Rotate_Degrees_float(_TilingAndOffset_5a892791744c4205818e4162cba3a833_Out_3, float2 (0.5, 0.5), _Property_61f2533f1f0f4b2e9a39165110a6d8cb_Out_0, _Rotate_f20c70501e6a4e1e946bb31f6bd852f4_Out_3);
                    float4 _SampleTexture2D_66835b651206479b8da548ce63cec2a2_RGBA_0 = SAMPLE_TEXTURE2D(_Property_ab131e76fa9e4575850bad711d6bc112_Out_0.tex, _Property_ab131e76fa9e4575850bad711d6bc112_Out_0.samplerstate, _Rotate_f20c70501e6a4e1e946bb31f6bd852f4_Out_3);
                    _SampleTexture2D_66835b651206479b8da548ce63cec2a2_RGBA_0.rgb = UnpackNormal(_SampleTexture2D_66835b651206479b8da548ce63cec2a2_RGBA_0);
                    float _SampleTexture2D_66835b651206479b8da548ce63cec2a2_R_4 = _SampleTexture2D_66835b651206479b8da548ce63cec2a2_RGBA_0.r;
                    float _SampleTexture2D_66835b651206479b8da548ce63cec2a2_G_5 = _SampleTexture2D_66835b651206479b8da548ce63cec2a2_RGBA_0.g;
                    float _SampleTexture2D_66835b651206479b8da548ce63cec2a2_B_6 = _SampleTexture2D_66835b651206479b8da548ce63cec2a2_RGBA_0.b;
                    float _SampleTexture2D_66835b651206479b8da548ce63cec2a2_A_7 = _SampleTexture2D_66835b651206479b8da548ce63cec2a2_RGBA_0.a;
                    UnityTexture2D _Property_3ac158951f79428685aa829dd82f0bc3_Out_0 = UnityBuildTexture2DStructNoScale(_LevelRiverNormal);
                    float2 _TilingAndOffset_5e717e1b97944a55bc66662a06d78ea7_Out_3;
                    Unity_TilingAndOffset_float(IN.uv0.xy, _Property_409975023fe344e4969558e96ae8b3fe_Out_0, float2 (0, 0), _TilingAndOffset_5e717e1b97944a55bc66662a06d78ea7_Out_3);
                    float4 _SampleTexture2D_e5aebb8d1445433bacf47e39067cb0a0_RGBA_0 = SAMPLE_TEXTURE2D(_Property_3ac158951f79428685aa829dd82f0bc3_Out_0.tex, _Property_3ac158951f79428685aa829dd82f0bc3_Out_0.samplerstate, _TilingAndOffset_5e717e1b97944a55bc66662a06d78ea7_Out_3);
                    _SampleTexture2D_e5aebb8d1445433bacf47e39067cb0a0_RGBA_0.rgb = UnpackNormal(_SampleTexture2D_e5aebb8d1445433bacf47e39067cb0a0_RGBA_0);
                    float _SampleTexture2D_e5aebb8d1445433bacf47e39067cb0a0_R_4 = _SampleTexture2D_e5aebb8d1445433bacf47e39067cb0a0_RGBA_0.r;
                    float _SampleTexture2D_e5aebb8d1445433bacf47e39067cb0a0_G_5 = _SampleTexture2D_e5aebb8d1445433bacf47e39067cb0a0_RGBA_0.g;
                    float _SampleTexture2D_e5aebb8d1445433bacf47e39067cb0a0_B_6 = _SampleTexture2D_e5aebb8d1445433bacf47e39067cb0a0_RGBA_0.b;
                    float _SampleTexture2D_e5aebb8d1445433bacf47e39067cb0a0_A_7 = _SampleTexture2D_e5aebb8d1445433bacf47e39067cb0a0_RGBA_0.a;
                    float4 _Branch_7d4a670ae12240ccbe8bdb249a237644_Out_3;
                    Unity_Branch_float4(_Comparison_8f4fb954760447e8b0db8924e20fd1d0_Out_2, _SampleTexture2D_66835b651206479b8da548ce63cec2a2_RGBA_0, _SampleTexture2D_e5aebb8d1445433bacf47e39067cb0a0_RGBA_0, _Branch_7d4a670ae12240ccbe8bdb249a237644_Out_3);
                    float4 _Branch_5225751f0aaf4e5885184101068828b5_Out_3;
                    Unity_Branch_float4(_Property_c92104f8c9d245dbb796f54a2386b2fa_Out_0, _Add_3e553e4abf784d7799c718cfe7d51b68_Out_2, _Branch_7d4a670ae12240ccbe8bdb249a237644_Out_3, _Branch_5225751f0aaf4e5885184101068828b5_Out_3);
                    float4 _Lerp_b501d8723a3b46369b51759c91fb6f3c_Out_3;
                    Unity_Lerp_float4(_SampleTexture2D_0121a928620142938ff635ec1ff89401_RGBA_0, _Branch_5225751f0aaf4e5885184101068828b5_Out_3, (_Clamp_0f7ac1e483384940a0714a9e608d50b4_Out_3.xxxx), _Lerp_b501d8723a3b46369b51759c91fb6f3c_Out_3);
                    UnityTexture2D _Property_d6241559ab474e5782a32fe991893c23_Out_0 = UnityBuildTexture2DStructNoScale(_FarNormal);
                    float2 _TilingAndOffset_bdb4faaa2ebc4eb990d5202f25946a55_Out_3;
                    Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), float2 (0, 0), _TilingAndOffset_bdb4faaa2ebc4eb990d5202f25946a55_Out_3);
                    float4 _SampleTexture2D_4e9f3a96a6da4e8bac8f2aa7059e160c_RGBA_0 = SAMPLE_TEXTURE2D(_Property_d6241559ab474e5782a32fe991893c23_Out_0.tex, _Property_d6241559ab474e5782a32fe991893c23_Out_0.samplerstate, _TilingAndOffset_bdb4faaa2ebc4eb990d5202f25946a55_Out_3);
                    _SampleTexture2D_4e9f3a96a6da4e8bac8f2aa7059e160c_RGBA_0.rgb = UnpackNormal(_SampleTexture2D_4e9f3a96a6da4e8bac8f2aa7059e160c_RGBA_0);
                    float _SampleTexture2D_4e9f3a96a6da4e8bac8f2aa7059e160c_R_4 = _SampleTexture2D_4e9f3a96a6da4e8bac8f2aa7059e160c_RGBA_0.r;
                    float _SampleTexture2D_4e9f3a96a6da4e8bac8f2aa7059e160c_G_5 = _SampleTexture2D_4e9f3a96a6da4e8bac8f2aa7059e160c_RGBA_0.g;
                    float _SampleTexture2D_4e9f3a96a6da4e8bac8f2aa7059e160c_B_6 = _SampleTexture2D_4e9f3a96a6da4e8bac8f2aa7059e160c_RGBA_0.b;
                    float _SampleTexture2D_4e9f3a96a6da4e8bac8f2aa7059e160c_A_7 = _SampleTexture2D_4e9f3a96a6da4e8bac8f2aa7059e160c_RGBA_0.a;
                    float _Distance_44875152cc614e5ba9d5c699495f08ab_Out_2;
                    Unity_Distance_float3(IN.WorldSpacePosition, _WorldSpaceCameraPos, _Distance_44875152cc614e5ba9d5c699495f08ab_Out_2);
                    float _Property_aebc16f7283a467a8048e6bb509da7c6_Out_0 = _LODdistance;
                    float _Divide_32fb228b5d524f178b884f2adaa8e599_Out_2;
                    Unity_Divide_float(_Distance_44875152cc614e5ba9d5c699495f08ab_Out_2, _Property_aebc16f7283a467a8048e6bb509da7c6_Out_0, _Divide_32fb228b5d524f178b884f2adaa8e599_Out_2);
                    float4 _Lerp_2e0a60782cb64960ac783789c38969b5_Out_3;
                    Unity_Lerp_float4(_Lerp_b501d8723a3b46369b51759c91fb6f3c_Out_3, _SampleTexture2D_4e9f3a96a6da4e8bac8f2aa7059e160c_RGBA_0, (_Divide_32fb228b5d524f178b884f2adaa8e599_Out_2.xxxx), _Lerp_2e0a60782cb64960ac783789c38969b5_Out_3);
                    float _Property_d642bbaad222433b9f2ebb353b53909f_Out_0 = _Metallic;
                    float _DotProduct_fb1cbb38204242edbadb0a15bc95b04e_Out_2;
                    Unity_DotProduct_float3(-1 * mul((float3x3)UNITY_MATRIX_M, transpose(mul(UNITY_MATRIX_I_M, UNITY_MATRIX_I_V)) [2].xyz), IN.WorldSpaceNormal, _DotProduct_fb1cbb38204242edbadb0a15bc95b04e_Out_2);
                    float _Remap_bde541d934954ce5b99314edcbcd70e5_Out_3;
                    Unity_Remap_float(_DotProduct_fb1cbb38204242edbadb0a15bc95b04e_Out_2, float2 (-1, 0), float2 (0, 1), _Remap_bde541d934954ce5b99314edcbcd70e5_Out_3);
                    float _Multiply_6330a2a6c69948a5aacc174b9da1d2f0_Out_2;
                    Unity_Multiply_float(_Split_17c957ee33bc4e28a994b8b8dd20a89f_A_4, _Remap_bde541d934954ce5b99314edcbcd70e5_Out_3, _Multiply_6330a2a6c69948a5aacc174b9da1d2f0_Out_2);
                    float _Property_bc84cef440384b15875875c65e907453_Out_0 = _DownAlphaStrength;
                    float _Property_f604cf40fc3249839fb755ab1c9d8eb2_Out_0 = _TranceparencyStrength;
                    float _Multiply_c4a5b4f21dfe45d2a2f78cc50eba3ec8_Out_2;
                    Unity_Multiply_float(_Subtract_bd4ff2ba7ce04051b10b968b020d06df_Out_2, _Property_f604cf40fc3249839fb755ab1c9d8eb2_Out_0, _Multiply_c4a5b4f21dfe45d2a2f78cc50eba3ec8_Out_2);
                    float _Clamp_61028b06dbf14a6092a617f0d8a7ac32_Out_3;
                    Unity_Clamp_float(_Multiply_c4a5b4f21dfe45d2a2f78cc50eba3ec8_Out_2, 0, 1, _Clamp_61028b06dbf14a6092a617f0d8a7ac32_Out_3);
                    float _Lerp_106a757383d0403399452dcbb99cc72a_Out_3;
                    Unity_Lerp_float(_Property_bc84cef440384b15875875c65e907453_Out_0, 0, _Clamp_61028b06dbf14a6092a617f0d8a7ac32_Out_3, _Lerp_106a757383d0403399452dcbb99cc72a_Out_3);
                    float _Lerp_729c45b3c3014bdbb92bb4198e06bd92_Out_3;
                    Unity_Lerp_float(1, 0, _Remap_bde541d934954ce5b99314edcbcd70e5_Out_3, _Lerp_729c45b3c3014bdbb92bb4198e06bd92_Out_3);
                    float _Multiply_a80cb3307cd746d7a1bb5f699c9423f3_Out_2;
                    Unity_Multiply_float(_Lerp_106a757383d0403399452dcbb99cc72a_Out_3, _Lerp_729c45b3c3014bdbb92bb4198e06bd92_Out_3, _Multiply_a80cb3307cd746d7a1bb5f699c9423f3_Out_2);
                    float _Lerp_b12dda477cf14695add7f2de406dd644_Out_3;
                    Unity_Lerp_float(_Split_17c957ee33bc4e28a994b8b8dd20a89f_A_4, _Multiply_6330a2a6c69948a5aacc174b9da1d2f0_Out_2, _Multiply_a80cb3307cd746d7a1bb5f699c9423f3_Out_2, _Lerp_b12dda477cf14695add7f2de406dd644_Out_3);
                    surface.BaseColor = _Vector3_3b779f158e6f4ba8ac091e620cd4bd1c_Out_0;
                    surface.NormalTS = (_Lerp_2e0a60782cb64960ac783789c38969b5_Out_3.xyz);
                    surface.Emission = float3(0, 0, 0);
                    surface.Metallic = _Property_d642bbaad222433b9f2ebb353b53909f_Out_0;
                    surface.Smoothness = 0.5;
                    surface.Occlusion = 1;
                    surface.Alpha = _Lerp_b12dda477cf14695add7f2de406dd644_Out_3;
                    return surface;
                }
    
                // --------------------------------------------------
                // Build Graph Inputs
    
                VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                {
                    VertexDescriptionInputs output;
                    ZERO_INITIALIZE(VertexDescriptionInputs, output);
                
                    output.ObjectSpaceNormal =           input.normalOS;
                    output.ObjectSpaceTangent =          input.tangentOS.xyz;
                    output.ObjectSpacePosition =         input.positionOS;
                
                    return output;
                }
                
                SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                {
                    SurfaceDescriptionInputs output;
                    ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
                
                	// must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
                	float3 unnormalizedNormalWS = input.normalWS;
                    const float renormFactor = 1.0 / length(unnormalizedNormalWS);
                
                
                    output.WorldSpaceNormal =            renormFactor*input.normalWS.xyz;		// we want a unit length Normal Vector node in shader graph
                    output.TangentSpaceNormal =          float3(0.0f, 0.0f, 1.0f);
                
                
                    output.WorldSpacePosition =          input.positionWS;
                    output.ScreenPosition =              ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
                    output.uv0 =                         input.texCoord0;
                    output.TimeParameters =              _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                #else
                #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                #endif
                #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                
                    return output;
                }
                
    
                // --------------------------------------------------
                // Main
    
                #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/UnityGBuffer.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBRGBufferPass.hlsl"
    
                ENDHLSL
            }
            Pass
            {
                Name "ShadowCaster"
                Tags
                {
                    "LightMode" = "ShadowCaster"
                }
    
                // Render State
                Cull Off
                Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
                ZTest LEqual
                ZWrite On
                ColorMask 0
    
                // Debug
                // <None>
    
                // --------------------------------------------------
                // Pass
    
                HLSLPROGRAM
    
                // Pragmas
                #pragma target 4.5
                #pragma exclude_renderers gles gles3 glcore
                #pragma multi_compile_instancing
                #pragma multi_compile _ DOTS_INSTANCING_ON
                #pragma vertex vert
                #pragma fragment frag
    
                // DotsInstancingOptions: <None>
                // HybridV1InjectedBuiltinProperties: <None>
    
                // Keywords
                // PassKeywords: <None>
                // GraphKeywords: <None>
    
                // Defines
                #define _SURFACE_TYPE_TRANSPARENT 1
                #define _NORMALMAP 1
                #define _NORMAL_DROPOFF_TS 1
                #define ATTRIBUTES_NEED_NORMAL
                #define ATTRIBUTES_NEED_TANGENT
                #define VARYINGS_NEED_POSITION_WS
                #define VARYINGS_NEED_NORMAL_WS
                #define FEATURES_GRAPH_VERTEX
                /* WARNING: $splice Could not find named fragment 'PassInstancing' */
                #define SHADERPASS SHADERPASS_SHADOWCASTER
                #define REQUIRE_DEPTH_TEXTURE
                /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
    
                // Includes
                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
    
                // --------------------------------------------------
                // Structs and Packing
    
                struct Attributes
                {
                    float3 positionOS : POSITION;
                    float3 normalOS : NORMAL;
                    float4 tangentOS : TANGENT;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    uint instanceID : INSTANCEID_SEMANTIC;
                    #endif
                };
                struct Varyings
                {
                    float4 positionCS : SV_POSITION;
                    float3 positionWS;
                    float3 normalWS;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    uint instanceID : CUSTOM_INSTANCE_ID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                    #endif
                };
                struct SurfaceDescriptionInputs
                {
                    float3 WorldSpaceNormal;
                    float3 WorldSpacePosition;
                    float4 ScreenPosition;
                    float3 TimeParameters;
                };
                struct VertexDescriptionInputs
                {
                    float3 ObjectSpaceNormal;
                    float3 ObjectSpaceTangent;
                    float3 ObjectSpacePosition;
                };
                struct PackedVaryings
                {
                    float4 positionCS : SV_POSITION;
                    float3 interp0 : TEXCOORD0;
                    float3 interp1 : TEXCOORD1;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    uint instanceID : CUSTOM_INSTANCE_ID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                    #endif
                };
    
                PackedVaryings PackVaryings (Varyings input)
                {
                    PackedVaryings output;
                    output.positionCS = input.positionCS;
                    output.interp0.xyz =  input.positionWS;
                    output.interp1.xyz =  input.normalWS;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    output.instanceID = input.instanceID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    output.cullFace = input.cullFace;
                    #endif
                    return output;
                }
                Varyings UnpackVaryings (PackedVaryings input)
                {
                    Varyings output;
                    output.positionCS = input.positionCS;
                    output.positionWS = input.interp0.xyz;
                    output.normalWS = input.interp1.xyz;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    output.instanceID = input.instanceID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    output.cullFace = input.cullFace;
                    #endif
                    return output;
                }
    
                // --------------------------------------------------
                // Graph
    
                // Graph Properties
                CBUFFER_START(UnityPerMaterial)
                float _DepthOffset;
                float _Strength;
                float4 _DeepWaterColor;
                float4 _ShallowWaterColor;
                float _Metallic;
                float2 _Tiling;
                float4 _OceanNormal2_TexelSize;
                float4 _OceanNormal1_TexelSize;
                float _GradientNoise;
                float2 _OceanSpeed;
                float _LODdistance;
                float4 _FarNormal_TexelSize;
                float4 _ShallowNormal_TexelSize;
                float _TranceparencyStrength;
                float _DownAlphaStrength;
                float _IsOcean;
                float4 _RiverNormal_TexelSize;
                float _RiverNormalRotAdjustment;
                float4 _LevelRiverNormal_TexelSize;
                float _RiverSpeed;
                float _ShoreIntersectionStrength;
                float4 Color_701f2c2f40b34b87975a0e85a71325dc;
                CBUFFER_END
                
                // Object and Global properties
                SAMPLER(SamplerState_Linear_Repeat);
                TEXTURE2D(_OceanNormal2);
                SAMPLER(sampler_OceanNormal2);
                TEXTURE2D(_OceanNormal1);
                SAMPLER(sampler_OceanNormal1);
                TEXTURE2D(_FarNormal);
                SAMPLER(sampler_FarNormal);
                TEXTURE2D(_ShallowNormal);
                SAMPLER(sampler_ShallowNormal);
                TEXTURE2D(_RiverNormal);
                SAMPLER(sampler_RiverNormal);
                TEXTURE2D(_LevelRiverNormal);
                SAMPLER(sampler_LevelRiverNormal);
                float _StretchScalar;
    
                // Graph Functions
                
                void Unity_SceneDepth_Linear01_float(float4 UV, out float Out)
                {
                    Out = Linear01Depth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
                }
                
                void Unity_Multiply_float(float A, float B, out float Out)
                {
                    Out = A * B;
                }
                
                void Unity_Add_float(float A, float B, out float Out)
                {
                    Out = A + B;
                }
                
                void Unity_Subtract_float(float A, float B, out float Out)
                {
                    Out = A - B;
                }
                
                void Unity_Sine_float(float In, out float Out)
                {
                    Out = sin(In);
                }
                
                void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
                {
                    Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
                }
                
                void Unity_Branch_float(float Predicate, float True, float False, out float Out)
                {
                    Out = Predicate ? True : False;
                }
                
                void Unity_Clamp_float(float In, float Min, float Max, out float Out)
                {
                    Out = clamp(In, Min, Max);
                }
                
                void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
                {
                    Out = lerp(A, B, T);
                }
                
                void Unity_Normalize_float3(float3 In, out float3 Out)
                {
                    Out = normalize(In);
                }
                
                void Unity_DotProduct_float3(float3 A, float3 B, out float Out)
                {
                    Out = dot(A, B);
                }
                
                void Unity_Add_float4(float4 A, float4 B, out float4 Out)
                {
                    Out = A + B;
                }
                
                void Unity_Lerp_float(float A, float B, float T, out float Out)
                {
                    Out = lerp(A, B, T);
                }
    
                // Graph Vertex
                struct VertexDescription
                {
                    float3 Position;
                    float3 Normal;
                    float3 Tangent;
                };
                
                VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                {
                    VertexDescription description = (VertexDescription)0;
                    description.Position = IN.ObjectSpacePosition;
                    description.Normal = IN.ObjectSpaceNormal;
                    description.Tangent = IN.ObjectSpaceTangent;
                    return description;
                }
    
                // Graph Pixel
                struct SurfaceDescription
                {
                    float Alpha;
                };
                
                SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                {
                    SurfaceDescription surface = (SurfaceDescription)0;
                    float4 _Property_231c0d262d3a466d85dfd53b116086ca_Out_0 = Color_701f2c2f40b34b87975a0e85a71325dc;
                    float _SceneDepth_3137d738aa0149fb8a54d88a60826a60_Out_1;
                    Unity_SceneDepth_Linear01_float(float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0), _SceneDepth_3137d738aa0149fb8a54d88a60826a60_Out_1);
                    float _Multiply_8ec8e0a1878e494ca0d6d16678168741_Out_2;
                    Unity_Multiply_float(_SceneDepth_3137d738aa0149fb8a54d88a60826a60_Out_1, _ProjectionParams.z, _Multiply_8ec8e0a1878e494ca0d6d16678168741_Out_2);
                    float4 _ScreenPosition_3840c0fb20fc4eb58387cd54ee7e2b18_Out_0 = IN.ScreenPosition;
                    float _Split_578ef5cadaac40969c114c4d1ae870d8_R_1 = _ScreenPosition_3840c0fb20fc4eb58387cd54ee7e2b18_Out_0[0];
                    float _Split_578ef5cadaac40969c114c4d1ae870d8_G_2 = _ScreenPosition_3840c0fb20fc4eb58387cd54ee7e2b18_Out_0[1];
                    float _Split_578ef5cadaac40969c114c4d1ae870d8_B_3 = _ScreenPosition_3840c0fb20fc4eb58387cd54ee7e2b18_Out_0[2];
                    float _Split_578ef5cadaac40969c114c4d1ae870d8_A_4 = _ScreenPosition_3840c0fb20fc4eb58387cd54ee7e2b18_Out_0[3];
                    float _Property_cedd17331b16484abf1a4ce8eb0e5a72_Out_0 = _DepthOffset;
                    float _Add_e04e1bc3087745d898c282f10a0f43e3_Out_2;
                    Unity_Add_float(_Split_578ef5cadaac40969c114c4d1ae870d8_A_4, _Property_cedd17331b16484abf1a4ce8eb0e5a72_Out_0, _Add_e04e1bc3087745d898c282f10a0f43e3_Out_2);
                    float _Subtract_bd4ff2ba7ce04051b10b968b020d06df_Out_2;
                    Unity_Subtract_float(_Multiply_8ec8e0a1878e494ca0d6d16678168741_Out_2, _Add_e04e1bc3087745d898c282f10a0f43e3_Out_2, _Subtract_bd4ff2ba7ce04051b10b968b020d06df_Out_2);
                    float _Property_90205b2f827548b295dc151171bc164c_Out_0 = _IsOcean;
                    float _Sine_24a173ac1d9d40b5b43bd7c8169386e4_Out_1;
                    Unity_Sine_float(IN.TimeParameters.x, _Sine_24a173ac1d9d40b5b43bd7c8169386e4_Out_1);
                    float _Remap_9ed3ea235fdc44d7a8c762cbe7ff6d0e_Out_3;
                    Unity_Remap_float(_Sine_24a173ac1d9d40b5b43bd7c8169386e4_Out_1, float2 (-1, 1), float2 (0.5, 1), _Remap_9ed3ea235fdc44d7a8c762cbe7ff6d0e_Out_3);
                    float _Branch_fcfcb84348fb4a5a90417124dc9ee3a2_Out_3;
                    Unity_Branch_float(_Property_90205b2f827548b295dc151171bc164c_Out_0, _Remap_9ed3ea235fdc44d7a8c762cbe7ff6d0e_Out_3, 1, _Branch_fcfcb84348fb4a5a90417124dc9ee3a2_Out_3);
                    float _Property_866bbbbe2a484e2eae1ad77ed223a577_Out_0 = _ShoreIntersectionStrength;
                    float _Multiply_cb7f54f30fb348b4a7f109f458e38b17_Out_2;
                    Unity_Multiply_float(_Branch_fcfcb84348fb4a5a90417124dc9ee3a2_Out_3, _Property_866bbbbe2a484e2eae1ad77ed223a577_Out_0, _Multiply_cb7f54f30fb348b4a7f109f458e38b17_Out_2);
                    float _Multiply_dcdae92bb4dd401a89df781ec062cecc_Out_2;
                    Unity_Multiply_float(_Subtract_bd4ff2ba7ce04051b10b968b020d06df_Out_2, _Multiply_cb7f54f30fb348b4a7f109f458e38b17_Out_2, _Multiply_dcdae92bb4dd401a89df781ec062cecc_Out_2);
                    float _Clamp_33ee6da80fc14439b6d7bab14be7ab07_Out_3;
                    Unity_Clamp_float(_Multiply_dcdae92bb4dd401a89df781ec062cecc_Out_2, 0.5, 1, _Clamp_33ee6da80fc14439b6d7bab14be7ab07_Out_3);
                    float4 _Lerp_f0669e92de0b409893955d23347ac238_Out_3;
                    Unity_Lerp_float4(_Property_231c0d262d3a466d85dfd53b116086ca_Out_0, float4(0, 0, 0, 0), (_Clamp_33ee6da80fc14439b6d7bab14be7ab07_Out_3.xxxx), _Lerp_f0669e92de0b409893955d23347ac238_Out_3);
                    float _Float_c4cf30aef9464dda83de90c7e790a9ba_Out_0 = 1.5;
                    float4 _Property_c854872c24e048c0aa372f0be547f07c_Out_0 = _ShallowWaterColor;
                    float4 _Property_dde44c4f61534e08a917dd16bcf5ebca_Out_0 = _DeepWaterColor;
                    float _Property_d328dfa89c674e67bffe73ef574a2d58_Out_0 = _Strength;
                    float _Multiply_4eb7822d949844e38f2bb60067662a47_Out_2;
                    Unity_Multiply_float(_Subtract_bd4ff2ba7ce04051b10b968b020d06df_Out_2, _Property_d328dfa89c674e67bffe73ef574a2d58_Out_0, _Multiply_4eb7822d949844e38f2bb60067662a47_Out_2);
                    float _Clamp_0f7ac1e483384940a0714a9e608d50b4_Out_3;
                    Unity_Clamp_float(_Multiply_4eb7822d949844e38f2bb60067662a47_Out_2, 0, 1, _Clamp_0f7ac1e483384940a0714a9e608d50b4_Out_3);
                    float4 _Lerp_3f9225ad7cdc45509b625268ef70e29c_Out_3;
                    Unity_Lerp_float4(_Property_c854872c24e048c0aa372f0be547f07c_Out_0, _Property_dde44c4f61534e08a917dd16bcf5ebca_Out_0, (_Clamp_0f7ac1e483384940a0714a9e608d50b4_Out_3.xxxx), _Lerp_3f9225ad7cdc45509b625268ef70e29c_Out_3);
                    float3 _Normalize_415b503188e443458e4172309aa4cb18_Out_1;
                    Unity_Normalize_float3(IN.WorldSpaceNormal, _Normalize_415b503188e443458e4172309aa4cb18_Out_1);
                    float _DotProduct_b3f1b90b273a4b2b99f07acbc4565dcb_Out_2;
                    Unity_DotProduct_float3(float3(0, 1, 0), _Normalize_415b503188e443458e4172309aa4cb18_Out_1, _DotProduct_b3f1b90b273a4b2b99f07acbc4565dcb_Out_2);
                    float _Remap_669938a90f934b9bab86d586a6917aca_Out_3;
                    Unity_Remap_float(_DotProduct_b3f1b90b273a4b2b99f07acbc4565dcb_Out_2, float2 (-1, 1), float2 (0, 1), _Remap_669938a90f934b9bab86d586a6917aca_Out_3);
                    float4 _Lerp_4536ba8c658e4f11aaefc80660368304_Out_3;
                    Unity_Lerp_float4((_Float_c4cf30aef9464dda83de90c7e790a9ba_Out_0.xxxx), _Lerp_3f9225ad7cdc45509b625268ef70e29c_Out_3, (_Remap_669938a90f934b9bab86d586a6917aca_Out_3.xxxx), _Lerp_4536ba8c658e4f11aaefc80660368304_Out_3);
                    float4 _Add_f8fda8450f33454d96a6212c8ebfdc62_Out_2;
                    Unity_Add_float4(_Lerp_f0669e92de0b409893955d23347ac238_Out_3, _Lerp_4536ba8c658e4f11aaefc80660368304_Out_3, _Add_f8fda8450f33454d96a6212c8ebfdc62_Out_2);
                    float _Split_17c957ee33bc4e28a994b8b8dd20a89f_R_1 = _Add_f8fda8450f33454d96a6212c8ebfdc62_Out_2[0];
                    float _Split_17c957ee33bc4e28a994b8b8dd20a89f_G_2 = _Add_f8fda8450f33454d96a6212c8ebfdc62_Out_2[1];
                    float _Split_17c957ee33bc4e28a994b8b8dd20a89f_B_3 = _Add_f8fda8450f33454d96a6212c8ebfdc62_Out_2[2];
                    float _Split_17c957ee33bc4e28a994b8b8dd20a89f_A_4 = _Add_f8fda8450f33454d96a6212c8ebfdc62_Out_2[3];
                    float _DotProduct_fb1cbb38204242edbadb0a15bc95b04e_Out_2;
                    Unity_DotProduct_float3(-1 * mul((float3x3)UNITY_MATRIX_M, transpose(mul(UNITY_MATRIX_I_M, UNITY_MATRIX_I_V)) [2].xyz), IN.WorldSpaceNormal, _DotProduct_fb1cbb38204242edbadb0a15bc95b04e_Out_2);
                    float _Remap_bde541d934954ce5b99314edcbcd70e5_Out_3;
                    Unity_Remap_float(_DotProduct_fb1cbb38204242edbadb0a15bc95b04e_Out_2, float2 (-1, 0), float2 (0, 1), _Remap_bde541d934954ce5b99314edcbcd70e5_Out_3);
                    float _Multiply_6330a2a6c69948a5aacc174b9da1d2f0_Out_2;
                    Unity_Multiply_float(_Split_17c957ee33bc4e28a994b8b8dd20a89f_A_4, _Remap_bde541d934954ce5b99314edcbcd70e5_Out_3, _Multiply_6330a2a6c69948a5aacc174b9da1d2f0_Out_2);
                    float _Property_bc84cef440384b15875875c65e907453_Out_0 = _DownAlphaStrength;
                    float _Property_f604cf40fc3249839fb755ab1c9d8eb2_Out_0 = _TranceparencyStrength;
                    float _Multiply_c4a5b4f21dfe45d2a2f78cc50eba3ec8_Out_2;
                    Unity_Multiply_float(_Subtract_bd4ff2ba7ce04051b10b968b020d06df_Out_2, _Property_f604cf40fc3249839fb755ab1c9d8eb2_Out_0, _Multiply_c4a5b4f21dfe45d2a2f78cc50eba3ec8_Out_2);
                    float _Clamp_61028b06dbf14a6092a617f0d8a7ac32_Out_3;
                    Unity_Clamp_float(_Multiply_c4a5b4f21dfe45d2a2f78cc50eba3ec8_Out_2, 0, 1, _Clamp_61028b06dbf14a6092a617f0d8a7ac32_Out_3);
                    float _Lerp_106a757383d0403399452dcbb99cc72a_Out_3;
                    Unity_Lerp_float(_Property_bc84cef440384b15875875c65e907453_Out_0, 0, _Clamp_61028b06dbf14a6092a617f0d8a7ac32_Out_3, _Lerp_106a757383d0403399452dcbb99cc72a_Out_3);
                    float _Lerp_729c45b3c3014bdbb92bb4198e06bd92_Out_3;
                    Unity_Lerp_float(1, 0, _Remap_bde541d934954ce5b99314edcbcd70e5_Out_3, _Lerp_729c45b3c3014bdbb92bb4198e06bd92_Out_3);
                    float _Multiply_a80cb3307cd746d7a1bb5f699c9423f3_Out_2;
                    Unity_Multiply_float(_Lerp_106a757383d0403399452dcbb99cc72a_Out_3, _Lerp_729c45b3c3014bdbb92bb4198e06bd92_Out_3, _Multiply_a80cb3307cd746d7a1bb5f699c9423f3_Out_2);
                    float _Lerp_b12dda477cf14695add7f2de406dd644_Out_3;
                    Unity_Lerp_float(_Split_17c957ee33bc4e28a994b8b8dd20a89f_A_4, _Multiply_6330a2a6c69948a5aacc174b9da1d2f0_Out_2, _Multiply_a80cb3307cd746d7a1bb5f699c9423f3_Out_2, _Lerp_b12dda477cf14695add7f2de406dd644_Out_3);
                    surface.Alpha = _Lerp_b12dda477cf14695add7f2de406dd644_Out_3;
                    return surface;
                }
    
                // --------------------------------------------------
                // Build Graph Inputs
    
                VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                {
                    VertexDescriptionInputs output;
                    ZERO_INITIALIZE(VertexDescriptionInputs, output);
                
                    output.ObjectSpaceNormal =           input.normalOS;
                    output.ObjectSpaceTangent =          input.tangentOS.xyz;
                    output.ObjectSpacePosition =         input.positionOS;
                
                    return output;
                }
                
                SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                {
                    SurfaceDescriptionInputs output;
                    ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
                
                	// must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
                	float3 unnormalizedNormalWS = input.normalWS;
                    const float renormFactor = 1.0 / length(unnormalizedNormalWS);
                
                
                    output.WorldSpaceNormal =            renormFactor*input.normalWS.xyz;		// we want a unit length Normal Vector node in shader graph
                
                
                    output.WorldSpacePosition =          input.positionWS;
                    output.ScreenPosition =              ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
                    output.TimeParameters =              _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                #else
                #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                #endif
                #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                
                    return output;
                }
                
    
                // --------------------------------------------------
                // Main
    
                #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShadowCasterPass.hlsl"
    
                ENDHLSL
            }
            Pass
            {
                Name "DepthOnly"
                Tags
                {
                    "LightMode" = "DepthOnly"
                }
    
                // Render State
                Cull Off
                Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
                ZTest LEqual
                ZWrite On
                ColorMask 0
    
                // Debug
                // <None>
    
                // --------------------------------------------------
                // Pass
    
                HLSLPROGRAM
    
                // Pragmas
                #pragma target 4.5
                #pragma exclude_renderers gles gles3 glcore
                #pragma multi_compile_instancing
                #pragma multi_compile _ DOTS_INSTANCING_ON
                #pragma vertex vert
                #pragma fragment frag
    
                // DotsInstancingOptions: <None>
                // HybridV1InjectedBuiltinProperties: <None>
    
                // Keywords
                // PassKeywords: <None>
                // GraphKeywords: <None>
    
                // Defines
                #define _SURFACE_TYPE_TRANSPARENT 1
                #define _NORMALMAP 1
                #define _NORMAL_DROPOFF_TS 1
                #define ATTRIBUTES_NEED_NORMAL
                #define ATTRIBUTES_NEED_TANGENT
                #define VARYINGS_NEED_POSITION_WS
                #define VARYINGS_NEED_NORMAL_WS
                #define FEATURES_GRAPH_VERTEX
                /* WARNING: $splice Could not find named fragment 'PassInstancing' */
                #define SHADERPASS SHADERPASS_DEPTHONLY
                #define REQUIRE_DEPTH_TEXTURE
                /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
    
                // Includes
                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
    
                // --------------------------------------------------
                // Structs and Packing
    
                struct Attributes
                {
                    float3 positionOS : POSITION;
                    float3 normalOS : NORMAL;
                    float4 tangentOS : TANGENT;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    uint instanceID : INSTANCEID_SEMANTIC;
                    #endif
                };
                struct Varyings
                {
                    float4 positionCS : SV_POSITION;
                    float3 positionWS;
                    float3 normalWS;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    uint instanceID : CUSTOM_INSTANCE_ID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                    #endif
                };
                struct SurfaceDescriptionInputs
                {
                    float3 WorldSpaceNormal;
                    float3 WorldSpacePosition;
                    float4 ScreenPosition;
                    float3 TimeParameters;
                };
                struct VertexDescriptionInputs
                {
                    float3 ObjectSpaceNormal;
                    float3 ObjectSpaceTangent;
                    float3 ObjectSpacePosition;
                };
                struct PackedVaryings
                {
                    float4 positionCS : SV_POSITION;
                    float3 interp0 : TEXCOORD0;
                    float3 interp1 : TEXCOORD1;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    uint instanceID : CUSTOM_INSTANCE_ID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                    #endif
                };
    
                PackedVaryings PackVaryings (Varyings input)
                {
                    PackedVaryings output;
                    output.positionCS = input.positionCS;
                    output.interp0.xyz =  input.positionWS;
                    output.interp1.xyz =  input.normalWS;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    output.instanceID = input.instanceID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    output.cullFace = input.cullFace;
                    #endif
                    return output;
                }
                Varyings UnpackVaryings (PackedVaryings input)
                {
                    Varyings output;
                    output.positionCS = input.positionCS;
                    output.positionWS = input.interp0.xyz;
                    output.normalWS = input.interp1.xyz;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    output.instanceID = input.instanceID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    output.cullFace = input.cullFace;
                    #endif
                    return output;
                }
    
                // --------------------------------------------------
                // Graph
    
                // Graph Properties
                CBUFFER_START(UnityPerMaterial)
                float _DepthOffset;
                float _Strength;
                float4 _DeepWaterColor;
                float4 _ShallowWaterColor;
                float _Metallic;
                float2 _Tiling;
                float4 _OceanNormal2_TexelSize;
                float4 _OceanNormal1_TexelSize;
                float _GradientNoise;
                float2 _OceanSpeed;
                float _LODdistance;
                float4 _FarNormal_TexelSize;
                float4 _ShallowNormal_TexelSize;
                float _TranceparencyStrength;
                float _DownAlphaStrength;
                float _IsOcean;
                float4 _RiverNormal_TexelSize;
                float _RiverNormalRotAdjustment;
                float4 _LevelRiverNormal_TexelSize;
                float _RiverSpeed;
                float _ShoreIntersectionStrength;
                float4 Color_701f2c2f40b34b87975a0e85a71325dc;
                CBUFFER_END
                
                // Object and Global properties
                SAMPLER(SamplerState_Linear_Repeat);
                TEXTURE2D(_OceanNormal2);
                SAMPLER(sampler_OceanNormal2);
                TEXTURE2D(_OceanNormal1);
                SAMPLER(sampler_OceanNormal1);
                TEXTURE2D(_FarNormal);
                SAMPLER(sampler_FarNormal);
                TEXTURE2D(_ShallowNormal);
                SAMPLER(sampler_ShallowNormal);
                TEXTURE2D(_RiverNormal);
                SAMPLER(sampler_RiverNormal);
                TEXTURE2D(_LevelRiverNormal);
                SAMPLER(sampler_LevelRiverNormal);
                float _StretchScalar;
    
                // Graph Functions
                
                void Unity_SceneDepth_Linear01_float(float4 UV, out float Out)
                {
                    Out = Linear01Depth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
                }
                
                void Unity_Multiply_float(float A, float B, out float Out)
                {
                    Out = A * B;
                }
                
                void Unity_Add_float(float A, float B, out float Out)
                {
                    Out = A + B;
                }
                
                void Unity_Subtract_float(float A, float B, out float Out)
                {
                    Out = A - B;
                }
                
                void Unity_Sine_float(float In, out float Out)
                {
                    Out = sin(In);
                }
                
                void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
                {
                    Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
                }
                
                void Unity_Branch_float(float Predicate, float True, float False, out float Out)
                {
                    Out = Predicate ? True : False;
                }
                
                void Unity_Clamp_float(float In, float Min, float Max, out float Out)
                {
                    Out = clamp(In, Min, Max);
                }
                
                void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
                {
                    Out = lerp(A, B, T);
                }
                
                void Unity_Normalize_float3(float3 In, out float3 Out)
                {
                    Out = normalize(In);
                }
                
                void Unity_DotProduct_float3(float3 A, float3 B, out float Out)
                {
                    Out = dot(A, B);
                }
                
                void Unity_Add_float4(float4 A, float4 B, out float4 Out)
                {
                    Out = A + B;
                }
                
                void Unity_Lerp_float(float A, float B, float T, out float Out)
                {
                    Out = lerp(A, B, T);
                }
    
                // Graph Vertex
                struct VertexDescription
                {
                    float3 Position;
                    float3 Normal;
                    float3 Tangent;
                };
                
                VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                {
                    VertexDescription description = (VertexDescription)0;
                    description.Position = IN.ObjectSpacePosition;
                    description.Normal = IN.ObjectSpaceNormal;
                    description.Tangent = IN.ObjectSpaceTangent;
                    return description;
                }
    
                // Graph Pixel
                struct SurfaceDescription
                {
                    float Alpha;
                };
                
                SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                {
                    SurfaceDescription surface = (SurfaceDescription)0;
                    float4 _Property_231c0d262d3a466d85dfd53b116086ca_Out_0 = Color_701f2c2f40b34b87975a0e85a71325dc;
                    float _SceneDepth_3137d738aa0149fb8a54d88a60826a60_Out_1;
                    Unity_SceneDepth_Linear01_float(float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0), _SceneDepth_3137d738aa0149fb8a54d88a60826a60_Out_1);
                    float _Multiply_8ec8e0a1878e494ca0d6d16678168741_Out_2;
                    Unity_Multiply_float(_SceneDepth_3137d738aa0149fb8a54d88a60826a60_Out_1, _ProjectionParams.z, _Multiply_8ec8e0a1878e494ca0d6d16678168741_Out_2);
                    float4 _ScreenPosition_3840c0fb20fc4eb58387cd54ee7e2b18_Out_0 = IN.ScreenPosition;
                    float _Split_578ef5cadaac40969c114c4d1ae870d8_R_1 = _ScreenPosition_3840c0fb20fc4eb58387cd54ee7e2b18_Out_0[0];
                    float _Split_578ef5cadaac40969c114c4d1ae870d8_G_2 = _ScreenPosition_3840c0fb20fc4eb58387cd54ee7e2b18_Out_0[1];
                    float _Split_578ef5cadaac40969c114c4d1ae870d8_B_3 = _ScreenPosition_3840c0fb20fc4eb58387cd54ee7e2b18_Out_0[2];
                    float _Split_578ef5cadaac40969c114c4d1ae870d8_A_4 = _ScreenPosition_3840c0fb20fc4eb58387cd54ee7e2b18_Out_0[3];
                    float _Property_cedd17331b16484abf1a4ce8eb0e5a72_Out_0 = _DepthOffset;
                    float _Add_e04e1bc3087745d898c282f10a0f43e3_Out_2;
                    Unity_Add_float(_Split_578ef5cadaac40969c114c4d1ae870d8_A_4, _Property_cedd17331b16484abf1a4ce8eb0e5a72_Out_0, _Add_e04e1bc3087745d898c282f10a0f43e3_Out_2);
                    float _Subtract_bd4ff2ba7ce04051b10b968b020d06df_Out_2;
                    Unity_Subtract_float(_Multiply_8ec8e0a1878e494ca0d6d16678168741_Out_2, _Add_e04e1bc3087745d898c282f10a0f43e3_Out_2, _Subtract_bd4ff2ba7ce04051b10b968b020d06df_Out_2);
                    float _Property_90205b2f827548b295dc151171bc164c_Out_0 = _IsOcean;
                    float _Sine_24a173ac1d9d40b5b43bd7c8169386e4_Out_1;
                    Unity_Sine_float(IN.TimeParameters.x, _Sine_24a173ac1d9d40b5b43bd7c8169386e4_Out_1);
                    float _Remap_9ed3ea235fdc44d7a8c762cbe7ff6d0e_Out_3;
                    Unity_Remap_float(_Sine_24a173ac1d9d40b5b43bd7c8169386e4_Out_1, float2 (-1, 1), float2 (0.5, 1), _Remap_9ed3ea235fdc44d7a8c762cbe7ff6d0e_Out_3);
                    float _Branch_fcfcb84348fb4a5a90417124dc9ee3a2_Out_3;
                    Unity_Branch_float(_Property_90205b2f827548b295dc151171bc164c_Out_0, _Remap_9ed3ea235fdc44d7a8c762cbe7ff6d0e_Out_3, 1, _Branch_fcfcb84348fb4a5a90417124dc9ee3a2_Out_3);
                    float _Property_866bbbbe2a484e2eae1ad77ed223a577_Out_0 = _ShoreIntersectionStrength;
                    float _Multiply_cb7f54f30fb348b4a7f109f458e38b17_Out_2;
                    Unity_Multiply_float(_Branch_fcfcb84348fb4a5a90417124dc9ee3a2_Out_3, _Property_866bbbbe2a484e2eae1ad77ed223a577_Out_0, _Multiply_cb7f54f30fb348b4a7f109f458e38b17_Out_2);
                    float _Multiply_dcdae92bb4dd401a89df781ec062cecc_Out_2;
                    Unity_Multiply_float(_Subtract_bd4ff2ba7ce04051b10b968b020d06df_Out_2, _Multiply_cb7f54f30fb348b4a7f109f458e38b17_Out_2, _Multiply_dcdae92bb4dd401a89df781ec062cecc_Out_2);
                    float _Clamp_33ee6da80fc14439b6d7bab14be7ab07_Out_3;
                    Unity_Clamp_float(_Multiply_dcdae92bb4dd401a89df781ec062cecc_Out_2, 0.5, 1, _Clamp_33ee6da80fc14439b6d7bab14be7ab07_Out_3);
                    float4 _Lerp_f0669e92de0b409893955d23347ac238_Out_3;
                    Unity_Lerp_float4(_Property_231c0d262d3a466d85dfd53b116086ca_Out_0, float4(0, 0, 0, 0), (_Clamp_33ee6da80fc14439b6d7bab14be7ab07_Out_3.xxxx), _Lerp_f0669e92de0b409893955d23347ac238_Out_3);
                    float _Float_c4cf30aef9464dda83de90c7e790a9ba_Out_0 = 1.5;
                    float4 _Property_c854872c24e048c0aa372f0be547f07c_Out_0 = _ShallowWaterColor;
                    float4 _Property_dde44c4f61534e08a917dd16bcf5ebca_Out_0 = _DeepWaterColor;
                    float _Property_d328dfa89c674e67bffe73ef574a2d58_Out_0 = _Strength;
                    float _Multiply_4eb7822d949844e38f2bb60067662a47_Out_2;
                    Unity_Multiply_float(_Subtract_bd4ff2ba7ce04051b10b968b020d06df_Out_2, _Property_d328dfa89c674e67bffe73ef574a2d58_Out_0, _Multiply_4eb7822d949844e38f2bb60067662a47_Out_2);
                    float _Clamp_0f7ac1e483384940a0714a9e608d50b4_Out_3;
                    Unity_Clamp_float(_Multiply_4eb7822d949844e38f2bb60067662a47_Out_2, 0, 1, _Clamp_0f7ac1e483384940a0714a9e608d50b4_Out_3);
                    float4 _Lerp_3f9225ad7cdc45509b625268ef70e29c_Out_3;
                    Unity_Lerp_float4(_Property_c854872c24e048c0aa372f0be547f07c_Out_0, _Property_dde44c4f61534e08a917dd16bcf5ebca_Out_0, (_Clamp_0f7ac1e483384940a0714a9e608d50b4_Out_3.xxxx), _Lerp_3f9225ad7cdc45509b625268ef70e29c_Out_3);
                    float3 _Normalize_415b503188e443458e4172309aa4cb18_Out_1;
                    Unity_Normalize_float3(IN.WorldSpaceNormal, _Normalize_415b503188e443458e4172309aa4cb18_Out_1);
                    float _DotProduct_b3f1b90b273a4b2b99f07acbc4565dcb_Out_2;
                    Unity_DotProduct_float3(float3(0, 1, 0), _Normalize_415b503188e443458e4172309aa4cb18_Out_1, _DotProduct_b3f1b90b273a4b2b99f07acbc4565dcb_Out_2);
                    float _Remap_669938a90f934b9bab86d586a6917aca_Out_3;
                    Unity_Remap_float(_DotProduct_b3f1b90b273a4b2b99f07acbc4565dcb_Out_2, float2 (-1, 1), float2 (0, 1), _Remap_669938a90f934b9bab86d586a6917aca_Out_3);
                    float4 _Lerp_4536ba8c658e4f11aaefc80660368304_Out_3;
                    Unity_Lerp_float4((_Float_c4cf30aef9464dda83de90c7e790a9ba_Out_0.xxxx), _Lerp_3f9225ad7cdc45509b625268ef70e29c_Out_3, (_Remap_669938a90f934b9bab86d586a6917aca_Out_3.xxxx), _Lerp_4536ba8c658e4f11aaefc80660368304_Out_3);
                    float4 _Add_f8fda8450f33454d96a6212c8ebfdc62_Out_2;
                    Unity_Add_float4(_Lerp_f0669e92de0b409893955d23347ac238_Out_3, _Lerp_4536ba8c658e4f11aaefc80660368304_Out_3, _Add_f8fda8450f33454d96a6212c8ebfdc62_Out_2);
                    float _Split_17c957ee33bc4e28a994b8b8dd20a89f_R_1 = _Add_f8fda8450f33454d96a6212c8ebfdc62_Out_2[0];
                    float _Split_17c957ee33bc4e28a994b8b8dd20a89f_G_2 = _Add_f8fda8450f33454d96a6212c8ebfdc62_Out_2[1];
                    float _Split_17c957ee33bc4e28a994b8b8dd20a89f_B_3 = _Add_f8fda8450f33454d96a6212c8ebfdc62_Out_2[2];
                    float _Split_17c957ee33bc4e28a994b8b8dd20a89f_A_4 = _Add_f8fda8450f33454d96a6212c8ebfdc62_Out_2[3];
                    float _DotProduct_fb1cbb38204242edbadb0a15bc95b04e_Out_2;
                    Unity_DotProduct_float3(-1 * mul((float3x3)UNITY_MATRIX_M, transpose(mul(UNITY_MATRIX_I_M, UNITY_MATRIX_I_V)) [2].xyz), IN.WorldSpaceNormal, _DotProduct_fb1cbb38204242edbadb0a15bc95b04e_Out_2);
                    float _Remap_bde541d934954ce5b99314edcbcd70e5_Out_3;
                    Unity_Remap_float(_DotProduct_fb1cbb38204242edbadb0a15bc95b04e_Out_2, float2 (-1, 0), float2 (0, 1), _Remap_bde541d934954ce5b99314edcbcd70e5_Out_3);
                    float _Multiply_6330a2a6c69948a5aacc174b9da1d2f0_Out_2;
                    Unity_Multiply_float(_Split_17c957ee33bc4e28a994b8b8dd20a89f_A_4, _Remap_bde541d934954ce5b99314edcbcd70e5_Out_3, _Multiply_6330a2a6c69948a5aacc174b9da1d2f0_Out_2);
                    float _Property_bc84cef440384b15875875c65e907453_Out_0 = _DownAlphaStrength;
                    float _Property_f604cf40fc3249839fb755ab1c9d8eb2_Out_0 = _TranceparencyStrength;
                    float _Multiply_c4a5b4f21dfe45d2a2f78cc50eba3ec8_Out_2;
                    Unity_Multiply_float(_Subtract_bd4ff2ba7ce04051b10b968b020d06df_Out_2, _Property_f604cf40fc3249839fb755ab1c9d8eb2_Out_0, _Multiply_c4a5b4f21dfe45d2a2f78cc50eba3ec8_Out_2);
                    float _Clamp_61028b06dbf14a6092a617f0d8a7ac32_Out_3;
                    Unity_Clamp_float(_Multiply_c4a5b4f21dfe45d2a2f78cc50eba3ec8_Out_2, 0, 1, _Clamp_61028b06dbf14a6092a617f0d8a7ac32_Out_3);
                    float _Lerp_106a757383d0403399452dcbb99cc72a_Out_3;
                    Unity_Lerp_float(_Property_bc84cef440384b15875875c65e907453_Out_0, 0, _Clamp_61028b06dbf14a6092a617f0d8a7ac32_Out_3, _Lerp_106a757383d0403399452dcbb99cc72a_Out_3);
                    float _Lerp_729c45b3c3014bdbb92bb4198e06bd92_Out_3;
                    Unity_Lerp_float(1, 0, _Remap_bde541d934954ce5b99314edcbcd70e5_Out_3, _Lerp_729c45b3c3014bdbb92bb4198e06bd92_Out_3);
                    float _Multiply_a80cb3307cd746d7a1bb5f699c9423f3_Out_2;
                    Unity_Multiply_float(_Lerp_106a757383d0403399452dcbb99cc72a_Out_3, _Lerp_729c45b3c3014bdbb92bb4198e06bd92_Out_3, _Multiply_a80cb3307cd746d7a1bb5f699c9423f3_Out_2);
                    float _Lerp_b12dda477cf14695add7f2de406dd644_Out_3;
                    Unity_Lerp_float(_Split_17c957ee33bc4e28a994b8b8dd20a89f_A_4, _Multiply_6330a2a6c69948a5aacc174b9da1d2f0_Out_2, _Multiply_a80cb3307cd746d7a1bb5f699c9423f3_Out_2, _Lerp_b12dda477cf14695add7f2de406dd644_Out_3);
                    surface.Alpha = _Lerp_b12dda477cf14695add7f2de406dd644_Out_3;
                    return surface;
                }
    
                // --------------------------------------------------
                // Build Graph Inputs
    
                VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                {
                    VertexDescriptionInputs output;
                    ZERO_INITIALIZE(VertexDescriptionInputs, output);
                
                    output.ObjectSpaceNormal =           input.normalOS;
                    output.ObjectSpaceTangent =          input.tangentOS.xyz;
                    output.ObjectSpacePosition =         input.positionOS;
                
                    return output;
                }
                
                SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                {
                    SurfaceDescriptionInputs output;
                    ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
                
                	// must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
                	float3 unnormalizedNormalWS = input.normalWS;
                    const float renormFactor = 1.0 / length(unnormalizedNormalWS);
                
                
                    output.WorldSpaceNormal =            renormFactor*input.normalWS.xyz;		// we want a unit length Normal Vector node in shader graph
                
                
                    output.WorldSpacePosition =          input.positionWS;
                    output.ScreenPosition =              ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
                    output.TimeParameters =              _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                #else
                #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                #endif
                #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                
                    return output;
                }
                
    
                // --------------------------------------------------
                // Main
    
                #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DepthOnlyPass.hlsl"
    
                ENDHLSL
            }
            Pass
            {
                Name "DepthNormals"
                Tags
                {
                    "LightMode" = "DepthNormals"
                }
    
                // Render State
                Cull Off
                Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
                ZTest LEqual
                ZWrite On
    
                // Debug
                // <None>
    
                // --------------------------------------------------
                // Pass
    
                HLSLPROGRAM
    
                // Pragmas
                #pragma target 4.5
                #pragma exclude_renderers gles gles3 glcore
                #pragma multi_compile_instancing
                #pragma multi_compile _ DOTS_INSTANCING_ON
                #pragma vertex vert
                #pragma fragment frag
    
                // DotsInstancingOptions: <None>
                // HybridV1InjectedBuiltinProperties: <None>
    
                // Keywords
                // PassKeywords: <None>
                // GraphKeywords: <None>
    
                // Defines
                #define _SURFACE_TYPE_TRANSPARENT 1
                #define _NORMALMAP 1
                #define _NORMAL_DROPOFF_TS 1
                #define ATTRIBUTES_NEED_NORMAL
                #define ATTRIBUTES_NEED_TANGENT
                #define ATTRIBUTES_NEED_TEXCOORD0
                #define ATTRIBUTES_NEED_TEXCOORD1
                #define VARYINGS_NEED_POSITION_WS
                #define VARYINGS_NEED_NORMAL_WS
                #define VARYINGS_NEED_TANGENT_WS
                #define VARYINGS_NEED_TEXCOORD0
                #define FEATURES_GRAPH_VERTEX
                /* WARNING: $splice Could not find named fragment 'PassInstancing' */
                #define SHADERPASS SHADERPASS_DEPTHNORMALSONLY
                #define REQUIRE_DEPTH_TEXTURE
                /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
    
                // Includes
                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
    
                // --------------------------------------------------
                // Structs and Packing
    
                struct Attributes
                {
                    float3 positionOS : POSITION;
                    float3 normalOS : NORMAL;
                    float4 tangentOS : TANGENT;
                    float4 uv0 : TEXCOORD0;
                    float4 uv1 : TEXCOORD1;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    uint instanceID : INSTANCEID_SEMANTIC;
                    #endif
                };
                struct Varyings
                {
                    float4 positionCS : SV_POSITION;
                    float3 positionWS;
                    float3 normalWS;
                    float4 tangentWS;
                    float4 texCoord0;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    uint instanceID : CUSTOM_INSTANCE_ID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                    #endif
                };
                struct SurfaceDescriptionInputs
                {
                    float3 WorldSpaceNormal;
                    float3 TangentSpaceNormal;
                    float3 WorldSpacePosition;
                    float4 ScreenPosition;
                    float4 uv0;
                    float3 TimeParameters;
                };
                struct VertexDescriptionInputs
                {
                    float3 ObjectSpaceNormal;
                    float3 ObjectSpaceTangent;
                    float3 ObjectSpacePosition;
                };
                struct PackedVaryings
                {
                    float4 positionCS : SV_POSITION;
                    float3 interp0 : TEXCOORD0;
                    float3 interp1 : TEXCOORD1;
                    float4 interp2 : TEXCOORD2;
                    float4 interp3 : TEXCOORD3;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    uint instanceID : CUSTOM_INSTANCE_ID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                    #endif
                };
    
                PackedVaryings PackVaryings (Varyings input)
                {
                    PackedVaryings output;
                    output.positionCS = input.positionCS;
                    output.interp0.xyz =  input.positionWS;
                    output.interp1.xyz =  input.normalWS;
                    output.interp2.xyzw =  input.tangentWS;
                    output.interp3.xyzw =  input.texCoord0;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    output.instanceID = input.instanceID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    output.cullFace = input.cullFace;
                    #endif
                    return output;
                }
                Varyings UnpackVaryings (PackedVaryings input)
                {
                    Varyings output;
                    output.positionCS = input.positionCS;
                    output.positionWS = input.interp0.xyz;
                    output.normalWS = input.interp1.xyz;
                    output.tangentWS = input.interp2.xyzw;
                    output.texCoord0 = input.interp3.xyzw;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    output.instanceID = input.instanceID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    output.cullFace = input.cullFace;
                    #endif
                    return output;
                }
    
                // --------------------------------------------------
                // Graph
    
                // Graph Properties
                CBUFFER_START(UnityPerMaterial)
                float _DepthOffset;
                float _Strength;
                float4 _DeepWaterColor;
                float4 _ShallowWaterColor;
                float _Metallic;
                float2 _Tiling;
                float4 _OceanNormal2_TexelSize;
                float4 _OceanNormal1_TexelSize;
                float _GradientNoise;
                float2 _OceanSpeed;
                float _LODdistance;
                float4 _FarNormal_TexelSize;
                float4 _ShallowNormal_TexelSize;
                float _TranceparencyStrength;
                float _DownAlphaStrength;
                float _IsOcean;
                float4 _RiverNormal_TexelSize;
                float _RiverNormalRotAdjustment;
                float4 _LevelRiverNormal_TexelSize;
                float _RiverSpeed;
                float _ShoreIntersectionStrength;
                float4 Color_701f2c2f40b34b87975a0e85a71325dc;
                CBUFFER_END
                
                // Object and Global properties
                SAMPLER(SamplerState_Linear_Repeat);
                TEXTURE2D(_OceanNormal2);
                SAMPLER(sampler_OceanNormal2);
                TEXTURE2D(_OceanNormal1);
                SAMPLER(sampler_OceanNormal1);
                TEXTURE2D(_FarNormal);
                SAMPLER(sampler_FarNormal);
                TEXTURE2D(_ShallowNormal);
                SAMPLER(sampler_ShallowNormal);
                TEXTURE2D(_RiverNormal);
                SAMPLER(sampler_RiverNormal);
                TEXTURE2D(_LevelRiverNormal);
                SAMPLER(sampler_LevelRiverNormal);
                float _StretchScalar;
    
                // Graph Functions
                
                void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
                {
                    Out = UV * Tiling + Offset;
                }
                
                void Unity_Divide_float(float A, float B, out float Out)
                {
                    Out = A / B;
                }
                
                
                float2 Unity_GradientNoise_Dir_float(float2 p)
                {
                    // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
                    p = p % 289;
                    // need full precision, otherwise half overflows when p > 1
                    float x = float(34 * p.x + 1) * p.x % 289 + p.y;
                    x = (34 * x + 1) * x % 289;
                    x = frac(x / 41) * 2 - 1;
                    return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
                }
                
                void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
                { 
                    float2 p = UV * Scale;
                    float2 ip = floor(p);
                    float2 fp = frac(p);
                    float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
                    float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
                    float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
                    float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
                    fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
                    Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
                }
                
                void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
                {
                    Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
                }
                
                void Unity_Add_float4(float4 A, float4 B, out float4 Out)
                {
                    Out = A + B;
                }
                
                void Unity_Normalize_float3(float3 In, out float3 Out)
                {
                    Out = normalize(In);
                }
                
                void Unity_DotProduct_float3(float3 A, float3 B, out float Out)
                {
                    Out = dot(A, B);
                }
                
                void Unity_Comparison_Greater_float(float A, float B, out float Out)
                {
                    Out = A > B ? 1 : 0;
                }
                
                void Unity_Normalize_float2(float2 In, out float2 Out)
                {
                    Out = normalize(In);
                }
                
                void Unity_DotProduct_float2(float2 A, float2 B, out float Out)
                {
                    Out = dot(A, B);
                }
                
                void Unity_Arccosine_float(float In, out float Out)
                {
                    Out = acos(In);
                }
                
                void Unity_Multiply_float(float A, float B, out float Out)
                {
                    Out = A * B;
                }
                
                void Unity_Add_float(float A, float B, out float Out)
                {
                    Out = A + B;
                }
                
                void Unity_Branch_float(float Predicate, float True, float False, out float Out)
                {
                    Out = Predicate ? True : False;
                }
                
                void Unity_Rotate_Radians_float(float2 UV, float2 Center, float Rotation, out float2 Out)
                {
                    //rotation matrix
                    UV -= Center;
                    float s = sin(Rotation);
                    float c = cos(Rotation);
                
                    //center rotation matrix
                    float2x2 rMatrix = float2x2(c, -s, s, c);
                    rMatrix *= 0.5;
                    rMatrix += 0.5;
                    rMatrix = rMatrix*2 - 1;
                
                    //multiply the UVs by the rotation matrix
                    UV.xy = mul(UV.xy, rMatrix);
                    UV += Center;
                
                    Out = UV;
                }
                
                void Unity_Lerp_float(float A, float B, float T, out float Out)
                {
                    Out = lerp(A, B, T);
                }
                
                void Unity_Rotate_Degrees_float(float2 UV, float2 Center, float Rotation, out float2 Out)
                {
                    //rotation matrix
                    Rotation = Rotation * (3.1415926f/180.0f);
                    UV -= Center;
                    float s = sin(Rotation);
                    float c = cos(Rotation);
                
                    //center rotation matrix
                    float2x2 rMatrix = float2x2(c, -s, s, c);
                    rMatrix *= 0.5;
                    rMatrix += 0.5;
                    rMatrix = rMatrix*2 - 1;
                
                    //multiply the UVs by the rotation matrix
                    UV.xy = mul(UV.xy, rMatrix);
                    UV += Center;
                
                    Out = UV;
                }
                
                void Unity_Branch_float4(float Predicate, float4 True, float4 False, out float4 Out)
                {
                    Out = Predicate ? True : False;
                }
                
                void Unity_SceneDepth_Linear01_float(float4 UV, out float Out)
                {
                    Out = Linear01Depth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
                }
                
                void Unity_Subtract_float(float A, float B, out float Out)
                {
                    Out = A - B;
                }
                
                void Unity_Clamp_float(float In, float Min, float Max, out float Out)
                {
                    Out = clamp(In, Min, Max);
                }
                
                void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
                {
                    Out = lerp(A, B, T);
                }
                
                void Unity_Distance_float3(float3 A, float3 B, out float Out)
                {
                    Out = distance(A, B);
                }
                
                void Unity_Sine_float(float In, out float Out)
                {
                    Out = sin(In);
                }
    
                // Graph Vertex
                struct VertexDescription
                {
                    float3 Position;
                    float3 Normal;
                    float3 Tangent;
                };
                
                VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                {
                    VertexDescription description = (VertexDescription)0;
                    description.Position = IN.ObjectSpacePosition;
                    description.Normal = IN.ObjectSpaceNormal;
                    description.Tangent = IN.ObjectSpaceTangent;
                    return description;
                }
    
                // Graph Pixel
                struct SurfaceDescription
                {
                    float3 NormalTS;
                    float Alpha;
                };
                
                SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                {
                    SurfaceDescription surface = (SurfaceDescription)0;
                    UnityTexture2D _Property_98dcadd153784e00b3d99c72c66a28b9_Out_0 = UnityBuildTexture2DStructNoScale(_ShallowNormal);
                    float2 _TilingAndOffset_e057885e86584dea86f94cfc76e1e048_Out_3;
                    Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), float2 (0, 0), _TilingAndOffset_e057885e86584dea86f94cfc76e1e048_Out_3);
                    float4 _SampleTexture2D_0121a928620142938ff635ec1ff89401_RGBA_0 = SAMPLE_TEXTURE2D(_Property_98dcadd153784e00b3d99c72c66a28b9_Out_0.tex, _Property_98dcadd153784e00b3d99c72c66a28b9_Out_0.samplerstate, _TilingAndOffset_e057885e86584dea86f94cfc76e1e048_Out_3);
                    _SampleTexture2D_0121a928620142938ff635ec1ff89401_RGBA_0.rgb = UnpackNormal(_SampleTexture2D_0121a928620142938ff635ec1ff89401_RGBA_0);
                    float _SampleTexture2D_0121a928620142938ff635ec1ff89401_R_4 = _SampleTexture2D_0121a928620142938ff635ec1ff89401_RGBA_0.r;
                    float _SampleTexture2D_0121a928620142938ff635ec1ff89401_G_5 = _SampleTexture2D_0121a928620142938ff635ec1ff89401_RGBA_0.g;
                    float _SampleTexture2D_0121a928620142938ff635ec1ff89401_B_6 = _SampleTexture2D_0121a928620142938ff635ec1ff89401_RGBA_0.b;
                    float _SampleTexture2D_0121a928620142938ff635ec1ff89401_A_7 = _SampleTexture2D_0121a928620142938ff635ec1ff89401_RGBA_0.a;
                    float _Property_c92104f8c9d245dbb796f54a2386b2fa_Out_0 = _IsOcean;
                    float2 _Property_0165785b858447e9be7aeae88e49b876_Out_0 = _Tiling;
                    float _Divide_40fd94b5668f4354bc4f097174879071_Out_2;
                    Unity_Divide_float(IN.TimeParameters.x, 25, _Divide_40fd94b5668f4354bc4f097174879071_Out_2);
                    float2 _TilingAndOffset_dd58a4e4d2f44f4692185d84f037be72_Out_3;
                    Unity_TilingAndOffset_float(IN.uv0.xy, _Property_0165785b858447e9be7aeae88e49b876_Out_0, (_Divide_40fd94b5668f4354bc4f097174879071_Out_2.xx), _TilingAndOffset_dd58a4e4d2f44f4692185d84f037be72_Out_3);
                    float _Property_dcf2fdcb8f824668b8a6e8c81f6e182d_Out_0 = _GradientNoise;
                    float _GradientNoise_2c52090e5ac5473ba4d45f48de31694f_Out_2;
                    Unity_GradientNoise_float(_TilingAndOffset_dd58a4e4d2f44f4692185d84f037be72_Out_3, _Property_dcf2fdcb8f824668b8a6e8c81f6e182d_Out_0, _GradientNoise_2c52090e5ac5473ba4d45f48de31694f_Out_2);
                    float _Remap_fe18556f20a1429782d5401a4e93f4ff_Out_3;
                    Unity_Remap_float(_GradientNoise_2c52090e5ac5473ba4d45f48de31694f_Out_2, float2 (0, 1), float2 (-1, 1), _Remap_fe18556f20a1429782d5401a4e93f4ff_Out_3);
                    UnityTexture2D _Property_1aa6808f044b4d20b816c793ef91056c_Out_0 = UnityBuildTexture2DStructNoScale(_OceanNormal1);
                    float2 _Property_6dc7633668bb4df38e93ccda13f0e850_Out_0 = _OceanSpeed;
                    float _Split_35918e73b31d4ab383b2221ebc8e73c7_R_1 = _Property_6dc7633668bb4df38e93ccda13f0e850_Out_0[0];
                    float _Split_35918e73b31d4ab383b2221ebc8e73c7_G_2 = _Property_6dc7633668bb4df38e93ccda13f0e850_Out_0[1];
                    float _Split_35918e73b31d4ab383b2221ebc8e73c7_B_3 = 0;
                    float _Split_35918e73b31d4ab383b2221ebc8e73c7_A_4 = 0;
                    float _Divide_320942700ecd49068a4d2fac0bbcd012_Out_2;
                    Unity_Divide_float(IN.TimeParameters.x, _Split_35918e73b31d4ab383b2221ebc8e73c7_R_1, _Divide_320942700ecd49068a4d2fac0bbcd012_Out_2);
                    float2 _TilingAndOffset_2c0d1a11da414db2972d2b0e6e6eead7_Out_3;
                    Unity_TilingAndOffset_float(IN.uv0.xy, _Property_0165785b858447e9be7aeae88e49b876_Out_0, (_Divide_320942700ecd49068a4d2fac0bbcd012_Out_2.xx), _TilingAndOffset_2c0d1a11da414db2972d2b0e6e6eead7_Out_3);
                    float4 _SampleTexture2D_95cbac09786f4d9f877a32a692103c63_RGBA_0 = SAMPLE_TEXTURE2D(_Property_1aa6808f044b4d20b816c793ef91056c_Out_0.tex, _Property_1aa6808f044b4d20b816c793ef91056c_Out_0.samplerstate, _TilingAndOffset_2c0d1a11da414db2972d2b0e6e6eead7_Out_3);
                    _SampleTexture2D_95cbac09786f4d9f877a32a692103c63_RGBA_0.rgb = UnpackNormal(_SampleTexture2D_95cbac09786f4d9f877a32a692103c63_RGBA_0);
                    float _SampleTexture2D_95cbac09786f4d9f877a32a692103c63_R_4 = _SampleTexture2D_95cbac09786f4d9f877a32a692103c63_RGBA_0.r;
                    float _SampleTexture2D_95cbac09786f4d9f877a32a692103c63_G_5 = _SampleTexture2D_95cbac09786f4d9f877a32a692103c63_RGBA_0.g;
                    float _SampleTexture2D_95cbac09786f4d9f877a32a692103c63_B_6 = _SampleTexture2D_95cbac09786f4d9f877a32a692103c63_RGBA_0.b;
                    float _SampleTexture2D_95cbac09786f4d9f877a32a692103c63_A_7 = _SampleTexture2D_95cbac09786f4d9f877a32a692103c63_RGBA_0.a;
                    UnityTexture2D _Property_fab5aef84b23441fbfd40281cf1ada82_Out_0 = UnityBuildTexture2DStructNoScale(_OceanNormal2);
                    float _Divide_dbf1715fe11a470fb42e9a29bb351a9d_Out_2;
                    Unity_Divide_float(IN.TimeParameters.x, _Split_35918e73b31d4ab383b2221ebc8e73c7_G_2, _Divide_dbf1715fe11a470fb42e9a29bb351a9d_Out_2);
                    float2 _TilingAndOffset_bc9854cad9a042cfb0ebc3bb5b4792e4_Out_3;
                    Unity_TilingAndOffset_float(IN.uv0.xy, _Property_0165785b858447e9be7aeae88e49b876_Out_0, (_Divide_dbf1715fe11a470fb42e9a29bb351a9d_Out_2.xx), _TilingAndOffset_bc9854cad9a042cfb0ebc3bb5b4792e4_Out_3);
                    float4 _SampleTexture2D_7f1b3f3ae5d243f9b432299bdc4f7b97_RGBA_0 = SAMPLE_TEXTURE2D(_Property_fab5aef84b23441fbfd40281cf1ada82_Out_0.tex, _Property_fab5aef84b23441fbfd40281cf1ada82_Out_0.samplerstate, _TilingAndOffset_bc9854cad9a042cfb0ebc3bb5b4792e4_Out_3);
                    _SampleTexture2D_7f1b3f3ae5d243f9b432299bdc4f7b97_RGBA_0.rgb = UnpackNormal(_SampleTexture2D_7f1b3f3ae5d243f9b432299bdc4f7b97_RGBA_0);
                    float _SampleTexture2D_7f1b3f3ae5d243f9b432299bdc4f7b97_R_4 = _SampleTexture2D_7f1b3f3ae5d243f9b432299bdc4f7b97_RGBA_0.r;
                    float _SampleTexture2D_7f1b3f3ae5d243f9b432299bdc4f7b97_G_5 = _SampleTexture2D_7f1b3f3ae5d243f9b432299bdc4f7b97_RGBA_0.g;
                    float _SampleTexture2D_7f1b3f3ae5d243f9b432299bdc4f7b97_B_6 = _SampleTexture2D_7f1b3f3ae5d243f9b432299bdc4f7b97_RGBA_0.b;
                    float _SampleTexture2D_7f1b3f3ae5d243f9b432299bdc4f7b97_A_7 = _SampleTexture2D_7f1b3f3ae5d243f9b432299bdc4f7b97_RGBA_0.a;
                    float4 _Add_3f6c04238c1f459eb8e6300b9eb1f842_Out_2;
                    Unity_Add_float4(_SampleTexture2D_95cbac09786f4d9f877a32a692103c63_RGBA_0, _SampleTexture2D_7f1b3f3ae5d243f9b432299bdc4f7b97_RGBA_0, _Add_3f6c04238c1f459eb8e6300b9eb1f842_Out_2);
                    float4 _Add_3e553e4abf784d7799c718cfe7d51b68_Out_2;
                    Unity_Add_float4((_Remap_fe18556f20a1429782d5401a4e93f4ff_Out_3.xxxx), _Add_3f6c04238c1f459eb8e6300b9eb1f842_Out_2, _Add_3e553e4abf784d7799c718cfe7d51b68_Out_2);
                    float3 _Normalize_415b503188e443458e4172309aa4cb18_Out_1;
                    Unity_Normalize_float3(IN.WorldSpaceNormal, _Normalize_415b503188e443458e4172309aa4cb18_Out_1);
                    float _DotProduct_b3f1b90b273a4b2b99f07acbc4565dcb_Out_2;
                    Unity_DotProduct_float3(float3(0, 1, 0), _Normalize_415b503188e443458e4172309aa4cb18_Out_1, _DotProduct_b3f1b90b273a4b2b99f07acbc4565dcb_Out_2);
                    float _Remap_669938a90f934b9bab86d586a6917aca_Out_3;
                    Unity_Remap_float(_DotProduct_b3f1b90b273a4b2b99f07acbc4565dcb_Out_2, float2 (-1, 1), float2 (0, 1), _Remap_669938a90f934b9bab86d586a6917aca_Out_3);
                    float _Comparison_8f4fb954760447e8b0db8924e20fd1d0_Out_2;
                    Unity_Comparison_Greater_float(_Remap_669938a90f934b9bab86d586a6917aca_Out_3, 0, _Comparison_8f4fb954760447e8b0db8924e20fd1d0_Out_2);
                    UnityTexture2D _Property_ab131e76fa9e4575850bad711d6bc112_Out_0 = UnityBuildTexture2DStructNoScale(_RiverNormal);
                    float3 _Normalize_62a13fd33141482da88d8a4f6cbbc589_Out_1;
                    Unity_Normalize_float3(IN.WorldSpaceNormal, _Normalize_62a13fd33141482da88d8a4f6cbbc589_Out_1);
                    float _Split_0d3686f12540443e91f7387b6f77c10d_R_1 = _Normalize_62a13fd33141482da88d8a4f6cbbc589_Out_1[0];
                    float _Split_0d3686f12540443e91f7387b6f77c10d_G_2 = _Normalize_62a13fd33141482da88d8a4f6cbbc589_Out_1[1];
                    float _Split_0d3686f12540443e91f7387b6f77c10d_B_3 = _Normalize_62a13fd33141482da88d8a4f6cbbc589_Out_1[2];
                    float _Split_0d3686f12540443e91f7387b6f77c10d_A_4 = 0;
                    float _Comparison_e88851318be2459db93159ca801db3b8_Out_2;
                    Unity_Comparison_Greater_float(_Split_0d3686f12540443e91f7387b6f77c10d_B_3, 0, _Comparison_e88851318be2459db93159ca801db3b8_Out_2);
                    float2 _Vector2_cd982aedb6df469f81c94d251afa4ef4_Out_0 = float2(_Split_0d3686f12540443e91f7387b6f77c10d_R_1, _Split_0d3686f12540443e91f7387b6f77c10d_B_3);
                    float2 _Normalize_029f1f95e8854efe8413e4f0e8266c57_Out_1;
                    Unity_Normalize_float2(_Vector2_cd982aedb6df469f81c94d251afa4ef4_Out_0, _Normalize_029f1f95e8854efe8413e4f0e8266c57_Out_1);
                    float _DotProduct_ebf7ce672ca34ebaaa92a71bef863e84_Out_2;
                    Unity_DotProduct_float2(float2(1, 0), _Normalize_029f1f95e8854efe8413e4f0e8266c57_Out_1, _DotProduct_ebf7ce672ca34ebaaa92a71bef863e84_Out_2);
                    float _Arccosine_4b874182f6a14874840ee7586e79f531_Out_1;
                    Unity_Arccosine_float(_DotProduct_ebf7ce672ca34ebaaa92a71bef863e84_Out_2, _Arccosine_4b874182f6a14874840ee7586e79f531_Out_1);
                    float _Multiply_2cb80113cd264bd684265987dfc99fdc_Out_2;
                    Unity_Multiply_float(_DotProduct_ebf7ce672ca34ebaaa92a71bef863e84_Out_2, -1, _Multiply_2cb80113cd264bd684265987dfc99fdc_Out_2);
                    float _Arccosine_4402c39ae97e427eb6a05c3ec6df8476_Out_1;
                    Unity_Arccosine_float(_Multiply_2cb80113cd264bd684265987dfc99fdc_Out_2, _Arccosine_4402c39ae97e427eb6a05c3ec6df8476_Out_1);
                    float Constant_2af68751986845ed87773c58bfc03190 = 3.141593;
                    float _Add_db22dd4581f6401c9b151c2d904fb1fd_Out_2;
                    Unity_Add_float(_Arccosine_4402c39ae97e427eb6a05c3ec6df8476_Out_1, Constant_2af68751986845ed87773c58bfc03190, _Add_db22dd4581f6401c9b151c2d904fb1fd_Out_2);
                    float _Branch_5fd995eba4cc4a4c8abe7fca6cd0c1c8_Out_3;
                    Unity_Branch_float(_Comparison_e88851318be2459db93159ca801db3b8_Out_2, _Arccosine_4b874182f6a14874840ee7586e79f531_Out_1, _Add_db22dd4581f6401c9b151c2d904fb1fd_Out_2, _Branch_5fd995eba4cc4a4c8abe7fca6cd0c1c8_Out_3);
                    float2 _Rotate_e2dc059678654897947c4905d958d640_Out_3;
                    Unity_Rotate_Radians_float(IN.uv0.xy, float2 (0.5, 0.5), _Branch_5fd995eba4cc4a4c8abe7fca6cd0c1c8_Out_3, _Rotate_e2dc059678654897947c4905d958d640_Out_3);
                    float2 _Property_409975023fe344e4969558e96ae8b3fe_Out_0 = _Tiling;
                    float _Property_fe8bd49591be4d8493cd9d1aef424249_Out_0 = _RiverSpeed;
                    float _Multiply_11dac49a52be47e2accb8b9de45dab52_Out_2;
                    Unity_Multiply_float(IN.TimeParameters.x, _Property_fe8bd49591be4d8493cd9d1aef424249_Out_0, _Multiply_11dac49a52be47e2accb8b9de45dab52_Out_2);
                    float _Lerp_8be4d289e2cb484489c128e89e81cbd7_Out_3;
                    Unity_Lerp_float(_Multiply_11dac49a52be47e2accb8b9de45dab52_Out_2, IN.TimeParameters.x, _Remap_669938a90f934b9bab86d586a6917aca_Out_3, _Lerp_8be4d289e2cb484489c128e89e81cbd7_Out_3);
                    float2 _Vector2_d7594f71adcb4015bc07aa3fac73b0cf_Out_0 = float2(_Lerp_8be4d289e2cb484489c128e89e81cbd7_Out_3, 0);
                    float2 _TilingAndOffset_5a892791744c4205818e4162cba3a833_Out_3;
                    Unity_TilingAndOffset_float(_Rotate_e2dc059678654897947c4905d958d640_Out_3, _Property_409975023fe344e4969558e96ae8b3fe_Out_0, _Vector2_d7594f71adcb4015bc07aa3fac73b0cf_Out_0, _TilingAndOffset_5a892791744c4205818e4162cba3a833_Out_3);
                    float _Property_61f2533f1f0f4b2e9a39165110a6d8cb_Out_0 = _RiverNormalRotAdjustment;
                    float2 _Rotate_f20c70501e6a4e1e946bb31f6bd852f4_Out_3;
                    Unity_Rotate_Degrees_float(_TilingAndOffset_5a892791744c4205818e4162cba3a833_Out_3, float2 (0.5, 0.5), _Property_61f2533f1f0f4b2e9a39165110a6d8cb_Out_0, _Rotate_f20c70501e6a4e1e946bb31f6bd852f4_Out_3);
                    float4 _SampleTexture2D_66835b651206479b8da548ce63cec2a2_RGBA_0 = SAMPLE_TEXTURE2D(_Property_ab131e76fa9e4575850bad711d6bc112_Out_0.tex, _Property_ab131e76fa9e4575850bad711d6bc112_Out_0.samplerstate, _Rotate_f20c70501e6a4e1e946bb31f6bd852f4_Out_3);
                    _SampleTexture2D_66835b651206479b8da548ce63cec2a2_RGBA_0.rgb = UnpackNormal(_SampleTexture2D_66835b651206479b8da548ce63cec2a2_RGBA_0);
                    float _SampleTexture2D_66835b651206479b8da548ce63cec2a2_R_4 = _SampleTexture2D_66835b651206479b8da548ce63cec2a2_RGBA_0.r;
                    float _SampleTexture2D_66835b651206479b8da548ce63cec2a2_G_5 = _SampleTexture2D_66835b651206479b8da548ce63cec2a2_RGBA_0.g;
                    float _SampleTexture2D_66835b651206479b8da548ce63cec2a2_B_6 = _SampleTexture2D_66835b651206479b8da548ce63cec2a2_RGBA_0.b;
                    float _SampleTexture2D_66835b651206479b8da548ce63cec2a2_A_7 = _SampleTexture2D_66835b651206479b8da548ce63cec2a2_RGBA_0.a;
                    UnityTexture2D _Property_3ac158951f79428685aa829dd82f0bc3_Out_0 = UnityBuildTexture2DStructNoScale(_LevelRiverNormal);
                    float2 _TilingAndOffset_5e717e1b97944a55bc66662a06d78ea7_Out_3;
                    Unity_TilingAndOffset_float(IN.uv0.xy, _Property_409975023fe344e4969558e96ae8b3fe_Out_0, float2 (0, 0), _TilingAndOffset_5e717e1b97944a55bc66662a06d78ea7_Out_3);
                    float4 _SampleTexture2D_e5aebb8d1445433bacf47e39067cb0a0_RGBA_0 = SAMPLE_TEXTURE2D(_Property_3ac158951f79428685aa829dd82f0bc3_Out_0.tex, _Property_3ac158951f79428685aa829dd82f0bc3_Out_0.samplerstate, _TilingAndOffset_5e717e1b97944a55bc66662a06d78ea7_Out_3);
                    _SampleTexture2D_e5aebb8d1445433bacf47e39067cb0a0_RGBA_0.rgb = UnpackNormal(_SampleTexture2D_e5aebb8d1445433bacf47e39067cb0a0_RGBA_0);
                    float _SampleTexture2D_e5aebb8d1445433bacf47e39067cb0a0_R_4 = _SampleTexture2D_e5aebb8d1445433bacf47e39067cb0a0_RGBA_0.r;
                    float _SampleTexture2D_e5aebb8d1445433bacf47e39067cb0a0_G_5 = _SampleTexture2D_e5aebb8d1445433bacf47e39067cb0a0_RGBA_0.g;
                    float _SampleTexture2D_e5aebb8d1445433bacf47e39067cb0a0_B_6 = _SampleTexture2D_e5aebb8d1445433bacf47e39067cb0a0_RGBA_0.b;
                    float _SampleTexture2D_e5aebb8d1445433bacf47e39067cb0a0_A_7 = _SampleTexture2D_e5aebb8d1445433bacf47e39067cb0a0_RGBA_0.a;
                    float4 _Branch_7d4a670ae12240ccbe8bdb249a237644_Out_3;
                    Unity_Branch_float4(_Comparison_8f4fb954760447e8b0db8924e20fd1d0_Out_2, _SampleTexture2D_66835b651206479b8da548ce63cec2a2_RGBA_0, _SampleTexture2D_e5aebb8d1445433bacf47e39067cb0a0_RGBA_0, _Branch_7d4a670ae12240ccbe8bdb249a237644_Out_3);
                    float4 _Branch_5225751f0aaf4e5885184101068828b5_Out_3;
                    Unity_Branch_float4(_Property_c92104f8c9d245dbb796f54a2386b2fa_Out_0, _Add_3e553e4abf784d7799c718cfe7d51b68_Out_2, _Branch_7d4a670ae12240ccbe8bdb249a237644_Out_3, _Branch_5225751f0aaf4e5885184101068828b5_Out_3);
                    float _SceneDepth_3137d738aa0149fb8a54d88a60826a60_Out_1;
                    Unity_SceneDepth_Linear01_float(float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0), _SceneDepth_3137d738aa0149fb8a54d88a60826a60_Out_1);
                    float _Multiply_8ec8e0a1878e494ca0d6d16678168741_Out_2;
                    Unity_Multiply_float(_SceneDepth_3137d738aa0149fb8a54d88a60826a60_Out_1, _ProjectionParams.z, _Multiply_8ec8e0a1878e494ca0d6d16678168741_Out_2);
                    float4 _ScreenPosition_3840c0fb20fc4eb58387cd54ee7e2b18_Out_0 = IN.ScreenPosition;
                    float _Split_578ef5cadaac40969c114c4d1ae870d8_R_1 = _ScreenPosition_3840c0fb20fc4eb58387cd54ee7e2b18_Out_0[0];
                    float _Split_578ef5cadaac40969c114c4d1ae870d8_G_2 = _ScreenPosition_3840c0fb20fc4eb58387cd54ee7e2b18_Out_0[1];
                    float _Split_578ef5cadaac40969c114c4d1ae870d8_B_3 = _ScreenPosition_3840c0fb20fc4eb58387cd54ee7e2b18_Out_0[2];
                    float _Split_578ef5cadaac40969c114c4d1ae870d8_A_4 = _ScreenPosition_3840c0fb20fc4eb58387cd54ee7e2b18_Out_0[3];
                    float _Property_cedd17331b16484abf1a4ce8eb0e5a72_Out_0 = _DepthOffset;
                    float _Add_e04e1bc3087745d898c282f10a0f43e3_Out_2;
                    Unity_Add_float(_Split_578ef5cadaac40969c114c4d1ae870d8_A_4, _Property_cedd17331b16484abf1a4ce8eb0e5a72_Out_0, _Add_e04e1bc3087745d898c282f10a0f43e3_Out_2);
                    float _Subtract_bd4ff2ba7ce04051b10b968b020d06df_Out_2;
                    Unity_Subtract_float(_Multiply_8ec8e0a1878e494ca0d6d16678168741_Out_2, _Add_e04e1bc3087745d898c282f10a0f43e3_Out_2, _Subtract_bd4ff2ba7ce04051b10b968b020d06df_Out_2);
                    float _Property_d328dfa89c674e67bffe73ef574a2d58_Out_0 = _Strength;
                    float _Multiply_4eb7822d949844e38f2bb60067662a47_Out_2;
                    Unity_Multiply_float(_Subtract_bd4ff2ba7ce04051b10b968b020d06df_Out_2, _Property_d328dfa89c674e67bffe73ef574a2d58_Out_0, _Multiply_4eb7822d949844e38f2bb60067662a47_Out_2);
                    float _Clamp_0f7ac1e483384940a0714a9e608d50b4_Out_3;
                    Unity_Clamp_float(_Multiply_4eb7822d949844e38f2bb60067662a47_Out_2, 0, 1, _Clamp_0f7ac1e483384940a0714a9e608d50b4_Out_3);
                    float4 _Lerp_b501d8723a3b46369b51759c91fb6f3c_Out_3;
                    Unity_Lerp_float4(_SampleTexture2D_0121a928620142938ff635ec1ff89401_RGBA_0, _Branch_5225751f0aaf4e5885184101068828b5_Out_3, (_Clamp_0f7ac1e483384940a0714a9e608d50b4_Out_3.xxxx), _Lerp_b501d8723a3b46369b51759c91fb6f3c_Out_3);
                    UnityTexture2D _Property_d6241559ab474e5782a32fe991893c23_Out_0 = UnityBuildTexture2DStructNoScale(_FarNormal);
                    float2 _TilingAndOffset_bdb4faaa2ebc4eb990d5202f25946a55_Out_3;
                    Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), float2 (0, 0), _TilingAndOffset_bdb4faaa2ebc4eb990d5202f25946a55_Out_3);
                    float4 _SampleTexture2D_4e9f3a96a6da4e8bac8f2aa7059e160c_RGBA_0 = SAMPLE_TEXTURE2D(_Property_d6241559ab474e5782a32fe991893c23_Out_0.tex, _Property_d6241559ab474e5782a32fe991893c23_Out_0.samplerstate, _TilingAndOffset_bdb4faaa2ebc4eb990d5202f25946a55_Out_3);
                    _SampleTexture2D_4e9f3a96a6da4e8bac8f2aa7059e160c_RGBA_0.rgb = UnpackNormal(_SampleTexture2D_4e9f3a96a6da4e8bac8f2aa7059e160c_RGBA_0);
                    float _SampleTexture2D_4e9f3a96a6da4e8bac8f2aa7059e160c_R_4 = _SampleTexture2D_4e9f3a96a6da4e8bac8f2aa7059e160c_RGBA_0.r;
                    float _SampleTexture2D_4e9f3a96a6da4e8bac8f2aa7059e160c_G_5 = _SampleTexture2D_4e9f3a96a6da4e8bac8f2aa7059e160c_RGBA_0.g;
                    float _SampleTexture2D_4e9f3a96a6da4e8bac8f2aa7059e160c_B_6 = _SampleTexture2D_4e9f3a96a6da4e8bac8f2aa7059e160c_RGBA_0.b;
                    float _SampleTexture2D_4e9f3a96a6da4e8bac8f2aa7059e160c_A_7 = _SampleTexture2D_4e9f3a96a6da4e8bac8f2aa7059e160c_RGBA_0.a;
                    float _Distance_44875152cc614e5ba9d5c699495f08ab_Out_2;
                    Unity_Distance_float3(IN.WorldSpacePosition, _WorldSpaceCameraPos, _Distance_44875152cc614e5ba9d5c699495f08ab_Out_2);
                    float _Property_aebc16f7283a467a8048e6bb509da7c6_Out_0 = _LODdistance;
                    float _Divide_32fb228b5d524f178b884f2adaa8e599_Out_2;
                    Unity_Divide_float(_Distance_44875152cc614e5ba9d5c699495f08ab_Out_2, _Property_aebc16f7283a467a8048e6bb509da7c6_Out_0, _Divide_32fb228b5d524f178b884f2adaa8e599_Out_2);
                    float4 _Lerp_2e0a60782cb64960ac783789c38969b5_Out_3;
                    Unity_Lerp_float4(_Lerp_b501d8723a3b46369b51759c91fb6f3c_Out_3, _SampleTexture2D_4e9f3a96a6da4e8bac8f2aa7059e160c_RGBA_0, (_Divide_32fb228b5d524f178b884f2adaa8e599_Out_2.xxxx), _Lerp_2e0a60782cb64960ac783789c38969b5_Out_3);
                    float4 _Property_231c0d262d3a466d85dfd53b116086ca_Out_0 = Color_701f2c2f40b34b87975a0e85a71325dc;
                    float _Property_90205b2f827548b295dc151171bc164c_Out_0 = _IsOcean;
                    float _Sine_24a173ac1d9d40b5b43bd7c8169386e4_Out_1;
                    Unity_Sine_float(IN.TimeParameters.x, _Sine_24a173ac1d9d40b5b43bd7c8169386e4_Out_1);
                    float _Remap_9ed3ea235fdc44d7a8c762cbe7ff6d0e_Out_3;
                    Unity_Remap_float(_Sine_24a173ac1d9d40b5b43bd7c8169386e4_Out_1, float2 (-1, 1), float2 (0.5, 1), _Remap_9ed3ea235fdc44d7a8c762cbe7ff6d0e_Out_3);
                    float _Branch_fcfcb84348fb4a5a90417124dc9ee3a2_Out_3;
                    Unity_Branch_float(_Property_90205b2f827548b295dc151171bc164c_Out_0, _Remap_9ed3ea235fdc44d7a8c762cbe7ff6d0e_Out_3, 1, _Branch_fcfcb84348fb4a5a90417124dc9ee3a2_Out_3);
                    float _Property_866bbbbe2a484e2eae1ad77ed223a577_Out_0 = _ShoreIntersectionStrength;
                    float _Multiply_cb7f54f30fb348b4a7f109f458e38b17_Out_2;
                    Unity_Multiply_float(_Branch_fcfcb84348fb4a5a90417124dc9ee3a2_Out_3, _Property_866bbbbe2a484e2eae1ad77ed223a577_Out_0, _Multiply_cb7f54f30fb348b4a7f109f458e38b17_Out_2);
                    float _Multiply_dcdae92bb4dd401a89df781ec062cecc_Out_2;
                    Unity_Multiply_float(_Subtract_bd4ff2ba7ce04051b10b968b020d06df_Out_2, _Multiply_cb7f54f30fb348b4a7f109f458e38b17_Out_2, _Multiply_dcdae92bb4dd401a89df781ec062cecc_Out_2);
                    float _Clamp_33ee6da80fc14439b6d7bab14be7ab07_Out_3;
                    Unity_Clamp_float(_Multiply_dcdae92bb4dd401a89df781ec062cecc_Out_2, 0.5, 1, _Clamp_33ee6da80fc14439b6d7bab14be7ab07_Out_3);
                    float4 _Lerp_f0669e92de0b409893955d23347ac238_Out_3;
                    Unity_Lerp_float4(_Property_231c0d262d3a466d85dfd53b116086ca_Out_0, float4(0, 0, 0, 0), (_Clamp_33ee6da80fc14439b6d7bab14be7ab07_Out_3.xxxx), _Lerp_f0669e92de0b409893955d23347ac238_Out_3);
                    float _Float_c4cf30aef9464dda83de90c7e790a9ba_Out_0 = 1.5;
                    float4 _Property_c854872c24e048c0aa372f0be547f07c_Out_0 = _ShallowWaterColor;
                    float4 _Property_dde44c4f61534e08a917dd16bcf5ebca_Out_0 = _DeepWaterColor;
                    float4 _Lerp_3f9225ad7cdc45509b625268ef70e29c_Out_3;
                    Unity_Lerp_float4(_Property_c854872c24e048c0aa372f0be547f07c_Out_0, _Property_dde44c4f61534e08a917dd16bcf5ebca_Out_0, (_Clamp_0f7ac1e483384940a0714a9e608d50b4_Out_3.xxxx), _Lerp_3f9225ad7cdc45509b625268ef70e29c_Out_3);
                    float4 _Lerp_4536ba8c658e4f11aaefc80660368304_Out_3;
                    Unity_Lerp_float4((_Float_c4cf30aef9464dda83de90c7e790a9ba_Out_0.xxxx), _Lerp_3f9225ad7cdc45509b625268ef70e29c_Out_3, (_Remap_669938a90f934b9bab86d586a6917aca_Out_3.xxxx), _Lerp_4536ba8c658e4f11aaefc80660368304_Out_3);
                    float4 _Add_f8fda8450f33454d96a6212c8ebfdc62_Out_2;
                    Unity_Add_float4(_Lerp_f0669e92de0b409893955d23347ac238_Out_3, _Lerp_4536ba8c658e4f11aaefc80660368304_Out_3, _Add_f8fda8450f33454d96a6212c8ebfdc62_Out_2);
                    float _Split_17c957ee33bc4e28a994b8b8dd20a89f_R_1 = _Add_f8fda8450f33454d96a6212c8ebfdc62_Out_2[0];
                    float _Split_17c957ee33bc4e28a994b8b8dd20a89f_G_2 = _Add_f8fda8450f33454d96a6212c8ebfdc62_Out_2[1];
                    float _Split_17c957ee33bc4e28a994b8b8dd20a89f_B_3 = _Add_f8fda8450f33454d96a6212c8ebfdc62_Out_2[2];
                    float _Split_17c957ee33bc4e28a994b8b8dd20a89f_A_4 = _Add_f8fda8450f33454d96a6212c8ebfdc62_Out_2[3];
                    float _DotProduct_fb1cbb38204242edbadb0a15bc95b04e_Out_2;
                    Unity_DotProduct_float3(-1 * mul((float3x3)UNITY_MATRIX_M, transpose(mul(UNITY_MATRIX_I_M, UNITY_MATRIX_I_V)) [2].xyz), IN.WorldSpaceNormal, _DotProduct_fb1cbb38204242edbadb0a15bc95b04e_Out_2);
                    float _Remap_bde541d934954ce5b99314edcbcd70e5_Out_3;
                    Unity_Remap_float(_DotProduct_fb1cbb38204242edbadb0a15bc95b04e_Out_2, float2 (-1, 0), float2 (0, 1), _Remap_bde541d934954ce5b99314edcbcd70e5_Out_3);
                    float _Multiply_6330a2a6c69948a5aacc174b9da1d2f0_Out_2;
                    Unity_Multiply_float(_Split_17c957ee33bc4e28a994b8b8dd20a89f_A_4, _Remap_bde541d934954ce5b99314edcbcd70e5_Out_3, _Multiply_6330a2a6c69948a5aacc174b9da1d2f0_Out_2);
                    float _Property_bc84cef440384b15875875c65e907453_Out_0 = _DownAlphaStrength;
                    float _Property_f604cf40fc3249839fb755ab1c9d8eb2_Out_0 = _TranceparencyStrength;
                    float _Multiply_c4a5b4f21dfe45d2a2f78cc50eba3ec8_Out_2;
                    Unity_Multiply_float(_Subtract_bd4ff2ba7ce04051b10b968b020d06df_Out_2, _Property_f604cf40fc3249839fb755ab1c9d8eb2_Out_0, _Multiply_c4a5b4f21dfe45d2a2f78cc50eba3ec8_Out_2);
                    float _Clamp_61028b06dbf14a6092a617f0d8a7ac32_Out_3;
                    Unity_Clamp_float(_Multiply_c4a5b4f21dfe45d2a2f78cc50eba3ec8_Out_2, 0, 1, _Clamp_61028b06dbf14a6092a617f0d8a7ac32_Out_3);
                    float _Lerp_106a757383d0403399452dcbb99cc72a_Out_3;
                    Unity_Lerp_float(_Property_bc84cef440384b15875875c65e907453_Out_0, 0, _Clamp_61028b06dbf14a6092a617f0d8a7ac32_Out_3, _Lerp_106a757383d0403399452dcbb99cc72a_Out_3);
                    float _Lerp_729c45b3c3014bdbb92bb4198e06bd92_Out_3;
                    Unity_Lerp_float(1, 0, _Remap_bde541d934954ce5b99314edcbcd70e5_Out_3, _Lerp_729c45b3c3014bdbb92bb4198e06bd92_Out_3);
                    float _Multiply_a80cb3307cd746d7a1bb5f699c9423f3_Out_2;
                    Unity_Multiply_float(_Lerp_106a757383d0403399452dcbb99cc72a_Out_3, _Lerp_729c45b3c3014bdbb92bb4198e06bd92_Out_3, _Multiply_a80cb3307cd746d7a1bb5f699c9423f3_Out_2);
                    float _Lerp_b12dda477cf14695add7f2de406dd644_Out_3;
                    Unity_Lerp_float(_Split_17c957ee33bc4e28a994b8b8dd20a89f_A_4, _Multiply_6330a2a6c69948a5aacc174b9da1d2f0_Out_2, _Multiply_a80cb3307cd746d7a1bb5f699c9423f3_Out_2, _Lerp_b12dda477cf14695add7f2de406dd644_Out_3);
                    surface.NormalTS = (_Lerp_2e0a60782cb64960ac783789c38969b5_Out_3.xyz);
                    surface.Alpha = _Lerp_b12dda477cf14695add7f2de406dd644_Out_3;
                    return surface;
                }
    
                // --------------------------------------------------
                // Build Graph Inputs
    
                VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                {
                    VertexDescriptionInputs output;
                    ZERO_INITIALIZE(VertexDescriptionInputs, output);
                
                    output.ObjectSpaceNormal =           input.normalOS;
                    output.ObjectSpaceTangent =          input.tangentOS.xyz;
                    output.ObjectSpacePosition =         input.positionOS;
                
                    return output;
                }
                
                SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                {
                    SurfaceDescriptionInputs output;
                    ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
                
                	// must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
                	float3 unnormalizedNormalWS = input.normalWS;
                    const float renormFactor = 1.0 / length(unnormalizedNormalWS);
                
                
                    output.WorldSpaceNormal =            renormFactor*input.normalWS.xyz;		// we want a unit length Normal Vector node in shader graph
                    output.TangentSpaceNormal =          float3(0.0f, 0.0f, 1.0f);
                
                
                    output.WorldSpacePosition =          input.positionWS;
                    output.ScreenPosition =              ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
                    output.uv0 =                         input.texCoord0;
                    output.TimeParameters =              _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                #else
                #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                #endif
                #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                
                    return output;
                }
                
    
                // --------------------------------------------------
                // Main
    
                #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DepthNormalsOnlyPass.hlsl"
    
                ENDHLSL
            }
            Pass
            {
                Name "Meta"
                Tags
                {
                    "LightMode" = "Meta"
                }
    
                // Render State
                Cull Off
    
                // Debug
                // <None>
    
                // --------------------------------------------------
                // Pass
    
                HLSLPROGRAM
    
                // Pragmas
                #pragma target 4.5
                #pragma exclude_renderers gles gles3 glcore
                #pragma vertex vert
                #pragma fragment frag
    
                // DotsInstancingOptions: <None>
                // HybridV1InjectedBuiltinProperties: <None>
    
                // Keywords
                #pragma shader_feature _ _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A
                // GraphKeywords: <None>
    
                // Defines
                #define _SURFACE_TYPE_TRANSPARENT 1
                #define _NORMALMAP 1
                #define _NORMAL_DROPOFF_TS 1
                #define ATTRIBUTES_NEED_NORMAL
                #define ATTRIBUTES_NEED_TANGENT
                #define ATTRIBUTES_NEED_TEXCOORD1
                #define ATTRIBUTES_NEED_TEXCOORD2
                #define VARYINGS_NEED_POSITION_WS
                #define VARYINGS_NEED_NORMAL_WS
                #define FEATURES_GRAPH_VERTEX
                /* WARNING: $splice Could not find named fragment 'PassInstancing' */
                #define SHADERPASS SHADERPASS_META
                #define REQUIRE_DEPTH_TEXTURE
                /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
    
                // Includes
                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/MetaInput.hlsl"
    
                // --------------------------------------------------
                // Structs and Packing
    
                struct Attributes
                {
                    float3 positionOS : POSITION;
                    float3 normalOS : NORMAL;
                    float4 tangentOS : TANGENT;
                    float4 uv1 : TEXCOORD1;
                    float4 uv2 : TEXCOORD2;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    uint instanceID : INSTANCEID_SEMANTIC;
                    #endif
                };
                struct Varyings
                {
                    float4 positionCS : SV_POSITION;
                    float3 positionWS;
                    float3 normalWS;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    uint instanceID : CUSTOM_INSTANCE_ID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                    #endif
                };
                struct SurfaceDescriptionInputs
                {
                    float3 WorldSpaceNormal;
                    float3 WorldSpacePosition;
                    float4 ScreenPosition;
                    float3 TimeParameters;
                };
                struct VertexDescriptionInputs
                {
                    float3 ObjectSpaceNormal;
                    float3 ObjectSpaceTangent;
                    float3 ObjectSpacePosition;
                };
                struct PackedVaryings
                {
                    float4 positionCS : SV_POSITION;
                    float3 interp0 : TEXCOORD0;
                    float3 interp1 : TEXCOORD1;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    uint instanceID : CUSTOM_INSTANCE_ID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                    #endif
                };
    
                PackedVaryings PackVaryings (Varyings input)
                {
                    PackedVaryings output;
                    output.positionCS = input.positionCS;
                    output.interp0.xyz =  input.positionWS;
                    output.interp1.xyz =  input.normalWS;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    output.instanceID = input.instanceID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    output.cullFace = input.cullFace;
                    #endif
                    return output;
                }
                Varyings UnpackVaryings (PackedVaryings input)
                {
                    Varyings output;
                    output.positionCS = input.positionCS;
                    output.positionWS = input.interp0.xyz;
                    output.normalWS = input.interp1.xyz;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    output.instanceID = input.instanceID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    output.cullFace = input.cullFace;
                    #endif
                    return output;
                }
    
                // --------------------------------------------------
                // Graph
    
                // Graph Properties
                CBUFFER_START(UnityPerMaterial)
                float _DepthOffset;
                float _Strength;
                float4 _DeepWaterColor;
                float4 _ShallowWaterColor;
                float _Metallic;
                float2 _Tiling;
                float4 _OceanNormal2_TexelSize;
                float4 _OceanNormal1_TexelSize;
                float _GradientNoise;
                float2 _OceanSpeed;
                float _LODdistance;
                float4 _FarNormal_TexelSize;
                float4 _ShallowNormal_TexelSize;
                float _TranceparencyStrength;
                float _DownAlphaStrength;
                float _IsOcean;
                float4 _RiverNormal_TexelSize;
                float _RiverNormalRotAdjustment;
                float4 _LevelRiverNormal_TexelSize;
                float _RiverSpeed;
                float _ShoreIntersectionStrength;
                float4 Color_701f2c2f40b34b87975a0e85a71325dc;
                CBUFFER_END
                
                // Object and Global properties
                SAMPLER(SamplerState_Linear_Repeat);
                TEXTURE2D(_OceanNormal2);
                SAMPLER(sampler_OceanNormal2);
                TEXTURE2D(_OceanNormal1);
                SAMPLER(sampler_OceanNormal1);
                TEXTURE2D(_FarNormal);
                SAMPLER(sampler_FarNormal);
                TEXTURE2D(_ShallowNormal);
                SAMPLER(sampler_ShallowNormal);
                TEXTURE2D(_RiverNormal);
                SAMPLER(sampler_RiverNormal);
                TEXTURE2D(_LevelRiverNormal);
                SAMPLER(sampler_LevelRiverNormal);
                float _StretchScalar;
    
                // Graph Functions
                
                void Unity_SceneDepth_Linear01_float(float4 UV, out float Out)
                {
                    Out = Linear01Depth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
                }
                
                void Unity_Multiply_float(float A, float B, out float Out)
                {
                    Out = A * B;
                }
                
                void Unity_Add_float(float A, float B, out float Out)
                {
                    Out = A + B;
                }
                
                void Unity_Subtract_float(float A, float B, out float Out)
                {
                    Out = A - B;
                }
                
                void Unity_Sine_float(float In, out float Out)
                {
                    Out = sin(In);
                }
                
                void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
                {
                    Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
                }
                
                void Unity_Branch_float(float Predicate, float True, float False, out float Out)
                {
                    Out = Predicate ? True : False;
                }
                
                void Unity_Clamp_float(float In, float Min, float Max, out float Out)
                {
                    Out = clamp(In, Min, Max);
                }
                
                void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
                {
                    Out = lerp(A, B, T);
                }
                
                void Unity_Normalize_float3(float3 In, out float3 Out)
                {
                    Out = normalize(In);
                }
                
                void Unity_DotProduct_float3(float3 A, float3 B, out float Out)
                {
                    Out = dot(A, B);
                }
                
                void Unity_Add_float4(float4 A, float4 B, out float4 Out)
                {
                    Out = A + B;
                }
                
                void Unity_Lerp_float(float A, float B, float T, out float Out)
                {
                    Out = lerp(A, B, T);
                }
    
                // Graph Vertex
                struct VertexDescription
                {
                    float3 Position;
                    float3 Normal;
                    float3 Tangent;
                };
                
                VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                {
                    VertexDescription description = (VertexDescription)0;
                    description.Position = IN.ObjectSpacePosition;
                    description.Normal = IN.ObjectSpaceNormal;
                    description.Tangent = IN.ObjectSpaceTangent;
                    return description;
                }
    
                // Graph Pixel
                struct SurfaceDescription
                {
                    float3 BaseColor;
                    float3 Emission;
                    float Alpha;
                };
                
                SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                {
                    SurfaceDescription surface = (SurfaceDescription)0;
                    float4 _Property_231c0d262d3a466d85dfd53b116086ca_Out_0 = Color_701f2c2f40b34b87975a0e85a71325dc;
                    float _SceneDepth_3137d738aa0149fb8a54d88a60826a60_Out_1;
                    Unity_SceneDepth_Linear01_float(float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0), _SceneDepth_3137d738aa0149fb8a54d88a60826a60_Out_1);
                    float _Multiply_8ec8e0a1878e494ca0d6d16678168741_Out_2;
                    Unity_Multiply_float(_SceneDepth_3137d738aa0149fb8a54d88a60826a60_Out_1, _ProjectionParams.z, _Multiply_8ec8e0a1878e494ca0d6d16678168741_Out_2);
                    float4 _ScreenPosition_3840c0fb20fc4eb58387cd54ee7e2b18_Out_0 = IN.ScreenPosition;
                    float _Split_578ef5cadaac40969c114c4d1ae870d8_R_1 = _ScreenPosition_3840c0fb20fc4eb58387cd54ee7e2b18_Out_0[0];
                    float _Split_578ef5cadaac40969c114c4d1ae870d8_G_2 = _ScreenPosition_3840c0fb20fc4eb58387cd54ee7e2b18_Out_0[1];
                    float _Split_578ef5cadaac40969c114c4d1ae870d8_B_3 = _ScreenPosition_3840c0fb20fc4eb58387cd54ee7e2b18_Out_0[2];
                    float _Split_578ef5cadaac40969c114c4d1ae870d8_A_4 = _ScreenPosition_3840c0fb20fc4eb58387cd54ee7e2b18_Out_0[3];
                    float _Property_cedd17331b16484abf1a4ce8eb0e5a72_Out_0 = _DepthOffset;
                    float _Add_e04e1bc3087745d898c282f10a0f43e3_Out_2;
                    Unity_Add_float(_Split_578ef5cadaac40969c114c4d1ae870d8_A_4, _Property_cedd17331b16484abf1a4ce8eb0e5a72_Out_0, _Add_e04e1bc3087745d898c282f10a0f43e3_Out_2);
                    float _Subtract_bd4ff2ba7ce04051b10b968b020d06df_Out_2;
                    Unity_Subtract_float(_Multiply_8ec8e0a1878e494ca0d6d16678168741_Out_2, _Add_e04e1bc3087745d898c282f10a0f43e3_Out_2, _Subtract_bd4ff2ba7ce04051b10b968b020d06df_Out_2);
                    float _Property_90205b2f827548b295dc151171bc164c_Out_0 = _IsOcean;
                    float _Sine_24a173ac1d9d40b5b43bd7c8169386e4_Out_1;
                    Unity_Sine_float(IN.TimeParameters.x, _Sine_24a173ac1d9d40b5b43bd7c8169386e4_Out_1);
                    float _Remap_9ed3ea235fdc44d7a8c762cbe7ff6d0e_Out_3;
                    Unity_Remap_float(_Sine_24a173ac1d9d40b5b43bd7c8169386e4_Out_1, float2 (-1, 1), float2 (0.5, 1), _Remap_9ed3ea235fdc44d7a8c762cbe7ff6d0e_Out_3);
                    float _Branch_fcfcb84348fb4a5a90417124dc9ee3a2_Out_3;
                    Unity_Branch_float(_Property_90205b2f827548b295dc151171bc164c_Out_0, _Remap_9ed3ea235fdc44d7a8c762cbe7ff6d0e_Out_3, 1, _Branch_fcfcb84348fb4a5a90417124dc9ee3a2_Out_3);
                    float _Property_866bbbbe2a484e2eae1ad77ed223a577_Out_0 = _ShoreIntersectionStrength;
                    float _Multiply_cb7f54f30fb348b4a7f109f458e38b17_Out_2;
                    Unity_Multiply_float(_Branch_fcfcb84348fb4a5a90417124dc9ee3a2_Out_3, _Property_866bbbbe2a484e2eae1ad77ed223a577_Out_0, _Multiply_cb7f54f30fb348b4a7f109f458e38b17_Out_2);
                    float _Multiply_dcdae92bb4dd401a89df781ec062cecc_Out_2;
                    Unity_Multiply_float(_Subtract_bd4ff2ba7ce04051b10b968b020d06df_Out_2, _Multiply_cb7f54f30fb348b4a7f109f458e38b17_Out_2, _Multiply_dcdae92bb4dd401a89df781ec062cecc_Out_2);
                    float _Clamp_33ee6da80fc14439b6d7bab14be7ab07_Out_3;
                    Unity_Clamp_float(_Multiply_dcdae92bb4dd401a89df781ec062cecc_Out_2, 0.5, 1, _Clamp_33ee6da80fc14439b6d7bab14be7ab07_Out_3);
                    float4 _Lerp_f0669e92de0b409893955d23347ac238_Out_3;
                    Unity_Lerp_float4(_Property_231c0d262d3a466d85dfd53b116086ca_Out_0, float4(0, 0, 0, 0), (_Clamp_33ee6da80fc14439b6d7bab14be7ab07_Out_3.xxxx), _Lerp_f0669e92de0b409893955d23347ac238_Out_3);
                    float _Float_c4cf30aef9464dda83de90c7e790a9ba_Out_0 = 1.5;
                    float4 _Property_c854872c24e048c0aa372f0be547f07c_Out_0 = _ShallowWaterColor;
                    float4 _Property_dde44c4f61534e08a917dd16bcf5ebca_Out_0 = _DeepWaterColor;
                    float _Property_d328dfa89c674e67bffe73ef574a2d58_Out_0 = _Strength;
                    float _Multiply_4eb7822d949844e38f2bb60067662a47_Out_2;
                    Unity_Multiply_float(_Subtract_bd4ff2ba7ce04051b10b968b020d06df_Out_2, _Property_d328dfa89c674e67bffe73ef574a2d58_Out_0, _Multiply_4eb7822d949844e38f2bb60067662a47_Out_2);
                    float _Clamp_0f7ac1e483384940a0714a9e608d50b4_Out_3;
                    Unity_Clamp_float(_Multiply_4eb7822d949844e38f2bb60067662a47_Out_2, 0, 1, _Clamp_0f7ac1e483384940a0714a9e608d50b4_Out_3);
                    float4 _Lerp_3f9225ad7cdc45509b625268ef70e29c_Out_3;
                    Unity_Lerp_float4(_Property_c854872c24e048c0aa372f0be547f07c_Out_0, _Property_dde44c4f61534e08a917dd16bcf5ebca_Out_0, (_Clamp_0f7ac1e483384940a0714a9e608d50b4_Out_3.xxxx), _Lerp_3f9225ad7cdc45509b625268ef70e29c_Out_3);
                    float3 _Normalize_415b503188e443458e4172309aa4cb18_Out_1;
                    Unity_Normalize_float3(IN.WorldSpaceNormal, _Normalize_415b503188e443458e4172309aa4cb18_Out_1);
                    float _DotProduct_b3f1b90b273a4b2b99f07acbc4565dcb_Out_2;
                    Unity_DotProduct_float3(float3(0, 1, 0), _Normalize_415b503188e443458e4172309aa4cb18_Out_1, _DotProduct_b3f1b90b273a4b2b99f07acbc4565dcb_Out_2);
                    float _Remap_669938a90f934b9bab86d586a6917aca_Out_3;
                    Unity_Remap_float(_DotProduct_b3f1b90b273a4b2b99f07acbc4565dcb_Out_2, float2 (-1, 1), float2 (0, 1), _Remap_669938a90f934b9bab86d586a6917aca_Out_3);
                    float4 _Lerp_4536ba8c658e4f11aaefc80660368304_Out_3;
                    Unity_Lerp_float4((_Float_c4cf30aef9464dda83de90c7e790a9ba_Out_0.xxxx), _Lerp_3f9225ad7cdc45509b625268ef70e29c_Out_3, (_Remap_669938a90f934b9bab86d586a6917aca_Out_3.xxxx), _Lerp_4536ba8c658e4f11aaefc80660368304_Out_3);
                    float4 _Add_f8fda8450f33454d96a6212c8ebfdc62_Out_2;
                    Unity_Add_float4(_Lerp_f0669e92de0b409893955d23347ac238_Out_3, _Lerp_4536ba8c658e4f11aaefc80660368304_Out_3, _Add_f8fda8450f33454d96a6212c8ebfdc62_Out_2);
                    float _Split_17c957ee33bc4e28a994b8b8dd20a89f_R_1 = _Add_f8fda8450f33454d96a6212c8ebfdc62_Out_2[0];
                    float _Split_17c957ee33bc4e28a994b8b8dd20a89f_G_2 = _Add_f8fda8450f33454d96a6212c8ebfdc62_Out_2[1];
                    float _Split_17c957ee33bc4e28a994b8b8dd20a89f_B_3 = _Add_f8fda8450f33454d96a6212c8ebfdc62_Out_2[2];
                    float _Split_17c957ee33bc4e28a994b8b8dd20a89f_A_4 = _Add_f8fda8450f33454d96a6212c8ebfdc62_Out_2[3];
                    float3 _Vector3_3b779f158e6f4ba8ac091e620cd4bd1c_Out_0 = float3(_Split_17c957ee33bc4e28a994b8b8dd20a89f_R_1, _Split_17c957ee33bc4e28a994b8b8dd20a89f_G_2, _Split_17c957ee33bc4e28a994b8b8dd20a89f_B_3);
                    float _DotProduct_fb1cbb38204242edbadb0a15bc95b04e_Out_2;
                    Unity_DotProduct_float3(-1 * mul((float3x3)UNITY_MATRIX_M, transpose(mul(UNITY_MATRIX_I_M, UNITY_MATRIX_I_V)) [2].xyz), IN.WorldSpaceNormal, _DotProduct_fb1cbb38204242edbadb0a15bc95b04e_Out_2);
                    float _Remap_bde541d934954ce5b99314edcbcd70e5_Out_3;
                    Unity_Remap_float(_DotProduct_fb1cbb38204242edbadb0a15bc95b04e_Out_2, float2 (-1, 0), float2 (0, 1), _Remap_bde541d934954ce5b99314edcbcd70e5_Out_3);
                    float _Multiply_6330a2a6c69948a5aacc174b9da1d2f0_Out_2;
                    Unity_Multiply_float(_Split_17c957ee33bc4e28a994b8b8dd20a89f_A_4, _Remap_bde541d934954ce5b99314edcbcd70e5_Out_3, _Multiply_6330a2a6c69948a5aacc174b9da1d2f0_Out_2);
                    float _Property_bc84cef440384b15875875c65e907453_Out_0 = _DownAlphaStrength;
                    float _Property_f604cf40fc3249839fb755ab1c9d8eb2_Out_0 = _TranceparencyStrength;
                    float _Multiply_c4a5b4f21dfe45d2a2f78cc50eba3ec8_Out_2;
                    Unity_Multiply_float(_Subtract_bd4ff2ba7ce04051b10b968b020d06df_Out_2, _Property_f604cf40fc3249839fb755ab1c9d8eb2_Out_0, _Multiply_c4a5b4f21dfe45d2a2f78cc50eba3ec8_Out_2);
                    float _Clamp_61028b06dbf14a6092a617f0d8a7ac32_Out_3;
                    Unity_Clamp_float(_Multiply_c4a5b4f21dfe45d2a2f78cc50eba3ec8_Out_2, 0, 1, _Clamp_61028b06dbf14a6092a617f0d8a7ac32_Out_3);
                    float _Lerp_106a757383d0403399452dcbb99cc72a_Out_3;
                    Unity_Lerp_float(_Property_bc84cef440384b15875875c65e907453_Out_0, 0, _Clamp_61028b06dbf14a6092a617f0d8a7ac32_Out_3, _Lerp_106a757383d0403399452dcbb99cc72a_Out_3);
                    float _Lerp_729c45b3c3014bdbb92bb4198e06bd92_Out_3;
                    Unity_Lerp_float(1, 0, _Remap_bde541d934954ce5b99314edcbcd70e5_Out_3, _Lerp_729c45b3c3014bdbb92bb4198e06bd92_Out_3);
                    float _Multiply_a80cb3307cd746d7a1bb5f699c9423f3_Out_2;
                    Unity_Multiply_float(_Lerp_106a757383d0403399452dcbb99cc72a_Out_3, _Lerp_729c45b3c3014bdbb92bb4198e06bd92_Out_3, _Multiply_a80cb3307cd746d7a1bb5f699c9423f3_Out_2);
                    float _Lerp_b12dda477cf14695add7f2de406dd644_Out_3;
                    Unity_Lerp_float(_Split_17c957ee33bc4e28a994b8b8dd20a89f_A_4, _Multiply_6330a2a6c69948a5aacc174b9da1d2f0_Out_2, _Multiply_a80cb3307cd746d7a1bb5f699c9423f3_Out_2, _Lerp_b12dda477cf14695add7f2de406dd644_Out_3);
                    surface.BaseColor = _Vector3_3b779f158e6f4ba8ac091e620cd4bd1c_Out_0;
                    surface.Emission = float3(0, 0, 0);
                    surface.Alpha = _Lerp_b12dda477cf14695add7f2de406dd644_Out_3;
                    return surface;
                }
    
                // --------------------------------------------------
                // Build Graph Inputs
    
                VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                {
                    VertexDescriptionInputs output;
                    ZERO_INITIALIZE(VertexDescriptionInputs, output);
                
                    output.ObjectSpaceNormal =           input.normalOS;
                    output.ObjectSpaceTangent =          input.tangentOS.xyz;
                    output.ObjectSpacePosition =         input.positionOS;
                
                    return output;
                }
                
                SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                {
                    SurfaceDescriptionInputs output;
                    ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
                
                	// must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
                	float3 unnormalizedNormalWS = input.normalWS;
                    const float renormFactor = 1.0 / length(unnormalizedNormalWS);
                
                
                    output.WorldSpaceNormal =            renormFactor*input.normalWS.xyz;		// we want a unit length Normal Vector node in shader graph
                
                
                    output.WorldSpacePosition =          input.positionWS;
                    output.ScreenPosition =              ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
                    output.TimeParameters =              _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                #else
                #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                #endif
                #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                
                    return output;
                }
                
    
                // --------------------------------------------------
                // Main
    
                #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/LightingMetaPass.hlsl"
    
                ENDHLSL
            }
            Pass
            {
                // Name: <None>
                Tags
                {
                    "LightMode" = "Universal2D"
                }
    
                // Render State
                Cull Off
                Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
                ZTest LEqual
                ZWrite Off
    
                // Debug
                // <None>
    
                // --------------------------------------------------
                // Pass
    
                HLSLPROGRAM
    
                // Pragmas
                #pragma target 4.5
                #pragma exclude_renderers gles gles3 glcore
                #pragma vertex vert
                #pragma fragment frag
    
                // DotsInstancingOptions: <None>
                // HybridV1InjectedBuiltinProperties: <None>
    
                // Keywords
                // PassKeywords: <None>
                // GraphKeywords: <None>
    
                // Defines
                #define _SURFACE_TYPE_TRANSPARENT 1
                #define _NORMALMAP 1
                #define _NORMAL_DROPOFF_TS 1
                #define ATTRIBUTES_NEED_NORMAL
                #define ATTRIBUTES_NEED_TANGENT
                #define VARYINGS_NEED_POSITION_WS
                #define VARYINGS_NEED_NORMAL_WS
                #define FEATURES_GRAPH_VERTEX
                /* WARNING: $splice Could not find named fragment 'PassInstancing' */
                #define SHADERPASS SHADERPASS_2D
                #define REQUIRE_DEPTH_TEXTURE
                /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
    
                // Includes
                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
    
                // --------------------------------------------------
                // Structs and Packing
    
                struct Attributes
                {
                    float3 positionOS : POSITION;
                    float3 normalOS : NORMAL;
                    float4 tangentOS : TANGENT;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    uint instanceID : INSTANCEID_SEMANTIC;
                    #endif
                };
                struct Varyings
                {
                    float4 positionCS : SV_POSITION;
                    float3 positionWS;
                    float3 normalWS;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    uint instanceID : CUSTOM_INSTANCE_ID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                    #endif
                };
                struct SurfaceDescriptionInputs
                {
                    float3 WorldSpaceNormal;
                    float3 WorldSpacePosition;
                    float4 ScreenPosition;
                    float3 TimeParameters;
                };
                struct VertexDescriptionInputs
                {
                    float3 ObjectSpaceNormal;
                    float3 ObjectSpaceTangent;
                    float3 ObjectSpacePosition;
                };
                struct PackedVaryings
                {
                    float4 positionCS : SV_POSITION;
                    float3 interp0 : TEXCOORD0;
                    float3 interp1 : TEXCOORD1;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    uint instanceID : CUSTOM_INSTANCE_ID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                    #endif
                };
    
                PackedVaryings PackVaryings (Varyings input)
                {
                    PackedVaryings output;
                    output.positionCS = input.positionCS;
                    output.interp0.xyz =  input.positionWS;
                    output.interp1.xyz =  input.normalWS;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    output.instanceID = input.instanceID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    output.cullFace = input.cullFace;
                    #endif
                    return output;
                }
                Varyings UnpackVaryings (PackedVaryings input)
                {
                    Varyings output;
                    output.positionCS = input.positionCS;
                    output.positionWS = input.interp0.xyz;
                    output.normalWS = input.interp1.xyz;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    output.instanceID = input.instanceID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    output.cullFace = input.cullFace;
                    #endif
                    return output;
                }
    
                // --------------------------------------------------
                // Graph
    
                // Graph Properties
                CBUFFER_START(UnityPerMaterial)
                float _DepthOffset;
                float _Strength;
                float4 _DeepWaterColor;
                float4 _ShallowWaterColor;
                float _Metallic;
                float2 _Tiling;
                float4 _OceanNormal2_TexelSize;
                float4 _OceanNormal1_TexelSize;
                float _GradientNoise;
                float2 _OceanSpeed;
                float _LODdistance;
                float4 _FarNormal_TexelSize;
                float4 _ShallowNormal_TexelSize;
                float _TranceparencyStrength;
                float _DownAlphaStrength;
                float _IsOcean;
                float4 _RiverNormal_TexelSize;
                float _RiverNormalRotAdjustment;
                float4 _LevelRiverNormal_TexelSize;
                float _RiverSpeed;
                float _ShoreIntersectionStrength;
                float4 Color_701f2c2f40b34b87975a0e85a71325dc;
                CBUFFER_END
                
                // Object and Global properties
                SAMPLER(SamplerState_Linear_Repeat);
                TEXTURE2D(_OceanNormal2);
                SAMPLER(sampler_OceanNormal2);
                TEXTURE2D(_OceanNormal1);
                SAMPLER(sampler_OceanNormal1);
                TEXTURE2D(_FarNormal);
                SAMPLER(sampler_FarNormal);
                TEXTURE2D(_ShallowNormal);
                SAMPLER(sampler_ShallowNormal);
                TEXTURE2D(_RiverNormal);
                SAMPLER(sampler_RiverNormal);
                TEXTURE2D(_LevelRiverNormal);
                SAMPLER(sampler_LevelRiverNormal);
                float _StretchScalar;
    
                // Graph Functions
                
                void Unity_SceneDepth_Linear01_float(float4 UV, out float Out)
                {
                    Out = Linear01Depth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
                }
                
                void Unity_Multiply_float(float A, float B, out float Out)
                {
                    Out = A * B;
                }
                
                void Unity_Add_float(float A, float B, out float Out)
                {
                    Out = A + B;
                }
                
                void Unity_Subtract_float(float A, float B, out float Out)
                {
                    Out = A - B;
                }
                
                void Unity_Sine_float(float In, out float Out)
                {
                    Out = sin(In);
                }
                
                void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
                {
                    Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
                }
                
                void Unity_Branch_float(float Predicate, float True, float False, out float Out)
                {
                    Out = Predicate ? True : False;
                }
                
                void Unity_Clamp_float(float In, float Min, float Max, out float Out)
                {
                    Out = clamp(In, Min, Max);
                }
                
                void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
                {
                    Out = lerp(A, B, T);
                }
                
                void Unity_Normalize_float3(float3 In, out float3 Out)
                {
                    Out = normalize(In);
                }
                
                void Unity_DotProduct_float3(float3 A, float3 B, out float Out)
                {
                    Out = dot(A, B);
                }
                
                void Unity_Add_float4(float4 A, float4 B, out float4 Out)
                {
                    Out = A + B;
                }
                
                void Unity_Lerp_float(float A, float B, float T, out float Out)
                {
                    Out = lerp(A, B, T);
                }
    
                // Graph Vertex
                struct VertexDescription
                {
                    float3 Position;
                    float3 Normal;
                    float3 Tangent;
                };
                
                VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                {
                    VertexDescription description = (VertexDescription)0;
                    description.Position = IN.ObjectSpacePosition;
                    description.Normal = IN.ObjectSpaceNormal;
                    description.Tangent = IN.ObjectSpaceTangent;
                    return description;
                }
    
                // Graph Pixel
                struct SurfaceDescription
                {
                    float3 BaseColor;
                    float Alpha;
                };
                
                SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                {
                    SurfaceDescription surface = (SurfaceDescription)0;
                    float4 _Property_231c0d262d3a466d85dfd53b116086ca_Out_0 = Color_701f2c2f40b34b87975a0e85a71325dc;
                    float _SceneDepth_3137d738aa0149fb8a54d88a60826a60_Out_1;
                    Unity_SceneDepth_Linear01_float(float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0), _SceneDepth_3137d738aa0149fb8a54d88a60826a60_Out_1);
                    float _Multiply_8ec8e0a1878e494ca0d6d16678168741_Out_2;
                    Unity_Multiply_float(_SceneDepth_3137d738aa0149fb8a54d88a60826a60_Out_1, _ProjectionParams.z, _Multiply_8ec8e0a1878e494ca0d6d16678168741_Out_2);
                    float4 _ScreenPosition_3840c0fb20fc4eb58387cd54ee7e2b18_Out_0 = IN.ScreenPosition;
                    float _Split_578ef5cadaac40969c114c4d1ae870d8_R_1 = _ScreenPosition_3840c0fb20fc4eb58387cd54ee7e2b18_Out_0[0];
                    float _Split_578ef5cadaac40969c114c4d1ae870d8_G_2 = _ScreenPosition_3840c0fb20fc4eb58387cd54ee7e2b18_Out_0[1];
                    float _Split_578ef5cadaac40969c114c4d1ae870d8_B_3 = _ScreenPosition_3840c0fb20fc4eb58387cd54ee7e2b18_Out_0[2];
                    float _Split_578ef5cadaac40969c114c4d1ae870d8_A_4 = _ScreenPosition_3840c0fb20fc4eb58387cd54ee7e2b18_Out_0[3];
                    float _Property_cedd17331b16484abf1a4ce8eb0e5a72_Out_0 = _DepthOffset;
                    float _Add_e04e1bc3087745d898c282f10a0f43e3_Out_2;
                    Unity_Add_float(_Split_578ef5cadaac40969c114c4d1ae870d8_A_4, _Property_cedd17331b16484abf1a4ce8eb0e5a72_Out_0, _Add_e04e1bc3087745d898c282f10a0f43e3_Out_2);
                    float _Subtract_bd4ff2ba7ce04051b10b968b020d06df_Out_2;
                    Unity_Subtract_float(_Multiply_8ec8e0a1878e494ca0d6d16678168741_Out_2, _Add_e04e1bc3087745d898c282f10a0f43e3_Out_2, _Subtract_bd4ff2ba7ce04051b10b968b020d06df_Out_2);
                    float _Property_90205b2f827548b295dc151171bc164c_Out_0 = _IsOcean;
                    float _Sine_24a173ac1d9d40b5b43bd7c8169386e4_Out_1;
                    Unity_Sine_float(IN.TimeParameters.x, _Sine_24a173ac1d9d40b5b43bd7c8169386e4_Out_1);
                    float _Remap_9ed3ea235fdc44d7a8c762cbe7ff6d0e_Out_3;
                    Unity_Remap_float(_Sine_24a173ac1d9d40b5b43bd7c8169386e4_Out_1, float2 (-1, 1), float2 (0.5, 1), _Remap_9ed3ea235fdc44d7a8c762cbe7ff6d0e_Out_3);
                    float _Branch_fcfcb84348fb4a5a90417124dc9ee3a2_Out_3;
                    Unity_Branch_float(_Property_90205b2f827548b295dc151171bc164c_Out_0, _Remap_9ed3ea235fdc44d7a8c762cbe7ff6d0e_Out_3, 1, _Branch_fcfcb84348fb4a5a90417124dc9ee3a2_Out_3);
                    float _Property_866bbbbe2a484e2eae1ad77ed223a577_Out_0 = _ShoreIntersectionStrength;
                    float _Multiply_cb7f54f30fb348b4a7f109f458e38b17_Out_2;
                    Unity_Multiply_float(_Branch_fcfcb84348fb4a5a90417124dc9ee3a2_Out_3, _Property_866bbbbe2a484e2eae1ad77ed223a577_Out_0, _Multiply_cb7f54f30fb348b4a7f109f458e38b17_Out_2);
                    float _Multiply_dcdae92bb4dd401a89df781ec062cecc_Out_2;
                    Unity_Multiply_float(_Subtract_bd4ff2ba7ce04051b10b968b020d06df_Out_2, _Multiply_cb7f54f30fb348b4a7f109f458e38b17_Out_2, _Multiply_dcdae92bb4dd401a89df781ec062cecc_Out_2);
                    float _Clamp_33ee6da80fc14439b6d7bab14be7ab07_Out_3;
                    Unity_Clamp_float(_Multiply_dcdae92bb4dd401a89df781ec062cecc_Out_2, 0.5, 1, _Clamp_33ee6da80fc14439b6d7bab14be7ab07_Out_3);
                    float4 _Lerp_f0669e92de0b409893955d23347ac238_Out_3;
                    Unity_Lerp_float4(_Property_231c0d262d3a466d85dfd53b116086ca_Out_0, float4(0, 0, 0, 0), (_Clamp_33ee6da80fc14439b6d7bab14be7ab07_Out_3.xxxx), _Lerp_f0669e92de0b409893955d23347ac238_Out_3);
                    float _Float_c4cf30aef9464dda83de90c7e790a9ba_Out_0 = 1.5;
                    float4 _Property_c854872c24e048c0aa372f0be547f07c_Out_0 = _ShallowWaterColor;
                    float4 _Property_dde44c4f61534e08a917dd16bcf5ebca_Out_0 = _DeepWaterColor;
                    float _Property_d328dfa89c674e67bffe73ef574a2d58_Out_0 = _Strength;
                    float _Multiply_4eb7822d949844e38f2bb60067662a47_Out_2;
                    Unity_Multiply_float(_Subtract_bd4ff2ba7ce04051b10b968b020d06df_Out_2, _Property_d328dfa89c674e67bffe73ef574a2d58_Out_0, _Multiply_4eb7822d949844e38f2bb60067662a47_Out_2);
                    float _Clamp_0f7ac1e483384940a0714a9e608d50b4_Out_3;
                    Unity_Clamp_float(_Multiply_4eb7822d949844e38f2bb60067662a47_Out_2, 0, 1, _Clamp_0f7ac1e483384940a0714a9e608d50b4_Out_3);
                    float4 _Lerp_3f9225ad7cdc45509b625268ef70e29c_Out_3;
                    Unity_Lerp_float4(_Property_c854872c24e048c0aa372f0be547f07c_Out_0, _Property_dde44c4f61534e08a917dd16bcf5ebca_Out_0, (_Clamp_0f7ac1e483384940a0714a9e608d50b4_Out_3.xxxx), _Lerp_3f9225ad7cdc45509b625268ef70e29c_Out_3);
                    float3 _Normalize_415b503188e443458e4172309aa4cb18_Out_1;
                    Unity_Normalize_float3(IN.WorldSpaceNormal, _Normalize_415b503188e443458e4172309aa4cb18_Out_1);
                    float _DotProduct_b3f1b90b273a4b2b99f07acbc4565dcb_Out_2;
                    Unity_DotProduct_float3(float3(0, 1, 0), _Normalize_415b503188e443458e4172309aa4cb18_Out_1, _DotProduct_b3f1b90b273a4b2b99f07acbc4565dcb_Out_2);
                    float _Remap_669938a90f934b9bab86d586a6917aca_Out_3;
                    Unity_Remap_float(_DotProduct_b3f1b90b273a4b2b99f07acbc4565dcb_Out_2, float2 (-1, 1), float2 (0, 1), _Remap_669938a90f934b9bab86d586a6917aca_Out_3);
                    float4 _Lerp_4536ba8c658e4f11aaefc80660368304_Out_3;
                    Unity_Lerp_float4((_Float_c4cf30aef9464dda83de90c7e790a9ba_Out_0.xxxx), _Lerp_3f9225ad7cdc45509b625268ef70e29c_Out_3, (_Remap_669938a90f934b9bab86d586a6917aca_Out_3.xxxx), _Lerp_4536ba8c658e4f11aaefc80660368304_Out_3);
                    float4 _Add_f8fda8450f33454d96a6212c8ebfdc62_Out_2;
                    Unity_Add_float4(_Lerp_f0669e92de0b409893955d23347ac238_Out_3, _Lerp_4536ba8c658e4f11aaefc80660368304_Out_3, _Add_f8fda8450f33454d96a6212c8ebfdc62_Out_2);
                    float _Split_17c957ee33bc4e28a994b8b8dd20a89f_R_1 = _Add_f8fda8450f33454d96a6212c8ebfdc62_Out_2[0];
                    float _Split_17c957ee33bc4e28a994b8b8dd20a89f_G_2 = _Add_f8fda8450f33454d96a6212c8ebfdc62_Out_2[1];
                    float _Split_17c957ee33bc4e28a994b8b8dd20a89f_B_3 = _Add_f8fda8450f33454d96a6212c8ebfdc62_Out_2[2];
                    float _Split_17c957ee33bc4e28a994b8b8dd20a89f_A_4 = _Add_f8fda8450f33454d96a6212c8ebfdc62_Out_2[3];
                    float3 _Vector3_3b779f158e6f4ba8ac091e620cd4bd1c_Out_0 = float3(_Split_17c957ee33bc4e28a994b8b8dd20a89f_R_1, _Split_17c957ee33bc4e28a994b8b8dd20a89f_G_2, _Split_17c957ee33bc4e28a994b8b8dd20a89f_B_3);
                    float _DotProduct_fb1cbb38204242edbadb0a15bc95b04e_Out_2;
                    Unity_DotProduct_float3(-1 * mul((float3x3)UNITY_MATRIX_M, transpose(mul(UNITY_MATRIX_I_M, UNITY_MATRIX_I_V)) [2].xyz), IN.WorldSpaceNormal, _DotProduct_fb1cbb38204242edbadb0a15bc95b04e_Out_2);
                    float _Remap_bde541d934954ce5b99314edcbcd70e5_Out_3;
                    Unity_Remap_float(_DotProduct_fb1cbb38204242edbadb0a15bc95b04e_Out_2, float2 (-1, 0), float2 (0, 1), _Remap_bde541d934954ce5b99314edcbcd70e5_Out_3);
                    float _Multiply_6330a2a6c69948a5aacc174b9da1d2f0_Out_2;
                    Unity_Multiply_float(_Split_17c957ee33bc4e28a994b8b8dd20a89f_A_4, _Remap_bde541d934954ce5b99314edcbcd70e5_Out_3, _Multiply_6330a2a6c69948a5aacc174b9da1d2f0_Out_2);
                    float _Property_bc84cef440384b15875875c65e907453_Out_0 = _DownAlphaStrength;
                    float _Property_f604cf40fc3249839fb755ab1c9d8eb2_Out_0 = _TranceparencyStrength;
                    float _Multiply_c4a5b4f21dfe45d2a2f78cc50eba3ec8_Out_2;
                    Unity_Multiply_float(_Subtract_bd4ff2ba7ce04051b10b968b020d06df_Out_2, _Property_f604cf40fc3249839fb755ab1c9d8eb2_Out_0, _Multiply_c4a5b4f21dfe45d2a2f78cc50eba3ec8_Out_2);
                    float _Clamp_61028b06dbf14a6092a617f0d8a7ac32_Out_3;
                    Unity_Clamp_float(_Multiply_c4a5b4f21dfe45d2a2f78cc50eba3ec8_Out_2, 0, 1, _Clamp_61028b06dbf14a6092a617f0d8a7ac32_Out_3);
                    float _Lerp_106a757383d0403399452dcbb99cc72a_Out_3;
                    Unity_Lerp_float(_Property_bc84cef440384b15875875c65e907453_Out_0, 0, _Clamp_61028b06dbf14a6092a617f0d8a7ac32_Out_3, _Lerp_106a757383d0403399452dcbb99cc72a_Out_3);
                    float _Lerp_729c45b3c3014bdbb92bb4198e06bd92_Out_3;
                    Unity_Lerp_float(1, 0, _Remap_bde541d934954ce5b99314edcbcd70e5_Out_3, _Lerp_729c45b3c3014bdbb92bb4198e06bd92_Out_3);
                    float _Multiply_a80cb3307cd746d7a1bb5f699c9423f3_Out_2;
                    Unity_Multiply_float(_Lerp_106a757383d0403399452dcbb99cc72a_Out_3, _Lerp_729c45b3c3014bdbb92bb4198e06bd92_Out_3, _Multiply_a80cb3307cd746d7a1bb5f699c9423f3_Out_2);
                    float _Lerp_b12dda477cf14695add7f2de406dd644_Out_3;
                    Unity_Lerp_float(_Split_17c957ee33bc4e28a994b8b8dd20a89f_A_4, _Multiply_6330a2a6c69948a5aacc174b9da1d2f0_Out_2, _Multiply_a80cb3307cd746d7a1bb5f699c9423f3_Out_2, _Lerp_b12dda477cf14695add7f2de406dd644_Out_3);
                    surface.BaseColor = _Vector3_3b779f158e6f4ba8ac091e620cd4bd1c_Out_0;
                    surface.Alpha = _Lerp_b12dda477cf14695add7f2de406dd644_Out_3;
                    return surface;
                }
    
                // --------------------------------------------------
                // Build Graph Inputs
    
                VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                {
                    VertexDescriptionInputs output;
                    ZERO_INITIALIZE(VertexDescriptionInputs, output);
                
                    output.ObjectSpaceNormal =           input.normalOS;
                    output.ObjectSpaceTangent =          input.tangentOS.xyz;
                    output.ObjectSpacePosition =         input.positionOS;
                
                    return output;
                }
                
                SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                {
                    SurfaceDescriptionInputs output;
                    ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
                
                	// must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
                	float3 unnormalizedNormalWS = input.normalWS;
                    const float renormFactor = 1.0 / length(unnormalizedNormalWS);
                
                
                    output.WorldSpaceNormal =            renormFactor*input.normalWS.xyz;		// we want a unit length Normal Vector node in shader graph
                
                
                    output.WorldSpacePosition =          input.positionWS;
                    output.ScreenPosition =              ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
                    output.TimeParameters =              _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                #else
                #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                #endif
                #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                
                    return output;
                }
                
    
                // --------------------------------------------------
                // Main
    
                #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBR2DPass.hlsl"
    
                ENDHLSL
            }
        }
        SubShader
        {
            Tags
            {
                "RenderPipeline"="UniversalPipeline"
                "RenderType"="Transparent"
                "UniversalMaterialType" = "Lit"
                "Queue"="Transparent"
            }
            Pass
            {
                Name "Universal Forward"
                Tags
                {
                    "LightMode" = "UniversalForward"
                }
    
                // Render State
                Cull Off
                Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
                ZTest LEqual
                ZWrite Off
    
                // Debug
                // <None>
    
                // --------------------------------------------------
                // Pass
    
                HLSLPROGRAM
    
                // Pragmas
                #pragma target 2.0
                #pragma only_renderers gles gles3 glcore d3d11
                #pragma multi_compile_instancing
                #pragma multi_compile_fog
                #pragma vertex vert
                #pragma fragment frag
    
                // DotsInstancingOptions: <None>
                // HybridV1InjectedBuiltinProperties: <None>
    
                // Keywords
                #pragma multi_compile _ _SCREEN_SPACE_OCCLUSION
                #pragma multi_compile _ LIGHTMAP_ON
                #pragma multi_compile _ DIRLIGHTMAP_COMBINED
                #pragma multi_compile _ _MAIN_LIGHT_SHADOWS
                #pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
                #pragma multi_compile _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS _ADDITIONAL_OFF
                #pragma multi_compile _ _ADDITIONAL_LIGHT_SHADOWS
                #pragma multi_compile _ _SHADOWS_SOFT
                #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
                #pragma multi_compile _ SHADOWS_SHADOWMASK
                // GraphKeywords: <None>
    
                // Defines
                #define _SURFACE_TYPE_TRANSPARENT 1
                #define _NORMALMAP 1
                #define _NORMAL_DROPOFF_TS 1
                #define ATTRIBUTES_NEED_NORMAL
                #define ATTRIBUTES_NEED_TANGENT
                #define ATTRIBUTES_NEED_TEXCOORD0
                #define ATTRIBUTES_NEED_TEXCOORD1
                #define VARYINGS_NEED_POSITION_WS
                #define VARYINGS_NEED_NORMAL_WS
                #define VARYINGS_NEED_TANGENT_WS
                #define VARYINGS_NEED_TEXCOORD0
                #define VARYINGS_NEED_VIEWDIRECTION_WS
                #define VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
                #define FEATURES_GRAPH_VERTEX
                /* WARNING: $splice Could not find named fragment 'PassInstancing' */
                #define SHADERPASS SHADERPASS_FORWARD
                #define REQUIRE_DEPTH_TEXTURE
                /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
    
                // Includes
                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
    
                // --------------------------------------------------
                // Structs and Packing
    
                struct Attributes
                {
                    float3 positionOS : POSITION;
                    float3 normalOS : NORMAL;
                    float4 tangentOS : TANGENT;
                    float4 uv0 : TEXCOORD0;
                    float4 uv1 : TEXCOORD1;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    uint instanceID : INSTANCEID_SEMANTIC;
                    #endif
                };
                struct Varyings
                {
                    float4 positionCS : SV_POSITION;
                    float3 positionWS;
                    float3 normalWS;
                    float4 tangentWS;
                    float4 texCoord0;
                    float3 viewDirectionWS;
                    #if defined(LIGHTMAP_ON)
                    float2 lightmapUV;
                    #endif
                    #if !defined(LIGHTMAP_ON)
                    float3 sh;
                    #endif
                    float4 fogFactorAndVertexLight;
                    float4 shadowCoord;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    uint instanceID : CUSTOM_INSTANCE_ID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                    #endif
                };
                struct SurfaceDescriptionInputs
                {
                    float3 WorldSpaceNormal;
                    float3 TangentSpaceNormal;
                    float3 WorldSpacePosition;
                    float4 ScreenPosition;
                    float4 uv0;
                    float3 TimeParameters;
                };
                struct VertexDescriptionInputs
                {
                    float3 ObjectSpaceNormal;
                    float3 ObjectSpaceTangent;
                    float3 ObjectSpacePosition;
                };
                struct PackedVaryings
                {
                    float4 positionCS : SV_POSITION;
                    float3 interp0 : TEXCOORD0;
                    float3 interp1 : TEXCOORD1;
                    float4 interp2 : TEXCOORD2;
                    float4 interp3 : TEXCOORD3;
                    float3 interp4 : TEXCOORD4;
                    #if defined(LIGHTMAP_ON)
                    float2 interp5 : TEXCOORD5;
                    #endif
                    #if !defined(LIGHTMAP_ON)
                    float3 interp6 : TEXCOORD6;
                    #endif
                    float4 interp7 : TEXCOORD7;
                    float4 interp8 : TEXCOORD8;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    uint instanceID : CUSTOM_INSTANCE_ID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                    #endif
                };
    
                PackedVaryings PackVaryings (Varyings input)
                {
                    PackedVaryings output;
                    output.positionCS = input.positionCS;
                    output.interp0.xyz =  input.positionWS;
                    output.interp1.xyz =  input.normalWS;
                    output.interp2.xyzw =  input.tangentWS;
                    output.interp3.xyzw =  input.texCoord0;
                    output.interp4.xyz =  input.viewDirectionWS;
                    #if defined(LIGHTMAP_ON)
                    output.interp5.xy =  input.lightmapUV;
                    #endif
                    #if !defined(LIGHTMAP_ON)
                    output.interp6.xyz =  input.sh;
                    #endif
                    output.interp7.xyzw =  input.fogFactorAndVertexLight;
                    output.interp8.xyzw =  input.shadowCoord;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    output.instanceID = input.instanceID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    output.cullFace = input.cullFace;
                    #endif
                    return output;
                }
                Varyings UnpackVaryings (PackedVaryings input)
                {
                    Varyings output;
                    output.positionCS = input.positionCS;
                    output.positionWS = input.interp0.xyz;
                    output.normalWS = input.interp1.xyz;
                    output.tangentWS = input.interp2.xyzw;
                    output.texCoord0 = input.interp3.xyzw;
                    output.viewDirectionWS = input.interp4.xyz;
                    #if defined(LIGHTMAP_ON)
                    output.lightmapUV = input.interp5.xy;
                    #endif
                    #if !defined(LIGHTMAP_ON)
                    output.sh = input.interp6.xyz;
                    #endif
                    output.fogFactorAndVertexLight = input.interp7.xyzw;
                    output.shadowCoord = input.interp8.xyzw;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    output.instanceID = input.instanceID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    output.cullFace = input.cullFace;
                    #endif
                    return output;
                }
    
                // --------------------------------------------------
                // Graph
    
                // Graph Properties
                CBUFFER_START(UnityPerMaterial)
                float _DepthOffset;
                float _Strength;
                float4 _DeepWaterColor;
                float4 _ShallowWaterColor;
                float _Metallic;
                float2 _Tiling;
                float4 _OceanNormal2_TexelSize;
                float4 _OceanNormal1_TexelSize;
                float _GradientNoise;
                float2 _OceanSpeed;
                float _LODdistance;
                float4 _FarNormal_TexelSize;
                float4 _ShallowNormal_TexelSize;
                float _TranceparencyStrength;
                float _DownAlphaStrength;
                float _IsOcean;
                float4 _RiverNormal_TexelSize;
                float _RiverNormalRotAdjustment;
                float4 _LevelRiverNormal_TexelSize;
                float _RiverSpeed;
                float _ShoreIntersectionStrength;
                float4 Color_701f2c2f40b34b87975a0e85a71325dc;
                CBUFFER_END
                
                // Object and Global properties
                SAMPLER(SamplerState_Linear_Repeat);
                TEXTURE2D(_OceanNormal2);
                SAMPLER(sampler_OceanNormal2);
                TEXTURE2D(_OceanNormal1);
                SAMPLER(sampler_OceanNormal1);
                TEXTURE2D(_FarNormal);
                SAMPLER(sampler_FarNormal);
                TEXTURE2D(_ShallowNormal);
                SAMPLER(sampler_ShallowNormal);
                TEXTURE2D(_RiverNormal);
                SAMPLER(sampler_RiverNormal);
                TEXTURE2D(_LevelRiverNormal);
                SAMPLER(sampler_LevelRiverNormal);
                float _StretchScalar;
    
                // Graph Functions
                
                void Unity_SceneDepth_Linear01_float(float4 UV, out float Out)
                {
                    Out = Linear01Depth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
                }
                
                void Unity_Multiply_float(float A, float B, out float Out)
                {
                    Out = A * B;
                }
                
                void Unity_Add_float(float A, float B, out float Out)
                {
                    Out = A + B;
                }
                
                void Unity_Subtract_float(float A, float B, out float Out)
                {
                    Out = A - B;
                }
                
                void Unity_Sine_float(float In, out float Out)
                {
                    Out = sin(In);
                }
                
                void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
                {
                    Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
                }
                
                void Unity_Branch_float(float Predicate, float True, float False, out float Out)
                {
                    Out = Predicate ? True : False;
                }
                
                void Unity_Clamp_float(float In, float Min, float Max, out float Out)
                {
                    Out = clamp(In, Min, Max);
                }
                
                void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
                {
                    Out = lerp(A, B, T);
                }
                
                void Unity_Normalize_float3(float3 In, out float3 Out)
                {
                    Out = normalize(In);
                }
                
                void Unity_DotProduct_float3(float3 A, float3 B, out float Out)
                {
                    Out = dot(A, B);
                }
                
                void Unity_Add_float4(float4 A, float4 B, out float4 Out)
                {
                    Out = A + B;
                }
                
                void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
                {
                    Out = UV * Tiling + Offset;
                }
                
                void Unity_Divide_float(float A, float B, out float Out)
                {
                    Out = A / B;
                }
                
                
                float2 Unity_GradientNoise_Dir_float(float2 p)
                {
                    // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
                    p = p % 289;
                    // need full precision, otherwise half overflows when p > 1
                    float x = float(34 * p.x + 1) * p.x % 289 + p.y;
                    x = (34 * x + 1) * x % 289;
                    x = frac(x / 41) * 2 - 1;
                    return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
                }
                
                void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
                { 
                    float2 p = UV * Scale;
                    float2 ip = floor(p);
                    float2 fp = frac(p);
                    float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
                    float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
                    float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
                    float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
                    fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
                    Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
                }
                
                void Unity_Comparison_Greater_float(float A, float B, out float Out)
                {
                    Out = A > B ? 1 : 0;
                }
                
                void Unity_Normalize_float2(float2 In, out float2 Out)
                {
                    Out = normalize(In);
                }
                
                void Unity_DotProduct_float2(float2 A, float2 B, out float Out)
                {
                    Out = dot(A, B);
                }
                
                void Unity_Arccosine_float(float In, out float Out)
                {
                    Out = acos(In);
                }
                
                void Unity_Rotate_Radians_float(float2 UV, float2 Center, float Rotation, out float2 Out)
                {
                    //rotation matrix
                    UV -= Center;
                    float s = sin(Rotation);
                    float c = cos(Rotation);
                
                    //center rotation matrix
                    float2x2 rMatrix = float2x2(c, -s, s, c);
                    rMatrix *= 0.5;
                    rMatrix += 0.5;
                    rMatrix = rMatrix*2 - 1;
                
                    //multiply the UVs by the rotation matrix
                    UV.xy = mul(UV.xy, rMatrix);
                    UV += Center;
                
                    Out = UV;
                }
                
                void Unity_Lerp_float(float A, float B, float T, out float Out)
                {
                    Out = lerp(A, B, T);
                }
                
                void Unity_Rotate_Degrees_float(float2 UV, float2 Center, float Rotation, out float2 Out)
                {
                    //rotation matrix
                    Rotation = Rotation * (3.1415926f/180.0f);
                    UV -= Center;
                    float s = sin(Rotation);
                    float c = cos(Rotation);
                
                    //center rotation matrix
                    float2x2 rMatrix = float2x2(c, -s, s, c);
                    rMatrix *= 0.5;
                    rMatrix += 0.5;
                    rMatrix = rMatrix*2 - 1;
                
                    //multiply the UVs by the rotation matrix
                    UV.xy = mul(UV.xy, rMatrix);
                    UV += Center;
                
                    Out = UV;
                }
                
                void Unity_Branch_float4(float Predicate, float4 True, float4 False, out float4 Out)
                {
                    Out = Predicate ? True : False;
                }
                
                void Unity_Distance_float3(float3 A, float3 B, out float Out)
                {
                    Out = distance(A, B);
                }
    
                // Graph Vertex
                struct VertexDescription
                {
                    float3 Position;
                    float3 Normal;
                    float3 Tangent;
                };
                
                VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                {
                    VertexDescription description = (VertexDescription)0;
                    description.Position = IN.ObjectSpacePosition;
                    description.Normal = IN.ObjectSpaceNormal;
                    description.Tangent = IN.ObjectSpaceTangent;
                    return description;
                }
    
                // Graph Pixel
                struct SurfaceDescription
                {
                    float3 BaseColor;
                    float3 NormalTS;
                    float3 Emission;
                    float Metallic;
                    float Smoothness;
                    float Occlusion;
                    float Alpha;
                };
                
                SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                {
                    SurfaceDescription surface = (SurfaceDescription)0;
                    float4 _Property_231c0d262d3a466d85dfd53b116086ca_Out_0 = Color_701f2c2f40b34b87975a0e85a71325dc;
                    float _SceneDepth_3137d738aa0149fb8a54d88a60826a60_Out_1;
                    Unity_SceneDepth_Linear01_float(float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0), _SceneDepth_3137d738aa0149fb8a54d88a60826a60_Out_1);
                    float _Multiply_8ec8e0a1878e494ca0d6d16678168741_Out_2;
                    Unity_Multiply_float(_SceneDepth_3137d738aa0149fb8a54d88a60826a60_Out_1, _ProjectionParams.z, _Multiply_8ec8e0a1878e494ca0d6d16678168741_Out_2);
                    float4 _ScreenPosition_3840c0fb20fc4eb58387cd54ee7e2b18_Out_0 = IN.ScreenPosition;
                    float _Split_578ef5cadaac40969c114c4d1ae870d8_R_1 = _ScreenPosition_3840c0fb20fc4eb58387cd54ee7e2b18_Out_0[0];
                    float _Split_578ef5cadaac40969c114c4d1ae870d8_G_2 = _ScreenPosition_3840c0fb20fc4eb58387cd54ee7e2b18_Out_0[1];
                    float _Split_578ef5cadaac40969c114c4d1ae870d8_B_3 = _ScreenPosition_3840c0fb20fc4eb58387cd54ee7e2b18_Out_0[2];
                    float _Split_578ef5cadaac40969c114c4d1ae870d8_A_4 = _ScreenPosition_3840c0fb20fc4eb58387cd54ee7e2b18_Out_0[3];
                    float _Property_cedd17331b16484abf1a4ce8eb0e5a72_Out_0 = _DepthOffset;
                    float _Add_e04e1bc3087745d898c282f10a0f43e3_Out_2;
                    Unity_Add_float(_Split_578ef5cadaac40969c114c4d1ae870d8_A_4, _Property_cedd17331b16484abf1a4ce8eb0e5a72_Out_0, _Add_e04e1bc3087745d898c282f10a0f43e3_Out_2);
                    float _Subtract_bd4ff2ba7ce04051b10b968b020d06df_Out_2;
                    Unity_Subtract_float(_Multiply_8ec8e0a1878e494ca0d6d16678168741_Out_2, _Add_e04e1bc3087745d898c282f10a0f43e3_Out_2, _Subtract_bd4ff2ba7ce04051b10b968b020d06df_Out_2);
                    float _Property_90205b2f827548b295dc151171bc164c_Out_0 = _IsOcean;
                    float _Sine_24a173ac1d9d40b5b43bd7c8169386e4_Out_1;
                    Unity_Sine_float(IN.TimeParameters.x, _Sine_24a173ac1d9d40b5b43bd7c8169386e4_Out_1);
                    float _Remap_9ed3ea235fdc44d7a8c762cbe7ff6d0e_Out_3;
                    Unity_Remap_float(_Sine_24a173ac1d9d40b5b43bd7c8169386e4_Out_1, float2 (-1, 1), float2 (0.5, 1), _Remap_9ed3ea235fdc44d7a8c762cbe7ff6d0e_Out_3);
                    float _Branch_fcfcb84348fb4a5a90417124dc9ee3a2_Out_3;
                    Unity_Branch_float(_Property_90205b2f827548b295dc151171bc164c_Out_0, _Remap_9ed3ea235fdc44d7a8c762cbe7ff6d0e_Out_3, 1, _Branch_fcfcb84348fb4a5a90417124dc9ee3a2_Out_3);
                    float _Property_866bbbbe2a484e2eae1ad77ed223a577_Out_0 = _ShoreIntersectionStrength;
                    float _Multiply_cb7f54f30fb348b4a7f109f458e38b17_Out_2;
                    Unity_Multiply_float(_Branch_fcfcb84348fb4a5a90417124dc9ee3a2_Out_3, _Property_866bbbbe2a484e2eae1ad77ed223a577_Out_0, _Multiply_cb7f54f30fb348b4a7f109f458e38b17_Out_2);
                    float _Multiply_dcdae92bb4dd401a89df781ec062cecc_Out_2;
                    Unity_Multiply_float(_Subtract_bd4ff2ba7ce04051b10b968b020d06df_Out_2, _Multiply_cb7f54f30fb348b4a7f109f458e38b17_Out_2, _Multiply_dcdae92bb4dd401a89df781ec062cecc_Out_2);
                    float _Clamp_33ee6da80fc14439b6d7bab14be7ab07_Out_3;
                    Unity_Clamp_float(_Multiply_dcdae92bb4dd401a89df781ec062cecc_Out_2, 0.5, 1, _Clamp_33ee6da80fc14439b6d7bab14be7ab07_Out_3);
                    float4 _Lerp_f0669e92de0b409893955d23347ac238_Out_3;
                    Unity_Lerp_float4(_Property_231c0d262d3a466d85dfd53b116086ca_Out_0, float4(0, 0, 0, 0), (_Clamp_33ee6da80fc14439b6d7bab14be7ab07_Out_3.xxxx), _Lerp_f0669e92de0b409893955d23347ac238_Out_3);
                    float _Float_c4cf30aef9464dda83de90c7e790a9ba_Out_0 = 1.5;
                    float4 _Property_c854872c24e048c0aa372f0be547f07c_Out_0 = _ShallowWaterColor;
                    float4 _Property_dde44c4f61534e08a917dd16bcf5ebca_Out_0 = _DeepWaterColor;
                    float _Property_d328dfa89c674e67bffe73ef574a2d58_Out_0 = _Strength;
                    float _Multiply_4eb7822d949844e38f2bb60067662a47_Out_2;
                    Unity_Multiply_float(_Subtract_bd4ff2ba7ce04051b10b968b020d06df_Out_2, _Property_d328dfa89c674e67bffe73ef574a2d58_Out_0, _Multiply_4eb7822d949844e38f2bb60067662a47_Out_2);
                    float _Clamp_0f7ac1e483384940a0714a9e608d50b4_Out_3;
                    Unity_Clamp_float(_Multiply_4eb7822d949844e38f2bb60067662a47_Out_2, 0, 1, _Clamp_0f7ac1e483384940a0714a9e608d50b4_Out_3);
                    float4 _Lerp_3f9225ad7cdc45509b625268ef70e29c_Out_3;
                    Unity_Lerp_float4(_Property_c854872c24e048c0aa372f0be547f07c_Out_0, _Property_dde44c4f61534e08a917dd16bcf5ebca_Out_0, (_Clamp_0f7ac1e483384940a0714a9e608d50b4_Out_3.xxxx), _Lerp_3f9225ad7cdc45509b625268ef70e29c_Out_3);
                    float3 _Normalize_415b503188e443458e4172309aa4cb18_Out_1;
                    Unity_Normalize_float3(IN.WorldSpaceNormal, _Normalize_415b503188e443458e4172309aa4cb18_Out_1);
                    float _DotProduct_b3f1b90b273a4b2b99f07acbc4565dcb_Out_2;
                    Unity_DotProduct_float3(float3(0, 1, 0), _Normalize_415b503188e443458e4172309aa4cb18_Out_1, _DotProduct_b3f1b90b273a4b2b99f07acbc4565dcb_Out_2);
                    float _Remap_669938a90f934b9bab86d586a6917aca_Out_3;
                    Unity_Remap_float(_DotProduct_b3f1b90b273a4b2b99f07acbc4565dcb_Out_2, float2 (-1, 1), float2 (0, 1), _Remap_669938a90f934b9bab86d586a6917aca_Out_3);
                    float4 _Lerp_4536ba8c658e4f11aaefc80660368304_Out_3;
                    Unity_Lerp_float4((_Float_c4cf30aef9464dda83de90c7e790a9ba_Out_0.xxxx), _Lerp_3f9225ad7cdc45509b625268ef70e29c_Out_3, (_Remap_669938a90f934b9bab86d586a6917aca_Out_3.xxxx), _Lerp_4536ba8c658e4f11aaefc80660368304_Out_3);
                    float4 _Add_f8fda8450f33454d96a6212c8ebfdc62_Out_2;
                    Unity_Add_float4(_Lerp_f0669e92de0b409893955d23347ac238_Out_3, _Lerp_4536ba8c658e4f11aaefc80660368304_Out_3, _Add_f8fda8450f33454d96a6212c8ebfdc62_Out_2);
                    float _Split_17c957ee33bc4e28a994b8b8dd20a89f_R_1 = _Add_f8fda8450f33454d96a6212c8ebfdc62_Out_2[0];
                    float _Split_17c957ee33bc4e28a994b8b8dd20a89f_G_2 = _Add_f8fda8450f33454d96a6212c8ebfdc62_Out_2[1];
                    float _Split_17c957ee33bc4e28a994b8b8dd20a89f_B_3 = _Add_f8fda8450f33454d96a6212c8ebfdc62_Out_2[2];
                    float _Split_17c957ee33bc4e28a994b8b8dd20a89f_A_4 = _Add_f8fda8450f33454d96a6212c8ebfdc62_Out_2[3];
                    float3 _Vector3_3b779f158e6f4ba8ac091e620cd4bd1c_Out_0 = float3(_Split_17c957ee33bc4e28a994b8b8dd20a89f_R_1, _Split_17c957ee33bc4e28a994b8b8dd20a89f_G_2, _Split_17c957ee33bc4e28a994b8b8dd20a89f_B_3);
                    UnityTexture2D _Property_98dcadd153784e00b3d99c72c66a28b9_Out_0 = UnityBuildTexture2DStructNoScale(_ShallowNormal);
                    float2 _TilingAndOffset_e057885e86584dea86f94cfc76e1e048_Out_3;
                    Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), float2 (0, 0), _TilingAndOffset_e057885e86584dea86f94cfc76e1e048_Out_3);
                    float4 _SampleTexture2D_0121a928620142938ff635ec1ff89401_RGBA_0 = SAMPLE_TEXTURE2D(_Property_98dcadd153784e00b3d99c72c66a28b9_Out_0.tex, _Property_98dcadd153784e00b3d99c72c66a28b9_Out_0.samplerstate, _TilingAndOffset_e057885e86584dea86f94cfc76e1e048_Out_3);
                    _SampleTexture2D_0121a928620142938ff635ec1ff89401_RGBA_0.rgb = UnpackNormal(_SampleTexture2D_0121a928620142938ff635ec1ff89401_RGBA_0);
                    float _SampleTexture2D_0121a928620142938ff635ec1ff89401_R_4 = _SampleTexture2D_0121a928620142938ff635ec1ff89401_RGBA_0.r;
                    float _SampleTexture2D_0121a928620142938ff635ec1ff89401_G_5 = _SampleTexture2D_0121a928620142938ff635ec1ff89401_RGBA_0.g;
                    float _SampleTexture2D_0121a928620142938ff635ec1ff89401_B_6 = _SampleTexture2D_0121a928620142938ff635ec1ff89401_RGBA_0.b;
                    float _SampleTexture2D_0121a928620142938ff635ec1ff89401_A_7 = _SampleTexture2D_0121a928620142938ff635ec1ff89401_RGBA_0.a;
                    float _Property_c92104f8c9d245dbb796f54a2386b2fa_Out_0 = _IsOcean;
                    float2 _Property_0165785b858447e9be7aeae88e49b876_Out_0 = _Tiling;
                    float _Divide_40fd94b5668f4354bc4f097174879071_Out_2;
                    Unity_Divide_float(IN.TimeParameters.x, 25, _Divide_40fd94b5668f4354bc4f097174879071_Out_2);
                    float2 _TilingAndOffset_dd58a4e4d2f44f4692185d84f037be72_Out_3;
                    Unity_TilingAndOffset_float(IN.uv0.xy, _Property_0165785b858447e9be7aeae88e49b876_Out_0, (_Divide_40fd94b5668f4354bc4f097174879071_Out_2.xx), _TilingAndOffset_dd58a4e4d2f44f4692185d84f037be72_Out_3);
                    float _Property_dcf2fdcb8f824668b8a6e8c81f6e182d_Out_0 = _GradientNoise;
                    float _GradientNoise_2c52090e5ac5473ba4d45f48de31694f_Out_2;
                    Unity_GradientNoise_float(_TilingAndOffset_dd58a4e4d2f44f4692185d84f037be72_Out_3, _Property_dcf2fdcb8f824668b8a6e8c81f6e182d_Out_0, _GradientNoise_2c52090e5ac5473ba4d45f48de31694f_Out_2);
                    float _Remap_fe18556f20a1429782d5401a4e93f4ff_Out_3;
                    Unity_Remap_float(_GradientNoise_2c52090e5ac5473ba4d45f48de31694f_Out_2, float2 (0, 1), float2 (-1, 1), _Remap_fe18556f20a1429782d5401a4e93f4ff_Out_3);
                    UnityTexture2D _Property_1aa6808f044b4d20b816c793ef91056c_Out_0 = UnityBuildTexture2DStructNoScale(_OceanNormal1);
                    float2 _Property_6dc7633668bb4df38e93ccda13f0e850_Out_0 = _OceanSpeed;
                    float _Split_35918e73b31d4ab383b2221ebc8e73c7_R_1 = _Property_6dc7633668bb4df38e93ccda13f0e850_Out_0[0];
                    float _Split_35918e73b31d4ab383b2221ebc8e73c7_G_2 = _Property_6dc7633668bb4df38e93ccda13f0e850_Out_0[1];
                    float _Split_35918e73b31d4ab383b2221ebc8e73c7_B_3 = 0;
                    float _Split_35918e73b31d4ab383b2221ebc8e73c7_A_4 = 0;
                    float _Divide_320942700ecd49068a4d2fac0bbcd012_Out_2;
                    Unity_Divide_float(IN.TimeParameters.x, _Split_35918e73b31d4ab383b2221ebc8e73c7_R_1, _Divide_320942700ecd49068a4d2fac0bbcd012_Out_2);
                    float2 _TilingAndOffset_2c0d1a11da414db2972d2b0e6e6eead7_Out_3;
                    Unity_TilingAndOffset_float(IN.uv0.xy, _Property_0165785b858447e9be7aeae88e49b876_Out_0, (_Divide_320942700ecd49068a4d2fac0bbcd012_Out_2.xx), _TilingAndOffset_2c0d1a11da414db2972d2b0e6e6eead7_Out_3);
                    float4 _SampleTexture2D_95cbac09786f4d9f877a32a692103c63_RGBA_0 = SAMPLE_TEXTURE2D(_Property_1aa6808f044b4d20b816c793ef91056c_Out_0.tex, _Property_1aa6808f044b4d20b816c793ef91056c_Out_0.samplerstate, _TilingAndOffset_2c0d1a11da414db2972d2b0e6e6eead7_Out_3);
                    _SampleTexture2D_95cbac09786f4d9f877a32a692103c63_RGBA_0.rgb = UnpackNormal(_SampleTexture2D_95cbac09786f4d9f877a32a692103c63_RGBA_0);
                    float _SampleTexture2D_95cbac09786f4d9f877a32a692103c63_R_4 = _SampleTexture2D_95cbac09786f4d9f877a32a692103c63_RGBA_0.r;
                    float _SampleTexture2D_95cbac09786f4d9f877a32a692103c63_G_5 = _SampleTexture2D_95cbac09786f4d9f877a32a692103c63_RGBA_0.g;
                    float _SampleTexture2D_95cbac09786f4d9f877a32a692103c63_B_6 = _SampleTexture2D_95cbac09786f4d9f877a32a692103c63_RGBA_0.b;
                    float _SampleTexture2D_95cbac09786f4d9f877a32a692103c63_A_7 = _SampleTexture2D_95cbac09786f4d9f877a32a692103c63_RGBA_0.a;
                    UnityTexture2D _Property_fab5aef84b23441fbfd40281cf1ada82_Out_0 = UnityBuildTexture2DStructNoScale(_OceanNormal2);
                    float _Divide_dbf1715fe11a470fb42e9a29bb351a9d_Out_2;
                    Unity_Divide_float(IN.TimeParameters.x, _Split_35918e73b31d4ab383b2221ebc8e73c7_G_2, _Divide_dbf1715fe11a470fb42e9a29bb351a9d_Out_2);
                    float2 _TilingAndOffset_bc9854cad9a042cfb0ebc3bb5b4792e4_Out_3;
                    Unity_TilingAndOffset_float(IN.uv0.xy, _Property_0165785b858447e9be7aeae88e49b876_Out_0, (_Divide_dbf1715fe11a470fb42e9a29bb351a9d_Out_2.xx), _TilingAndOffset_bc9854cad9a042cfb0ebc3bb5b4792e4_Out_3);
                    float4 _SampleTexture2D_7f1b3f3ae5d243f9b432299bdc4f7b97_RGBA_0 = SAMPLE_TEXTURE2D(_Property_fab5aef84b23441fbfd40281cf1ada82_Out_0.tex, _Property_fab5aef84b23441fbfd40281cf1ada82_Out_0.samplerstate, _TilingAndOffset_bc9854cad9a042cfb0ebc3bb5b4792e4_Out_3);
                    _SampleTexture2D_7f1b3f3ae5d243f9b432299bdc4f7b97_RGBA_0.rgb = UnpackNormal(_SampleTexture2D_7f1b3f3ae5d243f9b432299bdc4f7b97_RGBA_0);
                    float _SampleTexture2D_7f1b3f3ae5d243f9b432299bdc4f7b97_R_4 = _SampleTexture2D_7f1b3f3ae5d243f9b432299bdc4f7b97_RGBA_0.r;
                    float _SampleTexture2D_7f1b3f3ae5d243f9b432299bdc4f7b97_G_5 = _SampleTexture2D_7f1b3f3ae5d243f9b432299bdc4f7b97_RGBA_0.g;
                    float _SampleTexture2D_7f1b3f3ae5d243f9b432299bdc4f7b97_B_6 = _SampleTexture2D_7f1b3f3ae5d243f9b432299bdc4f7b97_RGBA_0.b;
                    float _SampleTexture2D_7f1b3f3ae5d243f9b432299bdc4f7b97_A_7 = _SampleTexture2D_7f1b3f3ae5d243f9b432299bdc4f7b97_RGBA_0.a;
                    float4 _Add_3f6c04238c1f459eb8e6300b9eb1f842_Out_2;
                    Unity_Add_float4(_SampleTexture2D_95cbac09786f4d9f877a32a692103c63_RGBA_0, _SampleTexture2D_7f1b3f3ae5d243f9b432299bdc4f7b97_RGBA_0, _Add_3f6c04238c1f459eb8e6300b9eb1f842_Out_2);
                    float4 _Add_3e553e4abf784d7799c718cfe7d51b68_Out_2;
                    Unity_Add_float4((_Remap_fe18556f20a1429782d5401a4e93f4ff_Out_3.xxxx), _Add_3f6c04238c1f459eb8e6300b9eb1f842_Out_2, _Add_3e553e4abf784d7799c718cfe7d51b68_Out_2);
                    float _Comparison_8f4fb954760447e8b0db8924e20fd1d0_Out_2;
                    Unity_Comparison_Greater_float(_Remap_669938a90f934b9bab86d586a6917aca_Out_3, 0, _Comparison_8f4fb954760447e8b0db8924e20fd1d0_Out_2);
                    UnityTexture2D _Property_ab131e76fa9e4575850bad711d6bc112_Out_0 = UnityBuildTexture2DStructNoScale(_RiverNormal);
                    float3 _Normalize_62a13fd33141482da88d8a4f6cbbc589_Out_1;
                    Unity_Normalize_float3(IN.WorldSpaceNormal, _Normalize_62a13fd33141482da88d8a4f6cbbc589_Out_1);
                    float _Split_0d3686f12540443e91f7387b6f77c10d_R_1 = _Normalize_62a13fd33141482da88d8a4f6cbbc589_Out_1[0];
                    float _Split_0d3686f12540443e91f7387b6f77c10d_G_2 = _Normalize_62a13fd33141482da88d8a4f6cbbc589_Out_1[1];
                    float _Split_0d3686f12540443e91f7387b6f77c10d_B_3 = _Normalize_62a13fd33141482da88d8a4f6cbbc589_Out_1[2];
                    float _Split_0d3686f12540443e91f7387b6f77c10d_A_4 = 0;
                    float _Comparison_e88851318be2459db93159ca801db3b8_Out_2;
                    Unity_Comparison_Greater_float(_Split_0d3686f12540443e91f7387b6f77c10d_B_3, 0, _Comparison_e88851318be2459db93159ca801db3b8_Out_2);
                    float2 _Vector2_cd982aedb6df469f81c94d251afa4ef4_Out_0 = float2(_Split_0d3686f12540443e91f7387b6f77c10d_R_1, _Split_0d3686f12540443e91f7387b6f77c10d_B_3);
                    float2 _Normalize_029f1f95e8854efe8413e4f0e8266c57_Out_1;
                    Unity_Normalize_float2(_Vector2_cd982aedb6df469f81c94d251afa4ef4_Out_0, _Normalize_029f1f95e8854efe8413e4f0e8266c57_Out_1);
                    float _DotProduct_ebf7ce672ca34ebaaa92a71bef863e84_Out_2;
                    Unity_DotProduct_float2(float2(1, 0), _Normalize_029f1f95e8854efe8413e4f0e8266c57_Out_1, _DotProduct_ebf7ce672ca34ebaaa92a71bef863e84_Out_2);
                    float _Arccosine_4b874182f6a14874840ee7586e79f531_Out_1;
                    Unity_Arccosine_float(_DotProduct_ebf7ce672ca34ebaaa92a71bef863e84_Out_2, _Arccosine_4b874182f6a14874840ee7586e79f531_Out_1);
                    float _Multiply_2cb80113cd264bd684265987dfc99fdc_Out_2;
                    Unity_Multiply_float(_DotProduct_ebf7ce672ca34ebaaa92a71bef863e84_Out_2, -1, _Multiply_2cb80113cd264bd684265987dfc99fdc_Out_2);
                    float _Arccosine_4402c39ae97e427eb6a05c3ec6df8476_Out_1;
                    Unity_Arccosine_float(_Multiply_2cb80113cd264bd684265987dfc99fdc_Out_2, _Arccosine_4402c39ae97e427eb6a05c3ec6df8476_Out_1);
                    float Constant_2af68751986845ed87773c58bfc03190 = 3.141593;
                    float _Add_db22dd4581f6401c9b151c2d904fb1fd_Out_2;
                    Unity_Add_float(_Arccosine_4402c39ae97e427eb6a05c3ec6df8476_Out_1, Constant_2af68751986845ed87773c58bfc03190, _Add_db22dd4581f6401c9b151c2d904fb1fd_Out_2);
                    float _Branch_5fd995eba4cc4a4c8abe7fca6cd0c1c8_Out_3;
                    Unity_Branch_float(_Comparison_e88851318be2459db93159ca801db3b8_Out_2, _Arccosine_4b874182f6a14874840ee7586e79f531_Out_1, _Add_db22dd4581f6401c9b151c2d904fb1fd_Out_2, _Branch_5fd995eba4cc4a4c8abe7fca6cd0c1c8_Out_3);
                    float2 _Rotate_e2dc059678654897947c4905d958d640_Out_3;
                    Unity_Rotate_Radians_float(IN.uv0.xy, float2 (0.5, 0.5), _Branch_5fd995eba4cc4a4c8abe7fca6cd0c1c8_Out_3, _Rotate_e2dc059678654897947c4905d958d640_Out_3);
                    float2 _Property_409975023fe344e4969558e96ae8b3fe_Out_0 = _Tiling;
                    float _Property_fe8bd49591be4d8493cd9d1aef424249_Out_0 = _RiverSpeed;
                    float _Multiply_11dac49a52be47e2accb8b9de45dab52_Out_2;
                    Unity_Multiply_float(IN.TimeParameters.x, _Property_fe8bd49591be4d8493cd9d1aef424249_Out_0, _Multiply_11dac49a52be47e2accb8b9de45dab52_Out_2);
                    float _Lerp_8be4d289e2cb484489c128e89e81cbd7_Out_3;
                    Unity_Lerp_float(_Multiply_11dac49a52be47e2accb8b9de45dab52_Out_2, IN.TimeParameters.x, _Remap_669938a90f934b9bab86d586a6917aca_Out_3, _Lerp_8be4d289e2cb484489c128e89e81cbd7_Out_3);
                    float2 _Vector2_d7594f71adcb4015bc07aa3fac73b0cf_Out_0 = float2(_Lerp_8be4d289e2cb484489c128e89e81cbd7_Out_3, 0);
                    float2 _TilingAndOffset_5a892791744c4205818e4162cba3a833_Out_3;
                    Unity_TilingAndOffset_float(_Rotate_e2dc059678654897947c4905d958d640_Out_3, _Property_409975023fe344e4969558e96ae8b3fe_Out_0, _Vector2_d7594f71adcb4015bc07aa3fac73b0cf_Out_0, _TilingAndOffset_5a892791744c4205818e4162cba3a833_Out_3);
                    float _Property_61f2533f1f0f4b2e9a39165110a6d8cb_Out_0 = _RiverNormalRotAdjustment;
                    float2 _Rotate_f20c70501e6a4e1e946bb31f6bd852f4_Out_3;
                    Unity_Rotate_Degrees_float(_TilingAndOffset_5a892791744c4205818e4162cba3a833_Out_3, float2 (0.5, 0.5), _Property_61f2533f1f0f4b2e9a39165110a6d8cb_Out_0, _Rotate_f20c70501e6a4e1e946bb31f6bd852f4_Out_3);
                    float4 _SampleTexture2D_66835b651206479b8da548ce63cec2a2_RGBA_0 = SAMPLE_TEXTURE2D(_Property_ab131e76fa9e4575850bad711d6bc112_Out_0.tex, _Property_ab131e76fa9e4575850bad711d6bc112_Out_0.samplerstate, _Rotate_f20c70501e6a4e1e946bb31f6bd852f4_Out_3);
                    _SampleTexture2D_66835b651206479b8da548ce63cec2a2_RGBA_0.rgb = UnpackNormal(_SampleTexture2D_66835b651206479b8da548ce63cec2a2_RGBA_0);
                    float _SampleTexture2D_66835b651206479b8da548ce63cec2a2_R_4 = _SampleTexture2D_66835b651206479b8da548ce63cec2a2_RGBA_0.r;
                    float _SampleTexture2D_66835b651206479b8da548ce63cec2a2_G_5 = _SampleTexture2D_66835b651206479b8da548ce63cec2a2_RGBA_0.g;
                    float _SampleTexture2D_66835b651206479b8da548ce63cec2a2_B_6 = _SampleTexture2D_66835b651206479b8da548ce63cec2a2_RGBA_0.b;
                    float _SampleTexture2D_66835b651206479b8da548ce63cec2a2_A_7 = _SampleTexture2D_66835b651206479b8da548ce63cec2a2_RGBA_0.a;
                    UnityTexture2D _Property_3ac158951f79428685aa829dd82f0bc3_Out_0 = UnityBuildTexture2DStructNoScale(_LevelRiverNormal);
                    float2 _TilingAndOffset_5e717e1b97944a55bc66662a06d78ea7_Out_3;
                    Unity_TilingAndOffset_float(IN.uv0.xy, _Property_409975023fe344e4969558e96ae8b3fe_Out_0, float2 (0, 0), _TilingAndOffset_5e717e1b97944a55bc66662a06d78ea7_Out_3);
                    float4 _SampleTexture2D_e5aebb8d1445433bacf47e39067cb0a0_RGBA_0 = SAMPLE_TEXTURE2D(_Property_3ac158951f79428685aa829dd82f0bc3_Out_0.tex, _Property_3ac158951f79428685aa829dd82f0bc3_Out_0.samplerstate, _TilingAndOffset_5e717e1b97944a55bc66662a06d78ea7_Out_3);
                    _SampleTexture2D_e5aebb8d1445433bacf47e39067cb0a0_RGBA_0.rgb = UnpackNormal(_SampleTexture2D_e5aebb8d1445433bacf47e39067cb0a0_RGBA_0);
                    float _SampleTexture2D_e5aebb8d1445433bacf47e39067cb0a0_R_4 = _SampleTexture2D_e5aebb8d1445433bacf47e39067cb0a0_RGBA_0.r;
                    float _SampleTexture2D_e5aebb8d1445433bacf47e39067cb0a0_G_5 = _SampleTexture2D_e5aebb8d1445433bacf47e39067cb0a0_RGBA_0.g;
                    float _SampleTexture2D_e5aebb8d1445433bacf47e39067cb0a0_B_6 = _SampleTexture2D_e5aebb8d1445433bacf47e39067cb0a0_RGBA_0.b;
                    float _SampleTexture2D_e5aebb8d1445433bacf47e39067cb0a0_A_7 = _SampleTexture2D_e5aebb8d1445433bacf47e39067cb0a0_RGBA_0.a;
                    float4 _Branch_7d4a670ae12240ccbe8bdb249a237644_Out_3;
                    Unity_Branch_float4(_Comparison_8f4fb954760447e8b0db8924e20fd1d0_Out_2, _SampleTexture2D_66835b651206479b8da548ce63cec2a2_RGBA_0, _SampleTexture2D_e5aebb8d1445433bacf47e39067cb0a0_RGBA_0, _Branch_7d4a670ae12240ccbe8bdb249a237644_Out_3);
                    float4 _Branch_5225751f0aaf4e5885184101068828b5_Out_3;
                    Unity_Branch_float4(_Property_c92104f8c9d245dbb796f54a2386b2fa_Out_0, _Add_3e553e4abf784d7799c718cfe7d51b68_Out_2, _Branch_7d4a670ae12240ccbe8bdb249a237644_Out_3, _Branch_5225751f0aaf4e5885184101068828b5_Out_3);
                    float4 _Lerp_b501d8723a3b46369b51759c91fb6f3c_Out_3;
                    Unity_Lerp_float4(_SampleTexture2D_0121a928620142938ff635ec1ff89401_RGBA_0, _Branch_5225751f0aaf4e5885184101068828b5_Out_3, (_Clamp_0f7ac1e483384940a0714a9e608d50b4_Out_3.xxxx), _Lerp_b501d8723a3b46369b51759c91fb6f3c_Out_3);
                    UnityTexture2D _Property_d6241559ab474e5782a32fe991893c23_Out_0 = UnityBuildTexture2DStructNoScale(_FarNormal);
                    float2 _TilingAndOffset_bdb4faaa2ebc4eb990d5202f25946a55_Out_3;
                    Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), float2 (0, 0), _TilingAndOffset_bdb4faaa2ebc4eb990d5202f25946a55_Out_3);
                    float4 _SampleTexture2D_4e9f3a96a6da4e8bac8f2aa7059e160c_RGBA_0 = SAMPLE_TEXTURE2D(_Property_d6241559ab474e5782a32fe991893c23_Out_0.tex, _Property_d6241559ab474e5782a32fe991893c23_Out_0.samplerstate, _TilingAndOffset_bdb4faaa2ebc4eb990d5202f25946a55_Out_3);
                    _SampleTexture2D_4e9f3a96a6da4e8bac8f2aa7059e160c_RGBA_0.rgb = UnpackNormal(_SampleTexture2D_4e9f3a96a6da4e8bac8f2aa7059e160c_RGBA_0);
                    float _SampleTexture2D_4e9f3a96a6da4e8bac8f2aa7059e160c_R_4 = _SampleTexture2D_4e9f3a96a6da4e8bac8f2aa7059e160c_RGBA_0.r;
                    float _SampleTexture2D_4e9f3a96a6da4e8bac8f2aa7059e160c_G_5 = _SampleTexture2D_4e9f3a96a6da4e8bac8f2aa7059e160c_RGBA_0.g;
                    float _SampleTexture2D_4e9f3a96a6da4e8bac8f2aa7059e160c_B_6 = _SampleTexture2D_4e9f3a96a6da4e8bac8f2aa7059e160c_RGBA_0.b;
                    float _SampleTexture2D_4e9f3a96a6da4e8bac8f2aa7059e160c_A_7 = _SampleTexture2D_4e9f3a96a6da4e8bac8f2aa7059e160c_RGBA_0.a;
                    float _Distance_44875152cc614e5ba9d5c699495f08ab_Out_2;
                    Unity_Distance_float3(IN.WorldSpacePosition, _WorldSpaceCameraPos, _Distance_44875152cc614e5ba9d5c699495f08ab_Out_2);
                    float _Property_aebc16f7283a467a8048e6bb509da7c6_Out_0 = _LODdistance;
                    float _Divide_32fb228b5d524f178b884f2adaa8e599_Out_2;
                    Unity_Divide_float(_Distance_44875152cc614e5ba9d5c699495f08ab_Out_2, _Property_aebc16f7283a467a8048e6bb509da7c6_Out_0, _Divide_32fb228b5d524f178b884f2adaa8e599_Out_2);
                    float4 _Lerp_2e0a60782cb64960ac783789c38969b5_Out_3;
                    Unity_Lerp_float4(_Lerp_b501d8723a3b46369b51759c91fb6f3c_Out_3, _SampleTexture2D_4e9f3a96a6da4e8bac8f2aa7059e160c_RGBA_0, (_Divide_32fb228b5d524f178b884f2adaa8e599_Out_2.xxxx), _Lerp_2e0a60782cb64960ac783789c38969b5_Out_3);
                    float _Property_d642bbaad222433b9f2ebb353b53909f_Out_0 = _Metallic;
                    float _DotProduct_fb1cbb38204242edbadb0a15bc95b04e_Out_2;
                    Unity_DotProduct_float3(-1 * mul((float3x3)UNITY_MATRIX_M, transpose(mul(UNITY_MATRIX_I_M, UNITY_MATRIX_I_V)) [2].xyz), IN.WorldSpaceNormal, _DotProduct_fb1cbb38204242edbadb0a15bc95b04e_Out_2);
                    float _Remap_bde541d934954ce5b99314edcbcd70e5_Out_3;
                    Unity_Remap_float(_DotProduct_fb1cbb38204242edbadb0a15bc95b04e_Out_2, float2 (-1, 0), float2 (0, 1), _Remap_bde541d934954ce5b99314edcbcd70e5_Out_3);
                    float _Multiply_6330a2a6c69948a5aacc174b9da1d2f0_Out_2;
                    Unity_Multiply_float(_Split_17c957ee33bc4e28a994b8b8dd20a89f_A_4, _Remap_bde541d934954ce5b99314edcbcd70e5_Out_3, _Multiply_6330a2a6c69948a5aacc174b9da1d2f0_Out_2);
                    float _Property_bc84cef440384b15875875c65e907453_Out_0 = _DownAlphaStrength;
                    float _Property_f604cf40fc3249839fb755ab1c9d8eb2_Out_0 = _TranceparencyStrength;
                    float _Multiply_c4a5b4f21dfe45d2a2f78cc50eba3ec8_Out_2;
                    Unity_Multiply_float(_Subtract_bd4ff2ba7ce04051b10b968b020d06df_Out_2, _Property_f604cf40fc3249839fb755ab1c9d8eb2_Out_0, _Multiply_c4a5b4f21dfe45d2a2f78cc50eba3ec8_Out_2);
                    float _Clamp_61028b06dbf14a6092a617f0d8a7ac32_Out_3;
                    Unity_Clamp_float(_Multiply_c4a5b4f21dfe45d2a2f78cc50eba3ec8_Out_2, 0, 1, _Clamp_61028b06dbf14a6092a617f0d8a7ac32_Out_3);
                    float _Lerp_106a757383d0403399452dcbb99cc72a_Out_3;
                    Unity_Lerp_float(_Property_bc84cef440384b15875875c65e907453_Out_0, 0, _Clamp_61028b06dbf14a6092a617f0d8a7ac32_Out_3, _Lerp_106a757383d0403399452dcbb99cc72a_Out_3);
                    float _Lerp_729c45b3c3014bdbb92bb4198e06bd92_Out_3;
                    Unity_Lerp_float(1, 0, _Remap_bde541d934954ce5b99314edcbcd70e5_Out_3, _Lerp_729c45b3c3014bdbb92bb4198e06bd92_Out_3);
                    float _Multiply_a80cb3307cd746d7a1bb5f699c9423f3_Out_2;
                    Unity_Multiply_float(_Lerp_106a757383d0403399452dcbb99cc72a_Out_3, _Lerp_729c45b3c3014bdbb92bb4198e06bd92_Out_3, _Multiply_a80cb3307cd746d7a1bb5f699c9423f3_Out_2);
                    float _Lerp_b12dda477cf14695add7f2de406dd644_Out_3;
                    Unity_Lerp_float(_Split_17c957ee33bc4e28a994b8b8dd20a89f_A_4, _Multiply_6330a2a6c69948a5aacc174b9da1d2f0_Out_2, _Multiply_a80cb3307cd746d7a1bb5f699c9423f3_Out_2, _Lerp_b12dda477cf14695add7f2de406dd644_Out_3);
                    surface.BaseColor = _Vector3_3b779f158e6f4ba8ac091e620cd4bd1c_Out_0;
                    surface.NormalTS = (_Lerp_2e0a60782cb64960ac783789c38969b5_Out_3.xyz);
                    surface.Emission = float3(0, 0, 0);
                    surface.Metallic = _Property_d642bbaad222433b9f2ebb353b53909f_Out_0;
                    surface.Smoothness = 0.5;
                    surface.Occlusion = 1;
                    surface.Alpha = _Lerp_b12dda477cf14695add7f2de406dd644_Out_3;
                    return surface;
                }
    
                // --------------------------------------------------
                // Build Graph Inputs
    
                VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                {
                    VertexDescriptionInputs output;
                    ZERO_INITIALIZE(VertexDescriptionInputs, output);
                
                    output.ObjectSpaceNormal =           input.normalOS;
                    output.ObjectSpaceTangent =          input.tangentOS.xyz;
                    output.ObjectSpacePosition =         input.positionOS;
                
                    return output;
                }
                
                SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                {
                    SurfaceDescriptionInputs output;
                    ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
                
                	// must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
                	float3 unnormalizedNormalWS = input.normalWS;
                    const float renormFactor = 1.0 / length(unnormalizedNormalWS);
                
                
                    output.WorldSpaceNormal =            renormFactor*input.normalWS.xyz;		// we want a unit length Normal Vector node in shader graph
                    output.TangentSpaceNormal =          float3(0.0f, 0.0f, 1.0f);
                
                
                    output.WorldSpacePosition =          input.positionWS;
                    output.ScreenPosition =              ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
                    output.uv0 =                         input.texCoord0;
                    output.TimeParameters =              _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                #else
                #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                #endif
                #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                
                    return output;
                }
                
    
                // --------------------------------------------------
                // Main
    
                #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBRForwardPass.hlsl"
    
                ENDHLSL
            }
            Pass
            {
                Name "ShadowCaster"
                Tags
                {
                    "LightMode" = "ShadowCaster"
                }
    
                // Render State
                Cull Off
                Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
                ZTest LEqual
                ZWrite On
                ColorMask 0
    
                // Debug
                // <None>
    
                // --------------------------------------------------
                // Pass
    
                HLSLPROGRAM
    
                // Pragmas
                #pragma target 2.0
                #pragma only_renderers gles gles3 glcore d3d11
                #pragma multi_compile_instancing
                #pragma vertex vert
                #pragma fragment frag
    
                // DotsInstancingOptions: <None>
                // HybridV1InjectedBuiltinProperties: <None>
    
                // Keywords
                // PassKeywords: <None>
                // GraphKeywords: <None>
    
                // Defines
                #define _SURFACE_TYPE_TRANSPARENT 1
                #define _NORMALMAP 1
                #define _NORMAL_DROPOFF_TS 1
                #define ATTRIBUTES_NEED_NORMAL
                #define ATTRIBUTES_NEED_TANGENT
                #define VARYINGS_NEED_POSITION_WS
                #define VARYINGS_NEED_NORMAL_WS
                #define FEATURES_GRAPH_VERTEX
                /* WARNING: $splice Could not find named fragment 'PassInstancing' */
                #define SHADERPASS SHADERPASS_SHADOWCASTER
                #define REQUIRE_DEPTH_TEXTURE
                /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
    
                // Includes
                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
    
                // --------------------------------------------------
                // Structs and Packing
    
                struct Attributes
                {
                    float3 positionOS : POSITION;
                    float3 normalOS : NORMAL;
                    float4 tangentOS : TANGENT;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    uint instanceID : INSTANCEID_SEMANTIC;
                    #endif
                };
                struct Varyings
                {
                    float4 positionCS : SV_POSITION;
                    float3 positionWS;
                    float3 normalWS;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    uint instanceID : CUSTOM_INSTANCE_ID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                    #endif
                };
                struct SurfaceDescriptionInputs
                {
                    float3 WorldSpaceNormal;
                    float3 WorldSpacePosition;
                    float4 ScreenPosition;
                    float3 TimeParameters;
                };
                struct VertexDescriptionInputs
                {
                    float3 ObjectSpaceNormal;
                    float3 ObjectSpaceTangent;
                    float3 ObjectSpacePosition;
                };
                struct PackedVaryings
                {
                    float4 positionCS : SV_POSITION;
                    float3 interp0 : TEXCOORD0;
                    float3 interp1 : TEXCOORD1;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    uint instanceID : CUSTOM_INSTANCE_ID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                    #endif
                };
    
                PackedVaryings PackVaryings (Varyings input)
                {
                    PackedVaryings output;
                    output.positionCS = input.positionCS;
                    output.interp0.xyz =  input.positionWS;
                    output.interp1.xyz =  input.normalWS;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    output.instanceID = input.instanceID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    output.cullFace = input.cullFace;
                    #endif
                    return output;
                }
                Varyings UnpackVaryings (PackedVaryings input)
                {
                    Varyings output;
                    output.positionCS = input.positionCS;
                    output.positionWS = input.interp0.xyz;
                    output.normalWS = input.interp1.xyz;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    output.instanceID = input.instanceID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    output.cullFace = input.cullFace;
                    #endif
                    return output;
                }
    
                // --------------------------------------------------
                // Graph
    
                // Graph Properties
                CBUFFER_START(UnityPerMaterial)
                float _DepthOffset;
                float _Strength;
                float4 _DeepWaterColor;
                float4 _ShallowWaterColor;
                float _Metallic;
                float2 _Tiling;
                float4 _OceanNormal2_TexelSize;
                float4 _OceanNormal1_TexelSize;
                float _GradientNoise;
                float2 _OceanSpeed;
                float _LODdistance;
                float4 _FarNormal_TexelSize;
                float4 _ShallowNormal_TexelSize;
                float _TranceparencyStrength;
                float _DownAlphaStrength;
                float _IsOcean;
                float4 _RiverNormal_TexelSize;
                float _RiverNormalRotAdjustment;
                float4 _LevelRiverNormal_TexelSize;
                float _RiverSpeed;
                float _ShoreIntersectionStrength;
                float4 Color_701f2c2f40b34b87975a0e85a71325dc;
                CBUFFER_END
                
                // Object and Global properties
                SAMPLER(SamplerState_Linear_Repeat);
                TEXTURE2D(_OceanNormal2);
                SAMPLER(sampler_OceanNormal2);
                TEXTURE2D(_OceanNormal1);
                SAMPLER(sampler_OceanNormal1);
                TEXTURE2D(_FarNormal);
                SAMPLER(sampler_FarNormal);
                TEXTURE2D(_ShallowNormal);
                SAMPLER(sampler_ShallowNormal);
                TEXTURE2D(_RiverNormal);
                SAMPLER(sampler_RiverNormal);
                TEXTURE2D(_LevelRiverNormal);
                SAMPLER(sampler_LevelRiverNormal);
                float _StretchScalar;
    
                // Graph Functions
                
                void Unity_SceneDepth_Linear01_float(float4 UV, out float Out)
                {
                    Out = Linear01Depth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
                }
                
                void Unity_Multiply_float(float A, float B, out float Out)
                {
                    Out = A * B;
                }
                
                void Unity_Add_float(float A, float B, out float Out)
                {
                    Out = A + B;
                }
                
                void Unity_Subtract_float(float A, float B, out float Out)
                {
                    Out = A - B;
                }
                
                void Unity_Sine_float(float In, out float Out)
                {
                    Out = sin(In);
                }
                
                void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
                {
                    Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
                }
                
                void Unity_Branch_float(float Predicate, float True, float False, out float Out)
                {
                    Out = Predicate ? True : False;
                }
                
                void Unity_Clamp_float(float In, float Min, float Max, out float Out)
                {
                    Out = clamp(In, Min, Max);
                }
                
                void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
                {
                    Out = lerp(A, B, T);
                }
                
                void Unity_Normalize_float3(float3 In, out float3 Out)
                {
                    Out = normalize(In);
                }
                
                void Unity_DotProduct_float3(float3 A, float3 B, out float Out)
                {
                    Out = dot(A, B);
                }
                
                void Unity_Add_float4(float4 A, float4 B, out float4 Out)
                {
                    Out = A + B;
                }
                
                void Unity_Lerp_float(float A, float B, float T, out float Out)
                {
                    Out = lerp(A, B, T);
                }
    
                // Graph Vertex
                struct VertexDescription
                {
                    float3 Position;
                    float3 Normal;
                    float3 Tangent;
                };
                
                VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                {
                    VertexDescription description = (VertexDescription)0;
                    description.Position = IN.ObjectSpacePosition;
                    description.Normal = IN.ObjectSpaceNormal;
                    description.Tangent = IN.ObjectSpaceTangent;
                    return description;
                }
    
                // Graph Pixel
                struct SurfaceDescription
                {
                    float Alpha;
                };
                
                SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                {
                    SurfaceDescription surface = (SurfaceDescription)0;
                    float4 _Property_231c0d262d3a466d85dfd53b116086ca_Out_0 = Color_701f2c2f40b34b87975a0e85a71325dc;
                    float _SceneDepth_3137d738aa0149fb8a54d88a60826a60_Out_1;
                    Unity_SceneDepth_Linear01_float(float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0), _SceneDepth_3137d738aa0149fb8a54d88a60826a60_Out_1);
                    float _Multiply_8ec8e0a1878e494ca0d6d16678168741_Out_2;
                    Unity_Multiply_float(_SceneDepth_3137d738aa0149fb8a54d88a60826a60_Out_1, _ProjectionParams.z, _Multiply_8ec8e0a1878e494ca0d6d16678168741_Out_2);
                    float4 _ScreenPosition_3840c0fb20fc4eb58387cd54ee7e2b18_Out_0 = IN.ScreenPosition;
                    float _Split_578ef5cadaac40969c114c4d1ae870d8_R_1 = _ScreenPosition_3840c0fb20fc4eb58387cd54ee7e2b18_Out_0[0];
                    float _Split_578ef5cadaac40969c114c4d1ae870d8_G_2 = _ScreenPosition_3840c0fb20fc4eb58387cd54ee7e2b18_Out_0[1];
                    float _Split_578ef5cadaac40969c114c4d1ae870d8_B_3 = _ScreenPosition_3840c0fb20fc4eb58387cd54ee7e2b18_Out_0[2];
                    float _Split_578ef5cadaac40969c114c4d1ae870d8_A_4 = _ScreenPosition_3840c0fb20fc4eb58387cd54ee7e2b18_Out_0[3];
                    float _Property_cedd17331b16484abf1a4ce8eb0e5a72_Out_0 = _DepthOffset;
                    float _Add_e04e1bc3087745d898c282f10a0f43e3_Out_2;
                    Unity_Add_float(_Split_578ef5cadaac40969c114c4d1ae870d8_A_4, _Property_cedd17331b16484abf1a4ce8eb0e5a72_Out_0, _Add_e04e1bc3087745d898c282f10a0f43e3_Out_2);
                    float _Subtract_bd4ff2ba7ce04051b10b968b020d06df_Out_2;
                    Unity_Subtract_float(_Multiply_8ec8e0a1878e494ca0d6d16678168741_Out_2, _Add_e04e1bc3087745d898c282f10a0f43e3_Out_2, _Subtract_bd4ff2ba7ce04051b10b968b020d06df_Out_2);
                    float _Property_90205b2f827548b295dc151171bc164c_Out_0 = _IsOcean;
                    float _Sine_24a173ac1d9d40b5b43bd7c8169386e4_Out_1;
                    Unity_Sine_float(IN.TimeParameters.x, _Sine_24a173ac1d9d40b5b43bd7c8169386e4_Out_1);
                    float _Remap_9ed3ea235fdc44d7a8c762cbe7ff6d0e_Out_3;
                    Unity_Remap_float(_Sine_24a173ac1d9d40b5b43bd7c8169386e4_Out_1, float2 (-1, 1), float2 (0.5, 1), _Remap_9ed3ea235fdc44d7a8c762cbe7ff6d0e_Out_3);
                    float _Branch_fcfcb84348fb4a5a90417124dc9ee3a2_Out_3;
                    Unity_Branch_float(_Property_90205b2f827548b295dc151171bc164c_Out_0, _Remap_9ed3ea235fdc44d7a8c762cbe7ff6d0e_Out_3, 1, _Branch_fcfcb84348fb4a5a90417124dc9ee3a2_Out_3);
                    float _Property_866bbbbe2a484e2eae1ad77ed223a577_Out_0 = _ShoreIntersectionStrength;
                    float _Multiply_cb7f54f30fb348b4a7f109f458e38b17_Out_2;
                    Unity_Multiply_float(_Branch_fcfcb84348fb4a5a90417124dc9ee3a2_Out_3, _Property_866bbbbe2a484e2eae1ad77ed223a577_Out_0, _Multiply_cb7f54f30fb348b4a7f109f458e38b17_Out_2);
                    float _Multiply_dcdae92bb4dd401a89df781ec062cecc_Out_2;
                    Unity_Multiply_float(_Subtract_bd4ff2ba7ce04051b10b968b020d06df_Out_2, _Multiply_cb7f54f30fb348b4a7f109f458e38b17_Out_2, _Multiply_dcdae92bb4dd401a89df781ec062cecc_Out_2);
                    float _Clamp_33ee6da80fc14439b6d7bab14be7ab07_Out_3;
                    Unity_Clamp_float(_Multiply_dcdae92bb4dd401a89df781ec062cecc_Out_2, 0.5, 1, _Clamp_33ee6da80fc14439b6d7bab14be7ab07_Out_3);
                    float4 _Lerp_f0669e92de0b409893955d23347ac238_Out_3;
                    Unity_Lerp_float4(_Property_231c0d262d3a466d85dfd53b116086ca_Out_0, float4(0, 0, 0, 0), (_Clamp_33ee6da80fc14439b6d7bab14be7ab07_Out_3.xxxx), _Lerp_f0669e92de0b409893955d23347ac238_Out_3);
                    float _Float_c4cf30aef9464dda83de90c7e790a9ba_Out_0 = 1.5;
                    float4 _Property_c854872c24e048c0aa372f0be547f07c_Out_0 = _ShallowWaterColor;
                    float4 _Property_dde44c4f61534e08a917dd16bcf5ebca_Out_0 = _DeepWaterColor;
                    float _Property_d328dfa89c674e67bffe73ef574a2d58_Out_0 = _Strength;
                    float _Multiply_4eb7822d949844e38f2bb60067662a47_Out_2;
                    Unity_Multiply_float(_Subtract_bd4ff2ba7ce04051b10b968b020d06df_Out_2, _Property_d328dfa89c674e67bffe73ef574a2d58_Out_0, _Multiply_4eb7822d949844e38f2bb60067662a47_Out_2);
                    float _Clamp_0f7ac1e483384940a0714a9e608d50b4_Out_3;
                    Unity_Clamp_float(_Multiply_4eb7822d949844e38f2bb60067662a47_Out_2, 0, 1, _Clamp_0f7ac1e483384940a0714a9e608d50b4_Out_3);
                    float4 _Lerp_3f9225ad7cdc45509b625268ef70e29c_Out_3;
                    Unity_Lerp_float4(_Property_c854872c24e048c0aa372f0be547f07c_Out_0, _Property_dde44c4f61534e08a917dd16bcf5ebca_Out_0, (_Clamp_0f7ac1e483384940a0714a9e608d50b4_Out_3.xxxx), _Lerp_3f9225ad7cdc45509b625268ef70e29c_Out_3);
                    float3 _Normalize_415b503188e443458e4172309aa4cb18_Out_1;
                    Unity_Normalize_float3(IN.WorldSpaceNormal, _Normalize_415b503188e443458e4172309aa4cb18_Out_1);
                    float _DotProduct_b3f1b90b273a4b2b99f07acbc4565dcb_Out_2;
                    Unity_DotProduct_float3(float3(0, 1, 0), _Normalize_415b503188e443458e4172309aa4cb18_Out_1, _DotProduct_b3f1b90b273a4b2b99f07acbc4565dcb_Out_2);
                    float _Remap_669938a90f934b9bab86d586a6917aca_Out_3;
                    Unity_Remap_float(_DotProduct_b3f1b90b273a4b2b99f07acbc4565dcb_Out_2, float2 (-1, 1), float2 (0, 1), _Remap_669938a90f934b9bab86d586a6917aca_Out_3);
                    float4 _Lerp_4536ba8c658e4f11aaefc80660368304_Out_3;
                    Unity_Lerp_float4((_Float_c4cf30aef9464dda83de90c7e790a9ba_Out_0.xxxx), _Lerp_3f9225ad7cdc45509b625268ef70e29c_Out_3, (_Remap_669938a90f934b9bab86d586a6917aca_Out_3.xxxx), _Lerp_4536ba8c658e4f11aaefc80660368304_Out_3);
                    float4 _Add_f8fda8450f33454d96a6212c8ebfdc62_Out_2;
                    Unity_Add_float4(_Lerp_f0669e92de0b409893955d23347ac238_Out_3, _Lerp_4536ba8c658e4f11aaefc80660368304_Out_3, _Add_f8fda8450f33454d96a6212c8ebfdc62_Out_2);
                    float _Split_17c957ee33bc4e28a994b8b8dd20a89f_R_1 = _Add_f8fda8450f33454d96a6212c8ebfdc62_Out_2[0];
                    float _Split_17c957ee33bc4e28a994b8b8dd20a89f_G_2 = _Add_f8fda8450f33454d96a6212c8ebfdc62_Out_2[1];
                    float _Split_17c957ee33bc4e28a994b8b8dd20a89f_B_3 = _Add_f8fda8450f33454d96a6212c8ebfdc62_Out_2[2];
                    float _Split_17c957ee33bc4e28a994b8b8dd20a89f_A_4 = _Add_f8fda8450f33454d96a6212c8ebfdc62_Out_2[3];
                    float _DotProduct_fb1cbb38204242edbadb0a15bc95b04e_Out_2;
                    Unity_DotProduct_float3(-1 * mul((float3x3)UNITY_MATRIX_M, transpose(mul(UNITY_MATRIX_I_M, UNITY_MATRIX_I_V)) [2].xyz), IN.WorldSpaceNormal, _DotProduct_fb1cbb38204242edbadb0a15bc95b04e_Out_2);
                    float _Remap_bde541d934954ce5b99314edcbcd70e5_Out_3;
                    Unity_Remap_float(_DotProduct_fb1cbb38204242edbadb0a15bc95b04e_Out_2, float2 (-1, 0), float2 (0, 1), _Remap_bde541d934954ce5b99314edcbcd70e5_Out_3);
                    float _Multiply_6330a2a6c69948a5aacc174b9da1d2f0_Out_2;
                    Unity_Multiply_float(_Split_17c957ee33bc4e28a994b8b8dd20a89f_A_4, _Remap_bde541d934954ce5b99314edcbcd70e5_Out_3, _Multiply_6330a2a6c69948a5aacc174b9da1d2f0_Out_2);
                    float _Property_bc84cef440384b15875875c65e907453_Out_0 = _DownAlphaStrength;
                    float _Property_f604cf40fc3249839fb755ab1c9d8eb2_Out_0 = _TranceparencyStrength;
                    float _Multiply_c4a5b4f21dfe45d2a2f78cc50eba3ec8_Out_2;
                    Unity_Multiply_float(_Subtract_bd4ff2ba7ce04051b10b968b020d06df_Out_2, _Property_f604cf40fc3249839fb755ab1c9d8eb2_Out_0, _Multiply_c4a5b4f21dfe45d2a2f78cc50eba3ec8_Out_2);
                    float _Clamp_61028b06dbf14a6092a617f0d8a7ac32_Out_3;
                    Unity_Clamp_float(_Multiply_c4a5b4f21dfe45d2a2f78cc50eba3ec8_Out_2, 0, 1, _Clamp_61028b06dbf14a6092a617f0d8a7ac32_Out_3);
                    float _Lerp_106a757383d0403399452dcbb99cc72a_Out_3;
                    Unity_Lerp_float(_Property_bc84cef440384b15875875c65e907453_Out_0, 0, _Clamp_61028b06dbf14a6092a617f0d8a7ac32_Out_3, _Lerp_106a757383d0403399452dcbb99cc72a_Out_3);
                    float _Lerp_729c45b3c3014bdbb92bb4198e06bd92_Out_3;
                    Unity_Lerp_float(1, 0, _Remap_bde541d934954ce5b99314edcbcd70e5_Out_3, _Lerp_729c45b3c3014bdbb92bb4198e06bd92_Out_3);
                    float _Multiply_a80cb3307cd746d7a1bb5f699c9423f3_Out_2;
                    Unity_Multiply_float(_Lerp_106a757383d0403399452dcbb99cc72a_Out_3, _Lerp_729c45b3c3014bdbb92bb4198e06bd92_Out_3, _Multiply_a80cb3307cd746d7a1bb5f699c9423f3_Out_2);
                    float _Lerp_b12dda477cf14695add7f2de406dd644_Out_3;
                    Unity_Lerp_float(_Split_17c957ee33bc4e28a994b8b8dd20a89f_A_4, _Multiply_6330a2a6c69948a5aacc174b9da1d2f0_Out_2, _Multiply_a80cb3307cd746d7a1bb5f699c9423f3_Out_2, _Lerp_b12dda477cf14695add7f2de406dd644_Out_3);
                    surface.Alpha = _Lerp_b12dda477cf14695add7f2de406dd644_Out_3;
                    return surface;
                }
    
                // --------------------------------------------------
                // Build Graph Inputs
    
                VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                {
                    VertexDescriptionInputs output;
                    ZERO_INITIALIZE(VertexDescriptionInputs, output);
                
                    output.ObjectSpaceNormal =           input.normalOS;
                    output.ObjectSpaceTangent =          input.tangentOS.xyz;
                    output.ObjectSpacePosition =         input.positionOS;
                
                    return output;
                }
                
                SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                {
                    SurfaceDescriptionInputs output;
                    ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
                
                	// must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
                	float3 unnormalizedNormalWS = input.normalWS;
                    const float renormFactor = 1.0 / length(unnormalizedNormalWS);
                
                
                    output.WorldSpaceNormal =            renormFactor*input.normalWS.xyz;		// we want a unit length Normal Vector node in shader graph
                
                
                    output.WorldSpacePosition =          input.positionWS;
                    output.ScreenPosition =              ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
                    output.TimeParameters =              _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                #else
                #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                #endif
                #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                
                    return output;
                }
                
    
                // --------------------------------------------------
                // Main
    
                #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShadowCasterPass.hlsl"
    
                ENDHLSL
            }
            Pass
            {
                Name "DepthOnly"
                Tags
                {
                    "LightMode" = "DepthOnly"
                }
    
                // Render State
                Cull Off
                Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
                ZTest LEqual
                ZWrite On
                ColorMask 0
    
                // Debug
                // <None>
    
                // --------------------------------------------------
                // Pass
    
                HLSLPROGRAM
    
                // Pragmas
                #pragma target 2.0
                #pragma only_renderers gles gles3 glcore d3d11
                #pragma multi_compile_instancing
                #pragma vertex vert
                #pragma fragment frag
    
                // DotsInstancingOptions: <None>
                // HybridV1InjectedBuiltinProperties: <None>
    
                // Keywords
                // PassKeywords: <None>
                // GraphKeywords: <None>
    
                // Defines
                #define _SURFACE_TYPE_TRANSPARENT 1
                #define _NORMALMAP 1
                #define _NORMAL_DROPOFF_TS 1
                #define ATTRIBUTES_NEED_NORMAL
                #define ATTRIBUTES_NEED_TANGENT
                #define VARYINGS_NEED_POSITION_WS
                #define VARYINGS_NEED_NORMAL_WS
                #define FEATURES_GRAPH_VERTEX
                /* WARNING: $splice Could not find named fragment 'PassInstancing' */
                #define SHADERPASS SHADERPASS_DEPTHONLY
                #define REQUIRE_DEPTH_TEXTURE
                /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
    
                // Includes
                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
    
                // --------------------------------------------------
                // Structs and Packing
    
                struct Attributes
                {
                    float3 positionOS : POSITION;
                    float3 normalOS : NORMAL;
                    float4 tangentOS : TANGENT;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    uint instanceID : INSTANCEID_SEMANTIC;
                    #endif
                };
                struct Varyings
                {
                    float4 positionCS : SV_POSITION;
                    float3 positionWS;
                    float3 normalWS;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    uint instanceID : CUSTOM_INSTANCE_ID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                    #endif
                };
                struct SurfaceDescriptionInputs
                {
                    float3 WorldSpaceNormal;
                    float3 WorldSpacePosition;
                    float4 ScreenPosition;
                    float3 TimeParameters;
                };
                struct VertexDescriptionInputs
                {
                    float3 ObjectSpaceNormal;
                    float3 ObjectSpaceTangent;
                    float3 ObjectSpacePosition;
                };
                struct PackedVaryings
                {
                    float4 positionCS : SV_POSITION;
                    float3 interp0 : TEXCOORD0;
                    float3 interp1 : TEXCOORD1;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    uint instanceID : CUSTOM_INSTANCE_ID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                    #endif
                };
    
                PackedVaryings PackVaryings (Varyings input)
                {
                    PackedVaryings output;
                    output.positionCS = input.positionCS;
                    output.interp0.xyz =  input.positionWS;
                    output.interp1.xyz =  input.normalWS;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    output.instanceID = input.instanceID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    output.cullFace = input.cullFace;
                    #endif
                    return output;
                }
                Varyings UnpackVaryings (PackedVaryings input)
                {
                    Varyings output;
                    output.positionCS = input.positionCS;
                    output.positionWS = input.interp0.xyz;
                    output.normalWS = input.interp1.xyz;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    output.instanceID = input.instanceID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    output.cullFace = input.cullFace;
                    #endif
                    return output;
                }
    
                // --------------------------------------------------
                // Graph
    
                // Graph Properties
                CBUFFER_START(UnityPerMaterial)
                float _DepthOffset;
                float _Strength;
                float4 _DeepWaterColor;
                float4 _ShallowWaterColor;
                float _Metallic;
                float2 _Tiling;
                float4 _OceanNormal2_TexelSize;
                float4 _OceanNormal1_TexelSize;
                float _GradientNoise;
                float2 _OceanSpeed;
                float _LODdistance;
                float4 _FarNormal_TexelSize;
                float4 _ShallowNormal_TexelSize;
                float _TranceparencyStrength;
                float _DownAlphaStrength;
                float _IsOcean;
                float4 _RiverNormal_TexelSize;
                float _RiverNormalRotAdjustment;
                float4 _LevelRiverNormal_TexelSize;
                float _RiverSpeed;
                float _ShoreIntersectionStrength;
                float4 Color_701f2c2f40b34b87975a0e85a71325dc;
                CBUFFER_END
                
                // Object and Global properties
                SAMPLER(SamplerState_Linear_Repeat);
                TEXTURE2D(_OceanNormal2);
                SAMPLER(sampler_OceanNormal2);
                TEXTURE2D(_OceanNormal1);
                SAMPLER(sampler_OceanNormal1);
                TEXTURE2D(_FarNormal);
                SAMPLER(sampler_FarNormal);
                TEXTURE2D(_ShallowNormal);
                SAMPLER(sampler_ShallowNormal);
                TEXTURE2D(_RiverNormal);
                SAMPLER(sampler_RiverNormal);
                TEXTURE2D(_LevelRiverNormal);
                SAMPLER(sampler_LevelRiverNormal);
                float _StretchScalar;
    
                // Graph Functions
                
                void Unity_SceneDepth_Linear01_float(float4 UV, out float Out)
                {
                    Out = Linear01Depth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
                }
                
                void Unity_Multiply_float(float A, float B, out float Out)
                {
                    Out = A * B;
                }
                
                void Unity_Add_float(float A, float B, out float Out)
                {
                    Out = A + B;
                }
                
                void Unity_Subtract_float(float A, float B, out float Out)
                {
                    Out = A - B;
                }
                
                void Unity_Sine_float(float In, out float Out)
                {
                    Out = sin(In);
                }
                
                void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
                {
                    Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
                }
                
                void Unity_Branch_float(float Predicate, float True, float False, out float Out)
                {
                    Out = Predicate ? True : False;
                }
                
                void Unity_Clamp_float(float In, float Min, float Max, out float Out)
                {
                    Out = clamp(In, Min, Max);
                }
                
                void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
                {
                    Out = lerp(A, B, T);
                }
                
                void Unity_Normalize_float3(float3 In, out float3 Out)
                {
                    Out = normalize(In);
                }
                
                void Unity_DotProduct_float3(float3 A, float3 B, out float Out)
                {
                    Out = dot(A, B);
                }
                
                void Unity_Add_float4(float4 A, float4 B, out float4 Out)
                {
                    Out = A + B;
                }
                
                void Unity_Lerp_float(float A, float B, float T, out float Out)
                {
                    Out = lerp(A, B, T);
                }
    
                // Graph Vertex
                struct VertexDescription
                {
                    float3 Position;
                    float3 Normal;
                    float3 Tangent;
                };
                
                VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                {
                    VertexDescription description = (VertexDescription)0;
                    description.Position = IN.ObjectSpacePosition;
                    description.Normal = IN.ObjectSpaceNormal;
                    description.Tangent = IN.ObjectSpaceTangent;
                    return description;
                }
    
                // Graph Pixel
                struct SurfaceDescription
                {
                    float Alpha;
                };
                
                SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                {
                    SurfaceDescription surface = (SurfaceDescription)0;
                    float4 _Property_231c0d262d3a466d85dfd53b116086ca_Out_0 = Color_701f2c2f40b34b87975a0e85a71325dc;
                    float _SceneDepth_3137d738aa0149fb8a54d88a60826a60_Out_1;
                    Unity_SceneDepth_Linear01_float(float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0), _SceneDepth_3137d738aa0149fb8a54d88a60826a60_Out_1);
                    float _Multiply_8ec8e0a1878e494ca0d6d16678168741_Out_2;
                    Unity_Multiply_float(_SceneDepth_3137d738aa0149fb8a54d88a60826a60_Out_1, _ProjectionParams.z, _Multiply_8ec8e0a1878e494ca0d6d16678168741_Out_2);
                    float4 _ScreenPosition_3840c0fb20fc4eb58387cd54ee7e2b18_Out_0 = IN.ScreenPosition;
                    float _Split_578ef5cadaac40969c114c4d1ae870d8_R_1 = _ScreenPosition_3840c0fb20fc4eb58387cd54ee7e2b18_Out_0[0];
                    float _Split_578ef5cadaac40969c114c4d1ae870d8_G_2 = _ScreenPosition_3840c0fb20fc4eb58387cd54ee7e2b18_Out_0[1];
                    float _Split_578ef5cadaac40969c114c4d1ae870d8_B_3 = _ScreenPosition_3840c0fb20fc4eb58387cd54ee7e2b18_Out_0[2];
                    float _Split_578ef5cadaac40969c114c4d1ae870d8_A_4 = _ScreenPosition_3840c0fb20fc4eb58387cd54ee7e2b18_Out_0[3];
                    float _Property_cedd17331b16484abf1a4ce8eb0e5a72_Out_0 = _DepthOffset;
                    float _Add_e04e1bc3087745d898c282f10a0f43e3_Out_2;
                    Unity_Add_float(_Split_578ef5cadaac40969c114c4d1ae870d8_A_4, _Property_cedd17331b16484abf1a4ce8eb0e5a72_Out_0, _Add_e04e1bc3087745d898c282f10a0f43e3_Out_2);
                    float _Subtract_bd4ff2ba7ce04051b10b968b020d06df_Out_2;
                    Unity_Subtract_float(_Multiply_8ec8e0a1878e494ca0d6d16678168741_Out_2, _Add_e04e1bc3087745d898c282f10a0f43e3_Out_2, _Subtract_bd4ff2ba7ce04051b10b968b020d06df_Out_2);
                    float _Property_90205b2f827548b295dc151171bc164c_Out_0 = _IsOcean;
                    float _Sine_24a173ac1d9d40b5b43bd7c8169386e4_Out_1;
                    Unity_Sine_float(IN.TimeParameters.x, _Sine_24a173ac1d9d40b5b43bd7c8169386e4_Out_1);
                    float _Remap_9ed3ea235fdc44d7a8c762cbe7ff6d0e_Out_3;
                    Unity_Remap_float(_Sine_24a173ac1d9d40b5b43bd7c8169386e4_Out_1, float2 (-1, 1), float2 (0.5, 1), _Remap_9ed3ea235fdc44d7a8c762cbe7ff6d0e_Out_3);
                    float _Branch_fcfcb84348fb4a5a90417124dc9ee3a2_Out_3;
                    Unity_Branch_float(_Property_90205b2f827548b295dc151171bc164c_Out_0, _Remap_9ed3ea235fdc44d7a8c762cbe7ff6d0e_Out_3, 1, _Branch_fcfcb84348fb4a5a90417124dc9ee3a2_Out_3);
                    float _Property_866bbbbe2a484e2eae1ad77ed223a577_Out_0 = _ShoreIntersectionStrength;
                    float _Multiply_cb7f54f30fb348b4a7f109f458e38b17_Out_2;
                    Unity_Multiply_float(_Branch_fcfcb84348fb4a5a90417124dc9ee3a2_Out_3, _Property_866bbbbe2a484e2eae1ad77ed223a577_Out_0, _Multiply_cb7f54f30fb348b4a7f109f458e38b17_Out_2);
                    float _Multiply_dcdae92bb4dd401a89df781ec062cecc_Out_2;
                    Unity_Multiply_float(_Subtract_bd4ff2ba7ce04051b10b968b020d06df_Out_2, _Multiply_cb7f54f30fb348b4a7f109f458e38b17_Out_2, _Multiply_dcdae92bb4dd401a89df781ec062cecc_Out_2);
                    float _Clamp_33ee6da80fc14439b6d7bab14be7ab07_Out_3;
                    Unity_Clamp_float(_Multiply_dcdae92bb4dd401a89df781ec062cecc_Out_2, 0.5, 1, _Clamp_33ee6da80fc14439b6d7bab14be7ab07_Out_3);
                    float4 _Lerp_f0669e92de0b409893955d23347ac238_Out_3;
                    Unity_Lerp_float4(_Property_231c0d262d3a466d85dfd53b116086ca_Out_0, float4(0, 0, 0, 0), (_Clamp_33ee6da80fc14439b6d7bab14be7ab07_Out_3.xxxx), _Lerp_f0669e92de0b409893955d23347ac238_Out_3);
                    float _Float_c4cf30aef9464dda83de90c7e790a9ba_Out_0 = 1.5;
                    float4 _Property_c854872c24e048c0aa372f0be547f07c_Out_0 = _ShallowWaterColor;
                    float4 _Property_dde44c4f61534e08a917dd16bcf5ebca_Out_0 = _DeepWaterColor;
                    float _Property_d328dfa89c674e67bffe73ef574a2d58_Out_0 = _Strength;
                    float _Multiply_4eb7822d949844e38f2bb60067662a47_Out_2;
                    Unity_Multiply_float(_Subtract_bd4ff2ba7ce04051b10b968b020d06df_Out_2, _Property_d328dfa89c674e67bffe73ef574a2d58_Out_0, _Multiply_4eb7822d949844e38f2bb60067662a47_Out_2);
                    float _Clamp_0f7ac1e483384940a0714a9e608d50b4_Out_3;
                    Unity_Clamp_float(_Multiply_4eb7822d949844e38f2bb60067662a47_Out_2, 0, 1, _Clamp_0f7ac1e483384940a0714a9e608d50b4_Out_3);
                    float4 _Lerp_3f9225ad7cdc45509b625268ef70e29c_Out_3;
                    Unity_Lerp_float4(_Property_c854872c24e048c0aa372f0be547f07c_Out_0, _Property_dde44c4f61534e08a917dd16bcf5ebca_Out_0, (_Clamp_0f7ac1e483384940a0714a9e608d50b4_Out_3.xxxx), _Lerp_3f9225ad7cdc45509b625268ef70e29c_Out_3);
                    float3 _Normalize_415b503188e443458e4172309aa4cb18_Out_1;
                    Unity_Normalize_float3(IN.WorldSpaceNormal, _Normalize_415b503188e443458e4172309aa4cb18_Out_1);
                    float _DotProduct_b3f1b90b273a4b2b99f07acbc4565dcb_Out_2;
                    Unity_DotProduct_float3(float3(0, 1, 0), _Normalize_415b503188e443458e4172309aa4cb18_Out_1, _DotProduct_b3f1b90b273a4b2b99f07acbc4565dcb_Out_2);
                    float _Remap_669938a90f934b9bab86d586a6917aca_Out_3;
                    Unity_Remap_float(_DotProduct_b3f1b90b273a4b2b99f07acbc4565dcb_Out_2, float2 (-1, 1), float2 (0, 1), _Remap_669938a90f934b9bab86d586a6917aca_Out_3);
                    float4 _Lerp_4536ba8c658e4f11aaefc80660368304_Out_3;
                    Unity_Lerp_float4((_Float_c4cf30aef9464dda83de90c7e790a9ba_Out_0.xxxx), _Lerp_3f9225ad7cdc45509b625268ef70e29c_Out_3, (_Remap_669938a90f934b9bab86d586a6917aca_Out_3.xxxx), _Lerp_4536ba8c658e4f11aaefc80660368304_Out_3);
                    float4 _Add_f8fda8450f33454d96a6212c8ebfdc62_Out_2;
                    Unity_Add_float4(_Lerp_f0669e92de0b409893955d23347ac238_Out_3, _Lerp_4536ba8c658e4f11aaefc80660368304_Out_3, _Add_f8fda8450f33454d96a6212c8ebfdc62_Out_2);
                    float _Split_17c957ee33bc4e28a994b8b8dd20a89f_R_1 = _Add_f8fda8450f33454d96a6212c8ebfdc62_Out_2[0];
                    float _Split_17c957ee33bc4e28a994b8b8dd20a89f_G_2 = _Add_f8fda8450f33454d96a6212c8ebfdc62_Out_2[1];
                    float _Split_17c957ee33bc4e28a994b8b8dd20a89f_B_3 = _Add_f8fda8450f33454d96a6212c8ebfdc62_Out_2[2];
                    float _Split_17c957ee33bc4e28a994b8b8dd20a89f_A_4 = _Add_f8fda8450f33454d96a6212c8ebfdc62_Out_2[3];
                    float _DotProduct_fb1cbb38204242edbadb0a15bc95b04e_Out_2;
                    Unity_DotProduct_float3(-1 * mul((float3x3)UNITY_MATRIX_M, transpose(mul(UNITY_MATRIX_I_M, UNITY_MATRIX_I_V)) [2].xyz), IN.WorldSpaceNormal, _DotProduct_fb1cbb38204242edbadb0a15bc95b04e_Out_2);
                    float _Remap_bde541d934954ce5b99314edcbcd70e5_Out_3;
                    Unity_Remap_float(_DotProduct_fb1cbb38204242edbadb0a15bc95b04e_Out_2, float2 (-1, 0), float2 (0, 1), _Remap_bde541d934954ce5b99314edcbcd70e5_Out_3);
                    float _Multiply_6330a2a6c69948a5aacc174b9da1d2f0_Out_2;
                    Unity_Multiply_float(_Split_17c957ee33bc4e28a994b8b8dd20a89f_A_4, _Remap_bde541d934954ce5b99314edcbcd70e5_Out_3, _Multiply_6330a2a6c69948a5aacc174b9da1d2f0_Out_2);
                    float _Property_bc84cef440384b15875875c65e907453_Out_0 = _DownAlphaStrength;
                    float _Property_f604cf40fc3249839fb755ab1c9d8eb2_Out_0 = _TranceparencyStrength;
                    float _Multiply_c4a5b4f21dfe45d2a2f78cc50eba3ec8_Out_2;
                    Unity_Multiply_float(_Subtract_bd4ff2ba7ce04051b10b968b020d06df_Out_2, _Property_f604cf40fc3249839fb755ab1c9d8eb2_Out_0, _Multiply_c4a5b4f21dfe45d2a2f78cc50eba3ec8_Out_2);
                    float _Clamp_61028b06dbf14a6092a617f0d8a7ac32_Out_3;
                    Unity_Clamp_float(_Multiply_c4a5b4f21dfe45d2a2f78cc50eba3ec8_Out_2, 0, 1, _Clamp_61028b06dbf14a6092a617f0d8a7ac32_Out_3);
                    float _Lerp_106a757383d0403399452dcbb99cc72a_Out_3;
                    Unity_Lerp_float(_Property_bc84cef440384b15875875c65e907453_Out_0, 0, _Clamp_61028b06dbf14a6092a617f0d8a7ac32_Out_3, _Lerp_106a757383d0403399452dcbb99cc72a_Out_3);
                    float _Lerp_729c45b3c3014bdbb92bb4198e06bd92_Out_3;
                    Unity_Lerp_float(1, 0, _Remap_bde541d934954ce5b99314edcbcd70e5_Out_3, _Lerp_729c45b3c3014bdbb92bb4198e06bd92_Out_3);
                    float _Multiply_a80cb3307cd746d7a1bb5f699c9423f3_Out_2;
                    Unity_Multiply_float(_Lerp_106a757383d0403399452dcbb99cc72a_Out_3, _Lerp_729c45b3c3014bdbb92bb4198e06bd92_Out_3, _Multiply_a80cb3307cd746d7a1bb5f699c9423f3_Out_2);
                    float _Lerp_b12dda477cf14695add7f2de406dd644_Out_3;
                    Unity_Lerp_float(_Split_17c957ee33bc4e28a994b8b8dd20a89f_A_4, _Multiply_6330a2a6c69948a5aacc174b9da1d2f0_Out_2, _Multiply_a80cb3307cd746d7a1bb5f699c9423f3_Out_2, _Lerp_b12dda477cf14695add7f2de406dd644_Out_3);
                    surface.Alpha = _Lerp_b12dda477cf14695add7f2de406dd644_Out_3;
                    return surface;
                }
    
                // --------------------------------------------------
                // Build Graph Inputs
    
                VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                {
                    VertexDescriptionInputs output;
                    ZERO_INITIALIZE(VertexDescriptionInputs, output);
                
                    output.ObjectSpaceNormal =           input.normalOS;
                    output.ObjectSpaceTangent =          input.tangentOS.xyz;
                    output.ObjectSpacePosition =         input.positionOS;
                
                    return output;
                }
                
                SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                {
                    SurfaceDescriptionInputs output;
                    ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
                
                	// must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
                	float3 unnormalizedNormalWS = input.normalWS;
                    const float renormFactor = 1.0 / length(unnormalizedNormalWS);
                
                
                    output.WorldSpaceNormal =            renormFactor*input.normalWS.xyz;		// we want a unit length Normal Vector node in shader graph
                
                
                    output.WorldSpacePosition =          input.positionWS;
                    output.ScreenPosition =              ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
                    output.TimeParameters =              _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                #else
                #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                #endif
                #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                
                    return output;
                }
                
    
                // --------------------------------------------------
                // Main
    
                #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DepthOnlyPass.hlsl"
    
                ENDHLSL
            }
            Pass
            {
                Name "DepthNormals"
                Tags
                {
                    "LightMode" = "DepthNormals"
                }
    
                // Render State
                Cull Off
                Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
                ZTest LEqual
                ZWrite On
    
                // Debug
                // <None>
    
                // --------------------------------------------------
                // Pass
    
                HLSLPROGRAM
    
                // Pragmas
                #pragma target 2.0
                #pragma only_renderers gles gles3 glcore d3d11
                #pragma multi_compile_instancing
                #pragma vertex vert
                #pragma fragment frag
    
                // DotsInstancingOptions: <None>
                // HybridV1InjectedBuiltinProperties: <None>
    
                // Keywords
                // PassKeywords: <None>
                // GraphKeywords: <None>
    
                // Defines
                #define _SURFACE_TYPE_TRANSPARENT 1
                #define _NORMALMAP 1
                #define _NORMAL_DROPOFF_TS 1
                #define ATTRIBUTES_NEED_NORMAL
                #define ATTRIBUTES_NEED_TANGENT
                #define ATTRIBUTES_NEED_TEXCOORD0
                #define ATTRIBUTES_NEED_TEXCOORD1
                #define VARYINGS_NEED_POSITION_WS
                #define VARYINGS_NEED_NORMAL_WS
                #define VARYINGS_NEED_TANGENT_WS
                #define VARYINGS_NEED_TEXCOORD0
                #define FEATURES_GRAPH_VERTEX
                /* WARNING: $splice Could not find named fragment 'PassInstancing' */
                #define SHADERPASS SHADERPASS_DEPTHNORMALSONLY
                #define REQUIRE_DEPTH_TEXTURE
                /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
    
                // Includes
                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
    
                // --------------------------------------------------
                // Structs and Packing
    
                struct Attributes
                {
                    float3 positionOS : POSITION;
                    float3 normalOS : NORMAL;
                    float4 tangentOS : TANGENT;
                    float4 uv0 : TEXCOORD0;
                    float4 uv1 : TEXCOORD1;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    uint instanceID : INSTANCEID_SEMANTIC;
                    #endif
                };
                struct Varyings
                {
                    float4 positionCS : SV_POSITION;
                    float3 positionWS;
                    float3 normalWS;
                    float4 tangentWS;
                    float4 texCoord0;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    uint instanceID : CUSTOM_INSTANCE_ID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                    #endif
                };
                struct SurfaceDescriptionInputs
                {
                    float3 WorldSpaceNormal;
                    float3 TangentSpaceNormal;
                    float3 WorldSpacePosition;
                    float4 ScreenPosition;
                    float4 uv0;
                    float3 TimeParameters;
                };
                struct VertexDescriptionInputs
                {
                    float3 ObjectSpaceNormal;
                    float3 ObjectSpaceTangent;
                    float3 ObjectSpacePosition;
                };
                struct PackedVaryings
                {
                    float4 positionCS : SV_POSITION;
                    float3 interp0 : TEXCOORD0;
                    float3 interp1 : TEXCOORD1;
                    float4 interp2 : TEXCOORD2;
                    float4 interp3 : TEXCOORD3;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    uint instanceID : CUSTOM_INSTANCE_ID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                    #endif
                };
    
                PackedVaryings PackVaryings (Varyings input)
                {
                    PackedVaryings output;
                    output.positionCS = input.positionCS;
                    output.interp0.xyz =  input.positionWS;
                    output.interp1.xyz =  input.normalWS;
                    output.interp2.xyzw =  input.tangentWS;
                    output.interp3.xyzw =  input.texCoord0;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    output.instanceID = input.instanceID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    output.cullFace = input.cullFace;
                    #endif
                    return output;
                }
                Varyings UnpackVaryings (PackedVaryings input)
                {
                    Varyings output;
                    output.positionCS = input.positionCS;
                    output.positionWS = input.interp0.xyz;
                    output.normalWS = input.interp1.xyz;
                    output.tangentWS = input.interp2.xyzw;
                    output.texCoord0 = input.interp3.xyzw;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    output.instanceID = input.instanceID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    output.cullFace = input.cullFace;
                    #endif
                    return output;
                }
    
                // --------------------------------------------------
                // Graph
    
                // Graph Properties
                CBUFFER_START(UnityPerMaterial)
                float _DepthOffset;
                float _Strength;
                float4 _DeepWaterColor;
                float4 _ShallowWaterColor;
                float _Metallic;
                float2 _Tiling;
                float4 _OceanNormal2_TexelSize;
                float4 _OceanNormal1_TexelSize;
                float _GradientNoise;
                float2 _OceanSpeed;
                float _LODdistance;
                float4 _FarNormal_TexelSize;
                float4 _ShallowNormal_TexelSize;
                float _TranceparencyStrength;
                float _DownAlphaStrength;
                float _IsOcean;
                float4 _RiverNormal_TexelSize;
                float _RiverNormalRotAdjustment;
                float4 _LevelRiverNormal_TexelSize;
                float _RiverSpeed;
                float _ShoreIntersectionStrength;
                float4 Color_701f2c2f40b34b87975a0e85a71325dc;
                CBUFFER_END
                
                // Object and Global properties
                SAMPLER(SamplerState_Linear_Repeat);
                TEXTURE2D(_OceanNormal2);
                SAMPLER(sampler_OceanNormal2);
                TEXTURE2D(_OceanNormal1);
                SAMPLER(sampler_OceanNormal1);
                TEXTURE2D(_FarNormal);
                SAMPLER(sampler_FarNormal);
                TEXTURE2D(_ShallowNormal);
                SAMPLER(sampler_ShallowNormal);
                TEXTURE2D(_RiverNormal);
                SAMPLER(sampler_RiverNormal);
                TEXTURE2D(_LevelRiverNormal);
                SAMPLER(sampler_LevelRiverNormal);
                float _StretchScalar;
    
                // Graph Functions
                
                void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
                {
                    Out = UV * Tiling + Offset;
                }
                
                void Unity_Divide_float(float A, float B, out float Out)
                {
                    Out = A / B;
                }
                
                
                float2 Unity_GradientNoise_Dir_float(float2 p)
                {
                    // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
                    p = p % 289;
                    // need full precision, otherwise half overflows when p > 1
                    float x = float(34 * p.x + 1) * p.x % 289 + p.y;
                    x = (34 * x + 1) * x % 289;
                    x = frac(x / 41) * 2 - 1;
                    return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
                }
                
                void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
                { 
                    float2 p = UV * Scale;
                    float2 ip = floor(p);
                    float2 fp = frac(p);
                    float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
                    float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
                    float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
                    float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
                    fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
                    Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
                }
                
                void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
                {
                    Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
                }
                
                void Unity_Add_float4(float4 A, float4 B, out float4 Out)
                {
                    Out = A + B;
                }
                
                void Unity_Normalize_float3(float3 In, out float3 Out)
                {
                    Out = normalize(In);
                }
                
                void Unity_DotProduct_float3(float3 A, float3 B, out float Out)
                {
                    Out = dot(A, B);
                }
                
                void Unity_Comparison_Greater_float(float A, float B, out float Out)
                {
                    Out = A > B ? 1 : 0;
                }
                
                void Unity_Normalize_float2(float2 In, out float2 Out)
                {
                    Out = normalize(In);
                }
                
                void Unity_DotProduct_float2(float2 A, float2 B, out float Out)
                {
                    Out = dot(A, B);
                }
                
                void Unity_Arccosine_float(float In, out float Out)
                {
                    Out = acos(In);
                }
                
                void Unity_Multiply_float(float A, float B, out float Out)
                {
                    Out = A * B;
                }
                
                void Unity_Add_float(float A, float B, out float Out)
                {
                    Out = A + B;
                }
                
                void Unity_Branch_float(float Predicate, float True, float False, out float Out)
                {
                    Out = Predicate ? True : False;
                }
                
                void Unity_Rotate_Radians_float(float2 UV, float2 Center, float Rotation, out float2 Out)
                {
                    //rotation matrix
                    UV -= Center;
                    float s = sin(Rotation);
                    float c = cos(Rotation);
                
                    //center rotation matrix
                    float2x2 rMatrix = float2x2(c, -s, s, c);
                    rMatrix *= 0.5;
                    rMatrix += 0.5;
                    rMatrix = rMatrix*2 - 1;
                
                    //multiply the UVs by the rotation matrix
                    UV.xy = mul(UV.xy, rMatrix);
                    UV += Center;
                
                    Out = UV;
                }
                
                void Unity_Lerp_float(float A, float B, float T, out float Out)
                {
                    Out = lerp(A, B, T);
                }
                
                void Unity_Rotate_Degrees_float(float2 UV, float2 Center, float Rotation, out float2 Out)
                {
                    //rotation matrix
                    Rotation = Rotation * (3.1415926f/180.0f);
                    UV -= Center;
                    float s = sin(Rotation);
                    float c = cos(Rotation);
                
                    //center rotation matrix
                    float2x2 rMatrix = float2x2(c, -s, s, c);
                    rMatrix *= 0.5;
                    rMatrix += 0.5;
                    rMatrix = rMatrix*2 - 1;
                
                    //multiply the UVs by the rotation matrix
                    UV.xy = mul(UV.xy, rMatrix);
                    UV += Center;
                
                    Out = UV;
                }
                
                void Unity_Branch_float4(float Predicate, float4 True, float4 False, out float4 Out)
                {
                    Out = Predicate ? True : False;
                }
                
                void Unity_SceneDepth_Linear01_float(float4 UV, out float Out)
                {
                    Out = Linear01Depth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
                }
                
                void Unity_Subtract_float(float A, float B, out float Out)
                {
                    Out = A - B;
                }
                
                void Unity_Clamp_float(float In, float Min, float Max, out float Out)
                {
                    Out = clamp(In, Min, Max);
                }
                
                void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
                {
                    Out = lerp(A, B, T);
                }
                
                void Unity_Distance_float3(float3 A, float3 B, out float Out)
                {
                    Out = distance(A, B);
                }
                
                void Unity_Sine_float(float In, out float Out)
                {
                    Out = sin(In);
                }
    
                // Graph Vertex
                struct VertexDescription
                {
                    float3 Position;
                    float3 Normal;
                    float3 Tangent;
                };
                
                VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                {
                    VertexDescription description = (VertexDescription)0;
                    description.Position = IN.ObjectSpacePosition;
                    description.Normal = IN.ObjectSpaceNormal;
                    description.Tangent = IN.ObjectSpaceTangent;
                    return description;
                }
    
                // Graph Pixel
                struct SurfaceDescription
                {
                    float3 NormalTS;
                    float Alpha;
                };
                
                SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                {
                    SurfaceDescription surface = (SurfaceDescription)0;
                    UnityTexture2D _Property_98dcadd153784e00b3d99c72c66a28b9_Out_0 = UnityBuildTexture2DStructNoScale(_ShallowNormal);
                    float2 _TilingAndOffset_e057885e86584dea86f94cfc76e1e048_Out_3;
                    Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), float2 (0, 0), _TilingAndOffset_e057885e86584dea86f94cfc76e1e048_Out_3);
                    float4 _SampleTexture2D_0121a928620142938ff635ec1ff89401_RGBA_0 = SAMPLE_TEXTURE2D(_Property_98dcadd153784e00b3d99c72c66a28b9_Out_0.tex, _Property_98dcadd153784e00b3d99c72c66a28b9_Out_0.samplerstate, _TilingAndOffset_e057885e86584dea86f94cfc76e1e048_Out_3);
                    _SampleTexture2D_0121a928620142938ff635ec1ff89401_RGBA_0.rgb = UnpackNormal(_SampleTexture2D_0121a928620142938ff635ec1ff89401_RGBA_0);
                    float _SampleTexture2D_0121a928620142938ff635ec1ff89401_R_4 = _SampleTexture2D_0121a928620142938ff635ec1ff89401_RGBA_0.r;
                    float _SampleTexture2D_0121a928620142938ff635ec1ff89401_G_5 = _SampleTexture2D_0121a928620142938ff635ec1ff89401_RGBA_0.g;
                    float _SampleTexture2D_0121a928620142938ff635ec1ff89401_B_6 = _SampleTexture2D_0121a928620142938ff635ec1ff89401_RGBA_0.b;
                    float _SampleTexture2D_0121a928620142938ff635ec1ff89401_A_7 = _SampleTexture2D_0121a928620142938ff635ec1ff89401_RGBA_0.a;
                    float _Property_c92104f8c9d245dbb796f54a2386b2fa_Out_0 = _IsOcean;
                    float2 _Property_0165785b858447e9be7aeae88e49b876_Out_0 = _Tiling;
                    float _Divide_40fd94b5668f4354bc4f097174879071_Out_2;
                    Unity_Divide_float(IN.TimeParameters.x, 25, _Divide_40fd94b5668f4354bc4f097174879071_Out_2);
                    float2 _TilingAndOffset_dd58a4e4d2f44f4692185d84f037be72_Out_3;
                    Unity_TilingAndOffset_float(IN.uv0.xy, _Property_0165785b858447e9be7aeae88e49b876_Out_0, (_Divide_40fd94b5668f4354bc4f097174879071_Out_2.xx), _TilingAndOffset_dd58a4e4d2f44f4692185d84f037be72_Out_3);
                    float _Property_dcf2fdcb8f824668b8a6e8c81f6e182d_Out_0 = _GradientNoise;
                    float _GradientNoise_2c52090e5ac5473ba4d45f48de31694f_Out_2;
                    Unity_GradientNoise_float(_TilingAndOffset_dd58a4e4d2f44f4692185d84f037be72_Out_3, _Property_dcf2fdcb8f824668b8a6e8c81f6e182d_Out_0, _GradientNoise_2c52090e5ac5473ba4d45f48de31694f_Out_2);
                    float _Remap_fe18556f20a1429782d5401a4e93f4ff_Out_3;
                    Unity_Remap_float(_GradientNoise_2c52090e5ac5473ba4d45f48de31694f_Out_2, float2 (0, 1), float2 (-1, 1), _Remap_fe18556f20a1429782d5401a4e93f4ff_Out_3);
                    UnityTexture2D _Property_1aa6808f044b4d20b816c793ef91056c_Out_0 = UnityBuildTexture2DStructNoScale(_OceanNormal1);
                    float2 _Property_6dc7633668bb4df38e93ccda13f0e850_Out_0 = _OceanSpeed;
                    float _Split_35918e73b31d4ab383b2221ebc8e73c7_R_1 = _Property_6dc7633668bb4df38e93ccda13f0e850_Out_0[0];
                    float _Split_35918e73b31d4ab383b2221ebc8e73c7_G_2 = _Property_6dc7633668bb4df38e93ccda13f0e850_Out_0[1];
                    float _Split_35918e73b31d4ab383b2221ebc8e73c7_B_3 = 0;
                    float _Split_35918e73b31d4ab383b2221ebc8e73c7_A_4 = 0;
                    float _Divide_320942700ecd49068a4d2fac0bbcd012_Out_2;
                    Unity_Divide_float(IN.TimeParameters.x, _Split_35918e73b31d4ab383b2221ebc8e73c7_R_1, _Divide_320942700ecd49068a4d2fac0bbcd012_Out_2);
                    float2 _TilingAndOffset_2c0d1a11da414db2972d2b0e6e6eead7_Out_3;
                    Unity_TilingAndOffset_float(IN.uv0.xy, _Property_0165785b858447e9be7aeae88e49b876_Out_0, (_Divide_320942700ecd49068a4d2fac0bbcd012_Out_2.xx), _TilingAndOffset_2c0d1a11da414db2972d2b0e6e6eead7_Out_3);
                    float4 _SampleTexture2D_95cbac09786f4d9f877a32a692103c63_RGBA_0 = SAMPLE_TEXTURE2D(_Property_1aa6808f044b4d20b816c793ef91056c_Out_0.tex, _Property_1aa6808f044b4d20b816c793ef91056c_Out_0.samplerstate, _TilingAndOffset_2c0d1a11da414db2972d2b0e6e6eead7_Out_3);
                    _SampleTexture2D_95cbac09786f4d9f877a32a692103c63_RGBA_0.rgb = UnpackNormal(_SampleTexture2D_95cbac09786f4d9f877a32a692103c63_RGBA_0);
                    float _SampleTexture2D_95cbac09786f4d9f877a32a692103c63_R_4 = _SampleTexture2D_95cbac09786f4d9f877a32a692103c63_RGBA_0.r;
                    float _SampleTexture2D_95cbac09786f4d9f877a32a692103c63_G_5 = _SampleTexture2D_95cbac09786f4d9f877a32a692103c63_RGBA_0.g;
                    float _SampleTexture2D_95cbac09786f4d9f877a32a692103c63_B_6 = _SampleTexture2D_95cbac09786f4d9f877a32a692103c63_RGBA_0.b;
                    float _SampleTexture2D_95cbac09786f4d9f877a32a692103c63_A_7 = _SampleTexture2D_95cbac09786f4d9f877a32a692103c63_RGBA_0.a;
                    UnityTexture2D _Property_fab5aef84b23441fbfd40281cf1ada82_Out_0 = UnityBuildTexture2DStructNoScale(_OceanNormal2);
                    float _Divide_dbf1715fe11a470fb42e9a29bb351a9d_Out_2;
                    Unity_Divide_float(IN.TimeParameters.x, _Split_35918e73b31d4ab383b2221ebc8e73c7_G_2, _Divide_dbf1715fe11a470fb42e9a29bb351a9d_Out_2);
                    float2 _TilingAndOffset_bc9854cad9a042cfb0ebc3bb5b4792e4_Out_3;
                    Unity_TilingAndOffset_float(IN.uv0.xy, _Property_0165785b858447e9be7aeae88e49b876_Out_0, (_Divide_dbf1715fe11a470fb42e9a29bb351a9d_Out_2.xx), _TilingAndOffset_bc9854cad9a042cfb0ebc3bb5b4792e4_Out_3);
                    float4 _SampleTexture2D_7f1b3f3ae5d243f9b432299bdc4f7b97_RGBA_0 = SAMPLE_TEXTURE2D(_Property_fab5aef84b23441fbfd40281cf1ada82_Out_0.tex, _Property_fab5aef84b23441fbfd40281cf1ada82_Out_0.samplerstate, _TilingAndOffset_bc9854cad9a042cfb0ebc3bb5b4792e4_Out_3);
                    _SampleTexture2D_7f1b3f3ae5d243f9b432299bdc4f7b97_RGBA_0.rgb = UnpackNormal(_SampleTexture2D_7f1b3f3ae5d243f9b432299bdc4f7b97_RGBA_0);
                    float _SampleTexture2D_7f1b3f3ae5d243f9b432299bdc4f7b97_R_4 = _SampleTexture2D_7f1b3f3ae5d243f9b432299bdc4f7b97_RGBA_0.r;
                    float _SampleTexture2D_7f1b3f3ae5d243f9b432299bdc4f7b97_G_5 = _SampleTexture2D_7f1b3f3ae5d243f9b432299bdc4f7b97_RGBA_0.g;
                    float _SampleTexture2D_7f1b3f3ae5d243f9b432299bdc4f7b97_B_6 = _SampleTexture2D_7f1b3f3ae5d243f9b432299bdc4f7b97_RGBA_0.b;
                    float _SampleTexture2D_7f1b3f3ae5d243f9b432299bdc4f7b97_A_7 = _SampleTexture2D_7f1b3f3ae5d243f9b432299bdc4f7b97_RGBA_0.a;
                    float4 _Add_3f6c04238c1f459eb8e6300b9eb1f842_Out_2;
                    Unity_Add_float4(_SampleTexture2D_95cbac09786f4d9f877a32a692103c63_RGBA_0, _SampleTexture2D_7f1b3f3ae5d243f9b432299bdc4f7b97_RGBA_0, _Add_3f6c04238c1f459eb8e6300b9eb1f842_Out_2);
                    float4 _Add_3e553e4abf784d7799c718cfe7d51b68_Out_2;
                    Unity_Add_float4((_Remap_fe18556f20a1429782d5401a4e93f4ff_Out_3.xxxx), _Add_3f6c04238c1f459eb8e6300b9eb1f842_Out_2, _Add_3e553e4abf784d7799c718cfe7d51b68_Out_2);
                    float3 _Normalize_415b503188e443458e4172309aa4cb18_Out_1;
                    Unity_Normalize_float3(IN.WorldSpaceNormal, _Normalize_415b503188e443458e4172309aa4cb18_Out_1);
                    float _DotProduct_b3f1b90b273a4b2b99f07acbc4565dcb_Out_2;
                    Unity_DotProduct_float3(float3(0, 1, 0), _Normalize_415b503188e443458e4172309aa4cb18_Out_1, _DotProduct_b3f1b90b273a4b2b99f07acbc4565dcb_Out_2);
                    float _Remap_669938a90f934b9bab86d586a6917aca_Out_3;
                    Unity_Remap_float(_DotProduct_b3f1b90b273a4b2b99f07acbc4565dcb_Out_2, float2 (-1, 1), float2 (0, 1), _Remap_669938a90f934b9bab86d586a6917aca_Out_3);
                    float _Comparison_8f4fb954760447e8b0db8924e20fd1d0_Out_2;
                    Unity_Comparison_Greater_float(_Remap_669938a90f934b9bab86d586a6917aca_Out_3, 0, _Comparison_8f4fb954760447e8b0db8924e20fd1d0_Out_2);
                    UnityTexture2D _Property_ab131e76fa9e4575850bad711d6bc112_Out_0 = UnityBuildTexture2DStructNoScale(_RiverNormal);
                    float3 _Normalize_62a13fd33141482da88d8a4f6cbbc589_Out_1;
                    Unity_Normalize_float3(IN.WorldSpaceNormal, _Normalize_62a13fd33141482da88d8a4f6cbbc589_Out_1);
                    float _Split_0d3686f12540443e91f7387b6f77c10d_R_1 = _Normalize_62a13fd33141482da88d8a4f6cbbc589_Out_1[0];
                    float _Split_0d3686f12540443e91f7387b6f77c10d_G_2 = _Normalize_62a13fd33141482da88d8a4f6cbbc589_Out_1[1];
                    float _Split_0d3686f12540443e91f7387b6f77c10d_B_3 = _Normalize_62a13fd33141482da88d8a4f6cbbc589_Out_1[2];
                    float _Split_0d3686f12540443e91f7387b6f77c10d_A_4 = 0;
                    float _Comparison_e88851318be2459db93159ca801db3b8_Out_2;
                    Unity_Comparison_Greater_float(_Split_0d3686f12540443e91f7387b6f77c10d_B_3, 0, _Comparison_e88851318be2459db93159ca801db3b8_Out_2);
                    float2 _Vector2_cd982aedb6df469f81c94d251afa4ef4_Out_0 = float2(_Split_0d3686f12540443e91f7387b6f77c10d_R_1, _Split_0d3686f12540443e91f7387b6f77c10d_B_3);
                    float2 _Normalize_029f1f95e8854efe8413e4f0e8266c57_Out_1;
                    Unity_Normalize_float2(_Vector2_cd982aedb6df469f81c94d251afa4ef4_Out_0, _Normalize_029f1f95e8854efe8413e4f0e8266c57_Out_1);
                    float _DotProduct_ebf7ce672ca34ebaaa92a71bef863e84_Out_2;
                    Unity_DotProduct_float2(float2(1, 0), _Normalize_029f1f95e8854efe8413e4f0e8266c57_Out_1, _DotProduct_ebf7ce672ca34ebaaa92a71bef863e84_Out_2);
                    float _Arccosine_4b874182f6a14874840ee7586e79f531_Out_1;
                    Unity_Arccosine_float(_DotProduct_ebf7ce672ca34ebaaa92a71bef863e84_Out_2, _Arccosine_4b874182f6a14874840ee7586e79f531_Out_1);
                    float _Multiply_2cb80113cd264bd684265987dfc99fdc_Out_2;
                    Unity_Multiply_float(_DotProduct_ebf7ce672ca34ebaaa92a71bef863e84_Out_2, -1, _Multiply_2cb80113cd264bd684265987dfc99fdc_Out_2);
                    float _Arccosine_4402c39ae97e427eb6a05c3ec6df8476_Out_1;
                    Unity_Arccosine_float(_Multiply_2cb80113cd264bd684265987dfc99fdc_Out_2, _Arccosine_4402c39ae97e427eb6a05c3ec6df8476_Out_1);
                    float Constant_2af68751986845ed87773c58bfc03190 = 3.141593;
                    float _Add_db22dd4581f6401c9b151c2d904fb1fd_Out_2;
                    Unity_Add_float(_Arccosine_4402c39ae97e427eb6a05c3ec6df8476_Out_1, Constant_2af68751986845ed87773c58bfc03190, _Add_db22dd4581f6401c9b151c2d904fb1fd_Out_2);
                    float _Branch_5fd995eba4cc4a4c8abe7fca6cd0c1c8_Out_3;
                    Unity_Branch_float(_Comparison_e88851318be2459db93159ca801db3b8_Out_2, _Arccosine_4b874182f6a14874840ee7586e79f531_Out_1, _Add_db22dd4581f6401c9b151c2d904fb1fd_Out_2, _Branch_5fd995eba4cc4a4c8abe7fca6cd0c1c8_Out_3);
                    float2 _Rotate_e2dc059678654897947c4905d958d640_Out_3;
                    Unity_Rotate_Radians_float(IN.uv0.xy, float2 (0.5, 0.5), _Branch_5fd995eba4cc4a4c8abe7fca6cd0c1c8_Out_3, _Rotate_e2dc059678654897947c4905d958d640_Out_3);
                    float2 _Property_409975023fe344e4969558e96ae8b3fe_Out_0 = _Tiling;
                    float _Property_fe8bd49591be4d8493cd9d1aef424249_Out_0 = _RiverSpeed;
                    float _Multiply_11dac49a52be47e2accb8b9de45dab52_Out_2;
                    Unity_Multiply_float(IN.TimeParameters.x, _Property_fe8bd49591be4d8493cd9d1aef424249_Out_0, _Multiply_11dac49a52be47e2accb8b9de45dab52_Out_2);
                    float _Lerp_8be4d289e2cb484489c128e89e81cbd7_Out_3;
                    Unity_Lerp_float(_Multiply_11dac49a52be47e2accb8b9de45dab52_Out_2, IN.TimeParameters.x, _Remap_669938a90f934b9bab86d586a6917aca_Out_3, _Lerp_8be4d289e2cb484489c128e89e81cbd7_Out_3);
                    float2 _Vector2_d7594f71adcb4015bc07aa3fac73b0cf_Out_0 = float2(_Lerp_8be4d289e2cb484489c128e89e81cbd7_Out_3, 0);
                    float2 _TilingAndOffset_5a892791744c4205818e4162cba3a833_Out_3;
                    Unity_TilingAndOffset_float(_Rotate_e2dc059678654897947c4905d958d640_Out_3, _Property_409975023fe344e4969558e96ae8b3fe_Out_0, _Vector2_d7594f71adcb4015bc07aa3fac73b0cf_Out_0, _TilingAndOffset_5a892791744c4205818e4162cba3a833_Out_3);
                    float _Property_61f2533f1f0f4b2e9a39165110a6d8cb_Out_0 = _RiverNormalRotAdjustment;
                    float2 _Rotate_f20c70501e6a4e1e946bb31f6bd852f4_Out_3;
                    Unity_Rotate_Degrees_float(_TilingAndOffset_5a892791744c4205818e4162cba3a833_Out_3, float2 (0.5, 0.5), _Property_61f2533f1f0f4b2e9a39165110a6d8cb_Out_0, _Rotate_f20c70501e6a4e1e946bb31f6bd852f4_Out_3);
                    float4 _SampleTexture2D_66835b651206479b8da548ce63cec2a2_RGBA_0 = SAMPLE_TEXTURE2D(_Property_ab131e76fa9e4575850bad711d6bc112_Out_0.tex, _Property_ab131e76fa9e4575850bad711d6bc112_Out_0.samplerstate, _Rotate_f20c70501e6a4e1e946bb31f6bd852f4_Out_3);
                    _SampleTexture2D_66835b651206479b8da548ce63cec2a2_RGBA_0.rgb = UnpackNormal(_SampleTexture2D_66835b651206479b8da548ce63cec2a2_RGBA_0);
                    float _SampleTexture2D_66835b651206479b8da548ce63cec2a2_R_4 = _SampleTexture2D_66835b651206479b8da548ce63cec2a2_RGBA_0.r;
                    float _SampleTexture2D_66835b651206479b8da548ce63cec2a2_G_5 = _SampleTexture2D_66835b651206479b8da548ce63cec2a2_RGBA_0.g;
                    float _SampleTexture2D_66835b651206479b8da548ce63cec2a2_B_6 = _SampleTexture2D_66835b651206479b8da548ce63cec2a2_RGBA_0.b;
                    float _SampleTexture2D_66835b651206479b8da548ce63cec2a2_A_7 = _SampleTexture2D_66835b651206479b8da548ce63cec2a2_RGBA_0.a;
                    UnityTexture2D _Property_3ac158951f79428685aa829dd82f0bc3_Out_0 = UnityBuildTexture2DStructNoScale(_LevelRiverNormal);
                    float2 _TilingAndOffset_5e717e1b97944a55bc66662a06d78ea7_Out_3;
                    Unity_TilingAndOffset_float(IN.uv0.xy, _Property_409975023fe344e4969558e96ae8b3fe_Out_0, float2 (0, 0), _TilingAndOffset_5e717e1b97944a55bc66662a06d78ea7_Out_3);
                    float4 _SampleTexture2D_e5aebb8d1445433bacf47e39067cb0a0_RGBA_0 = SAMPLE_TEXTURE2D(_Property_3ac158951f79428685aa829dd82f0bc3_Out_0.tex, _Property_3ac158951f79428685aa829dd82f0bc3_Out_0.samplerstate, _TilingAndOffset_5e717e1b97944a55bc66662a06d78ea7_Out_3);
                    _SampleTexture2D_e5aebb8d1445433bacf47e39067cb0a0_RGBA_0.rgb = UnpackNormal(_SampleTexture2D_e5aebb8d1445433bacf47e39067cb0a0_RGBA_0);
                    float _SampleTexture2D_e5aebb8d1445433bacf47e39067cb0a0_R_4 = _SampleTexture2D_e5aebb8d1445433bacf47e39067cb0a0_RGBA_0.r;
                    float _SampleTexture2D_e5aebb8d1445433bacf47e39067cb0a0_G_5 = _SampleTexture2D_e5aebb8d1445433bacf47e39067cb0a0_RGBA_0.g;
                    float _SampleTexture2D_e5aebb8d1445433bacf47e39067cb0a0_B_6 = _SampleTexture2D_e5aebb8d1445433bacf47e39067cb0a0_RGBA_0.b;
                    float _SampleTexture2D_e5aebb8d1445433bacf47e39067cb0a0_A_7 = _SampleTexture2D_e5aebb8d1445433bacf47e39067cb0a0_RGBA_0.a;
                    float4 _Branch_7d4a670ae12240ccbe8bdb249a237644_Out_3;
                    Unity_Branch_float4(_Comparison_8f4fb954760447e8b0db8924e20fd1d0_Out_2, _SampleTexture2D_66835b651206479b8da548ce63cec2a2_RGBA_0, _SampleTexture2D_e5aebb8d1445433bacf47e39067cb0a0_RGBA_0, _Branch_7d4a670ae12240ccbe8bdb249a237644_Out_3);
                    float4 _Branch_5225751f0aaf4e5885184101068828b5_Out_3;
                    Unity_Branch_float4(_Property_c92104f8c9d245dbb796f54a2386b2fa_Out_0, _Add_3e553e4abf784d7799c718cfe7d51b68_Out_2, _Branch_7d4a670ae12240ccbe8bdb249a237644_Out_3, _Branch_5225751f0aaf4e5885184101068828b5_Out_3);
                    float _SceneDepth_3137d738aa0149fb8a54d88a60826a60_Out_1;
                    Unity_SceneDepth_Linear01_float(float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0), _SceneDepth_3137d738aa0149fb8a54d88a60826a60_Out_1);
                    float _Multiply_8ec8e0a1878e494ca0d6d16678168741_Out_2;
                    Unity_Multiply_float(_SceneDepth_3137d738aa0149fb8a54d88a60826a60_Out_1, _ProjectionParams.z, _Multiply_8ec8e0a1878e494ca0d6d16678168741_Out_2);
                    float4 _ScreenPosition_3840c0fb20fc4eb58387cd54ee7e2b18_Out_0 = IN.ScreenPosition;
                    float _Split_578ef5cadaac40969c114c4d1ae870d8_R_1 = _ScreenPosition_3840c0fb20fc4eb58387cd54ee7e2b18_Out_0[0];
                    float _Split_578ef5cadaac40969c114c4d1ae870d8_G_2 = _ScreenPosition_3840c0fb20fc4eb58387cd54ee7e2b18_Out_0[1];
                    float _Split_578ef5cadaac40969c114c4d1ae870d8_B_3 = _ScreenPosition_3840c0fb20fc4eb58387cd54ee7e2b18_Out_0[2];
                    float _Split_578ef5cadaac40969c114c4d1ae870d8_A_4 = _ScreenPosition_3840c0fb20fc4eb58387cd54ee7e2b18_Out_0[3];
                    float _Property_cedd17331b16484abf1a4ce8eb0e5a72_Out_0 = _DepthOffset;
                    float _Add_e04e1bc3087745d898c282f10a0f43e3_Out_2;
                    Unity_Add_float(_Split_578ef5cadaac40969c114c4d1ae870d8_A_4, _Property_cedd17331b16484abf1a4ce8eb0e5a72_Out_0, _Add_e04e1bc3087745d898c282f10a0f43e3_Out_2);
                    float _Subtract_bd4ff2ba7ce04051b10b968b020d06df_Out_2;
                    Unity_Subtract_float(_Multiply_8ec8e0a1878e494ca0d6d16678168741_Out_2, _Add_e04e1bc3087745d898c282f10a0f43e3_Out_2, _Subtract_bd4ff2ba7ce04051b10b968b020d06df_Out_2);
                    float _Property_d328dfa89c674e67bffe73ef574a2d58_Out_0 = _Strength;
                    float _Multiply_4eb7822d949844e38f2bb60067662a47_Out_2;
                    Unity_Multiply_float(_Subtract_bd4ff2ba7ce04051b10b968b020d06df_Out_2, _Property_d328dfa89c674e67bffe73ef574a2d58_Out_0, _Multiply_4eb7822d949844e38f2bb60067662a47_Out_2);
                    float _Clamp_0f7ac1e483384940a0714a9e608d50b4_Out_3;
                    Unity_Clamp_float(_Multiply_4eb7822d949844e38f2bb60067662a47_Out_2, 0, 1, _Clamp_0f7ac1e483384940a0714a9e608d50b4_Out_3);
                    float4 _Lerp_b501d8723a3b46369b51759c91fb6f3c_Out_3;
                    Unity_Lerp_float4(_SampleTexture2D_0121a928620142938ff635ec1ff89401_RGBA_0, _Branch_5225751f0aaf4e5885184101068828b5_Out_3, (_Clamp_0f7ac1e483384940a0714a9e608d50b4_Out_3.xxxx), _Lerp_b501d8723a3b46369b51759c91fb6f3c_Out_3);
                    UnityTexture2D _Property_d6241559ab474e5782a32fe991893c23_Out_0 = UnityBuildTexture2DStructNoScale(_FarNormal);
                    float2 _TilingAndOffset_bdb4faaa2ebc4eb990d5202f25946a55_Out_3;
                    Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), float2 (0, 0), _TilingAndOffset_bdb4faaa2ebc4eb990d5202f25946a55_Out_3);
                    float4 _SampleTexture2D_4e9f3a96a6da4e8bac8f2aa7059e160c_RGBA_0 = SAMPLE_TEXTURE2D(_Property_d6241559ab474e5782a32fe991893c23_Out_0.tex, _Property_d6241559ab474e5782a32fe991893c23_Out_0.samplerstate, _TilingAndOffset_bdb4faaa2ebc4eb990d5202f25946a55_Out_3);
                    _SampleTexture2D_4e9f3a96a6da4e8bac8f2aa7059e160c_RGBA_0.rgb = UnpackNormal(_SampleTexture2D_4e9f3a96a6da4e8bac8f2aa7059e160c_RGBA_0);
                    float _SampleTexture2D_4e9f3a96a6da4e8bac8f2aa7059e160c_R_4 = _SampleTexture2D_4e9f3a96a6da4e8bac8f2aa7059e160c_RGBA_0.r;
                    float _SampleTexture2D_4e9f3a96a6da4e8bac8f2aa7059e160c_G_5 = _SampleTexture2D_4e9f3a96a6da4e8bac8f2aa7059e160c_RGBA_0.g;
                    float _SampleTexture2D_4e9f3a96a6da4e8bac8f2aa7059e160c_B_6 = _SampleTexture2D_4e9f3a96a6da4e8bac8f2aa7059e160c_RGBA_0.b;
                    float _SampleTexture2D_4e9f3a96a6da4e8bac8f2aa7059e160c_A_7 = _SampleTexture2D_4e9f3a96a6da4e8bac8f2aa7059e160c_RGBA_0.a;
                    float _Distance_44875152cc614e5ba9d5c699495f08ab_Out_2;
                    Unity_Distance_float3(IN.WorldSpacePosition, _WorldSpaceCameraPos, _Distance_44875152cc614e5ba9d5c699495f08ab_Out_2);
                    float _Property_aebc16f7283a467a8048e6bb509da7c6_Out_0 = _LODdistance;
                    float _Divide_32fb228b5d524f178b884f2adaa8e599_Out_2;
                    Unity_Divide_float(_Distance_44875152cc614e5ba9d5c699495f08ab_Out_2, _Property_aebc16f7283a467a8048e6bb509da7c6_Out_0, _Divide_32fb228b5d524f178b884f2adaa8e599_Out_2);
                    float4 _Lerp_2e0a60782cb64960ac783789c38969b5_Out_3;
                    Unity_Lerp_float4(_Lerp_b501d8723a3b46369b51759c91fb6f3c_Out_3, _SampleTexture2D_4e9f3a96a6da4e8bac8f2aa7059e160c_RGBA_0, (_Divide_32fb228b5d524f178b884f2adaa8e599_Out_2.xxxx), _Lerp_2e0a60782cb64960ac783789c38969b5_Out_3);
                    float4 _Property_231c0d262d3a466d85dfd53b116086ca_Out_0 = Color_701f2c2f40b34b87975a0e85a71325dc;
                    float _Property_90205b2f827548b295dc151171bc164c_Out_0 = _IsOcean;
                    float _Sine_24a173ac1d9d40b5b43bd7c8169386e4_Out_1;
                    Unity_Sine_float(IN.TimeParameters.x, _Sine_24a173ac1d9d40b5b43bd7c8169386e4_Out_1);
                    float _Remap_9ed3ea235fdc44d7a8c762cbe7ff6d0e_Out_3;
                    Unity_Remap_float(_Sine_24a173ac1d9d40b5b43bd7c8169386e4_Out_1, float2 (-1, 1), float2 (0.5, 1), _Remap_9ed3ea235fdc44d7a8c762cbe7ff6d0e_Out_3);
                    float _Branch_fcfcb84348fb4a5a90417124dc9ee3a2_Out_3;
                    Unity_Branch_float(_Property_90205b2f827548b295dc151171bc164c_Out_0, _Remap_9ed3ea235fdc44d7a8c762cbe7ff6d0e_Out_3, 1, _Branch_fcfcb84348fb4a5a90417124dc9ee3a2_Out_3);
                    float _Property_866bbbbe2a484e2eae1ad77ed223a577_Out_0 = _ShoreIntersectionStrength;
                    float _Multiply_cb7f54f30fb348b4a7f109f458e38b17_Out_2;
                    Unity_Multiply_float(_Branch_fcfcb84348fb4a5a90417124dc9ee3a2_Out_3, _Property_866bbbbe2a484e2eae1ad77ed223a577_Out_0, _Multiply_cb7f54f30fb348b4a7f109f458e38b17_Out_2);
                    float _Multiply_dcdae92bb4dd401a89df781ec062cecc_Out_2;
                    Unity_Multiply_float(_Subtract_bd4ff2ba7ce04051b10b968b020d06df_Out_2, _Multiply_cb7f54f30fb348b4a7f109f458e38b17_Out_2, _Multiply_dcdae92bb4dd401a89df781ec062cecc_Out_2);
                    float _Clamp_33ee6da80fc14439b6d7bab14be7ab07_Out_3;
                    Unity_Clamp_float(_Multiply_dcdae92bb4dd401a89df781ec062cecc_Out_2, 0.5, 1, _Clamp_33ee6da80fc14439b6d7bab14be7ab07_Out_3);
                    float4 _Lerp_f0669e92de0b409893955d23347ac238_Out_3;
                    Unity_Lerp_float4(_Property_231c0d262d3a466d85dfd53b116086ca_Out_0, float4(0, 0, 0, 0), (_Clamp_33ee6da80fc14439b6d7bab14be7ab07_Out_3.xxxx), _Lerp_f0669e92de0b409893955d23347ac238_Out_3);
                    float _Float_c4cf30aef9464dda83de90c7e790a9ba_Out_0 = 1.5;
                    float4 _Property_c854872c24e048c0aa372f0be547f07c_Out_0 = _ShallowWaterColor;
                    float4 _Property_dde44c4f61534e08a917dd16bcf5ebca_Out_0 = _DeepWaterColor;
                    float4 _Lerp_3f9225ad7cdc45509b625268ef70e29c_Out_3;
                    Unity_Lerp_float4(_Property_c854872c24e048c0aa372f0be547f07c_Out_0, _Property_dde44c4f61534e08a917dd16bcf5ebca_Out_0, (_Clamp_0f7ac1e483384940a0714a9e608d50b4_Out_3.xxxx), _Lerp_3f9225ad7cdc45509b625268ef70e29c_Out_3);
                    float4 _Lerp_4536ba8c658e4f11aaefc80660368304_Out_3;
                    Unity_Lerp_float4((_Float_c4cf30aef9464dda83de90c7e790a9ba_Out_0.xxxx), _Lerp_3f9225ad7cdc45509b625268ef70e29c_Out_3, (_Remap_669938a90f934b9bab86d586a6917aca_Out_3.xxxx), _Lerp_4536ba8c658e4f11aaefc80660368304_Out_3);
                    float4 _Add_f8fda8450f33454d96a6212c8ebfdc62_Out_2;
                    Unity_Add_float4(_Lerp_f0669e92de0b409893955d23347ac238_Out_3, _Lerp_4536ba8c658e4f11aaefc80660368304_Out_3, _Add_f8fda8450f33454d96a6212c8ebfdc62_Out_2);
                    float _Split_17c957ee33bc4e28a994b8b8dd20a89f_R_1 = _Add_f8fda8450f33454d96a6212c8ebfdc62_Out_2[0];
                    float _Split_17c957ee33bc4e28a994b8b8dd20a89f_G_2 = _Add_f8fda8450f33454d96a6212c8ebfdc62_Out_2[1];
                    float _Split_17c957ee33bc4e28a994b8b8dd20a89f_B_3 = _Add_f8fda8450f33454d96a6212c8ebfdc62_Out_2[2];
                    float _Split_17c957ee33bc4e28a994b8b8dd20a89f_A_4 = _Add_f8fda8450f33454d96a6212c8ebfdc62_Out_2[3];
                    float _DotProduct_fb1cbb38204242edbadb0a15bc95b04e_Out_2;
                    Unity_DotProduct_float3(-1 * mul((float3x3)UNITY_MATRIX_M, transpose(mul(UNITY_MATRIX_I_M, UNITY_MATRIX_I_V)) [2].xyz), IN.WorldSpaceNormal, _DotProduct_fb1cbb38204242edbadb0a15bc95b04e_Out_2);
                    float _Remap_bde541d934954ce5b99314edcbcd70e5_Out_3;
                    Unity_Remap_float(_DotProduct_fb1cbb38204242edbadb0a15bc95b04e_Out_2, float2 (-1, 0), float2 (0, 1), _Remap_bde541d934954ce5b99314edcbcd70e5_Out_3);
                    float _Multiply_6330a2a6c69948a5aacc174b9da1d2f0_Out_2;
                    Unity_Multiply_float(_Split_17c957ee33bc4e28a994b8b8dd20a89f_A_4, _Remap_bde541d934954ce5b99314edcbcd70e5_Out_3, _Multiply_6330a2a6c69948a5aacc174b9da1d2f0_Out_2);
                    float _Property_bc84cef440384b15875875c65e907453_Out_0 = _DownAlphaStrength;
                    float _Property_f604cf40fc3249839fb755ab1c9d8eb2_Out_0 = _TranceparencyStrength;
                    float _Multiply_c4a5b4f21dfe45d2a2f78cc50eba3ec8_Out_2;
                    Unity_Multiply_float(_Subtract_bd4ff2ba7ce04051b10b968b020d06df_Out_2, _Property_f604cf40fc3249839fb755ab1c9d8eb2_Out_0, _Multiply_c4a5b4f21dfe45d2a2f78cc50eba3ec8_Out_2);
                    float _Clamp_61028b06dbf14a6092a617f0d8a7ac32_Out_3;
                    Unity_Clamp_float(_Multiply_c4a5b4f21dfe45d2a2f78cc50eba3ec8_Out_2, 0, 1, _Clamp_61028b06dbf14a6092a617f0d8a7ac32_Out_3);
                    float _Lerp_106a757383d0403399452dcbb99cc72a_Out_3;
                    Unity_Lerp_float(_Property_bc84cef440384b15875875c65e907453_Out_0, 0, _Clamp_61028b06dbf14a6092a617f0d8a7ac32_Out_3, _Lerp_106a757383d0403399452dcbb99cc72a_Out_3);
                    float _Lerp_729c45b3c3014bdbb92bb4198e06bd92_Out_3;
                    Unity_Lerp_float(1, 0, _Remap_bde541d934954ce5b99314edcbcd70e5_Out_3, _Lerp_729c45b3c3014bdbb92bb4198e06bd92_Out_3);
                    float _Multiply_a80cb3307cd746d7a1bb5f699c9423f3_Out_2;
                    Unity_Multiply_float(_Lerp_106a757383d0403399452dcbb99cc72a_Out_3, _Lerp_729c45b3c3014bdbb92bb4198e06bd92_Out_3, _Multiply_a80cb3307cd746d7a1bb5f699c9423f3_Out_2);
                    float _Lerp_b12dda477cf14695add7f2de406dd644_Out_3;
                    Unity_Lerp_float(_Split_17c957ee33bc4e28a994b8b8dd20a89f_A_4, _Multiply_6330a2a6c69948a5aacc174b9da1d2f0_Out_2, _Multiply_a80cb3307cd746d7a1bb5f699c9423f3_Out_2, _Lerp_b12dda477cf14695add7f2de406dd644_Out_3);
                    surface.NormalTS = (_Lerp_2e0a60782cb64960ac783789c38969b5_Out_3.xyz);
                    surface.Alpha = _Lerp_b12dda477cf14695add7f2de406dd644_Out_3;
                    return surface;
                }
    
                // --------------------------------------------------
                // Build Graph Inputs
    
                VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                {
                    VertexDescriptionInputs output;
                    ZERO_INITIALIZE(VertexDescriptionInputs, output);
                
                    output.ObjectSpaceNormal =           input.normalOS;
                    output.ObjectSpaceTangent =          input.tangentOS.xyz;
                    output.ObjectSpacePosition =         input.positionOS;
                
                    return output;
                }
                
                SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                {
                    SurfaceDescriptionInputs output;
                    ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
                
                	// must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
                	float3 unnormalizedNormalWS = input.normalWS;
                    const float renormFactor = 1.0 / length(unnormalizedNormalWS);
                
                
                    output.WorldSpaceNormal =            renormFactor*input.normalWS.xyz;		// we want a unit length Normal Vector node in shader graph
                    output.TangentSpaceNormal =          float3(0.0f, 0.0f, 1.0f);
                
                
                    output.WorldSpacePosition =          input.positionWS;
                    output.ScreenPosition =              ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
                    output.uv0 =                         input.texCoord0;
                    output.TimeParameters =              _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                #else
                #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                #endif
                #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                
                    return output;
                }
                
    
                // --------------------------------------------------
                // Main
    
                #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DepthNormalsOnlyPass.hlsl"
    
                ENDHLSL
            }
            Pass
            {
                Name "Meta"
                Tags
                {
                    "LightMode" = "Meta"
                }
    
                // Render State
                Cull Off
    
                // Debug
                // <None>
    
                // --------------------------------------------------
                // Pass
    
                HLSLPROGRAM
    
                // Pragmas
                #pragma target 2.0
                #pragma only_renderers gles gles3 glcore d3d11
                #pragma vertex vert
                #pragma fragment frag
    
                // DotsInstancingOptions: <None>
                // HybridV1InjectedBuiltinProperties: <None>
    
                // Keywords
                #pragma shader_feature _ _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A
                // GraphKeywords: <None>
    
                // Defines
                #define _SURFACE_TYPE_TRANSPARENT 1
                #define _NORMALMAP 1
                #define _NORMAL_DROPOFF_TS 1
                #define ATTRIBUTES_NEED_NORMAL
                #define ATTRIBUTES_NEED_TANGENT
                #define ATTRIBUTES_NEED_TEXCOORD1
                #define ATTRIBUTES_NEED_TEXCOORD2
                #define VARYINGS_NEED_POSITION_WS
                #define VARYINGS_NEED_NORMAL_WS
                #define FEATURES_GRAPH_VERTEX
                /* WARNING: $splice Could not find named fragment 'PassInstancing' */
                #define SHADERPASS SHADERPASS_META
                #define REQUIRE_DEPTH_TEXTURE
                /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
    
                // Includes
                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/MetaInput.hlsl"
    
                // --------------------------------------------------
                // Structs and Packing
    
                struct Attributes
                {
                    float3 positionOS : POSITION;
                    float3 normalOS : NORMAL;
                    float4 tangentOS : TANGENT;
                    float4 uv1 : TEXCOORD1;
                    float4 uv2 : TEXCOORD2;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    uint instanceID : INSTANCEID_SEMANTIC;
                    #endif
                };
                struct Varyings
                {
                    float4 positionCS : SV_POSITION;
                    float3 positionWS;
                    float3 normalWS;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    uint instanceID : CUSTOM_INSTANCE_ID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                    #endif
                };
                struct SurfaceDescriptionInputs
                {
                    float3 WorldSpaceNormal;
                    float3 WorldSpacePosition;
                    float4 ScreenPosition;
                    float3 TimeParameters;
                };
                struct VertexDescriptionInputs
                {
                    float3 ObjectSpaceNormal;
                    float3 ObjectSpaceTangent;
                    float3 ObjectSpacePosition;
                };
                struct PackedVaryings
                {
                    float4 positionCS : SV_POSITION;
                    float3 interp0 : TEXCOORD0;
                    float3 interp1 : TEXCOORD1;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    uint instanceID : CUSTOM_INSTANCE_ID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                    #endif
                };
    
                PackedVaryings PackVaryings (Varyings input)
                {
                    PackedVaryings output;
                    output.positionCS = input.positionCS;
                    output.interp0.xyz =  input.positionWS;
                    output.interp1.xyz =  input.normalWS;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    output.instanceID = input.instanceID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    output.cullFace = input.cullFace;
                    #endif
                    return output;
                }
                Varyings UnpackVaryings (PackedVaryings input)
                {
                    Varyings output;
                    output.positionCS = input.positionCS;
                    output.positionWS = input.interp0.xyz;
                    output.normalWS = input.interp1.xyz;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    output.instanceID = input.instanceID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    output.cullFace = input.cullFace;
                    #endif
                    return output;
                }
    
                // --------------------------------------------------
                // Graph
    
                // Graph Properties
                CBUFFER_START(UnityPerMaterial)
                float _DepthOffset;
                float _Strength;
                float4 _DeepWaterColor;
                float4 _ShallowWaterColor;
                float _Metallic;
                float2 _Tiling;
                float4 _OceanNormal2_TexelSize;
                float4 _OceanNormal1_TexelSize;
                float _GradientNoise;
                float2 _OceanSpeed;
                float _LODdistance;
                float4 _FarNormal_TexelSize;
                float4 _ShallowNormal_TexelSize;
                float _TranceparencyStrength;
                float _DownAlphaStrength;
                float _IsOcean;
                float4 _RiverNormal_TexelSize;
                float _RiverNormalRotAdjustment;
                float4 _LevelRiverNormal_TexelSize;
                float _RiverSpeed;
                float _ShoreIntersectionStrength;
                float4 Color_701f2c2f40b34b87975a0e85a71325dc;
                CBUFFER_END
                
                // Object and Global properties
                SAMPLER(SamplerState_Linear_Repeat);
                TEXTURE2D(_OceanNormal2);
                SAMPLER(sampler_OceanNormal2);
                TEXTURE2D(_OceanNormal1);
                SAMPLER(sampler_OceanNormal1);
                TEXTURE2D(_FarNormal);
                SAMPLER(sampler_FarNormal);
                TEXTURE2D(_ShallowNormal);
                SAMPLER(sampler_ShallowNormal);
                TEXTURE2D(_RiverNormal);
                SAMPLER(sampler_RiverNormal);
                TEXTURE2D(_LevelRiverNormal);
                SAMPLER(sampler_LevelRiverNormal);
                float _StretchScalar;
    
                // Graph Functions
                
                void Unity_SceneDepth_Linear01_float(float4 UV, out float Out)
                {
                    Out = Linear01Depth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
                }
                
                void Unity_Multiply_float(float A, float B, out float Out)
                {
                    Out = A * B;
                }
                
                void Unity_Add_float(float A, float B, out float Out)
                {
                    Out = A + B;
                }
                
                void Unity_Subtract_float(float A, float B, out float Out)
                {
                    Out = A - B;
                }
                
                void Unity_Sine_float(float In, out float Out)
                {
                    Out = sin(In);
                }
                
                void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
                {
                    Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
                }
                
                void Unity_Branch_float(float Predicate, float True, float False, out float Out)
                {
                    Out = Predicate ? True : False;
                }
                
                void Unity_Clamp_float(float In, float Min, float Max, out float Out)
                {
                    Out = clamp(In, Min, Max);
                }
                
                void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
                {
                    Out = lerp(A, B, T);
                }
                
                void Unity_Normalize_float3(float3 In, out float3 Out)
                {
                    Out = normalize(In);
                }
                
                void Unity_DotProduct_float3(float3 A, float3 B, out float Out)
                {
                    Out = dot(A, B);
                }
                
                void Unity_Add_float4(float4 A, float4 B, out float4 Out)
                {
                    Out = A + B;
                }
                
                void Unity_Lerp_float(float A, float B, float T, out float Out)
                {
                    Out = lerp(A, B, T);
                }
    
                // Graph Vertex
                struct VertexDescription
                {
                    float3 Position;
                    float3 Normal;
                    float3 Tangent;
                };
                
                VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                {
                    VertexDescription description = (VertexDescription)0;
                    description.Position = IN.ObjectSpacePosition;
                    description.Normal = IN.ObjectSpaceNormal;
                    description.Tangent = IN.ObjectSpaceTangent;
                    return description;
                }
    
                // Graph Pixel
                struct SurfaceDescription
                {
                    float3 BaseColor;
                    float3 Emission;
                    float Alpha;
                };
                
                SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                {
                    SurfaceDescription surface = (SurfaceDescription)0;
                    float4 _Property_231c0d262d3a466d85dfd53b116086ca_Out_0 = Color_701f2c2f40b34b87975a0e85a71325dc;
                    float _SceneDepth_3137d738aa0149fb8a54d88a60826a60_Out_1;
                    Unity_SceneDepth_Linear01_float(float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0), _SceneDepth_3137d738aa0149fb8a54d88a60826a60_Out_1);
                    float _Multiply_8ec8e0a1878e494ca0d6d16678168741_Out_2;
                    Unity_Multiply_float(_SceneDepth_3137d738aa0149fb8a54d88a60826a60_Out_1, _ProjectionParams.z, _Multiply_8ec8e0a1878e494ca0d6d16678168741_Out_2);
                    float4 _ScreenPosition_3840c0fb20fc4eb58387cd54ee7e2b18_Out_0 = IN.ScreenPosition;
                    float _Split_578ef5cadaac40969c114c4d1ae870d8_R_1 = _ScreenPosition_3840c0fb20fc4eb58387cd54ee7e2b18_Out_0[0];
                    float _Split_578ef5cadaac40969c114c4d1ae870d8_G_2 = _ScreenPosition_3840c0fb20fc4eb58387cd54ee7e2b18_Out_0[1];
                    float _Split_578ef5cadaac40969c114c4d1ae870d8_B_3 = _ScreenPosition_3840c0fb20fc4eb58387cd54ee7e2b18_Out_0[2];
                    float _Split_578ef5cadaac40969c114c4d1ae870d8_A_4 = _ScreenPosition_3840c0fb20fc4eb58387cd54ee7e2b18_Out_0[3];
                    float _Property_cedd17331b16484abf1a4ce8eb0e5a72_Out_0 = _DepthOffset;
                    float _Add_e04e1bc3087745d898c282f10a0f43e3_Out_2;
                    Unity_Add_float(_Split_578ef5cadaac40969c114c4d1ae870d8_A_4, _Property_cedd17331b16484abf1a4ce8eb0e5a72_Out_0, _Add_e04e1bc3087745d898c282f10a0f43e3_Out_2);
                    float _Subtract_bd4ff2ba7ce04051b10b968b020d06df_Out_2;
                    Unity_Subtract_float(_Multiply_8ec8e0a1878e494ca0d6d16678168741_Out_2, _Add_e04e1bc3087745d898c282f10a0f43e3_Out_2, _Subtract_bd4ff2ba7ce04051b10b968b020d06df_Out_2);
                    float _Property_90205b2f827548b295dc151171bc164c_Out_0 = _IsOcean;
                    float _Sine_24a173ac1d9d40b5b43bd7c8169386e4_Out_1;
                    Unity_Sine_float(IN.TimeParameters.x, _Sine_24a173ac1d9d40b5b43bd7c8169386e4_Out_1);
                    float _Remap_9ed3ea235fdc44d7a8c762cbe7ff6d0e_Out_3;
                    Unity_Remap_float(_Sine_24a173ac1d9d40b5b43bd7c8169386e4_Out_1, float2 (-1, 1), float2 (0.5, 1), _Remap_9ed3ea235fdc44d7a8c762cbe7ff6d0e_Out_3);
                    float _Branch_fcfcb84348fb4a5a90417124dc9ee3a2_Out_3;
                    Unity_Branch_float(_Property_90205b2f827548b295dc151171bc164c_Out_0, _Remap_9ed3ea235fdc44d7a8c762cbe7ff6d0e_Out_3, 1, _Branch_fcfcb84348fb4a5a90417124dc9ee3a2_Out_3);
                    float _Property_866bbbbe2a484e2eae1ad77ed223a577_Out_0 = _ShoreIntersectionStrength;
                    float _Multiply_cb7f54f30fb348b4a7f109f458e38b17_Out_2;
                    Unity_Multiply_float(_Branch_fcfcb84348fb4a5a90417124dc9ee3a2_Out_3, _Property_866bbbbe2a484e2eae1ad77ed223a577_Out_0, _Multiply_cb7f54f30fb348b4a7f109f458e38b17_Out_2);
                    float _Multiply_dcdae92bb4dd401a89df781ec062cecc_Out_2;
                    Unity_Multiply_float(_Subtract_bd4ff2ba7ce04051b10b968b020d06df_Out_2, _Multiply_cb7f54f30fb348b4a7f109f458e38b17_Out_2, _Multiply_dcdae92bb4dd401a89df781ec062cecc_Out_2);
                    float _Clamp_33ee6da80fc14439b6d7bab14be7ab07_Out_3;
                    Unity_Clamp_float(_Multiply_dcdae92bb4dd401a89df781ec062cecc_Out_2, 0.5, 1, _Clamp_33ee6da80fc14439b6d7bab14be7ab07_Out_3);
                    float4 _Lerp_f0669e92de0b409893955d23347ac238_Out_3;
                    Unity_Lerp_float4(_Property_231c0d262d3a466d85dfd53b116086ca_Out_0, float4(0, 0, 0, 0), (_Clamp_33ee6da80fc14439b6d7bab14be7ab07_Out_3.xxxx), _Lerp_f0669e92de0b409893955d23347ac238_Out_3);
                    float _Float_c4cf30aef9464dda83de90c7e790a9ba_Out_0 = 1.5;
                    float4 _Property_c854872c24e048c0aa372f0be547f07c_Out_0 = _ShallowWaterColor;
                    float4 _Property_dde44c4f61534e08a917dd16bcf5ebca_Out_0 = _DeepWaterColor;
                    float _Property_d328dfa89c674e67bffe73ef574a2d58_Out_0 = _Strength;
                    float _Multiply_4eb7822d949844e38f2bb60067662a47_Out_2;
                    Unity_Multiply_float(_Subtract_bd4ff2ba7ce04051b10b968b020d06df_Out_2, _Property_d328dfa89c674e67bffe73ef574a2d58_Out_0, _Multiply_4eb7822d949844e38f2bb60067662a47_Out_2);
                    float _Clamp_0f7ac1e483384940a0714a9e608d50b4_Out_3;
                    Unity_Clamp_float(_Multiply_4eb7822d949844e38f2bb60067662a47_Out_2, 0, 1, _Clamp_0f7ac1e483384940a0714a9e608d50b4_Out_3);
                    float4 _Lerp_3f9225ad7cdc45509b625268ef70e29c_Out_3;
                    Unity_Lerp_float4(_Property_c854872c24e048c0aa372f0be547f07c_Out_0, _Property_dde44c4f61534e08a917dd16bcf5ebca_Out_0, (_Clamp_0f7ac1e483384940a0714a9e608d50b4_Out_3.xxxx), _Lerp_3f9225ad7cdc45509b625268ef70e29c_Out_3);
                    float3 _Normalize_415b503188e443458e4172309aa4cb18_Out_1;
                    Unity_Normalize_float3(IN.WorldSpaceNormal, _Normalize_415b503188e443458e4172309aa4cb18_Out_1);
                    float _DotProduct_b3f1b90b273a4b2b99f07acbc4565dcb_Out_2;
                    Unity_DotProduct_float3(float3(0, 1, 0), _Normalize_415b503188e443458e4172309aa4cb18_Out_1, _DotProduct_b3f1b90b273a4b2b99f07acbc4565dcb_Out_2);
                    float _Remap_669938a90f934b9bab86d586a6917aca_Out_3;
                    Unity_Remap_float(_DotProduct_b3f1b90b273a4b2b99f07acbc4565dcb_Out_2, float2 (-1, 1), float2 (0, 1), _Remap_669938a90f934b9bab86d586a6917aca_Out_3);
                    float4 _Lerp_4536ba8c658e4f11aaefc80660368304_Out_3;
                    Unity_Lerp_float4((_Float_c4cf30aef9464dda83de90c7e790a9ba_Out_0.xxxx), _Lerp_3f9225ad7cdc45509b625268ef70e29c_Out_3, (_Remap_669938a90f934b9bab86d586a6917aca_Out_3.xxxx), _Lerp_4536ba8c658e4f11aaefc80660368304_Out_3);
                    float4 _Add_f8fda8450f33454d96a6212c8ebfdc62_Out_2;
                    Unity_Add_float4(_Lerp_f0669e92de0b409893955d23347ac238_Out_3, _Lerp_4536ba8c658e4f11aaefc80660368304_Out_3, _Add_f8fda8450f33454d96a6212c8ebfdc62_Out_2);
                    float _Split_17c957ee33bc4e28a994b8b8dd20a89f_R_1 = _Add_f8fda8450f33454d96a6212c8ebfdc62_Out_2[0];
                    float _Split_17c957ee33bc4e28a994b8b8dd20a89f_G_2 = _Add_f8fda8450f33454d96a6212c8ebfdc62_Out_2[1];
                    float _Split_17c957ee33bc4e28a994b8b8dd20a89f_B_3 = _Add_f8fda8450f33454d96a6212c8ebfdc62_Out_2[2];
                    float _Split_17c957ee33bc4e28a994b8b8dd20a89f_A_4 = _Add_f8fda8450f33454d96a6212c8ebfdc62_Out_2[3];
                    float3 _Vector3_3b779f158e6f4ba8ac091e620cd4bd1c_Out_0 = float3(_Split_17c957ee33bc4e28a994b8b8dd20a89f_R_1, _Split_17c957ee33bc4e28a994b8b8dd20a89f_G_2, _Split_17c957ee33bc4e28a994b8b8dd20a89f_B_3);
                    float _DotProduct_fb1cbb38204242edbadb0a15bc95b04e_Out_2;
                    Unity_DotProduct_float3(-1 * mul((float3x3)UNITY_MATRIX_M, transpose(mul(UNITY_MATRIX_I_M, UNITY_MATRIX_I_V)) [2].xyz), IN.WorldSpaceNormal, _DotProduct_fb1cbb38204242edbadb0a15bc95b04e_Out_2);
                    float _Remap_bde541d934954ce5b99314edcbcd70e5_Out_3;
                    Unity_Remap_float(_DotProduct_fb1cbb38204242edbadb0a15bc95b04e_Out_2, float2 (-1, 0), float2 (0, 1), _Remap_bde541d934954ce5b99314edcbcd70e5_Out_3);
                    float _Multiply_6330a2a6c69948a5aacc174b9da1d2f0_Out_2;
                    Unity_Multiply_float(_Split_17c957ee33bc4e28a994b8b8dd20a89f_A_4, _Remap_bde541d934954ce5b99314edcbcd70e5_Out_3, _Multiply_6330a2a6c69948a5aacc174b9da1d2f0_Out_2);
                    float _Property_bc84cef440384b15875875c65e907453_Out_0 = _DownAlphaStrength;
                    float _Property_f604cf40fc3249839fb755ab1c9d8eb2_Out_0 = _TranceparencyStrength;
                    float _Multiply_c4a5b4f21dfe45d2a2f78cc50eba3ec8_Out_2;
                    Unity_Multiply_float(_Subtract_bd4ff2ba7ce04051b10b968b020d06df_Out_2, _Property_f604cf40fc3249839fb755ab1c9d8eb2_Out_0, _Multiply_c4a5b4f21dfe45d2a2f78cc50eba3ec8_Out_2);
                    float _Clamp_61028b06dbf14a6092a617f0d8a7ac32_Out_3;
                    Unity_Clamp_float(_Multiply_c4a5b4f21dfe45d2a2f78cc50eba3ec8_Out_2, 0, 1, _Clamp_61028b06dbf14a6092a617f0d8a7ac32_Out_3);
                    float _Lerp_106a757383d0403399452dcbb99cc72a_Out_3;
                    Unity_Lerp_float(_Property_bc84cef440384b15875875c65e907453_Out_0, 0, _Clamp_61028b06dbf14a6092a617f0d8a7ac32_Out_3, _Lerp_106a757383d0403399452dcbb99cc72a_Out_3);
                    float _Lerp_729c45b3c3014bdbb92bb4198e06bd92_Out_3;
                    Unity_Lerp_float(1, 0, _Remap_bde541d934954ce5b99314edcbcd70e5_Out_3, _Lerp_729c45b3c3014bdbb92bb4198e06bd92_Out_3);
                    float _Multiply_a80cb3307cd746d7a1bb5f699c9423f3_Out_2;
                    Unity_Multiply_float(_Lerp_106a757383d0403399452dcbb99cc72a_Out_3, _Lerp_729c45b3c3014bdbb92bb4198e06bd92_Out_3, _Multiply_a80cb3307cd746d7a1bb5f699c9423f3_Out_2);
                    float _Lerp_b12dda477cf14695add7f2de406dd644_Out_3;
                    Unity_Lerp_float(_Split_17c957ee33bc4e28a994b8b8dd20a89f_A_4, _Multiply_6330a2a6c69948a5aacc174b9da1d2f0_Out_2, _Multiply_a80cb3307cd746d7a1bb5f699c9423f3_Out_2, _Lerp_b12dda477cf14695add7f2de406dd644_Out_3);
                    surface.BaseColor = _Vector3_3b779f158e6f4ba8ac091e620cd4bd1c_Out_0;
                    surface.Emission = float3(0, 0, 0);
                    surface.Alpha = _Lerp_b12dda477cf14695add7f2de406dd644_Out_3;
                    return surface;
                }
    
                // --------------------------------------------------
                // Build Graph Inputs
    
                VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                {
                    VertexDescriptionInputs output;
                    ZERO_INITIALIZE(VertexDescriptionInputs, output);
                
                    output.ObjectSpaceNormal =           input.normalOS;
                    output.ObjectSpaceTangent =          input.tangentOS.xyz;
                    output.ObjectSpacePosition =         input.positionOS;
                
                    return output;
                }
                
                SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                {
                    SurfaceDescriptionInputs output;
                    ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
                
                	// must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
                	float3 unnormalizedNormalWS = input.normalWS;
                    const float renormFactor = 1.0 / length(unnormalizedNormalWS);
                
                
                    output.WorldSpaceNormal =            renormFactor*input.normalWS.xyz;		// we want a unit length Normal Vector node in shader graph
                
                
                    output.WorldSpacePosition =          input.positionWS;
                    output.ScreenPosition =              ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
                    output.TimeParameters =              _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                #else
                #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                #endif
                #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                
                    return output;
                }
                
    
                // --------------------------------------------------
                // Main
    
                #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/LightingMetaPass.hlsl"
    
                ENDHLSL
            }
            Pass
            {
                // Name: <None>
                Tags
                {
                    "LightMode" = "Universal2D"
                }
    
                // Render State
                Cull Off
                Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
                ZTest LEqual
                ZWrite Off
    
                // Debug
                // <None>
    
                // --------------------------------------------------
                // Pass
    
                HLSLPROGRAM
    
                // Pragmas
                #pragma target 2.0
                #pragma only_renderers gles gles3 glcore d3d11
                #pragma multi_compile_instancing
                #pragma vertex vert
                #pragma fragment frag
    
                // DotsInstancingOptions: <None>
                // HybridV1InjectedBuiltinProperties: <None>
    
                // Keywords
                // PassKeywords: <None>
                // GraphKeywords: <None>
    
                // Defines
                #define _SURFACE_TYPE_TRANSPARENT 1
                #define _NORMALMAP 1
                #define _NORMAL_DROPOFF_TS 1
                #define ATTRIBUTES_NEED_NORMAL
                #define ATTRIBUTES_NEED_TANGENT
                #define VARYINGS_NEED_POSITION_WS
                #define VARYINGS_NEED_NORMAL_WS
                #define FEATURES_GRAPH_VERTEX
                /* WARNING: $splice Could not find named fragment 'PassInstancing' */
                #define SHADERPASS SHADERPASS_2D
                #define REQUIRE_DEPTH_TEXTURE
                /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
    
                // Includes
                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
    
                // --------------------------------------------------
                // Structs and Packing
    
                struct Attributes
                {
                    float3 positionOS : POSITION;
                    float3 normalOS : NORMAL;
                    float4 tangentOS : TANGENT;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    uint instanceID : INSTANCEID_SEMANTIC;
                    #endif
                };
                struct Varyings
                {
                    float4 positionCS : SV_POSITION;
                    float3 positionWS;
                    float3 normalWS;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    uint instanceID : CUSTOM_INSTANCE_ID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                    #endif
                };
                struct SurfaceDescriptionInputs
                {
                    float3 WorldSpaceNormal;
                    float3 WorldSpacePosition;
                    float4 ScreenPosition;
                    float3 TimeParameters;
                };
                struct VertexDescriptionInputs
                {
                    float3 ObjectSpaceNormal;
                    float3 ObjectSpaceTangent;
                    float3 ObjectSpacePosition;
                };
                struct PackedVaryings
                {
                    float4 positionCS : SV_POSITION;
                    float3 interp0 : TEXCOORD0;
                    float3 interp1 : TEXCOORD1;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    uint instanceID : CUSTOM_INSTANCE_ID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                    #endif
                };
    
                PackedVaryings PackVaryings (Varyings input)
                {
                    PackedVaryings output;
                    output.positionCS = input.positionCS;
                    output.interp0.xyz =  input.positionWS;
                    output.interp1.xyz =  input.normalWS;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    output.instanceID = input.instanceID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    output.cullFace = input.cullFace;
                    #endif
                    return output;
                }
                Varyings UnpackVaryings (PackedVaryings input)
                {
                    Varyings output;
                    output.positionCS = input.positionCS;
                    output.positionWS = input.interp0.xyz;
                    output.normalWS = input.interp1.xyz;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    output.instanceID = input.instanceID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    output.cullFace = input.cullFace;
                    #endif
                    return output;
                }
    
                // --------------------------------------------------
                // Graph
    
                // Graph Properties
                CBUFFER_START(UnityPerMaterial)
                float _DepthOffset;
                float _Strength;
                float4 _DeepWaterColor;
                float4 _ShallowWaterColor;
                float _Metallic;
                float2 _Tiling;
                float4 _OceanNormal2_TexelSize;
                float4 _OceanNormal1_TexelSize;
                float _GradientNoise;
                float2 _OceanSpeed;
                float _LODdistance;
                float4 _FarNormal_TexelSize;
                float4 _ShallowNormal_TexelSize;
                float _TranceparencyStrength;
                float _DownAlphaStrength;
                float _IsOcean;
                float4 _RiverNormal_TexelSize;
                float _RiverNormalRotAdjustment;
                float4 _LevelRiverNormal_TexelSize;
                float _RiverSpeed;
                float _ShoreIntersectionStrength;
                float4 Color_701f2c2f40b34b87975a0e85a71325dc;
                CBUFFER_END
                
                // Object and Global properties
                SAMPLER(SamplerState_Linear_Repeat);
                TEXTURE2D(_OceanNormal2);
                SAMPLER(sampler_OceanNormal2);
                TEXTURE2D(_OceanNormal1);
                SAMPLER(sampler_OceanNormal1);
                TEXTURE2D(_FarNormal);
                SAMPLER(sampler_FarNormal);
                TEXTURE2D(_ShallowNormal);
                SAMPLER(sampler_ShallowNormal);
                TEXTURE2D(_RiverNormal);
                SAMPLER(sampler_RiverNormal);
                TEXTURE2D(_LevelRiverNormal);
                SAMPLER(sampler_LevelRiverNormal);
                float _StretchScalar;
    
                // Graph Functions
                
                void Unity_SceneDepth_Linear01_float(float4 UV, out float Out)
                {
                    Out = Linear01Depth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
                }
                
                void Unity_Multiply_float(float A, float B, out float Out)
                {
                    Out = A * B;
                }
                
                void Unity_Add_float(float A, float B, out float Out)
                {
                    Out = A + B;
                }
                
                void Unity_Subtract_float(float A, float B, out float Out)
                {
                    Out = A - B;
                }
                
                void Unity_Sine_float(float In, out float Out)
                {
                    Out = sin(In);
                }
                
                void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
                {
                    Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
                }
                
                void Unity_Branch_float(float Predicate, float True, float False, out float Out)
                {
                    Out = Predicate ? True : False;
                }
                
                void Unity_Clamp_float(float In, float Min, float Max, out float Out)
                {
                    Out = clamp(In, Min, Max);
                }
                
                void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
                {
                    Out = lerp(A, B, T);
                }
                
                void Unity_Normalize_float3(float3 In, out float3 Out)
                {
                    Out = normalize(In);
                }
                
                void Unity_DotProduct_float3(float3 A, float3 B, out float Out)
                {
                    Out = dot(A, B);
                }
                
                void Unity_Add_float4(float4 A, float4 B, out float4 Out)
                {
                    Out = A + B;
                }
                
                void Unity_Lerp_float(float A, float B, float T, out float Out)
                {
                    Out = lerp(A, B, T);
                }
    
                // Graph Vertex
                struct VertexDescription
                {
                    float3 Position;
                    float3 Normal;
                    float3 Tangent;
                };
                
                VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                {
                    VertexDescription description = (VertexDescription)0;
                    description.Position = IN.ObjectSpacePosition;
                    description.Normal = IN.ObjectSpaceNormal;
                    description.Tangent = IN.ObjectSpaceTangent;
                    return description;
                }
    
                // Graph Pixel
                struct SurfaceDescription
                {
                    float3 BaseColor;
                    float Alpha;
                };
                
                SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                {
                    SurfaceDescription surface = (SurfaceDescription)0;
                    float4 _Property_231c0d262d3a466d85dfd53b116086ca_Out_0 = Color_701f2c2f40b34b87975a0e85a71325dc;
                    float _SceneDepth_3137d738aa0149fb8a54d88a60826a60_Out_1;
                    Unity_SceneDepth_Linear01_float(float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0), _SceneDepth_3137d738aa0149fb8a54d88a60826a60_Out_1);
                    float _Multiply_8ec8e0a1878e494ca0d6d16678168741_Out_2;
                    Unity_Multiply_float(_SceneDepth_3137d738aa0149fb8a54d88a60826a60_Out_1, _ProjectionParams.z, _Multiply_8ec8e0a1878e494ca0d6d16678168741_Out_2);
                    float4 _ScreenPosition_3840c0fb20fc4eb58387cd54ee7e2b18_Out_0 = IN.ScreenPosition;
                    float _Split_578ef5cadaac40969c114c4d1ae870d8_R_1 = _ScreenPosition_3840c0fb20fc4eb58387cd54ee7e2b18_Out_0[0];
                    float _Split_578ef5cadaac40969c114c4d1ae870d8_G_2 = _ScreenPosition_3840c0fb20fc4eb58387cd54ee7e2b18_Out_0[1];
                    float _Split_578ef5cadaac40969c114c4d1ae870d8_B_3 = _ScreenPosition_3840c0fb20fc4eb58387cd54ee7e2b18_Out_0[2];
                    float _Split_578ef5cadaac40969c114c4d1ae870d8_A_4 = _ScreenPosition_3840c0fb20fc4eb58387cd54ee7e2b18_Out_0[3];
                    float _Property_cedd17331b16484abf1a4ce8eb0e5a72_Out_0 = _DepthOffset;
                    float _Add_e04e1bc3087745d898c282f10a0f43e3_Out_2;
                    Unity_Add_float(_Split_578ef5cadaac40969c114c4d1ae870d8_A_4, _Property_cedd17331b16484abf1a4ce8eb0e5a72_Out_0, _Add_e04e1bc3087745d898c282f10a0f43e3_Out_2);
                    float _Subtract_bd4ff2ba7ce04051b10b968b020d06df_Out_2;
                    Unity_Subtract_float(_Multiply_8ec8e0a1878e494ca0d6d16678168741_Out_2, _Add_e04e1bc3087745d898c282f10a0f43e3_Out_2, _Subtract_bd4ff2ba7ce04051b10b968b020d06df_Out_2);
                    float _Property_90205b2f827548b295dc151171bc164c_Out_0 = _IsOcean;
                    float _Sine_24a173ac1d9d40b5b43bd7c8169386e4_Out_1;
                    Unity_Sine_float(IN.TimeParameters.x, _Sine_24a173ac1d9d40b5b43bd7c8169386e4_Out_1);
                    float _Remap_9ed3ea235fdc44d7a8c762cbe7ff6d0e_Out_3;
                    Unity_Remap_float(_Sine_24a173ac1d9d40b5b43bd7c8169386e4_Out_1, float2 (-1, 1), float2 (0.5, 1), _Remap_9ed3ea235fdc44d7a8c762cbe7ff6d0e_Out_3);
                    float _Branch_fcfcb84348fb4a5a90417124dc9ee3a2_Out_3;
                    Unity_Branch_float(_Property_90205b2f827548b295dc151171bc164c_Out_0, _Remap_9ed3ea235fdc44d7a8c762cbe7ff6d0e_Out_3, 1, _Branch_fcfcb84348fb4a5a90417124dc9ee3a2_Out_3);
                    float _Property_866bbbbe2a484e2eae1ad77ed223a577_Out_0 = _ShoreIntersectionStrength;
                    float _Multiply_cb7f54f30fb348b4a7f109f458e38b17_Out_2;
                    Unity_Multiply_float(_Branch_fcfcb84348fb4a5a90417124dc9ee3a2_Out_3, _Property_866bbbbe2a484e2eae1ad77ed223a577_Out_0, _Multiply_cb7f54f30fb348b4a7f109f458e38b17_Out_2);
                    float _Multiply_dcdae92bb4dd401a89df781ec062cecc_Out_2;
                    Unity_Multiply_float(_Subtract_bd4ff2ba7ce04051b10b968b020d06df_Out_2, _Multiply_cb7f54f30fb348b4a7f109f458e38b17_Out_2, _Multiply_dcdae92bb4dd401a89df781ec062cecc_Out_2);
                    float _Clamp_33ee6da80fc14439b6d7bab14be7ab07_Out_3;
                    Unity_Clamp_float(_Multiply_dcdae92bb4dd401a89df781ec062cecc_Out_2, 0.5, 1, _Clamp_33ee6da80fc14439b6d7bab14be7ab07_Out_3);
                    float4 _Lerp_f0669e92de0b409893955d23347ac238_Out_3;
                    Unity_Lerp_float4(_Property_231c0d262d3a466d85dfd53b116086ca_Out_0, float4(0, 0, 0, 0), (_Clamp_33ee6da80fc14439b6d7bab14be7ab07_Out_3.xxxx), _Lerp_f0669e92de0b409893955d23347ac238_Out_3);
                    float _Float_c4cf30aef9464dda83de90c7e790a9ba_Out_0 = 1.5;
                    float4 _Property_c854872c24e048c0aa372f0be547f07c_Out_0 = _ShallowWaterColor;
                    float4 _Property_dde44c4f61534e08a917dd16bcf5ebca_Out_0 = _DeepWaterColor;
                    float _Property_d328dfa89c674e67bffe73ef574a2d58_Out_0 = _Strength;
                    float _Multiply_4eb7822d949844e38f2bb60067662a47_Out_2;
                    Unity_Multiply_float(_Subtract_bd4ff2ba7ce04051b10b968b020d06df_Out_2, _Property_d328dfa89c674e67bffe73ef574a2d58_Out_0, _Multiply_4eb7822d949844e38f2bb60067662a47_Out_2);
                    float _Clamp_0f7ac1e483384940a0714a9e608d50b4_Out_3;
                    Unity_Clamp_float(_Multiply_4eb7822d949844e38f2bb60067662a47_Out_2, 0, 1, _Clamp_0f7ac1e483384940a0714a9e608d50b4_Out_3);
                    float4 _Lerp_3f9225ad7cdc45509b625268ef70e29c_Out_3;
                    Unity_Lerp_float4(_Property_c854872c24e048c0aa372f0be547f07c_Out_0, _Property_dde44c4f61534e08a917dd16bcf5ebca_Out_0, (_Clamp_0f7ac1e483384940a0714a9e608d50b4_Out_3.xxxx), _Lerp_3f9225ad7cdc45509b625268ef70e29c_Out_3);
                    float3 _Normalize_415b503188e443458e4172309aa4cb18_Out_1;
                    Unity_Normalize_float3(IN.WorldSpaceNormal, _Normalize_415b503188e443458e4172309aa4cb18_Out_1);
                    float _DotProduct_b3f1b90b273a4b2b99f07acbc4565dcb_Out_2;
                    Unity_DotProduct_float3(float3(0, 1, 0), _Normalize_415b503188e443458e4172309aa4cb18_Out_1, _DotProduct_b3f1b90b273a4b2b99f07acbc4565dcb_Out_2);
                    float _Remap_669938a90f934b9bab86d586a6917aca_Out_3;
                    Unity_Remap_float(_DotProduct_b3f1b90b273a4b2b99f07acbc4565dcb_Out_2, float2 (-1, 1), float2 (0, 1), _Remap_669938a90f934b9bab86d586a6917aca_Out_3);
                    float4 _Lerp_4536ba8c658e4f11aaefc80660368304_Out_3;
                    Unity_Lerp_float4((_Float_c4cf30aef9464dda83de90c7e790a9ba_Out_0.xxxx), _Lerp_3f9225ad7cdc45509b625268ef70e29c_Out_3, (_Remap_669938a90f934b9bab86d586a6917aca_Out_3.xxxx), _Lerp_4536ba8c658e4f11aaefc80660368304_Out_3);
                    float4 _Add_f8fda8450f33454d96a6212c8ebfdc62_Out_2;
                    Unity_Add_float4(_Lerp_f0669e92de0b409893955d23347ac238_Out_3, _Lerp_4536ba8c658e4f11aaefc80660368304_Out_3, _Add_f8fda8450f33454d96a6212c8ebfdc62_Out_2);
                    float _Split_17c957ee33bc4e28a994b8b8dd20a89f_R_1 = _Add_f8fda8450f33454d96a6212c8ebfdc62_Out_2[0];
                    float _Split_17c957ee33bc4e28a994b8b8dd20a89f_G_2 = _Add_f8fda8450f33454d96a6212c8ebfdc62_Out_2[1];
                    float _Split_17c957ee33bc4e28a994b8b8dd20a89f_B_3 = _Add_f8fda8450f33454d96a6212c8ebfdc62_Out_2[2];
                    float _Split_17c957ee33bc4e28a994b8b8dd20a89f_A_4 = _Add_f8fda8450f33454d96a6212c8ebfdc62_Out_2[3];
                    float3 _Vector3_3b779f158e6f4ba8ac091e620cd4bd1c_Out_0 = float3(_Split_17c957ee33bc4e28a994b8b8dd20a89f_R_1, _Split_17c957ee33bc4e28a994b8b8dd20a89f_G_2, _Split_17c957ee33bc4e28a994b8b8dd20a89f_B_3);
                    float _DotProduct_fb1cbb38204242edbadb0a15bc95b04e_Out_2;
                    Unity_DotProduct_float3(-1 * mul((float3x3)UNITY_MATRIX_M, transpose(mul(UNITY_MATRIX_I_M, UNITY_MATRIX_I_V)) [2].xyz), IN.WorldSpaceNormal, _DotProduct_fb1cbb38204242edbadb0a15bc95b04e_Out_2);
                    float _Remap_bde541d934954ce5b99314edcbcd70e5_Out_3;
                    Unity_Remap_float(_DotProduct_fb1cbb38204242edbadb0a15bc95b04e_Out_2, float2 (-1, 0), float2 (0, 1), _Remap_bde541d934954ce5b99314edcbcd70e5_Out_3);
                    float _Multiply_6330a2a6c69948a5aacc174b9da1d2f0_Out_2;
                    Unity_Multiply_float(_Split_17c957ee33bc4e28a994b8b8dd20a89f_A_4, _Remap_bde541d934954ce5b99314edcbcd70e5_Out_3, _Multiply_6330a2a6c69948a5aacc174b9da1d2f0_Out_2);
                    float _Property_bc84cef440384b15875875c65e907453_Out_0 = _DownAlphaStrength;
                    float _Property_f604cf40fc3249839fb755ab1c9d8eb2_Out_0 = _TranceparencyStrength;
                    float _Multiply_c4a5b4f21dfe45d2a2f78cc50eba3ec8_Out_2;
                    Unity_Multiply_float(_Subtract_bd4ff2ba7ce04051b10b968b020d06df_Out_2, _Property_f604cf40fc3249839fb755ab1c9d8eb2_Out_0, _Multiply_c4a5b4f21dfe45d2a2f78cc50eba3ec8_Out_2);
                    float _Clamp_61028b06dbf14a6092a617f0d8a7ac32_Out_3;
                    Unity_Clamp_float(_Multiply_c4a5b4f21dfe45d2a2f78cc50eba3ec8_Out_2, 0, 1, _Clamp_61028b06dbf14a6092a617f0d8a7ac32_Out_3);
                    float _Lerp_106a757383d0403399452dcbb99cc72a_Out_3;
                    Unity_Lerp_float(_Property_bc84cef440384b15875875c65e907453_Out_0, 0, _Clamp_61028b06dbf14a6092a617f0d8a7ac32_Out_3, _Lerp_106a757383d0403399452dcbb99cc72a_Out_3);
                    float _Lerp_729c45b3c3014bdbb92bb4198e06bd92_Out_3;
                    Unity_Lerp_float(1, 0, _Remap_bde541d934954ce5b99314edcbcd70e5_Out_3, _Lerp_729c45b3c3014bdbb92bb4198e06bd92_Out_3);
                    float _Multiply_a80cb3307cd746d7a1bb5f699c9423f3_Out_2;
                    Unity_Multiply_float(_Lerp_106a757383d0403399452dcbb99cc72a_Out_3, _Lerp_729c45b3c3014bdbb92bb4198e06bd92_Out_3, _Multiply_a80cb3307cd746d7a1bb5f699c9423f3_Out_2);
                    float _Lerp_b12dda477cf14695add7f2de406dd644_Out_3;
                    Unity_Lerp_float(_Split_17c957ee33bc4e28a994b8b8dd20a89f_A_4, _Multiply_6330a2a6c69948a5aacc174b9da1d2f0_Out_2, _Multiply_a80cb3307cd746d7a1bb5f699c9423f3_Out_2, _Lerp_b12dda477cf14695add7f2de406dd644_Out_3);
                    surface.BaseColor = _Vector3_3b779f158e6f4ba8ac091e620cd4bd1c_Out_0;
                    surface.Alpha = _Lerp_b12dda477cf14695add7f2de406dd644_Out_3;
                    return surface;
                }
    
                // --------------------------------------------------
                // Build Graph Inputs
    
                VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                {
                    VertexDescriptionInputs output;
                    ZERO_INITIALIZE(VertexDescriptionInputs, output);
                
                    output.ObjectSpaceNormal =           input.normalOS;
                    output.ObjectSpaceTangent =          input.tangentOS.xyz;
                    output.ObjectSpacePosition =         input.positionOS;
                
                    return output;
                }
                
                SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                {
                    SurfaceDescriptionInputs output;
                    ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
                
                	// must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
                	float3 unnormalizedNormalWS = input.normalWS;
                    const float renormFactor = 1.0 / length(unnormalizedNormalWS);
                
                
                    output.WorldSpaceNormal =            renormFactor*input.normalWS.xyz;		// we want a unit length Normal Vector node in shader graph
                
                
                    output.WorldSpacePosition =          input.positionWS;
                    output.ScreenPosition =              ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
                    output.TimeParameters =              _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                #else
                #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                #endif
                #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                
                    return output;
                }
                
    
                // --------------------------------------------------
                // Main
    
                #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBR2DPass.hlsl"
    
                ENDHLSL
            }
        }
        CustomEditor "WaterShaderGUI"
        FallBack "Hidden/Shader Graph/FallbackError"
    }