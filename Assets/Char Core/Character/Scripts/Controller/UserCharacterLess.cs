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
    public class UserCharacterLess : Controller
    {
        public PlayerInput playerInput;
       

        public float aiming
        {
            get
            {
                if (aimAction == null) return 0;
                return aimAction.ReadValue<float>();
            }
        }
        bool jumpPressed;

        public InputAction moveAction;
        public InputAction jumpAction;
        public InputAction shootAction;
        public InputAction aimAction;
        public InputAction interactAction;

        public InputAction add;
        public InputAction subtract;


        void Awake()
        {
            //controller = GetComponent<ICharacter>();
            playerInput = GetComponent<PlayerInput>();
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

            moveAction = playerInput.actions["Move"];
            //aimAction = playerInput.actions["Aim"];
            //shootAction = playerInput.actions["Shoot"];
            jumpAction = playerInput.actions["Jump"];
            //interactAction = playerInput.actions["Interact"];

            //add = playerInput.actions["Add"];
            //subtract = playerInput.actions["Subtract"];


            Cursor.lockState = CursorLockMode.Locked;

            DisableColliders();
            for (int j = moveTypes.Count-1; j >= 0; j--)
            {
                moveTypes[j].IsActive = j == moveType;
            }
        }
        private void OnEnable()
        {
            shootAction.performed += _ => Shoot();
            interactAction.performed += _ => Interact();
        }
        private void OnDisable()
        {
            shootAction.performed -= _ => Shoot();
            interactAction.performed -= _ => Interact();
        }


        public override bool Aiming
        {
            get
            {
                if (aimAction == null) return false;
                return aimAction.ReadValue<float>() > 0.1f;
            }
        }

        void Update()
        {
            if (!jumpPressed)
                jumpPressed = jumpAction.triggered;

            if (Aiming)
            {
                Vector3 CamDir = Camera.main.transform.forward;
                transform.forward = Quaternion.Euler(0, 0, 0) * new Vector3(CamDir.x, 0, CamDir.z).normalized;
            }
        }

        private void FixedUpdate()
        {
            if(health != null && health.IsDead)
            {
                if(TryGetComponent(out Ragdoll ragdoll) && !ragdoll.IsRagdolled)
                {
                    ragdoll.EnterRagdoll();
                }
                return;
            }

            float h = moveAction.ReadValue<Vector2>().x;
            float v = moveAction.ReadValue<Vector2>().y;
            h = Mathf.Clamp(h, -1, 1);
            v = Mathf.Clamp(v, -1, 1);

            //jump, crouch, running, add, subtract, swim dash
            bool[] extraMove = { jumpPressed, false, false, add==null ? false : add.triggered, subtract==null ? false : subtract.triggered, jumpAction.triggered };


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