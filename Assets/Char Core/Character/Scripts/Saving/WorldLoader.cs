using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Character.Interactions;
using System.Runtime.Serialization.Formatters.Binary;
using System.IO;

namespace Character.Save
{
    public class WorldLoader : MonoBehaviour
    {
        public Transform pickupParent;
        public WorldSave save;
        public string path = "/world0.wld";
        public bool loadOnAwake = true;

        private void Awake()
        {
            Load();
        }
        //public List<PickupObject> pickupItems = new List<PickupObject>();
        //public List<PickupObject> pickupWeapons = new List<PickupObject>();

        //private void Awake()
        //{
        //    Load();
        //}
        //private void OnApplicationQuit()
        //{
        //    Save();
        //}

        [ContextMenu("SAVE")]
        public void Save()
        {
            BinaryFormatter bf = new BinaryFormatter();
            FileStream file = File.Create(Application.persistentDataPath + path);
            save = new WorldSave();

            PickupObject[] itemPickups = Object.FindObjectsOfType<PickupObject>();
            WeaponPickup[] weaponPickups = Object.FindObjectsOfType<WeaponPickup>();
            List<PickupSave> pickupSaves = new List<PickupSave>();

            for (int i = 0; i < itemPickups.Length; i++)
            {
                pickupSaves.Add(new PickupSave(itemPickups[i], Inventory.InventoryManager.Key));
            }
            for (int i = 0; i < weaponPickups.Length; i++)
            {
                pickupSaves.Add(new PickupSave(weaponPickups[i], weaponPickups[i].wType == WeaponPickup.WeaponType.Melee, Inventory.InventoryManager.Key));
            }
            save.pickups = pickupSaves;


            bf.Serialize(file, save);
            file.Close();
        }

        [ContextMenu("Load")]
        public void Load()
        {
            if (!File.Exists(Application.persistentDataPath + path))
            {
                Debug.LogError("There is no save data!");
                return;
            }

            BinaryFormatter bf = new BinaryFormatter();
            FileStream file = File.Open(Application.persistentDataPath + path, FileMode.Open);
            save = (WorldSave)bf.Deserialize(file);
            file.Close();

            PickupObject[] itemPickups = Object.FindObjectsOfType<PickupObject>();
            WeaponPickup[] weaponPickups = Object.FindObjectsOfType<WeaponPickup>();

            for (int i = 0; i < itemPickups.Length; i++)
            {
                Destroy(itemPickups[i].gameObject);
            }
            for (int i = 0; i < weaponPickups.Length; i++)
            {
                Destroy(weaponPickups[i].gameObject);
            }

            for (int i = 0; i < save.pickups.Count; i++)
            {
                Inventory.InventoryKey k = Inventory.InventoryManager.Key;
                if(save.pickups[i].itemType == 0)
                {
                    GameObject g = Instantiate(k.GetMeleePrefab(save.pickups[i].item).prefab, pickupParent);

                    g.transform.position = V3FromArr(save.pickups[i].pos);
                    g.transform.eulerAngles = V3FromArr(save.pickups[i].ea);
                }
                else if (save.pickups[i].itemType == 1)
                {
                    GameObject g = Instantiate(k.GetRangedPrefab(save.pickups[i].item).prefab, pickupParent);

                    g.transform.position = V3FromArr(save.pickups[i].pos);
                    g.transform.eulerAngles = V3FromArr(save.pickups[i].ea);
                }
                else if (save.pickups[i].itemType == 3)
                {
                    GameObject g = Instantiate(k.GetItemPrefab(save.pickups[i].item).prefab, pickupParent);

                    g.transform.position =  V3FromArr(save.pickups[i].pos);
                    g.transform.eulerAngles = V3FromArr(save.pickups[i].ea);
                }
            }
        }




        [ContextMenu("Reset")]
        void ResetData()
        {
            if (File.Exists(Application.persistentDataPath
                          + "/world0.wld"))
            {
                File.Delete(Application.persistentDataPath
                                  + "/world0.wld");
                save = new WorldSave();
                Debug.Log("Data reset complete!");
            }
            else
                Debug.LogError("No save data to delete.");
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