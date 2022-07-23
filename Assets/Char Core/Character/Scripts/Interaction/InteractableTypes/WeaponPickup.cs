using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Character.Inventory;

namespace Character.Interactions
{

    [AddComponentMenu("Interaction/Weapon Pickup")]
    public class WeaponPickup : Pickup
    {
        public GameObject Prefab;
        public WeaponSO weapon;
        public enum WeaponType { Melee, Ranged };
        public WeaponType wType = WeaponType.Melee;

        public override void Interact(Interactor interactor)
        {
            Combat.Combatant combatant = interactor.GetComponent<Combat.Combatant>();

            if (interactor.TryGetComponent(out CharacterInventory inventory))
            {
                bool can;
                if (wType == WeaponType.Melee)
                    inventory.inventory.PickUpMelee(out can, InventoryManager.Key.GetMeleeIndex(weapon));
                else if(wType == WeaponType.Ranged)
                    inventory.inventory.PickUpRanged(out can, InventoryManager.Key.GetRangedIndex(weapon));
            }

            //Drop old Gun
            //combatant.SwapWeapons(Prefab);
            //Add new

            Destroy(this.gameObject);
        }

        
    }
}