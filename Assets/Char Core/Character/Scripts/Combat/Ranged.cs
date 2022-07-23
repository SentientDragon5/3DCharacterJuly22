using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Character.Combat;
namespace Character.Combat
{
    public class Ranged : Weapon
    {
        public string animationName = "Fire";

        public int animationLayer = 3;

        public GameObject bulletPrefab;
        public GameObject muzzleFlashPrefab;
        public Transform barrel;
        public float cooldown = 0.2f;

        float lastShotTime = 0;

        void Awake()
        {
            if (bulletParent == null)
            {
                bulletParent = GameObject.Find("Bullet Parent").transform;
            }
        }

        public override void MeleeAttack(out string animation, out int layer)
        {
            //Nada
            animation = "none";
            layer = 2;
        }

        public override void RangedAttack(out string animation, out int layer)
        {
            layer = animationLayer;
            if (Time.time - lastShotTime < cooldown)
            {
                animation = "none";
                return;
            }

            lastShotTime = Time.time;

            animation = animationName;


            GameObject bulletObject = Instantiate(bulletPrefab, barrel.position, barrel.rotation, bulletParent);
            BulletController bullet = bulletObject.GetComponentInChildren<BulletController>();
            bullet.gunDamage = damage;

            Vector3 direction = GetComponentInParent<Combatant>().target - GetComponentInParent<Combatant>().transform.position;
            RaycastHit hit;
            if (Physics.Raycast(barrel.position, direction, out hit))// originally from Camera.main.transform.position and direction was camera forward
            {
                bullet.target = hit.point;
                bullet.hit = true;
            }
            else
            {
                bullet.target = transform.position + direction * 25f;
                bullet.hit = false;
            }
            bullet.target = GetComponentInParent<Combatant>().target;

            Instantiate(muzzleFlashPrefab, barrel);
        }
    }
}