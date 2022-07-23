using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Events;

namespace Character
{
    public class Health : MonoBehaviour
    {
        public int MaxHP = 12;
        int hp = 12;

        /// <summary>
        /// Regardless of whether a heal or a hurt, this will call.
        /// </summary>
        public UnityEvent OnHPChange;
        public UnityEvent OnDie;
        
        /// <summary>
        /// Modifiable HP. Will constrain HP to the maxHP and 0.
        /// </summary>
        public int HP
        {
            set
            {
                if(value < hp)
                {
                    if (TryGetComponent(out Combat.Combatant controller))
                    {
                        controller.Hit();
                    }
                }
                hp = Mathf.Clamp(value, 0, MaxHP);
                OnHPChange.Invoke();
                if (value <= 0) OnDie.Invoke();
            }
            get
            {
                return Mathf.Clamp(hp, 0, MaxHP);
            }
        }

        public void SetHpNoFX(int newHP)
        {

            hp = Mathf.Clamp(newHP, 0, MaxHP);
        }

        public bool IsDead
        {
            get
            {
                return HP <= 0;
            }
        }
    }
}