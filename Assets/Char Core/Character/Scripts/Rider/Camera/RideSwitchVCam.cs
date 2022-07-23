using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.InputSystem;
using Cinemachine;
using Character;
using Character.Riding;

public class RideSwitchVCam : PlayerRef
{
    [SerializeField]
    private int priorityBoostAmount = 10;

    public Controller controller;


    private CinemachineVirtualCamera vCam;
    private void Awake()
    {
        controller = TargetCharacter;
        vCam = GetComponent<CinemachineVirtualCamera>();
        if (controller.TryGetComponent<Rider>(out Rider rider))
        {
            rider.OnStartRide.AddListener(StartAim);
            rider.OnStopRide.AddListener(CancelAim);
        }
    }

    public void StartAim()
    {
        vCam.Priority += priorityBoostAmount;
    }
    public void CancelAim()
    {
        vCam.Priority -= priorityBoostAmount;
    }
}
