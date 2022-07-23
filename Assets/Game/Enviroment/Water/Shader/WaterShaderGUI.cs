using UnityEngine;
using UnityEditor;
public class WaterShaderGUI
{
}
//public class WaterShaderGUI : ShaderGUI
//{
//    public override void OnGUI(MaterialEditor materialEditor, MaterialProperty[] properties)
//    {
//        MaterialProperty _IsControlledByScript = ShaderGUI.FindProperty("_IsControlledByScript", properties);

//        //materialEditor.ShaderProperty(_IsControlledByScript, _IsControlledByScript.displayName);

//        MaterialProperty _DepthOffset = ShaderGUI.FindProperty("_DepthOffset", properties);
//        MaterialProperty _Strength = ShaderGUI.FindProperty("_Strength", properties);
//        MaterialProperty _DeepWaterColor = ShaderGUI.FindProperty("_DeepWaterColor", properties);
//        MaterialProperty _ShallowWaterColor = ShaderGUI.FindProperty("_ShallowWaterColor", properties);
//        MaterialProperty _Metallic = ShaderGUI.FindProperty("_Metallic", properties);
//        MaterialProperty _Tiling = ShaderGUI.FindProperty("_Tiling", properties);
//        MaterialProperty _IsOcean = ShaderGUI.FindProperty("_IsOcean", properties);

//        MaterialProperty _LODdistance = ShaderGUI.FindProperty("_LODdistance", properties);
//        MaterialProperty _FarNormal = ShaderGUI.FindProperty("_FarNormal", properties);

//        MaterialProperty _ShallowNormal = ShaderGUI.FindProperty("_ShallowNormal", properties);
//        MaterialProperty _TranceparencyStrength = ShaderGUI.FindProperty("_TranceparencyStrength", properties);
//        MaterialProperty _DownAlphaStrength = ShaderGUI.FindProperty("_DownAlphaStrength", properties);
//        MaterialProperty _ShoreIntersectionStrength = ShaderGUI.FindProperty("_ShoreIntersectionStrength", properties);
//        MaterialProperty ShoreColor = ShaderGUI.FindProperty("ShoreColor", properties);

//        MaterialProperty _OceanNormal1 = ShaderGUI.FindProperty("_OceanNormal1", properties);
//        MaterialProperty _OceanNormal2 = ShaderGUI.FindProperty("_OceanNormal2", properties);
//        MaterialProperty _GradientNoise = ShaderGUI.FindProperty("_GradientNoise", properties);
//        MaterialProperty _OceanSpeed = ShaderGUI.FindProperty("_OceanSpeed", properties);


//        MaterialProperty _RiverNormal = ShaderGUI.FindProperty("_RiverNormal", properties);
//        MaterialProperty _RiverNormalRotAdjustment = ShaderGUI.FindProperty("_RiverNormalRotAdjustment", properties);
//        MaterialProperty _LevelRiverNormal = ShaderGUI.FindProperty("_LevelRiverNormal", properties);
//        MaterialProperty _RiverSpeed = ShaderGUI.FindProperty("_RiverSpeed", properties);


//        if (_IsControlledByScript.floatValue == 1)
//        {
            

//            materialEditor.ShaderProperty(_DepthOffset, _DepthOffset.displayName);
//            materialEditor.ShaderProperty(_Strength, _Strength.displayName);
//            materialEditor.ShaderProperty(_DeepWaterColor, _DeepWaterColor.displayName);
//            materialEditor.ShaderProperty(_ShallowWaterColor, _ShallowWaterColor.displayName);
//            materialEditor.ShaderProperty(_Metallic, _Metallic.displayName);
//            materialEditor.ShaderProperty(_Tiling, _Tiling.displayName);
//            materialEditor.ShaderProperty(_IsOcean, _IsOcean.displayName);




//            if (_IsOcean.floatValue == 1)
//            {
                


//                materialEditor.ShaderProperty(_OceanNormal1, _OceanNormal1.displayName);
//                materialEditor.ShaderProperty(_OceanNormal2, _OceanNormal2.displayName);
//                materialEditor.ShaderProperty(_GradientNoise, _GradientNoise.displayName);
//                materialEditor.ShaderProperty(_OceanSpeed, _OceanSpeed.displayName);
//            }
//            else
//            {
                

//                materialEditor.ShaderProperty(_RiverNormal, _RiverNormal.displayName);
//                materialEditor.ShaderProperty(_RiverNormalRotAdjustment, _RiverNormalRotAdjustment.displayName);
//                materialEditor.ShaderProperty(_LevelRiverNormal, _LevelRiverNormal.displayName);
//                materialEditor.ShaderProperty(_RiverSpeed, _RiverSpeed.displayName);
//            }


//            materialEditor.ShaderProperty(_LODdistance, _LODdistance.displayName);
//            materialEditor.ShaderProperty(_FarNormal, _FarNormal.displayName);

//            materialEditor.ShaderProperty(_ShallowNormal, _ShallowNormal.displayName);
//            materialEditor.ShaderProperty(_TranceparencyStrength, _TranceparencyStrength.displayName);
//            materialEditor.ShaderProperty(_DownAlphaStrength, _DownAlphaStrength.displayName);
//            materialEditor.ShaderProperty(_ShoreIntersectionStrength, _ShoreIntersectionStrength.displayName);
//            materialEditor.ShaderProperty(ShoreColor, ShoreColor.displayName);
//        }
//    }
//}