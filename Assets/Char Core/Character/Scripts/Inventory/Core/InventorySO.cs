using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System.Linq;
using UnityEngine.Events;

namespace Character.Inventory
{
    //[CreateAssetMenu(fileName = "Inventory", menuName = "Inventory/Character")]
    [System.Serializable]
    public class InventorySO// : ScriptableObject
    {
        public int maxMelee = 5;
        public int maxRanged = 5;

        public List<int> meleeWeapons = new List<int>();
        public List<int> rangedWeapons = new List<int>();

        public List<Items> items = new List<Items>();

        public int meleeEquipped = 0;
        public int rangedEquipped = 0;

        /// <summary>
        /// index 0 is melee, Ranged is 1
        /// </summary>
        public GameObject[] GetEquipped(InventoryKey key)
        {
            GameObject[] weapons = new GameObject[2];
            weapons[0] = null;
            weapons[1] = null;

            if(meleeEquipped > -1)
            {
                weapons[0] = key.GetMeleePrefab(meleeWeapons[meleeEquipped]).weaponPrefab;
            }
            if(rangedEquipped > -1)
            {
                weapons[1] = key.GetRangedPrefab(rangedWeapons[rangedEquipped]).weaponPrefab;
            }

            return weapons;
        }

        public void PickUpMelee(out bool can, int index)
        {
            if(meleeWeapons.Count >= maxMelee)
            {
                can = false;
                return;
            }
            can = true;
            meleeWeapons.Add(index);
            needsUpdate = true;
            refresh.Invoke();
        }
        public void PickUpRanged(out bool can, int index)
        {
            if (rangedWeapons.Count >= maxMelee)
            {
                can = false;
                return;
            }
            can = true;
            rangedWeapons.Add(index);
            needsUpdate = true;
            refresh.Invoke();
        }

        public void AddItems(Items add)
        {
            bool added = false;
            foreach(Items i in items)
            {
                if(i.SameItem(add))
                {
                    i.count += add.count;
                    added = true;
                    break;
                }
            }
            if(!added)
            {
                items.Add(add);
            }
            ClearZeros();
            needsUpdate = true;
            refresh.Invoke();
        }
        public void RemoveItems(Items remove)
        {
            bool removed = false;
            foreach (Items i in items)
            {
                if (i.SameItem(remove))
                {
                    i.count -= remove.count;
                    if(i.count < 1)
                    {
                        items.Remove(i);
                    }
                    removed = true;
                    break;
                }
            }
            ClearZeros();
            needsUpdate = true;
            refresh.Invoke();
        }

        [ContextMenu("Clear Zeros")]
        public void ClearZeros()
        {
            for (int i = 0; i < items.Count; i++)
            {
                if (items[i].count < 1)
                {
                    items.RemoveAt(i);
                    ClearZeros();
                }
            }
            needsUpdate = true;
        }

        public bool needsUpdate;
        public UnityEvent refresh = new UnityEvent();
    }

    [System.Serializable]
    public class Items
    {
        public int index;
        public int count;

        public Items(int index, int count)
        {
            this.index = index;
            this.count = count;
        }


        public bool SameItem(Items other)
        {
            return this.index == other.index;
        }
    }
}