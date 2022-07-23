using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Character;
using UnityEngine.UI;


public class HealthBar : MonoBehaviour
{
    private Health health;
    private Image bar;

    private void Awake()
    {
        transform.localPosition = Vector3.up * 2f;

        health = GetComponentInParent<Health>();
        bar = GetComponentInChildren<Image>();
        health.OnHPChange.AddListener(UpdateHealthBar);
    }

    public void UpdateHealthBar()
    {
        bar.fillAmount = ((float)health.HP / health.MaxHP);
    }

    private void FixedUpdate()
    {
        transform.rotation = Quaternion.LookRotation(-Camera.main.transform.forward);
    }
}
