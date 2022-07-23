using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace Enviroment
{
    [RequireComponent(typeof(UnityEngine.VFX.VisualEffect))]
    [AddComponentMenu("Enviroment/Explosion")]
    public class Explosion : MonoBehaviour
    {
        public float radius = 2;
        public float force = 1;
        public int damage = 4;

        void OnEnable()
        {

            UnityEngine.VFX.VisualEffect vfx = GetComponent<UnityEngine.VFX.VisualEffect>();
            vfx.enabled = true;
            vfx.Play();
            Collider[] cols = Physics.OverlapSphere(transform.position, radius);
            foreach (Collider col in cols)
            {
                if (col.TryGetComponent(out Character.Ragdoll r))
                {
                    r.EnterRagdoll();
                    //r.GetComponent<Rigidbody>().AddExplosionForce(1, transform.position, radius, 1);
                    //r.AddExplosionForce(force, transform.position, radius, 1);
                    r.SetVelocity(Vector3.up * force + (r.transform.position - transform.position) * force);
                    r.AddRandomVelocity(0.01f);
                    r.GetComponent<Character.Health>().HP -= damage;
                }
                else if (col.TryGetComponent(out Rigidbody rb))
                {
                    rb.GetComponent<Rigidbody>().AddExplosionForce(1, transform.position, radius, 1);
                }
            }
            this.enabled = false;
        }
    }
}