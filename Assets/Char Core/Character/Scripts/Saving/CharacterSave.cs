using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Character.Inventory;
namespace Character.Save
{
    //[CreateAssetMenu(fileName = "Save", menuName = "Saves/Character")]
    [System.Serializable]
    public class CharacterSave //: ScriptableObject
    {
        //public Vector3 position;
        //public Vector3 eulerAngles;
        //public Inventory.InventorySO inventory;
        public int hp;

        public float[] pos;
        public float[] ea;
        public InventorySO inventory;

        public CharacterSave(Transform t, InventorySO inventory)
        {
            pos = ArrFromV3(t.position);
            ea = ArrFromV3(t.eulerAngles);
            hp = t.GetComponent<Health>().HP;
            this.inventory = inventory;
            //inventory = t.GetComponent<Character.Inventory.CharacterInventory>().
        }

        public static float[] ArrFromV3(Vector3 vector3)
        {
            float[] arr = { vector3.x, vector3.y, vector3.z };
            return arr;
        }
        public static Vector3 V3FromArr(float[] arr)
        {
            if (arr.Length < 3) return Vector3.zero;
            return new Vector3(arr[0], arr[1], arr[2]);
        }
    }

    //[System.Serializable]
    //public class Inventory
    //{
    //    public List<int> melee;
    //    public List<int> ranged;
    //    public List<Item> items;

    //    public int mEquipped = 0;
    //    public int rEquipped = 1;
    //}
    [System.Serializable]
    public class Item
    {
        public int index;
        public int count;
        public Item(int i, int c)
        {
            index = i;
            count = c;
        }
    }
}