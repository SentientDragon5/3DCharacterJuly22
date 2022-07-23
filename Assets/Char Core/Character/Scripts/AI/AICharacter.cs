using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.AI;
using Character.Combat;
using System.Linq;

namespace Character
{
    [RequireComponent(typeof(NavMeshAgent))]
    [RequireComponent(typeof(Character6))]
    [RequireComponent(typeof(Health))]
    [RequireComponent(typeof(Actor))]
    [DefaultExecutionOrder(-2)]
    public class AICharacter : Controller
    {
        public enum AIBehavior
        {
            Patrol,
            Follow,
            Attack
        }

        public NavMeshAgent agent;

        private Transform camTransform;

        private Vector3 playerVelocity;
        private bool groundedPlayer;

        private bool aiming = true;
        private bool fire;

        public AIBehavior aiBehavior = AIBehavior.Patrol;

        private void Start()
        {
            Awake();

            agent.updateRotation = false;
            agent.updatePosition = false;
        }
        protected override void Awake()
        {
            actor = GetComponent<Actor>();
            animator = GetComponent<Animator>();
            agent = GetComponent<NavMeshAgent>();
            combatant = GetComponent<Combatant>();
            health = GetComponent<Health>();
            aiming = true;
            base.Awake();
        }

        public bool Aiming
        {
            get
            {
                if(combatant.weapon != null && combatant.weapon.TryGetComponent(out Melee m))
                {
                    return false;
                }

                return aiming;
            }
        }

        void Update()
        {

            if (aiming)
            {
                FindTargets();
                Vector3 CamDir = transform.forward;
                if (targets.Count > 0) CamDir = targets[0].transform.position - transform.position;
                transform.forward = Quaternion.Euler(0, 0, 0) * new Vector3(CamDir.x, 0, CamDir.z).normalized;
            }
        }

        private void FixedUpdate()
        {

            if (health.IsDead)
            {
                if(!postDead)
                {
                    StartCoroutine(OnDie());
                }
                    
                return;
            }

            AI();

            Vector3 move = agent.desiredVelocity;
            Vector2 input = new Vector2(move.x, move.z);
            
            bool[] extraMove = { false, false, false, false, false, false, false };
            if (agent.remainingDistance > agent.stoppingDistance)
            {
                if (input.magnitude > 1)
                    input.Normalize();
                Debug.Log(agent.nextPosition - transform.position);
                Move(agent.nextPosition - transform.position, extraMove);
            }
            else Move(Vector2.zero, extraMove);

            animator.SetBool("Aiming", aiming);
            //combatant.Shoot(aiming);
        }


        public PatrolPath path;
        int currentPathIndex;
        public bool OnPath;

        int nextPathIndex
        {
            get
            {
                int o = currentPathIndex + 1; 
                if(o>path.Subdivided.Count)
                {
                    return 0;
                }
                return o;
            }
        }
        public void FollowPath()//out Vector3 move)
        {
            OnPath = Vector3.Distance(path.NearestPoint(transform.position), transform.position) < 0.1f;
            Debug.DrawLine(path.NearestPoint(transform.position), transform.position, Color.red);
            Debug.Log(Vector3.Distance(path.NearestPoint(transform.position), transform.position));
            if(!OnPath)//Off path
            {
                //go to path
                //find nearest point on path.
                agent.SetDestination(path.NearestPoint(transform.position));
            }
            else
            {
                //GO to the next point
                if (Vector3.Distance(path.Subdivided[currentPathIndex], path.Subdivided[nextPathIndex]) < 0.1f)
                {
                    //Is at point
                    currentPathIndex = nextPathIndex;
                }
                else
                {
                    //Go Closer
                    agent.SetDestination(path.Subdivided[nextPathIndex]);
                }
            }
        }

        List<Actor> targets = new List<Actor>();
        public float detectionRadius = 10;
        public float pursuitRadius = 30;
        public float standRadius = 5f;
        public float meleeAttackRadius = 1f;
        public float rangedAttackRadius = 5f;
        public LayerMask characterLayer = 7;


        //public float frustrumIteratins = 10f;
        //public float viewDistance = 20f;
        //public float viewFOV = 20f;

        public void FindTargets()
        {
            targets.Clear();
            Collider[] colliders = Physics.OverlapSphere(transform.position, detectionRadius, characterLayer);
            foreach (Collider c in colliders)
            {
                if(c.TryGetComponent(out Actor a))
                {
                    if(a.IsEnemy(actor))
                        targets.Add(a);
                }
            }
            //while(targets.Contains(controller.Actor))
            //{
            //    targets.Remove(controller.Actor);
            //}
            targets = targets.OrderBy(i => Vector3.Distance(i.transform.position, transform.position)).ToList();//using Linq

        }


        public Vector3 target
        {
            get
            {
                if (targets.Count == 0)
                    return transform.forward * 25f;
                return targets[0].transform.position;
                //Camera.main.transform.position + Camera.main.transform.forward * 25f
            }
        }

        static Collider[] ArrayAdd(Collider[] a, Collider[] b)
        {
            Collider[] o = new Collider[a.Length + b.Length];
            for (int i = 0; i < a.Length; i++)
            {
                o[i] = a[i];
            }
            for (int i = 0; i < b.Length; i++)
            {
                o[i + a.Length] = b[i];
            }
            return o;
        }

        public Vector3 StandAtDistanceFrom(Vector3 destination, float radius)
        {
            //Make a sphere at the location, then raycast from destination to find the y
            Vector3 dir = destination - transform.position;

            Ray ray = new Ray(destination - (dir.normalized * radius), Vector3.down);
            RaycastHit hit;
            Vector3 o = destination - (dir.normalized * radius);
            if (Physics.Raycast(ray, out hit, radius))
            {
                o.y = hit.point.y;
            }
            return o;
        }

        /// <summary>
        /// This will Update targets and return whether there are targets this frame.
        /// </summary>
        /// <returns></returns>
        public bool DetectEnemys()
        {
            targets.Clear();
            Collider[] colliders = Physics.OverlapSphere(transform.position, detectionRadius, characterLayer);
            
            //Frustrum
            //float lastBoxSize = viewDistance * Mathf.Cos(viewFOV);
            //float boxLen = viewDistance / frustrumIteratins;
            //Transform head = animator.GetBoneTransform(HumanBodyBones.Head);

            //for (int i = 1; i < frustrumIteratins; i++)
            //{
            //    Vector3 pos = head.position + head.forward * (viewDistance * i + boxLen * 0.5f);
            //    Vector3 size = new Vector3(lastBoxSize / frustrumIteratins * i, lastBoxSize / frustrumIteratins * i, boxLen);

            //    colliders = ArrayAdd(colliders, Physics.OverlapBox(pos, size / 2, head.rotation, characterLayer));
            //}

            foreach (Collider c in colliders)
            {
                if (c.TryGetComponent(out Actor a))
                {
                    if (a.IsEnemy(actor))
                    {
                        if(TryGetComponent(out Health h))
                        {
                            if(!h.IsDead)
                                targets.Add(a);
                        }
                    }
                }
            }
            //while(targets.Contains(controller.Actor))
            //{
            //    targets.Remove(controller.Actor);
            //}
            targets = targets.OrderBy(i => Vector3.Distance(i.transform.position, transform.position)).ToList();//using Linq
            if(targets.Count > 0)
            {

                lastTarget = targets[0].transform;
            }

            return targets.Count > 0;
        }
        /// <summary>
        /// This will NOT Update targets and return whether there are any enemys within Radius this frame.
        /// </summary>
        /// <returns></returns>
        public bool CheckEnemys(float radius)
        {
            List<Actor> check = new List<Actor>();
            Collider[] colliders = Physics.OverlapSphere(transform.position, radius, characterLayer);
            foreach (Collider c in colliders)
            {
                if (c.TryGetComponent(out Actor a))
                {
                    if (a.IsEnemy(actor))
                    {
                        if (TryGetComponent(out Health h))
                        {
                            if (!h.IsDead)
                                targets.Add(a);
                        }
                    }
                }
            }
            //while(targets.Contains(controller.Actor))
            //{
            //    targets.Remove(controller.Actor);
            //}
            check = check.OrderBy(i => Vector3.Distance(i.transform.position, transform.position)).ToList();//using Linq

            return check.Count > 0;
        }


        Transform lastTarget;
        public float shootCooldown = 1f;
        public float shootCooldownVariance = 0.5f;
        float lastShoot;
        float currentRandomCooldown = 0.5f;

        public void AI()
        {
            //EVALUATE
            if(DetectEnemys())
            {
                aiBehavior = AIBehavior.Attack;
            }
            else
            {
                aiBehavior = AIBehavior.Patrol;
                
                if(lastTarget != null && Vector3.Distance(lastTarget.position, transform.position) < pursuitRadius)
                {
                    aiBehavior = AIBehavior.Follow;
                }
            }


            //DO

            if (aiBehavior == AIBehavior.Patrol)
            {
                aiming = false;
                // Check distance to next patrol point.
                // Set destination to next patrol point.

                //For now stand still.
                agent.SetDestination(transform.position);
            }
            else if (aiBehavior == AIBehavior.Follow)
            {
                aiming = false;
                // Set destination
                agent.SetDestination(StandAtDistanceFrom(lastTarget.position, standRadius));
            }
            else if (aiBehavior == AIBehavior.Attack)
            {
                GetComponent<AimIK>().targetPos = targets[0].transform.position;
                float tempRadius = standRadius;
                if (GetComponentsInChildren<Ranged>().Length > 0)
                {
                    tempRadius = rangedAttackRadius;
                    aiming = true;
                }
                if (GetComponentsInChildren<Melee>().Length > 0)
                {
                    tempRadius = meleeAttackRadius;
                    aiming = false;
                }
                if (Time.time - lastShoot > shootCooldown + currentRandomCooldown && Vector3.Distance(lastTarget.position, transform.position) < tempRadius + 0.5f)
                {
                    lastShoot = Time.time;
                    currentRandomCooldown = Random.Range(0, shootCooldownVariance);
                    combatant.Attack(true);
                }
                agent.SetDestination(StandAtDistanceFrom(lastTarget.position, tempRadius));
                // Shoot and update cooldown
                // A little movement?
                // 
            }
            else
            {
                aiming = false;
                agent.SetDestination(transform.position);
                // Nothing
            }

            //MISC.
            if (lastTarget != null && Vector3.Distance(lastTarget.position, transform.position) > pursuitRadius)
            {
                lastTarget = null;
            }
            if(lastTarget != null && lastTarget.TryGetComponent(out Health h) && h.IsDead)
            {
                lastTarget = null;
            }
        }

        private void OnDrawGizmos()
        {
            Gizmos.color = Color.red;
            if(lastTarget != null)
            {
                Gizmos.DrawWireCube(lastTarget.position + Vector3.up, new Vector3(0.5f, 2f, 0.5f));
                //Gizmos.DrawIcon(lastTarget.position, "Animation.FilterBySelection");
            }
            Gizmos.DrawWireSphere(transform.position, detectionRadius);
            Gizmos.color = Color.yellow;
            Gizmos.DrawWireSphere(transform.position, pursuitRadius);

            //Frustrum
            //float lastBoxSize = viewDistance * Mathf.Cos(viewFOV);
            //float boxLen = viewDistance / frustrumIteratins;
            //animator = GetComponent<Animator>();
            //Transform head = animator.GetBoneTransform(HumanBodyBones.Head);

            //for (int i = 1; i < frustrumIteratins; i++)
            //{
            //    Vector3 pos = head.position + head.forward * (viewDistance * i + boxLen * 0.5f);
            //    Vector3 size = new Vector3(lastBoxSize / frustrumIteratins * i, lastBoxSize / frustrumIteratins * i, boxLen);

            //    Gizmos.DrawWireCube(pos, size);
            //}
            //Gizmos.DrawFrustum(head.position, viewFOV, viewDistance, 0.01f, 1f);
        }

        bool postDead = false;
        IEnumerator OnDie()
        {
            postDead = true;
            if (health != null && health.IsDead)
            {
                if (TryGetComponent(out Ragdoll ragdoll) && !ragdoll.IsRagdolled)
                {
                    ragdoll.EnterRagdoll();
                }
            }

            yield return new WaitForSeconds(3f);

            StopAllCoroutines();
            Destroy(gameObject);
        }


    }
}