using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Character;
namespace Character.Interactions
{
    [AddComponentMenu("Interaction/UpgradePickup")]
    public class UpgradePickup : Interactable
    {
        public int addedMaxHP = 4;
        public bool fullHeal = true;

        public override void Interact(Interactor interactor)
        {
            if (interactor.TryGetComponent(out Health health))
            {
                health.MaxHP += addedMaxHP;
                health.HP = health.MaxHP;
                Destroy(this.gameObject);
            }
        }
        private void OnTriggerEnter(Collider other)
        {
            if(other.TryGetComponent<UserCharacter1>(out UserCharacter1 u))
            {
                Interact(u.interactor);
            }
        }
    }
}