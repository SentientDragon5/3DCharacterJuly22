using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Character.Inventory;
using UnityEngine.UI;
using UnityEngine.Events;
using TMPro;
namespace UI
{
    [AddComponentMenu("UI/InventoryDrawer")]
    public class InventoryDrawer : PlayerRef
    {
        public CharacterInventory character;
        private InventorySO target
        {
            get
            {
                return character.inventory;
            }
        }
        public InventoryKey key;
        public GameObject panePrefab;
        public int meleeSlots = 5;
        public int rangedSlots = 5;
        public int itemSlots = 30;

        public Transform meleePanel;
        public Transform rangedPanel;
        public Transform itemPanel;

        public List<GameObject> meleePanes = new List<GameObject>();
        public List<GameObject> rangedPanes = new List<GameObject>();
        public List<GameObject> itemPanes = new List<GameObject>();

        private void Awake()
        {
            if(character != null)
            {
                if(TargetCharacter.TryGetComponent(out CharacterInventory inv))
                {
                    character = inv;
                }
                else
                {
                    Debug.LogError("InventoryDrawer autoreference character failed, please set manually in inspector.");
                }
            }
            //target = character.inventory;
            GetComponentInParent<PauseGame>().OnStartPause.AddListener(UpdateDraw);
            target.refresh.AddListener(UpdateDraw);
            UpdateDraw();
        }

        [ContextMenu("SET")]
        public void UpdateDraw()
        {
            //Debug.Log("UPDATIN");
            if (meleeSlots != meleePanes.Count || rangedSlots != rangedPanes.Count || itemSlots != itemPanes.Count)
            {
                DestroyAllChildren(meleePanel);
                DestroyAllChildren(rangedPanel);
                DestroyAllChildren(itemPanel);

                MakeEmptyTiles(meleeSlots, meleePanel, out meleePanes);
                MakeEmptyTiles(rangedSlots, rangedPanel, out rangedPanes);
                MakeEmptyTiles(itemSlots, itemPanel, out itemPanes);

                SetPanes();
                target.needsUpdate = false;
            }
            if(target.needsUpdate)
            {
                SetPanes();
                target.needsUpdate = false;
            }

        }

        void SetPanes()
        {
            for (int i = 0; i < target.meleeWeapons.Count; i++)
            {
                Image icon = meleePanes[i].transform.GetChild(0).GetComponent<Image>();
                icon.sprite = SpriteFromTex(key.GetMeleePrefab(target.meleeWeapons[i]).icon);
                InventoryitemActor inventoryitemActor = meleePanes[i].GetComponent<InventoryitemActor>();
                inventoryitemActor.item = key.GetMeleePrefab(target.meleeWeapons[i]);
                inventoryitemActor.type = 0;
                inventoryitemActor.index = i;
                inventoryitemActor.keyIndex = target.meleeWeapons[i];
                WeaponSO weapon = key.GetMeleePrefab(target.meleeWeapons[i]);
                meleePanes[i].GetComponent<Button>().onClick.AddListener(inventoryitemActor.Action);
                meleePanes[i].GetComponent<Button>().onClick.AddListener(UpdateDraw);
                //itemPanes[i].GetComponentInChildren<TextMeshProUGUI>().text = "" + weapon.power;
            }
            for (int i = 0; i < target.rangedWeapons.Count; i++)
            {
                Image icon = rangedPanes[i].transform.GetChild(0).GetComponent<Image>();

                icon.sprite = SpriteFromTex(key.GetRangedPrefab(target.rangedWeapons[i]).icon);
                InventoryitemActor inventoryitemActor = rangedPanes[i].GetComponent<InventoryitemActor>();
                inventoryitemActor.item = key.GetRangedPrefab(target.rangedWeapons[i]);
                inventoryitemActor.type = 1;
                inventoryitemActor.index = i;
                inventoryitemActor.keyIndex = target.rangedWeapons[i];
                WeaponSO weapon = key.GetRangedPrefab(target.rangedWeapons[i]);
                rangedPanes[i].GetComponent<Button>().onClick.AddListener(inventoryitemActor.Action);
                rangedPanes[i].GetComponent<Button>().onClick.AddListener(UpdateDraw);
                //itemPanes[i].GetComponentInChildren<TextMeshProUGUI>().text = "" + weapon.power;
            }
            for (int i=0;i<target.items.Count;i++)
            {
                Image icon = itemPanes[i].transform.GetChild(0).GetComponent<Image>();
                icon.sprite = SpriteFromTex(key.GetItemPrefab(target.items[i].index).icon);
                InventoryitemActor inventoryitemActor = itemPanes[i].GetComponent<InventoryitemActor>();
                inventoryitemActor.item = key.GetItemPrefab(target.items[i].index);
                inventoryitemActor.type = 2;
                inventoryitemActor.index = i;
                inventoryitemActor.keyIndex = target.items[i].index;
                itemPanes[i].GetComponent<Button>().onClick.AddListener(inventoryitemActor.Action);
                itemPanes[i].GetComponent<Button>().onClick.AddListener(UpdateDraw);
                itemPanes[i].GetComponentInChildren<TextMeshProUGUI>().text = "" + target.items[i].count;
            }
        }

        void DestroyAllChildren(Transform t)
        {
            for(int i=0; i<t.childCount; i++)
            {
                Destroy(t.GetChild(i).gameObject);
            }
        }
        void MakeEmptyTiles(int n, Transform parent, out List<GameObject> panes)
        {
            panes = new List<GameObject>();
            for(int i=0; i<n;i++)
            {
                GameObject pane = Instantiate(panePrefab, parent);
                panes.Add(pane);
            }
        }

        public void CarryItemOutAction(ItemSO item)
        {
            Debug.Log(item.name);
            item.Action(character);
            UpdateDraw();
        }
        public void Drop(ItemSO item, int type, int index, int keyIndex)
        {
            //Debug.Log("Dropping " + item.name + "tik: " + type + index + keyIndex);
            bool sucess = false;
            if(type == 0)
            {
                //Remove Melee
                target.meleeWeapons.RemoveAt(index);
                sucess = true;
            }
            else if (type == 1)
            {
                //Remove Ranged
                target.rangedWeapons.RemoveAt(index);
                sucess = true;
            }
            else if (type == 2)
            {
                //Remove Item
                target.RemoveItems(new Items(keyIndex, 1));
                sucess = true;
            }
            if(sucess)
            {
                if (item.prefab != null)
                {

                    Instantiate(item.prefab, character.transform.position + (character.transform.forward * 2f) + character.transform.up, Quaternion.identity);
                }
            }
            UpdateDraw();
        }

        public static Sprite SpriteFromTex(Texture2D tex)
        {
            return Sprite.Create(tex, new Rect(0, 0, tex.width, tex.height), Vector2.one / 2f);
        }
    }
}