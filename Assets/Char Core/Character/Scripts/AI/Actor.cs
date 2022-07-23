using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace Character
{
    public enum Affiliation { Evil = 2, Good = 1 }
    [AddComponentMenu("Character/Actor")]
    public class Actor : MonoBehaviour
    {
        public Affiliation team = Affiliation.Evil;

        public bool IsAlly(Actor other)
        {
            return other.team == team;
        }
        public bool IsEnemy(Actor other)
        {
            return other.team != team;
        }

        public Vector3 TargetLocation
        {
            get
            {
                Debug.Log("Getting Target");
                if (TryGetComponent(out CapsuleCollider c))
                {
                    return transform.position + c.center;
                }
                else if (TryGetComponent(out SphereCollider s))
                {
                    return transform.position + s.center;
                }
                else if (TryGetComponent(out BoxCollider b))
                {
                    return transform.position + b.center;
                }
                return transform.position;
            }
        }
    }
}