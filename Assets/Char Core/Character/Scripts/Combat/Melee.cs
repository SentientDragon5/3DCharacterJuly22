using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Character.Combat;
using Character;

namespace Character.Combat
{
    public class Melee : Weapon
    {
        public string animationName = "Sword";
        public int animationLayer = 3;

        public GameObject hitVFX;


        public float cooldown = 0.2f;
        public AnimationCurve time;
        public float rate = 0.01f;

        public float throwSpeed = 10f;
        private Combatant combatant;

        public Vector3 target;
        public Collider targetCollider;

        public string airAnimationName = "FallingSword";
        public GameObject hitGroundVFX;

        void Awake()
        {
            combatant = GetComponentInParent<Combatant>();
        }



        public override void MeleeAttack(out string animation, out int layer)
        {
            animation = animationName;
            layer = animationLayer;
            trail = 1;

            Combatant c = combatant;
            Transform t = c.transform;

            //New method -- Actually turns out internet all uses ovelap boxes? I guessed it?? It isnt smooth enough tho.

            //THis method creates an overlap box that deducts health for all within the box.
            return;
            //Now do damage in the Combatant
            // have a method call in the animation for the combatatant to do the melee damage.
            // it takes the current weapon and finds out its info.
            Collider[] hits = Physics.OverlapBox(t.position + t.forward + t.up, new Vector3(0.5f, 1f, 0.5f), t.rotation);
            foreach (Collider collider in hits)
            {
                if (collider.TryGetComponent(out Actor a))
                {
                    Vector3 pos = collider.transform.position;
                    if (hitVFX != null) Instantiate(hitVFX, pos, Quaternion.identity);
                    if (a.IsEnemy(c.GetComponent<Actor>()))
                    {
                        if (a.TryGetComponent(out Health h))
                        {
                            h.HP = h.HP - Mathf.RoundToInt(damage);
                        }
                    }
                }
            }
        }
        public override void AirMeleeAttack(out string animation, out int layer)
        {
            animation = airAnimationName;
            layer = animationLayer;
            trail = 1;

            Combatant c = combatant;
            Transform t = c.transform;

            c.GetComponent<Rigidbody>().velocity += Vector3.up * 2;
            //New method -- Actually turns out internet all uses ovelap boxes? I guessed it?? It isnt smooth enough tho.
            //THis method creates an overlap box that deducts health for all within the box.
            StartCoroutine(OnHitGround(c.GetComponent<Character6>()));      
        }
        IEnumerator OnHitGround(Character6 c)
        {
            Transform t = c.transform;
            while (!c.Grounded)
                yield return new WaitForFixedUpdate();
            Collider[] hits = Physics.OverlapSphere(t.position, 3);//Physics.OverlapBox(t.position + t.forward + t.up, new Vector3(0.5f, 1f, 0.5f), t.rotation);

            if (hitVFX != null) Instantiate(hitGroundVFX, t.position, Quaternion.identity);
            foreach (Collider collider in hits)
            {
                if (collider.TryGetComponent(out Actor a))
                {
                    Vector3 pos = collider.transform.position;
                    if (hitVFX != null) Instantiate(hitVFX, pos, Quaternion.identity);
                    if (a.IsEnemy(c.GetComponent<Actor>()))
                    {
                        if (a.TryGetComponent(out Health h))
                        {
                            h.HP = h.HP - Mathf.RoundToInt(damage);
                        }
                    }
                }
            }
        }


        public override void RangedAttack(out string animation, out int layer)
        {
            layer = animationLayer;
            animation = animationName;

            Combatant c = combatant;

            transform.parent = null;
            c.weapon = null;
            c.weaponPrefab = null;
            c.RemoveWeaponFromInventory();

            Rigidbody rigidbody;
            if (TryGetComponent<Rigidbody>(out rigidbody))
            {
                //continue;
            }
            else
            {
                rigidbody = gameObject.AddComponent<Rigidbody>();
            }
            throwDir = (c.target - transform.position).normalized * throwSpeed;
            rigidbody.velocity = throwDir;
            rigidbody.angularVelocity = Vector3.up * throwSpeed * 10;

            target = c.target;
            RaycastHit hit;
            if (Physics.Raycast(transform.position, throwDir, out hit, 200f))
            {
                targetCollider = hit.collider;
            }
            Debug.DrawLine(transform.position, c.target, Color.red, 2f);
            Debug.DrawRay(transform.position, throwDir, Color.yellow, 2f);

            StartCoroutine(DelayCollider(colliderDelay));
            //GetComponentInChildren<Collider>().enabled = true;
            c.SetParameter(parameterAim, false);
        }
        float thrown = 0;
        public float thrownRate = 1f;
        public float colliderDelay = 0.2f;
        Vector3 throwDir;
        private void OnCollisionEnter(Collision collision)
        {
            Combatant c = combatant;
            Collider collider = collision.collider;
            if (collider.TryGetComponent(out Actor a))
            {
                Vector3 pos = collider.transform.position;
                if (hitVFX != null) Instantiate(hitVFX, pos, Quaternion.identity);
                if (a.IsEnemy(c.GetComponent<Actor>()))
                {
                    if (a.TryGetComponent(out Health h))
                    {
                        h.HP = h.HP - Mathf.RoundToInt(damage * 2);
                    }
                }
            }
            Instantiate(Pickup, transform.position, transform.rotation);
            Destroy(gameObject);
        }

        Vector3 charprevPos;
        Vector3 previousPosition;
        private void FixedUpdate()
        {
            //Vector3 characterVel = (GetComponentInParent<Combatant>().transform.position - charprevPos) / Time.deltaTime;
            //Vector3 worldVelocity = (transform.position - previousPosition) / Time.deltaTime;

            //Vector3 LocalVel = worldVelocity - characterVel;
            //if(LocalVel.sqrMagnitude > 0.5f)
            //{
            //    GetComponentInChildren<TrailRenderer>().enabled = true;
            //    GetComponentInChildren<TrailRenderer>().time = 0.5f;
            //}
            //else
            //{
            //    GetComponentInChildren<TrailRenderer>().enabled = false;
            //}

            //charprevPos = GetComponentInParent<Combatant>().transform.position;
            //previousPosition = transform.position;

            //return;
            if (trail > 0)
            {
                trail -= rate * Time.deltaTime;
            }

            Material m = GetComponentInChildren<TrailRenderer>().material;
            //m.SetFloat("_Alpha", time.Evaluate(trail));
            //GetComponentInChildren<TrailRenderer>().time = time.Evaluate(trail);
            float animTrail = 0;
            try
            {
                animTrail = GetComponentInParent<Animator>().GetFloat("Trail");
            }
            catch { }
            m.SetFloat("_Alpha", animTrail);
            GetComponentInChildren<TrailRenderer>().time = animTrail;


            if (thrown > 0)
            {
                thrown -= thrownRate * Time.deltaTime;
                GetComponent<Rigidbody>().velocity = throwDir * thrown;
            }
            if (Vector3.Distance(target, transform.position) < 0.1f)
            {
                if (targetCollider != null)
                {
                    Combatant c = combatant;
                    Collider collider = targetCollider;
                    if (collider.TryGetComponent(out Actor a))
                    {
                        Vector3 pos = collider.transform.position;
                        if (hitVFX != null) Instantiate(hitVFX, pos, Quaternion.identity);
                        if (a.IsEnemy(c.GetComponent<Actor>()))
                        {
                            if (a.TryGetComponent(out Health h))
                            {
                                h.HP = h.HP - Mathf.RoundToInt(damage * 2);
                            }
                        }
                    }
                    Instantiate(Pickup, transform.position, transform.rotation);
                    Destroy(gameObject);
                }
                else
                {
                    Instantiate(Pickup, transform.position, transform.rotation);
                    Destroy(gameObject);
                }
            }
        }

        float trail = 0;


        IEnumerator DelayCollider(float t)
        {
            yield return new WaitForSeconds(t);
            GetComponentInChildren<Collider>().enabled = true;
        }
    }
}