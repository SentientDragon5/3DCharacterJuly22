using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.InputSystem;
using UnityEngine.AI;

namespace Character.Riding
{
    public enum HorseState
    {
        idle,
        trot,
        gallop,
        sidestep,
        back
    }

    [RequireComponent(typeof(Rigidbody))]
    public class Horse : MonoBehaviour
    {
        Rigidbody rigidBody;
        Animator animator;
        CapsuleCollider capsule;
        NavMeshAgent agent;

        [SerializeField] private Transform riderParent;

        [SerializeField] private Vector2 trotForesight = new Vector2(1f, 1f);
        [SerializeField] private Vector2 gallopForesight = new Vector2(5f, 5f);


        [SerializeField] private float trotSpeed = 1f;
        [SerializeField] private float gallopSpeed = 5f;

        [SerializeField] private float stationaryTurnSpeed = 180f;
        [SerializeField] private float movingTurnSpeed = 360f;


        float timeToStartBacking = 0.2f;
        float timeLastStop;

        public HorseState currentState;
        public Vector2 Direction(Vector2 input, bool[] extra)
        {
            if (currentState == HorseState.idle)
            {
                //you can go anywhere from idle
                if (extra[0])
                {
                    currentState = HorseState.trot;
                }
                else
                {
                    if (input.y < -0.1f)
                    {
                        if (Time.time - timeLastStop > timeToStartBacking)
                            currentState = HorseState.back;
                    }
                    else if (Mathf.Abs(input.x) > 0.1f)
                    {
                        currentState = HorseState.sidestep;
                    }
                }
            }
            else if (currentState == HorseState.trot)
            {
                if (extra[0])
                {
                    currentState = HorseState.gallop;
                }
                if (extra[1])
                {
                    currentState = HorseState.idle;
                    timeLastStop = Time.time;
                }
            }
            else if (currentState == HorseState.gallop)
            {
                if (extra[1])
                {
                    currentState = HorseState.trot;
                }
            }

            if (currentState == HorseState.sidestep)
            {
                if (Mathf.Abs(input.x) < 0.1f)
                    currentState = HorseState.idle;
                return new Vector2(input.x * trotForesight.x, 0);
            }
            else if (currentState == HorseState.back)
            {
                if (input.y > -0.1f)
                {
                    currentState = HorseState.idle;
                }
                else
                {
                    return new Vector2(0, input.y * trotForesight.y);
                }
            }

            if (currentState == HorseState.idle) return new Vector2(0, 0);
            else if (currentState == HorseState.trot) return new Vector2(input.x * trotForesight.x, trotForesight.y);
            else if (currentState == HorseState.gallop) return new Vector2(input.x * gallopForesight.x, gallopForesight.y);
            return Vector2.zero;
        }
        public Vector2 direction;


        public Vector3 moveInput;
        float extraTurnAmount;//for rotate.

        // amounts for movement
        float turnAmount;
        float forwardAmount;
        float rightdAmount;

        public bool isBeingRiden
        {
            set
            {
                if (value)
                {
                    //Stop mindless Ai
                }
                else
                {
                    //Start wander AI and stop running;
                }
            }
        }

        public Transform RiderParent { get => riderParent; }

        private void Awake()
        {
            rigidBody = GetComponent<Rigidbody>();
            animator = GetComponent<Animator>();
            capsule = GetComponent<CapsuleCollider>();
            agent = GetComponent<NavMeshAgent>();

        }


        public void Input(Vector2 input, bool[] extra)
        {
            //Debug.Log(extra[0] + " " + extra[1]);
            direction = Direction(input, extra);

            float v = direction.y;
            float h = direction.x;
            Transform camTransform = Camera.main.transform;
            Vector3 camForward = new Vector3(camTransform.forward.x, 0, camTransform.forward.z).normalized;
            Vector3 move = transform.forward * v + transform.right * h;
            //Vector3 move = v * camForward + h * camTransform.right;
            //if (move.magnitude > 1)
            //    move.Normalize();
            if (currentState == HorseState.sidestep)
            {
                move = transform.right * h;
            }
            if (currentState == HorseState.back)
            {
                move = transform.forward * v;
            }

            moveInput = move;
        }
        private void FixedUpdate()
        {
            Vector3 target = transform.position + moveInput * 2f;
            if (Physics.Raycast(target + Vector3.up * 2f, Vector3.down, out RaycastHit hit, 4f))
            {
                target = hit.point;
            }

            agent.SetDestination(target);

            if (currentState == HorseState.gallop)
            {
                agent.speed = gallopSpeed;
                agent.angularSpeed = movingTurnSpeed;
            }
            else
            {
                agent.speed = trotSpeed;
                agent.angularSpeed = stationaryTurnSpeed;
            }

            float animForward = (float)currentState;
            if (animForward > 2f)
                animForward = 1f;
            animator.SetFloat("Forward", animForward);
        }
        public void Move(Vector3 move, bool[] extra)
        {
            //Debug.Log(extra[0] + " " + extra[1]);
        }

        private void OnDrawGizmos()
        {

            Gizmos.color = Color.blue;
            Gizmos.DrawWireSphere(transform.position, 0.1f);
            Gizmos.color = Color.red;
            if (agent != null)
                Gizmos.DrawWireSphere(agent.destination, 0.1f);
        }
    }
}