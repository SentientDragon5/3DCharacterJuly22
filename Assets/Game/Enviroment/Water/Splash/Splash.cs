using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.VFX;

namespace Water
{
    public class Splash : MonoBehaviour
    {
        //controlled in splashController
        public static float lifetimeEndEffect;
        public static float lifetimeDestroyGameobject;
        public static AudioClip clip;

        VisualEffect effect;
        AudioSource source;

        private void OnDrawGizmos()
        {
            Gizmos.DrawWireSphere(p, r);
        }
        Vector3 p;
        float r;

        public void SetValues(Vector3 position, float radius)
        {
            effect.SetVector3("_position", position);
            effect.SetFloat("_radius", radius);
            p = position;
            r = radius;
        }

        private void Awake()
        {
            effect = GetComponent<VisualEffect>();
            source = GetComponent<AudioSource>();
            StartCoroutine(Life());
            PlayAudio();
        }

        void PlayAudio()
        {
            source.clip = clip;
            source.Play();
        }

        /// <summary>
        /// The position of the collision.
        /// </summary>
        Vector3 collisionPosition;
        /// <summary>
        /// The size of the collision and the size of the effect.
        /// </summary>
        float collisionRadius;

        /// <summary>
        /// A Method that updates the script's connected Visual Effect.
        /// </summary>
        public void UpdateEffect()
        {
            effect.SetVector3(0, collisionPosition);
            effect.SetFloat(1, collisionRadius);
        }

        /// <summary>
        /// A Coroutine that controls the stopping of the effect and destroying of the object.
        /// </summary>
        /// <returns></returns>
        IEnumerator Life()
        {
            yield return new WaitForSeconds(lifetimeEndEffect);
            effect.Stop();
            yield return new WaitForSeconds(Mathf.Abs(lifetimeDestroyGameobject - lifetimeEndEffect));
            Destroy(gameObject);
        }

    }
}