using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace Character.Inventory
{
    public class InventoryManager : MonoBehaviour
    {

        public static InventoryManager instance;

        private void Awake()
        {
            if (instance != null)
            {
                Destroy(this);
            }
            else
            {
                instance = this;
            }
        }


        public InventoryKey key;
        public static InventoryKey Key
        {
            get => instance.key;
        }
    }
}