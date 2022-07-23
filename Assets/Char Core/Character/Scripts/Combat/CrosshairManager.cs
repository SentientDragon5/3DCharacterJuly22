using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using TMPro;
using Character;
using Character.Combat;

namespace Shooter.UI
{
    public class CrosshairManager : PlayerRef
    {
        [Header("Recticles")]
        public GameObject Normal;
        public GameObject Aim;
        public Material Mat;

        [Header("Colors")]
        public Color ally = Color.green;
        public Color enemy = Color.red;
        public Color neutral = Color.white;

        public Color reloading = Color.yellow;
        [Range(0,1)]public float reload = 1;


        public Actor actor;
        Combatant combatant;

        

        private void Awake()
        {
            if (actor == null)
            {
                if (!TargetCharacter.TryGetComponent(out actor))
                {
                    Debug.Log("CrosshairManager autoreference character failed, please set manually in inspector.");
                }
            }
            if (combatant == null)
                combatant = actor.GetComponent<Combatant>();
            else
                Debug.LogError("Warning: CrosshairManager inactive - no reference to player. Please fix this in the inspector.");
            UpdateCorosshair();
        }

        public void UpdateCorosshair()
        {
            if (combatant == null)
                return;
            Normal.SetActive(!combatant.Aiming);
            Aim.SetActive(combatant.Aiming);

            Color recticleColor = neutral;
            Ray ray = Camera.main.ViewportPointToRay(new Vector3(0.5F, 0.5F, 0));
            RaycastHit hit;
            if (Physics.Raycast(ray, out hit))
            {
                if(hit.transform.TryGetComponent(out Actor other))
                {
                    if (actor.IsAlly(other))
                    {
                        recticleColor = ally;
                        Debug.DrawRay(actor.transform.position, actor.transform.forward * 100f, Color.green);
                    }
                    else if(actor.IsEnemy(other))
                    {
                        recticleColor = enemy;
                        Debug.DrawRay(actor.transform.position, actor.transform.forward * 100f, Color.red);
                    }
                    else
                    {
                        Debug.DrawRay(actor.transform.position, actor.transform.forward * 100f, Color.black);
                    }
                }
                else
                {
                    Debug.DrawRay(actor.transform.position, actor.transform.forward * 100f, Color.white);
                }
            }
            else
            {
                Debug.DrawRay(actor.transform.position, actor.transform.forward * 100f, Color.grey);
            }


            if (reload < 1f)
            {
                recticleColor = reloading;
                Normal.GetComponent<Image>().fillAmount = reload;
                Aim.GetComponent<Image>().fillAmount = reload;
            }
            else
            {
                Normal.GetComponent<Image>().fillAmount = 1f;
                Aim.GetComponent<Image>().fillAmount = 1f;
            }

            Normal.GetComponent<Image>().color = recticleColor;
            Aim.GetComponent<Image>().color = recticleColor;

            Mat.SetColor("_BaseColor", recticleColor);
        }

        private void FixedUpdate()
        {
            UpdateCorosshair();
        }
    }
}
