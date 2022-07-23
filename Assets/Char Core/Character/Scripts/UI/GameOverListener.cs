using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Character;
using UnityEngine.InputSystem;
using UnityEngine.SceneManagement;


public class GameOverListener : PlayerRef
{
    public Character.Health userHealth;

    private void Awake()
    {
        if (userHealth == null)
        {
            if (!TargetCharacter.TryGetComponent(out userHealth))
            {
                Debug.Log("GameOverListener autoreference character failed, please set manually in inspector.");
            }
        }
        transform.GetChild(0).gameObject.SetActive(false);
        if (userHealth != null)
            userHealth.OnDie.AddListener(OnDie);
        else
            Debug.LogError("Warning: GameOverListener inactive - no reference to player. Please fix this in the inspector.");
    }

    void OnDie()
    {
        transform.GetChild(0).gameObject.SetActive(true);
        died = true;
    }

    bool died = false;
    private void Update()
    {
        if(died)
        {
            Cursor.lockState = CursorLockMode.None;
            if (userHealth.GetComponent<PlayerInput>().actions["1"].triggered)
            {
                SceneManager.LoadScene(1, LoadSceneMode.Single);
            }

            if (userHealth.GetComponent<PlayerInput>().actions["2"].triggered)
            {
                SceneManager.LoadScene(0, LoadSceneMode.Single);
            }
        }
    }
}
