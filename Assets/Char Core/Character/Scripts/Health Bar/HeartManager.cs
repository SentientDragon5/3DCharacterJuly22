using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Character;
using UnityEngine.UI;

public class HeartManager : PlayerRef
{
    public Health health;

    public List<Image> maxHearts = new List<Image>();
    public List<Image> hearts = new List<Image>();

    public Transform maxHeartParent;
    public Transform heartParent;


    private void Awake()
    {
        if (health == null)
        {
            if (!TargetCharacter.TryGetComponent(out health))
            {
                Debug.Log("HeartManager autoreference character failed, please set manually in inspector.");
            }
        }
        if (health == null)
        {
            Debug.LogError("Warning: HeartManager inactive - no reference to player. Please fix this in the inspector.");
            return;
        }
        UpdateHearts();
        health.OnHPChange.AddListener(UpdateHearts);
    }

    /// <summary>
    /// Updated hearts list.
    /// </summary>
    [ContextMenu("Find Images")]
    public void FindImages()
    {
        maxHearts.Clear();
        for (int i = 0; i < maxHeartParent.childCount; i++)
        {
            maxHearts.Add(transform.GetChild(i).GetComponent<Image>());
        }
        hearts.Clear();
        for (int i = 0; i < heartParent.childCount; i++)
        {
            hearts.Add(transform.GetChild(i).GetComponent<Image>());
        }
    }

    /// <summary>
    /// Sets each heart's fill amount.
    /// </summary>
    /// <param name="HP"></param>
    public void UpdateHearts(int HP, int MaxHP)
    {
        if (hearts.Count == 0) FindImages();

        int HPPerHeart = 4;

        float numMaxHearts = (float)MaxHP / HPPerHeart;

        for (int i = 0; i < hearts.Count; i++)
        {
            float currentHeart = numMaxHearts - i;
            currentHeart = Mathf.Clamp01(currentHeart);
            maxHearts[i].fillAmount = currentHeart;
        }

        float numHearts = (float)HP / HPPerHeart;

        for (int i = 0; i < hearts.Count; i++)
        {
            float currentHeart = numHearts - i;
            currentHeart = Mathf.Clamp01(currentHeart);
            hearts[i].fillAmount = currentHeart;
        }

    }

    /// <summary>
    /// uses the health component to update hearts
    /// </summary>
    [ContextMenu("Update")]
    public void UpdateHearts()
    {
        if(health != null)
            UpdateHearts(health.HP, health.MaxHP);
    }

}
