using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System.Linq;
using Character.Interactions.InteractableExtras;

namespace Character.Interactions
{
    public class Interactor : MonoBehaviour
    {
        public Transform hand;

        private Animator animator;
        private RuntimeAnimatorController normalController;

        [Header("Settings")]
        public float interactionRadius = 1.5f;
        //public Vector3 offset = Vector3.zero;
        private Vector3 offset
        {
            get
            {
                if (TryGetComponent(out SphereCollider sc))
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

        public bool lookAtTarget = true;
        float lookWeight = 0;
        Vector3 target;
        public float lookSmoothRate = 5f;
        float maxDot = 0.2f;
        public AnimationCurve lookCurve = AnimationCurve.EaseInOut(0,0,1,1);

        [Header("Current Nearby Interactables")]
        public List<Interactable> interactionQueue = new List<Interactable>();

        //Set by the do animation interactable.
        [HideInInspector()] public List<IKTask> currentIKTasks = new List<IKTask>();

        private void FixedUpdate()
        {
            CheckForInteractables();
        }

        /// <summary>
        /// Call this to update the interaction Queue.
        /// </summary>
        public void CheckForInteractables()
        {
            Collider[] colliders = Physics.OverlapSphere(transform.position + offset, interactionRadius);
            interactionQueue.Clear();
            foreach (Collider collider in colliders)
            {
                if (collider.TryGetComponent(out Interactable interactable) && interactable.IsActive)
                {
                    if(interactable.transform != transform)
                    {
                        interactionQueue.Add(interactable);
                    }
                    //interactable.show = true;
                }
            }
            interactionQueue = interactionQueue.OrderBy(i => Vector3.Distance(this.transform.position, i.transform.position)).ToList();//using Linq
        }
        /// <summary>
        /// Call this to interact with the nearest object.
        /// </summary>
        public void Interact()
        {
            CheckForInteractables();

            if (interactionQueue.Count > 0)
            {
                AdjustThenInteract();
            }
        }

        void AdjustThenInteract()
        {
            //rotate the character to look at the interactable.
            //GetComponent<Character4>().Move(interactionQueue[0].transform.position - transform.position, false, false);
            Vector3 dir = (interactionQueue[0].transform.position - transform.position);
            Quaternion newRot = Quaternion.LookRotation(new Vector3(dir.x, 0, dir.z));//Or else the player will be laying down or something random.
            transform.rotation = newRot;
            interactionQueue[0].Interact(this);

        }

        private void OnDrawGizmosSelected()
        {
            Gizmos.color = Color.yellow;
            Gizmos.DrawWireSphere(offset + transform.position, interactionRadius);
            Gizmos.color = Color.Lerp(Color.yellow, Color.red, 0.3f);
            Gizmos.DrawWireSphere(offset + transform.position, 0.01f);
        }
        private void Awake()
        {
            animator = GetComponent<Animator>();
            normalController = animator.runtimeAnimatorController;
        }

        /// <summary>
        /// Switching back to normal animators
        /// </summary>
        public void SwitchToOriginal()
        {
            animator.runtimeAnimatorController = normalController;
        }

        private void OnValidate()
        {
            animator = GetComponent<Animator>();
            if (!animator.isHuman)
            {
                lookAtTarget = false;
            }
        }


        private void OnAnimatorIK(int layerIndex)
        {
            CheckForInteractables();
            bool anyToLookAt = false;
            for (int i = interactionQueue.Count -1; i >= 0; i--)
            {
                if(interactionQueue[i].lookAt)
                {
                    target = interactionQueue[i].transform.position;
                    if (interactionQueue[i].transform.TryGetComponent(out LookAtTarget look))
                    {
                        target = look.LookAtLocation;
                    }
                    anyToLookAt = true;
                }
            }
            //REMOVED LOOKING AT USERCHARACTER, REFER TO "Cine" project for that.

            if (lookAtTarget && (anyToLookAt))
            {
                Vector3 head = animator.GetBoneTransform(HumanBodyBones.Head).position;
                Vector3 directionOfInteractor = transform.forward;
                Vector3 directionFromTargetToInteractor = transform.position - target;
                bool facingTarget = Vector3.Dot(directionOfInteractor.normalized, directionFromTargetToInteractor.normalized) < maxDot;
                Debug.DrawRay(head, target - head, facingTarget ? Color.green : Color.magenta);
                if (facingTarget)
                {
                    animator.SetLookAtPosition(target);
                    if (lookWeight < 1)
                        lookWeight += lookSmoothRate * Time.deltaTime;

                }
                else
                {
                    if (lookWeight > 0)
                        lookWeight -= lookSmoothRate * Time.deltaTime;
                }
            }
            else
            {
                if (lookWeight > 0)
                    lookWeight -= lookSmoothRate * Time.deltaTime;
            }

            animator.SetLookAtWeight(lookCurve.Evaluate(lookWeight), lookCurve.Evaluate(lookWeight) * 0.1f, 1, 0, 0.8f);
            lookWeight = Mathf.Clamp01(lookWeight);


            foreach (IKTask task in currentIKTasks)
            {
                float t = animator.GetCurrentAnimatorStateInfo(0).normalizedTime / animator.GetCurrentAnimatorStateInfo(0).length;
                //Debug.Log(t);//IDK, the numbers didn't match up but the result looked good, Im not going to change it for now.
                animator.SetIKPosition(task.goal, task.parent.position + task.parent.rotation * task.offset);
                animator.SetIKPositionWeight(task.goal, task.weightCurve.Evaluate(t));
            }
        }
    }
}
