using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Character.Combat;

namespace Character.Combat
{
    public abstract class Weapon : MonoBehaviour
    {
        public static Transform bulletParent;

        public float damage = 2f;
        public bool aimed = true;
        public string parameterAim = "Aim";


        [SerializeField] private GameObject pickup;
        public GameObject Pickup { get => pickup; }


        public virtual void MeleeAttack(out string animation, out int layer)
        {
            //Nada
            animation = "none";
            layer = 3;
        }
        public virtual void AirMeleeAttack(out string animation, out int layer)
        {
            //Nada
            animation = "none";
            layer = 3;
        }
        public virtual void RangedAttack(out string animation, out int layer)
        {
            //Nada
            animation = "none";
            layer = 2;
        }

    }
}