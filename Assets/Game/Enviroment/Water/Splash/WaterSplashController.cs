using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.VFX;

namespace Water
{
    public enum WaterType { River, Ocean };

    public class WaterSplashController : MonoBehaviour
    {
        public GameObject effectPrefab;
        public AudioClip splashAudioClip;
        
        public float lifetimeEndEffect = 0.2f;
        public float lifetimeDestroyGameobject = 1.5f;


        List<Collider> colliders = new List<Collider>();

        public WaterType waterType = WaterType.Ocean;
        public AudioClip ambientAudio;
        AudioSource source;

        private void OnValidate()
        {
            Splash.lifetimeEndEffect = lifetimeEndEffect;
            Splash.lifetimeDestroyGameobject = lifetimeDestroyGameobject;
            Splash.clip = splashAudioClip;

        }
        private void Awake()
        {
            source = GetComponent<AudioSource>();
            source.clip = ambientAudio;
            source.loop = true;
            source.Play();
        }

        float caluclateSize(Collider other)
        {
            float size = 1f;
            if (other.gameObject.TryGetComponent(out SphereCollider s))
            {
                size = s.radius;
            }
            else if (other.gameObject.TryGetComponent(out CapsuleCollider c))
            {
                size = c.radius / 2;
            }
            else if (other.gameObject.TryGetComponent(out BoxCollider b))
            {
                size = Mathf.Sqrt(b.size.magnitude);
            }
            else if (other.gameObject.TryGetComponent(out Rigidbody rb))
            {
                size = rb.mass;
            }
            return size / 2;
        }

        private void OnTriggerEnter(Collider other)
        {
            Vector3 contact = GetComponent<Collider>().ClosestPoint(other.transform.position);
            float size = caluclateSize(other);
            
            CreateSplash(contact, size);
            if (waterType == WaterType.River)
            {
                colliders.Add(other);
            }
        }

        private void OnTriggerStay(Collider other)
        {
            if (waterType == WaterType.River)
            {
                if (!colliders.Contains(other))
                {
                    colliders.Add(other);
                }
                Vector3 contact = GetComponent<Collider>().ClosestPoint(other.transform.position);
                float size = caluclateSize(other);

                CreateSplash(contact, size);
            }
        }

        private void OnTriggerExit(Collider other)
        {
            foreach (Collider collider in colliders)
            {
                if (other == collider)
                {
                    colliders.Remove(other);
                }
            }
        }

        public void CreateSplash(Vector3 position, float radius)
        {
            GameObject effect = Instantiate(effectPrefab, position, Quaternion.identity);
            effect.GetComponent<Splash>().SetValues(position, radius);

        }
        //private void OnCollisionEnter(Collision collision)
        //{
        //    ProcessCollisions(collision);
        //}
        //private void OnCollisionStay(Collision collision)
        //{
        //    ProcessCollisions(collision);
        //}
        ////private void OnCollisionExit(Collision collision)
        ////{
        ////    foreach (ContactPoint contact in collision.contacts)
        ////    {
        ////        if (locations.Contains(contact.point))
        ////            locations.Remove(contact.point);
        ////        if (normals.Contains(contact.normal))
        ////            normals.Remove(contact.normal);
        ////    }
        ////    UpdateEffect();
        ////}

        //void ProcessCollisions(Collision collision)
        //{
        //    Debug.Log("a");
        //    locations.Clear();
        //    normals.Clear();
        //    foreach (ContactPoint contact in collision.contacts)
        //    {
        //        Instantiate(effectPrefab,contact.point, Quaternion.LookRotation(contact.normal));
        //        locations.Add(contact.point);
        //        normals.Add(contact.normal);
        //    }

        //}
    }
}