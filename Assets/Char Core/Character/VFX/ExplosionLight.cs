using System.Collections;
using UnityEngine;
using UnityEngine.VFX;

namespace Enviroment
{
    [RequireComponent(typeof(Light))]
    /// <summary>
    /// Simple script to control the light emmitted from an Explosion.
    /// </summary>
    public class ExplosionLight : MonoBehaviour
    {
        //VisualEffect vfx;
        Lifetime life;
        Light l;

        public Gradient gradient;
        public float maxIntensity = 10;

        void Start()
        {
            //vfx = GetComponent<VisualEffect>();
            life = GetComponent<Lifetime>();
            l = GetComponent<Light>();
        }

        void FixedUpdate()
        {
            Color c = gradient.Evaluate(life.AgeOverLifetime01);
            l.color = c;
            l.intensity = c.a * maxIntensity;
        }
    }
}