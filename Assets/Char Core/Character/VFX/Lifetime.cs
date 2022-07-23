using System.Collections;
using UnityEngine;

namespace Enviroment
{
    /// <summary>
    /// This will kill a gameObject after the lifetime. It uses coroutines.
    /// </summary>
    public class Lifetime : MonoBehaviour
    {
        public float lifetime = 3f;

        float start;
        private void Awake()
        {
            start = Time.time;
            StartCoroutine(KillAfterTime());
        }

        private IEnumerator KillAfterTime()
        {
            yield return new WaitForSeconds(lifetime);
            Destroy(this.gameObject);
        }

        /// <summary>
        /// Time that it was started
        /// </summary>
        public float AwakeTime
        {
            get => start;
        }
        /// <summary>
        /// Returns the age (0-1) where 1 is full lifetime
        /// </summary>
        public float AgeOverLifetime01
        {
            get
            {
                return Mathf.Clamp01(Time.time - start / lifetime);
            }
        }
    }
}