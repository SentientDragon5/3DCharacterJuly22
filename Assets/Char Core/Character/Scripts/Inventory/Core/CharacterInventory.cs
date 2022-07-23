using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.InputSystem;

namespace Character.Inventory
{
    [AddComponentMenu("Inventory")]
    public class CharacterInventory : MonoBehaviour
    {
        public InventorySO inventory;
        //{
        //    get
        //    {
        //        if(TryGetComponent(out Character.Save.CharacterLoader c))
        //        {
        //            return c.save.inventory;
        //        }
        //        return new InventorySO();
        //    }
        //}

        public GameObject[] GetEquipped(InventoryKey key)
        {
            return inventory.GetEquipped(key);
        }

        private void Start()
        {
            if(TryGetComponent(out Combat.Combatant combatant))
            {
                combatant.SetWeapon(GetEquipped(InventoryManager.Key)[currentIndex]);
            }
        }

        public PlayerInput Input;
        private InputAction swapMeleeRanged;
        public void OnEnable()
        {
            swapMeleeRanged = Input.actions["Swap"];
            swapMeleeRanged.performed += _ => Swap();
        }

        int currentIndex = 0;
        public void Swap()
        {
            currentIndex++;
            if(currentIndex >= 2)
            {
                currentIndex = 0;
            }
            SetCombatantWeapon();
        }

        public void SetCombatantWeapon()
        {
            if (TryGetComponent(out Combat.Combatant combatant))
            {
                combatant.SetWeapon(GetEquipped(InventoryManager.Key)[currentIndex]);
            }
        }

        public void RemoveWeaponFromInventory()
        {
            if (currentIndex == 0)
            {
                inventory.meleeWeapons.RemoveAt(inventory.meleeEquipped);
                inventory.meleeEquipped = -1;
            }
            else if (currentIndex == 1)
            {
                inventory.rangedWeapons.RemoveAt(inventory.rangedEquipped);
                inventory.rangedEquipped = -1;
            }
        }
    }
}