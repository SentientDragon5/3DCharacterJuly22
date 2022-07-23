using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace Character.Inventory
{
    [CreateAssetMenu(fileName = "Material", menuName = "Inventory/Items/Material")]
    public class MaterialSO : ItemSO
    {
        public bool edible = false;
        public int value = 10;
        public int hp = 4;

        public override void Action(CharacterInventory character)
        {
            if (!edible)
                return;

            InventoryKey key = InventoryManager.Key;
            character.GetComponent<Health>().HP += hp;
            character.inventory.RemoveItems(new Items(key.GetItemIndex(this), 1));
        }
    }
}