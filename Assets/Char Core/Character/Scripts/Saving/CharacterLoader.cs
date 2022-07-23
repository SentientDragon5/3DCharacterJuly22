using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System.Runtime.Serialization.Formatters.Binary;
using System.IO;

namespace Character.Save
{
    public class CharacterLoader : MonoBehaviour
    {
        public CharacterSave save;
        public string path = "/character0.chr";
        public bool loadOnAwake = true;

        private void Awake()
        {
            Load();
        }
        //private void OnApplicationQuit()
        //{
        //    Save();
        //}

        [ContextMenu("SAVE")]
        public void Save()
        {
            BinaryFormatter bf = new BinaryFormatter();
            FileStream file = File.Create(Application.persistentDataPath + path);
            Inventory.InventorySO inventory = GetComponent<Inventory.CharacterInventory>().inventory;


            save = new CharacterSave(transform, inventory);

            //GetComponent<Health>().SetHpNoFX(save.hp);
            //save.inventory = GetComponent<Inventory.CharacterInventory>().inventory;
            //save.position = transform.position;
            //save.eulerAngles = transform.eulerAngles;

            
            bf.Serialize(file, save);
            file.Close();
        }

        [ContextMenu("Load")]
        public void Load()
        {
            if (!File.Exists(Application.persistentDataPath + path))
            {
                Debug.LogError("There is no save data!");
                Inventory.InventorySO inventory = new Inventory.InventorySO();
                if (save != null)
                {
                    inventory = save.inventory;
                }
                save = new CharacterSave(transform, inventory);
                return;
            }

            BinaryFormatter bf = new BinaryFormatter();
            FileStream file = File.Open(Application.persistentDataPath + path, FileMode.Open);
            save = (CharacterSave)bf.Deserialize(file);
            file.Close();

            GetComponent<Health>().HP = save.hp;
            GetComponent<Inventory.CharacterInventory>().inventory = save.inventory;
            transform.position = CharacterSave.V3FromArr(save.pos);
            transform.eulerAngles = CharacterSave.V3FromArr(save.ea);
        }
        [ContextMenu("Set")]
        public void Set()
        {
            BinaryFormatter bf = new BinaryFormatter();
            FileStream file = File.Create(Application.persistentDataPath + path);

            bf.Serialize(file, save);
            file.Close();
        }
    }
}