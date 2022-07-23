using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Events;

namespace Character.Riding
{
    public class Rider : Moveable
    {
        public Horse ride;
        public Horse lastRide;
        public Animator animRider;

        public bool riding;
        public bool Riding
        {
            get
            {
                return riding;
            }
            set
            {
                if (value != riding)
                {
                    if (value)
                    {
                        //Start Riding
                        animRider.CrossFade("Riding", 0.1f, 0);

                    }
                    else
                    {
                        //Stop riding
                        animRider.CrossFade("Grounded", 0.1f, 0);
                    }
                }
                riding = value;
            }
        }

        public bool Active => Riding;

        public UnityEvent OnStartRide;
        public UnityEvent OnStopRide;


        public void StartRiding(Horse horse)
        {
            ride = horse;
            lastRide = horse;
        }
        public void StopRiding()
        {
            transform.parent = null;
            transform.position = ride.transform.position + ride.transform.right + ride.transform.up;
            ride = null;
            animRider.CrossFade("Grounded", 0.1f, 0);
            riding = false;
            OnStopRide.Invoke();
        }

        

        public override void Input(Vector2 move, bool[] extra)
        {
            if (ride != null)
            {
                //Reformated extra in controller.

                bool[] horseExtra = { extra[3], extra[4] };

                ride.Input(move, horseExtra);
            }
        }
        
        void Start()
        {
            animRider = GetComponent<Animator>();
        }

        bool isActivec;
        public override bool IsActive
        {
            get
            {
                return isActivec;
            }
            set
            {
                if (value)
                {
                    if(ride == null)
                    {
                        Debug.LogError("Cannot Ride without horse!");
                        return;
                    }

                    GetComponent<Rigidbody>().isKinematic = true;

                    transform.parent = ride.RiderParent;
                    transform.localPosition = Vector3.zero;
                    transform.localRotation = Quaternion.identity;
                    animRider.CrossFade("Riding", 0.1f, 0);
                    riding = true;
                }
                else
                {
                    if(lastRide != null)
                    {
                        transform.parent = null;
                        transform.position = lastRide.transform.position + lastRide.transform.right + lastRide.transform.up;
                        animRider.CrossFade("Grounded", 0.1f, 0);
                        riding = false;
                        OnStopRide.Invoke();
                        lastRide = null;
                    }
                    
                }
                isActivec = value;
            }
        }
        public override bool WantsActive
        {
            get
            {
                return ride != null;
            }
        }
        public override bool ColliderActive
        {
            get
            {
                return false;
            }
            set
            {
                //nada
                //A hitbox?
            }
        }
    }
}
