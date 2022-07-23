/*
 * Logan Shehane
 * 9/4/21
 * 
 * A script for the interactor to know which transform to look at.
 * 
 */
using UnityEngine;

public enum LookAtType { LookAtPosition, LookAtHead};
namespace Character.Interactions
{
    public class LookAtTarget : MonoBehaviour
    {
        /// <summary>
        /// which transform to look at.
        /// </summary>
        [SerializeField] private LookAtType type;
        private Vector3 offset
        {
            get
            {
                if(TryGetComponent(out SphereCollider sc))
                {
                    return sc.center;
                }
                if (TryGetComponent(out CapsuleCollider cc))
                {
                    return cc.center;
                }
                if (TryGetComponent(out BoxCollider bc))
                {
                    return bc.center;
                }
                return Vector3.zero;
            }
        }



        /// <summary>
        /// returns the position to look at
        /// </summary>
        public Vector3 LookAtLocation
        {
            get
            {
                if (type == LookAtType.LookAtHead)
                {
                    //find the transform of the head
                    if (TryGetComponent(out Animator anim))
                    {
                        //return the head transform if the thing has an animator that is humanoid
                        if (anim.isHuman)
                        {
                            return anim.GetBoneTransform(HumanBodyBones.Head).position;// + transform.rotation * offset;
                            //I choose to not use offset while targeting head.
                        }
                    }
                }

                //otherwise look at the transform position
                return transform.position + transform.rotation * offset;
            }
        }
    }
}