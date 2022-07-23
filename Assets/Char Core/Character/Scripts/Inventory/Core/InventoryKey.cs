using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace Character.Inventory
{
    [CreateAssetMenu(fileName = "Key", menuName = "Inventory/Key")]
    public class InventoryKey : ScriptableObject
    {
        public WeaponSO missingWeapon;
        public ItemSO missingItem;
        public GameObject missingObject;
        
        public List<WeaponSO> meleeWeapons = new List<WeaponSO>();
        public List<WeaponSO> rangedWeapons = new List<WeaponSO>();
        public List<ItemSO> items = new List<ItemSO>();






        public WeaponSO GetMeleePrefab(int index)
        {
            if (index < meleeWeapons.Count && index >= 0)
            {
                return meleeWeapons[index];
            }
            Debug.LogWarning("Inventory Err: no prefab found at index of " + index + ".");
            return missingWeapon;
        }

        public WeaponSO GetRangedPrefab(int index)
        {
            if (index < rangedWeapons.Count && index >= 0)
            {
                return rangedWeapons[index];
            }
            Debug.LogWarning("Inventory Err: no prefab found at index of " + index + ".");
            return missingWeapon;
        }

        public ItemSO GetItemPrefab(int index)
        {
            if (index < items.Count && index >= 0)
            {
                return items[index];
            }
            Debug.LogWarning("Inventory Err: no prefab found at index of " + index + ".");
            return missingItem;
        }

        ///============

        public int GetMeleeIndex(WeaponSO prefab)
        {
            if (meleeWeapons.Contains(prefab))
            {
                return meleeWeapons.IndexOf(prefab);
            }
            Debug.LogWarning("Inventory Err: " + prefab.name + " could not be found.");
            return -1;
        }

        public int GetRangedIndex(WeaponSO prefab)
        {
            if (rangedWeapons.Contains(prefab))
            {
                return rangedWeapons.IndexOf(prefab);
            }
            Debug.LogWarning("Inventory Err: " + prefab.name + " could not be found.");
            return -1;
        }

        public int GetItemIndex(ItemSO prefab)
        {
            if (items.Contains(prefab))
            {
                return items.IndexOf(prefab);
            }
            Debug.LogWarning("Inventory Err: " + prefab.name + " could not be found.");
            return -1;
        }

        //==============

        public static WeaponSO GetMeleePrefab(InventoryKey key, int index)
        {
            if (index < key.meleeWeapons.Count && index >= 0)
            {
                return key.meleeWeapons[index];
            }
            Debug.LogWarning("Inventory Err: no prefab found at index of " + index + ".");
            return key.missingWeapon;
        }

        public static WeaponSO GetRangedPrefab(InventoryKey key, int index)
        {
            if (index < key.rangedWeapons.Count && index >= 0)
            {
                return key.rangedWeapons[index];
            }
            Debug.LogWarning("Inventory Err: no prefab found at index of " + index + ".");
            return key.missingWeapon;
        }

        public static ItemSO GetItemPrefab(InventoryKey key, int index)
        {
            if (index < key.items.Count && index >= 0)
            {
                return key.items[index];
            }
            Debug.LogWarning("Inventory Err: no prefab found at index of "+ index + ".");
            return key.missingItem;
        }

        ///============

        public static int GetMeleeIndex(InventoryKey key, WeaponSO prefab)
        {
            if(key.meleeWeapons.Contains(prefab))
            {
                return key.meleeWeapons.IndexOf(prefab);
            }
            Debug.LogWarning("Inventory Err: " + prefab.name + " could not be found.");
            return -1;
        }

        public static int GetRangedIndex(InventoryKey key, WeaponSO prefab)
        {
            if (key.rangedWeapons.Contains(prefab))
            {
                return key.rangedWeapons.IndexOf(prefab);
            }
            Debug.LogWarning("Inventory Err: " + prefab.name + " could not be found.");
            return -1;
        }

        public static int GetItemIndex(InventoryKey key, ItemSO prefab)
        {
            if (key.items.Contains(prefab))
            {
                return key.items.IndexOf(prefab);
            }
            Debug.LogWarning("Inventory Err: " + prefab.name + " could not be found.");
            return -1;
        }
    }
}