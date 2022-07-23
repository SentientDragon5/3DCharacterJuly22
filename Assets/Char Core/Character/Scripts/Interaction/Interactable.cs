using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Events;
using Character.Interactions.InteractableExtras;

namespace Character.Interactions
{
    public abstract class Interactable : MonoBehaviour
    {
        public bool lookAt = true;

        public abstract void Interact(Interactor interactor);

        public virtual bool IsActive
        {
            get
            {
                return true;
                if(TryGetComponent(out Interactor i))
                {
                    return false;
                }
                return true;
            }
        }
    }
}
namespace Character.Interactions.InteractableExtras
{
    [System.Serializable]
    public class TriggerZone
    {
        public float interactionRadius;
        public Vector3 interactionOffset;
        public UnityEvent OnInteraction;

        public TriggerZone(float radius, Vector3 offset)
        {
            interactionRadius = radius;
            interactionOffset = offset;
        }
    }
}