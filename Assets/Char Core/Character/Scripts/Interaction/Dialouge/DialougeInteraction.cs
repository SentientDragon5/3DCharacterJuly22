using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace Character.Interactions.Dialouge
{
    [AddComponentMenu("Interaction/Dialouge")]
    public class DialougeInteraction : Interactable
    {
        public DialougeSO dialougeObject;

        public override void Interact(Interactor interactor)
        {
            DialougeReader.instance.dialougeObject = dialougeObject;
            DialougeReader.instance.Begin();
        }
    }
}
