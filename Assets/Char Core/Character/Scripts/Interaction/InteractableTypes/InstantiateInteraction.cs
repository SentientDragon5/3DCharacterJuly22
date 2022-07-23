using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace Character.Interactions
{

    [AddComponentMenu("Interaction/Instantiation")]
    public class InstantiateInteraction : Interactable
    {
        public GameObject prefab;
        public override void Interact(Interactor interactor)
        {
            Instantiate(prefab);
        }
    }
}