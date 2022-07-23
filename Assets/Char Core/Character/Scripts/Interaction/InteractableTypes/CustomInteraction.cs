using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Events;

namespace Character.Interactions
{
    [AddComponentMenu("Interaction/Custom")]
    public class CustomInteraction : Interactable
    {
        public UnityEvent OnInteraction;
        public override void Interact(Interactor interactor)
        {
            OnInteraction.Invoke();
        }
    }
}