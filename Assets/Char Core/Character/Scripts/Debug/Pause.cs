using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.InputSystem;

public class Pause : MonoBehaviour
{
    public PlayerInput input;
    private InputAction action;

    private void OnEnable()
    {
        action = input.actions["DebugPause"];
        action.performed += _ => Act();
    }
    void Act()
    {
        Debug.Break();
    }
}
