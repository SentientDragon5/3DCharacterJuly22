using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.InputSystem;
using Character.Combat;
using Character.Interactions;
using Character.Riding;

namespace Character
{

    /*
    [RequireComponent(typeof(PlayerInput))]

    [RequireComponent(typeof(Character6))]
    [RequireComponent(typeof(Health))]
    [RequireComponent(typeof(Actor))]
    [RequireComponent(typeof(Combatant))]
    [RequireComponent(typeof(Interactor))]
    [RequireComponent(typeof(Rider))]
    */
    public class UserCharacterOld : Controller
    {
        public float aiming
        {
            get
            {
                return Input.GetKey(KeyCode.Mouse1) ? 0 : 1;
            }
        }
        bool jumpPressed;


        void Awake()
        {
            //controller = GetComponent<ICharacter>();
            animator = GetComponent<Animator>();

            if (TryGetComponent(out Combatant combatant))
            {
                this.combatant = combatant;
            }
            if (TryGetComponent(out Health health))
            {
                this.health = health;
            }
            if(TryGetComponent(out Interactor interactor))
            {
                this.interactor = interactor;
            }



            Cursor.lockState = CursorLockMode.Locked;

            DisableColliders();
            for (int j = moveTypes.Count-1; j >= 0; j--)
            {
                moveTypes[j].IsActive = j == moveType;
            }
        }


        public override bool Aiming
        {
            get
            {
                return Input.GetKey(KeyCode.Mouse1);
            }
        }

        void Update()
        {
            if (!jumpPressed)
                jumpPressed = Input.GetKeyDown(KeyCode.Space);
            if (Input.GetKeyDown(KeyCode.Mouse0))
                Shoot();
            if (Input.GetKeyDown(KeyCode.E))
                Interact();


            if (Aiming)
            {
                Vector3 CamDir = Camera.main.transform.forward;
                transform.forward = Quaternion.Euler(0, 0, 0) * new Vector3(CamDir.x, 0, CamDir.z).normalized;
            }
            ///*
        }

        private void FixedUpdate()
        {
            //*/
            if(health != null && health.IsDead)
            {
                if(TryGetComponent(out Ragdoll ragdoll) && !ragdoll.IsRagdolled)
                {
                    ragdoll.EnterRagdoll();
                }
                return;
            }

            float h = Input.GetAxis("Horizontal");
            float v = Input.GetAxis("Vertical");
            h = Mathf.Clamp(h, -1, 1);
            v = Mathf.Clamp(v, -1, 1);

            //jump, crouch, running, add, subtract, swim dash
            bool[] extraMove = { jumpPressed, false, false, Input.GetKeyDown(KeyCode.W), Input.GetKeyDown(KeyCode.S), Input.GetKeyDown(KeyCode.Space) };


            int newMoveType = 0;//Set it to default so if no other wants to be active then normal.
            for (int i = moveTypes.Count-1; i >= 0; i--)
            {
                if(moveTypes[i].WantsActive)
                {
                    newMoveType = i;
                    break;
                }
            }

            if(newMoveType != moveType)
            {
                DisableColliders();
                for (int i = moveTypes.Count-1; i >= 0; i--)
                {
                    moveTypes[i].IsActive = i == newMoveType;
                }
                moveType = newMoveType;
            }
            moveTypes[moveType].Input(new Vector2(h, v), extraMove);

            jumpPressed = false;
        }


        public override Vector3 target
        {
            get
            {
                Transform cam = Camera.main.transform;
                Vector3 t = cam.position + cam.forward * 25f;
                RaycastHit hit;
                if (Physics.Raycast(cam.position, cam.forward, out hit, 200f))
                {
                    t = hit.point;
                }
                RaycastHit[] hits = Physics.RaycastAll(cam.position, cam.forward, 200f);
                for(int i = 0; i < hits.Length; i++)
                {
                    if(hits[i].transform.TryGetComponent(out Combatant c) && c == GetComponent<Combatant>())
                    {
                        //Do nada if it is this
                    }
                    else
                    {
                        return hits[i].point;
                    }
                }
                return t;
            }
        }

    }
}