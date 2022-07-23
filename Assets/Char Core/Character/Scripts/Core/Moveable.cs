using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace Character
{
    //[AddComponentMenu("Character/Movables/BaseMovement")]
    /// <summary>
    /// The base class for a movable controller. 
    /// </summary>
    public class Moveable : ForceApplier
    {

        /// <summary> whether the criteria for this state is met. ex: has a horse or is underwater </summary>
        public virtual bool WantsActive
        {
            get { return false; }
        }

        /// <summary> whether it should have no motion while in this state ex: sitting or riding. </summary>
        //public bool kinematic = false;
        bool isActive;

        /// <summary> whether this component should be affecting movement. </summary>
        public virtual bool IsActive
        {
            get
            {
                return isActive;
            }
            set
            {
                if (value)
                {
                    GetComponent<Rigidbody>().isKinematic = false;
                    ColliderActive = true;
                }
                isActive = value;
            }
        }

        /// <summary> This is called by input. Use this for AI and use Input(Vector2 input, bool[] extra) for players in camera space. </summary>
        public virtual void Move(Vector3 move, bool[] extra)
        {

        }

        /// <summary> This passes the input WITHOUT the camera affecting anything. </summary>
        /// <param name="input"> both x & y should be separatly clamped between -1 & 1</param>
        /// <param name="extra"> specific to per class. </param>
        public virtual void Input(Vector2 input, bool[] extra)
        {
            Transform camTransform = Camera.main.transform;

            Vector3 camForward = new Vector3(camTransform.forward.x, 0, camTransform.forward.z).normalized;
            Vector3 move = input.y * camForward + input.x * camTransform.right;
            if (move.magnitude > 1)
                move.Normalize();
            Move(move, extra);
        }

        bool colliderActive = false;
        /// <summary> whether its collider is active. </summary>
        public virtual bool ColliderActive
        {
            get
            {
                return colliderActive;
            }
            set
            {
                if (colliderActive != value)
                {
                    GetComponent<CapsuleCollider>().enabled = value;
                }
                colliderActive = value;
            }
        }

        // you can do this or use the getter setter Is Active set {} to override.

        /// <summary>
        /// Called during FixedUpdate, after the previous state exits.
        /// </summary>
        public virtual void OnEnterState()
        {

        }
        /// <summary>
        /// Called during FixedUpdate, before the next state enters.
        /// </summary>
        public virtual void OnExitState()
        {

        }
    }
}
