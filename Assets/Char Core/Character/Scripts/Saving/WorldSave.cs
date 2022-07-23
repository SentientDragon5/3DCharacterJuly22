using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Character.Inventory;
using Character.Interactions;

namespace Character.Save
{
    //[CreateAssetMenu(fileName = "World", menuName = "Saves/World")]
    [System.Serializable]
    public class WorldSave// : ScriptableObject
    {
        public List<PickupSave> pickups = new List<PickupSave>();

        public WorldSave()
        {
            pickups = new List<PickupSave>();
        }
    }

    [System.Serializable]
    public class PickupSave
    {
        //public Vector3 position;      
        //public Vector3 eulerAngles;
        public float[] pos;
        public float[] ea;

        //public GameObject prefab;

        public int item;
        /// <summary>
        /// 0 melee, 1 ranged, 3 item
        /// </summary>
        public int itemType;

        public PickupSave(WeaponPickup p, bool melee, InventoryKey key)
        {
            if (melee) item = key.GetMeleeIndex(p.weapon);
            else key.GetRangedIndex(p.weapon);

            pos = ArrFromV3(p.transform.position);
            ea = ArrFromV3(p.transform.eulerAngles);
            itemType = melee ? 0 : 1;

            //prefab = p.Prefab;
            //position = p.transform.position;
            //eulerAngles = p.transform.eulerAngles;
        }
        public PickupSave(PickupObject p, InventoryKey key)
        {
            item = key.GetItemIndex(p.item);
            pos = ArrFromV3(p.transform.position);
            ea = ArrFromV3(p.transform.eulerAngles);
            itemType = 3;

            //prefab = p.Prefab;
            //position = p.transform.position;
            //eulerAngles = p.transform.eulerAngles;
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
}