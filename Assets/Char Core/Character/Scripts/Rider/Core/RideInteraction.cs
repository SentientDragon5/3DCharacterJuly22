using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Events;
using Character.Riding;
namespace Character.Interactions
{
    [AddComponentMenu("Interaction/Ride")]
    public class RideInteraction : Interactable
    {

        public override void Interact(Interactor interactor)
        {
            if(interactor.TryGetComponent<Rider>(out Rider rider))
            {
                if(rider.riding)
                {
                    rider.StopRiding();
                }
                else
                {
                    if(TryGetComponent(out Horse horse))
                    {
                        rider.StartRiding(horse);
                    }
                }
            }
        }
    }
}