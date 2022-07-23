using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace Character.Inventory
{
    [CreateAssetMenu(fileName = "Weapon", menuName = "Inventory/Items/Weapon")]
    public class WeaponSO : ItemSO
    {
        public GameObject weaponPrefab;

        public override void Action(CharacterInventory character)
        {
            //Debug.Log(weaponPrefab.name);

            if (character.TryGetComponent(out Combat.Combatant combatant))
            {
                combatant.SetWeapon(weaponPrefab);
            }
        }
    }
}