using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Character.Inventory;

namespace UI {
    public class InventoryitemActor : MonoBehaviour
    {
        public ItemSO item;
        public int type;
        public int index;
        public int keyIndex;

        public GameObject deleteButton;
        private void Start()
        {
            deleteButton.SetActive(item != null);
        }

        public void Action()
        {
            GetComponentInParent<InventoryDrawer>().CarryItemOutAction(item);
        }
        public void Drop()
        {
            GetComponentInParent<InventoryDrawer>().Drop(item,type, index, keyIndex);
        }
    }
}