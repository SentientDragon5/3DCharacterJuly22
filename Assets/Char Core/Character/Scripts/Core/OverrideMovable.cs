using System.Collections;
using System.Collections.Generic;
using UnityEngine;


namespace Character
{
    public class OverrideMovable : MonoBehaviour
    {
        [SerializeField] private int[] overrideStates;
        /// <summary> The indices of the movetype in the controller that this can override in. </summary>
        public int[] Overrides { get => overrideStates; }

        /// <summary> whether the criteria for this state is met. ex: has a horse or is underwater </summary>
        public virtual bool WantsActive
        {
            get { return false; }
        }

        bool isActive;

        /// <summary> whether this component should be affecting movement. </summary>
        public virtual bool IsActive
        {
            get { return isActive; }
            set
            {
                isActive = value;
            }
        }

    }
}