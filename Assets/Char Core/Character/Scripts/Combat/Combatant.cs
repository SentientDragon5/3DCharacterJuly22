using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace Character.Combat
{

    [RequireComponent(typeof(Animator))]
    [AddComponentMenu("Character/Combat/Combatant")]
    public class Combatant : MonoBehaviour
    {
        private Animator animator;

        public Transform hand;
        public Transform weapon;
        public GameObject weaponPrefab;

        //public GameObject meleePrefab;
        //public Transform currentMelee;
        //public GameObject rangedPrefab;
        //public Transform currentRanged;


        [ContextMenu("Create Hand")]
        public void CreateHand()
        {
            if(hand == null)
            {
                if(TryGetComponent(out Animator animator))
                {
                    this.animator = animator;
                }
                else
                {
                    Debug.LogWarning("Warning: no animator could be found. please manually set the hand.");
                    return;
                }

                if (animator.isHuman)
                {
                    Transform handbone =  animator.GetBoneTransform(HumanBodyBones.RightHand);
                    GameObject newHand = new GameObject("Hand");
                    newHand.transform.parent = handbone;
                    handbone.transform.localEulerAngles = new Vector3(-90, 0, -90);
                    Debug.Log("new Hand Instantiated. Please double check that the Z axis points outward of the hand and that the Y axis points vertical.");
                }
                else
                {
                    Debug.LogWarning("Warning: Hand transform could not be made. Animator is not Humanoid. Please assign Transform manually or Retry.");
                }
            }
            else
            {
                Debug.LogWarning("Warning: Hand transform already exists. please remove the object if the autocreator is to proceed.");
            }
        }

        private void Awake()
        {
            animator = GetComponent<Animator>();

            if(hand == null)
            {
                CreateHand();
            }

            UpdateWeapon();
        }

        public bool Aiming
        {
            get
            {
                
                animator = GetComponent<Animator>();
                if (animator.GetCurrentAnimatorStateInfo(0).IsName("Hit"))
                    return false;


                if (TryGetComponent<Controller>(out Controller controller))
                {
                    return controller.Aiming;
                }
                return false;
            }
        }

        private void FixedUpdate()
        {
            animator.speed = animator.GetFloat("Speed");
            if(weaponPrefab != null)
            {
                if (weapon.TryGetComponent<Weapon>(out Weapon w))
                {

                    animator.SetBool(w.parameterAim, Aiming);
                }
                else
                {
                    animator.SetBool("Aiming", Aiming);
                }
            }
            else
            {
                UpdateWeapon();
            }
        }
        //Anticipation
        public void Attack()
        {
            Attack(false);
        }
        /// <summary>
        /// Will factor in whether the weapon is aimed or not.
        /// </summary>
        public void Attack(bool anticipation)
        {
            if (animator.GetCurrentAnimatorStateInfo(0).IsName("Hit"))
                return;

            if (weapon != null)
            {
                string anim = "none";
                int layer = 2;
                //Debug.Log("G: " + GetComponent<Character6>().Grounded + " A: " + Aiming);
                if(Aiming)
                {
                    weapon.GetComponent<Weapon>().RangedAttack(out anim, out layer);
                    if (anim != "none")
                    {
                        animator.CrossFade(anim, 0.05f, layer);
                    }
                }
                else
                {
                    if (GetComponent<Character6>().Grounded)
                    {
                        weapon.GetComponent<Weapon>().MeleeAttack(out anim, out layer);
                        if (anticipation)
                        {
                            anim += " Anticipation";
                        }
                        if (anim != "none")
                        {
                            animator.CrossFade(anim, 0.05f, layer);
                        }
                    }
                    else
                    {
                        weapon.GetComponent<Weapon>().AirMeleeAttack(out anim, out layer);
                        if (anim != "none")
                        {
                            animator.CrossFade(anim, 0.05f, layer);
                        }
                    }
                }
                
            }
        }

        public void DealMeleeDMG()
        {
            Melee m = weaponPrefab.GetComponent<Melee>();
            DoOverlapBoxAttack(m.hitVFX, m.damage);
        }

        public void DoOverlapBoxAttack(GameObject hitVFX, float damage)
        {
            Collider[] hits = Physics.OverlapBox(transform.position + transform.forward + transform.up, new Vector3(0.5f, 1f, 0.5f), transform.rotation);
            foreach (Collider collider in hits)
            {
                if (collider.TryGetComponent(out Actor a))
                {
                    Vector3 pos = collider.transform.position;
                    if (hitVFX != null) Instantiate(hitVFX, pos, Quaternion.identity);
                    if (a.IsEnemy(GetComponent<Actor>()))
                    {
                        if (a.TryGetComponent(out Health h))
                        {
                            h.HP = h.HP - Mathf.RoundToInt(damage);
                        }
                    }
                }
            }
        }

        public Vector3 target
        {
            get
            {
                if (TryGetComponent<Controller>(out Controller controller))
                {
                    return controller.target;
                }
                else
                    return transform.position + transform.forward;
            }
        }

        public void Hit()
        {
            animator.CrossFade("Hit", 0.1f, 0);
        }


        public void UpdateWeapon()
        {
            for (int i = 0; i < hand.childCount; i++)
            {
                Transform t = hand.GetChild(i);
                //t.parent = null;
                Destroy(t.gameObject);
            }
            if(weaponPrefab != null)
            {
                GameObject g = Instantiate(weaponPrefab, hand);
                weapon = g.transform;
                weapon.localPosition = Vector3.zero;
                weapon.localRotation = Quaternion.identity;
            }
            
        }
        public void SetParameter(string n, bool c)
        {
            animator.SetBool(n, c);
        }


        public void SetWeapon(GameObject newPrefab)
        {
            weaponPrefab = newPrefab;

            UpdateWeapon();
        }
        public void SwapWeapons(GameObject newPrefab)
        {
            //Drop old
            if(weaponPrefab != null)
            {
                Instantiate(weapon.GetComponent<Weapon>().Pickup, transform.position + (transform.forward * 2f) + transform.up, Quaternion.identity);
            }

            weaponPrefab = newPrefab;

            UpdateWeapon();
        }
        /// <summary>
        /// If it breaks or is thrown.
        /// </summary>
        public void RemoveWeaponFromInventory()
        {
            GetComponent<Inventory.CharacterInventory>().RemoveWeaponFromInventory();
        }

        private void OnDrawGizmos()
        {
            //Gizmos.color = Color.red;
            //Gizmos.DrawWireSphere(target, 0.1f);
            //Gizmos.DrawLine(hand.position, target);
        }
    }
}