using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

namespace Character.Inventory
{
    [CreateAssetMenu(fileName = "Item", menuName = "Inventory/Items/Item")]
    public class ItemSO : ScriptableObject
    {
        public Texture2D icon;
        [Tooltip("The prefab with Pickup on it.")]
        public GameObject prefab;
        public bool dropable = true;

        public virtual void Action(CharacterInventory character)
        {

        }
    }
}