using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Cinemachine;
public class CineSetTarget : PlayerRef
{
    
    private void Start()
    {
        Transform hips = TargetCharacter.GetComponent<Animator>().GetBoneTransform(HumanBodyBones.Hips);
        Cinemachine.CinemachineVirtualCamera[] cams = GetComponentsInChildren<CinemachineVirtualCamera>(true);
        foreach(CinemachineVirtualCamera cam in cams)
        {
            cam.Follow = hips.transform;
            cam.LookAt = hips.transform;
        }
        GetComponentInChildren<CinemachineBrain>().m_WorldUpOverride = TargetCharacter.transform;
        GetComponentInChildren<SwitchVCam>().controller = TargetCharacter;
        GetComponentInChildren<RideSwitchVCam>().controller = TargetCharacter;
    }
}
