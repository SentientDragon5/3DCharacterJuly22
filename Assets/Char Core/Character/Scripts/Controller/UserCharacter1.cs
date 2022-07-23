using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.InputSystem;
using Character.Combat;
using Character.Interactions;
using Character.Riding;

namespace Character
{

    //public enum MoveType { Normal, Riding, Swimming, Ragdoll, Climbing };
    /*
    [RequireComponent(typeof(PlayerInput))]

    [RequireComponent(typeof(Character6))]
    [RequireComponent(typeof(Health))]
    [RequireComponent(typeof(Actor))]
    [RequireComponent(typeof(Combatant))]
    [RequireComponent(typeof(Interactor))]
    [RequireComponent(typeof(Rider))]
    */

    [DefaultExecutionOrder(-2)]
    public class UserCharacter1 : Controller
    {
        /// <summary>
        /// returns all enabled UserCharacters. 
        /// </summary>
        public static List<UserCharacter1> userCharacters = new List<UserCharacter1>();


        public PlayerInput playerInput;
       

        public float aiming
        {
            get
            {
                return aimAction.ReadValue<float>();
            }
        }
        bool jumpPressed;

        private InputAction moveAction;
        private InputAction jumpAction;
        private InputAction shootAction;
        private InputAction aimAction;
        private InputAction interactAction;

        private InputAction add;
        private InputAction subtract;

        private bool[] extraMove;
        /// <summary>
        /// This is any extra input given by the player. this is mostly for active movables and 
        /// should only be acessesed in WantsActive, otherwise, use the Move method to get the
        /// extra input.
        /// jump, crouch, running, add, subtract, swim dash, glide toggle
        /// </summary>
        public bool[] ExtraInput
        {
            get => extraMove;
        }

        protected override void Awake()
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
            aimAction = playerInput.actions["Aim"];
            shootAction = playerInput.actions["Shoot"];
            jumpAction = playerInput.actions["Jump"];
            interactAction = playerInput.actions["Interact"];

            add = playerInput.actions["Add"];
            subtract = playerInput.actions["Subtract"];


            Cursor.lockState = CursorLockMode.Locked;

            base.Awake();
        }
        private void OnEnable()
        {
            if (!userCharacters.Contains(this) && this.enabled)
                userCharacters.Add(this);
            shootAction.performed += _ => Shoot();
            interactAction.performed += _ => Interact();
        }
        private void OnDisable()
        {
            if (userCharacters.Contains(this))
                userCharacters.Remove(this);

            shootAction.performed -= _ => Shoot();
            interactAction.performed -= _ => Interact();
        }


        public override bool Aiming
        {
            get
            {
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
            bool[] extraMove = { jumpPressed, false, false, add.triggered, subtract.triggered, jumpAction.triggered, jumpAction.triggered };
            this.extraMove = extraMove;

            Move(new Vector2(h, v), extraMove);
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