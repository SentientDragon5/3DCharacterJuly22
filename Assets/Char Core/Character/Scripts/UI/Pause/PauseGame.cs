using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.InputSystem;
using UnityEngine.Events;

public class PauseGame : MonoBehaviour
{
    public PlayerInput input;
    private GameObject hideShow;

    private void Awake()
    {
        Time.timeScale = 1f;
        Cursor.lockState = CursorLockMode.Locked;
        hideShow = transform.GetChild(0).gameObject;
        if (!input.GetComponent<Character.Controller>().IsDead)
        {
            input.actions["Pause"].performed += _ => TogglePause();
        }
    }

    bool paused = false;
    public bool Paused
    {
        get
        {
            return paused;
        }
        set
        {
            if(value)
            {
                StartPause();
            }
            else
            {
                EndPause();
            }
            paused = value;
        }
    }
    float oldTimeScale = 1f;

    public void TogglePause()
    {
        if (paused) EndPause();
        else StartPause();
    }


    public void StartPause()
    {
        if(oldTimeScale > 0)
            oldTimeScale = Time.timeScale;
        Time.timeScale = 0f;

        hideShow.SetActive(true);
        Cursor.lockState = CursorLockMode.None;
        OnStartPause.Invoke();
    }

    public void EndPause()
    {
        Time.timeScale = oldTimeScale;

        hideShow.SetActive(false);
        Cursor.lockState = CursorLockMode.Locked;
        OnEndPause.Invoke();
    }


    public UnityEvent OnStartPause;
    public UnityEvent OnEndPause;
}
