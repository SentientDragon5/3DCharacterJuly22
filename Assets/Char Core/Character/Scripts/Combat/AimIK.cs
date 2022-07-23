using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace Character.Combat
{
    public class AimIK : MonoBehaviour
    {
        float dir;

        Controller controller;
        Combatant combatant;
        Animator anim;

        Transform handPosition;
        /// <summary>
        /// Set this var
        /// </summary>
        public Vector3 targetPos;
        public Transform bone;


        [Tooltip("If AI then this should be true")] bool useTransformBasedTargeting = true;
        [Tooltip("If VRoid then this should be true")]
        public bool flipForward = true;

        private void Awake()
        {
            anim = GetComponent<Animator>();
            controller = GetComponent<Controller>();
            combatant = GetComponent<Combatant>();
            handPosition = combatant.hand;

            if(TryGetComponent(out AICharacter character))
            {
                useTransformBasedTargeting = true;
            }
            else
            {
                useTransformBasedTargeting = false;
            }
            if(bone == null)
            {
                bone = anim.GetBoneTransform(HumanBodyBones.Spine);
            }
        }


        private void OnAnimatorIK(int layerIndex)
        {
            if (handPosition == null) return;

            anim.SetIKPosition(AvatarIKGoal.LeftHand, handPosition.position);
            anim.SetIKRotation(AvatarIKGoal.LeftHand, handPosition.rotation);
            anim.SetIKPositionWeight(AvatarIKGoal.LeftHand, combatant.Aiming ? 1 : 0);
            anim.SetIKRotationWeight(AvatarIKGoal.LeftHand, combatant.Aiming ? 1 : 0);

            //anim.SetIKPosition(AvatarIKGoal.LeftHand, )
            //anim.SetIKHintPosition()
        }

        void Start()
        {

        }

        void LateUpdate()
        {
            //bone.rotation = Quaternion.LookRotation((new Vector3(0,dir,0) + transform.forward).normalized);
            Vector3 targetPosition = Camera.main.transform.position + Camera.main.transform.forward * 25f;//targetTransform.position;
            if(useTransformBasedTargeting)
            {
                targetPosition = targetPos;
            }

            Quaternion rot = Quaternion.LookRotation(targetPosition - transform.position, Vector3.up);
            if (flipForward)
                rot *= Quaternion.Euler(Vector3.up * 180);
            if (controller.Aiming)
            {
                bone.rotation = rot * Quaternion.AngleAxis(30, Vector3.up);
                //bone.rotation = Camera.main.transform.rotation * Quaternion.AngleAxis(30, Vector3.up);//Quaternion.FromToRotation(transform.forward, Camera.main.transform.forward);
            }
            dir = Vector3.Angle(flipForward ? -bone.forward : bone.forward, Camera.main.transform.forward);

            //Quaternion.Euler(bone.rotation.eulerAngles + Vector3.up * dir);//Quaternion.LookRotation(targetPosition);


            for (int i = 0; i < 10; i++)
            {
                //AimAtTarget(bone, targetPosition);
            }
        }
    }
}