using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.InputSystem;
using Cinemachine;
using Character;

public class SwitchVCam : PlayerRef
{
    [SerializeField]
    private PlayerInput playerInput;
    [SerializeField]
    private int priorityBoostAmount = 10;

    //public GameObject aimCrosshair;
    //public GameObject normalCrosshair;
    public Shooter.UI.CrosshairManager crosshairManager;
    public GameObject bulletTimeBlur;

    public Controller controller;

    public float distEndBullettime;

    private InputAction action;
    private CinemachineVirtualCamera vCam;
    private void Awake()
    {
        controller = TargetCharacter;
        vCam = GetComponent<CinemachineVirtualCamera>();
        if (controller.TryGetComponent(out PlayerInput playin) && playerInput == null)
        {
            playerInput = playin;
        }
        if (playerInput == null) Debug.LogError("Warning: PlayerInput not found.");// double check that you have a player referenced.
        action = playerInput.actions["Aim"];

    }

    private void OnEnable()
    {
        action.performed += _ => StartAim();
        action.canceled += _ => CancelAim();
    }
    private void OnDisable()
    {
        action.performed -= _ => StartAim();
        action.canceled -= _ => CancelAim();
    }

    public void StartAim()
    {
        vCam.Priority += priorityBoostAmount;
        //normalCrosshair.SetActive(false);
        //aimCrosshair.SetActive(true);
        //crosshairManager.UpdateCorosshair();

        if (!controller.Grounded)
        {
            bulletTimeBlur.SetActive(true);
            Time.timeScale = 0.33f;
            if(!running)
                StartCoroutine(CheckGround());
        }
    }
    public void CancelAim()
    {
        vCam.Priority -= priorityBoostAmount;
        //aimCrosshair.SetActive(false);
        crosshairManager.UpdateCorosshair();
        //normalCrosshair.SetActive(true);
        Time.timeScale = 1f;
        bulletTimeBlur.SetActive(false);
    }

    public void HitGround()
    {
        bulletTimeBlur.SetActive(false);
    }

    bool running = false;
    
    public IEnumerator CheckGround()
    {
        running = true;
        RaycastHit hit;

        yield return new WaitUntil(() => Physics.Raycast(controller.transform.position, Vector3.down, distEndBullettime));
        running = false;
        Time.timeScale = 1f;
        bulletTimeBlur.SetActive(false);
    }


}
