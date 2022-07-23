using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Character.Inventory;
namespace Character.Interactions
{

    [AddComponentMenu("Interaction/Pickup")]
    public class PickupObject : Pickup
    {
        public GameObject Prefab;
        public ItemSO item;
        public bool destroyOnPickup = true;

        public override void Interact(Interactor interactor)
        {
            //Drop old Gun
            //for(int i=0;i<interactor.hand.childCount; i++)
            //{
            //    Transform t = interactor.hand.GetChild(i);
            //    t.parent = null;
            //    //Destroy(interactor.hand.GetChild(i).gameObject);
            //}
            ////Add new
            //Instantiate(Prefab, Vector3.zero , Quaternion.identity, interactor.hand);
            if(interactor.TryGetComponent(out CharacterInventory inventory))
            {
                inventory.inventory.AddItems(new Items(InventoryManager.Key.GetItemIndex(item), 1));
            }
            //InventoryManager.instance.PickUp(Prefab);
            if (destroyOnPickup)
            {
                Destroy(this.gameObject);
            }
        }
        //private void FixedUpdate()
        //{
        //    Interactor[] interactors = GetComponentsInParent<Interactor>();
        //    if(interactors.Length > 0)
        //    {
        //        if(TryGetComponent(out Collider c))
        //        {
        //            c.enabled = false;
        //        }
        //    }
        //    else
        //    {
        //        if (TryGetComponent(out Collider c))
        //        {
        //            c.enabled = true;
        //        }
        //    }
        //}
    }

}