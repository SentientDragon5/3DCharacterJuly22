using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Cinemachine;

public class CineAddRot : MonoBehaviour
{
    public Transform target;
    CinemachineVirtualCamera vc;
    CinemachineComposer comp;

    private void Awake()
    {
        vc = GetComponent<CinemachineVirtualCamera>();
        comp = vc.GetCinemachineComponent<CinemachineComposer>();
    }
    private void FixedUpdate()
    {
        comp.m_TrackedObjectOffset = -transform.forward;
    }
}
