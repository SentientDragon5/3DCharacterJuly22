using System.Collections;
using System.Collections.Generic;
using UnityEngine;

/// <summary>
/// this script creates a field within a trigger collider or as a volume.
/// </summary>
public class ForceField: MonoBehaviour
{
    public static List<ForceField> globalFields = new List<ForceField>();

    [SerializeField] private string forceTag = "gravity";
    [SerializeField] private Vector3 force = new Vector3(0,-10,0);
    [SerializeField] private bool toCenter = false;
    [SerializeField] private AnimationCurve fallOff = new AnimationCurve(new Keyframe(0, 1), new Keyframe(1, 0));

    private void Awake()
    {
        if (IsGlobal)
        {
            globalFields.Add(this);
        }
        //Debug.Log("Adding " + gameObject.name + TryGetComponent(out Collider c));
    }

    public bool IsGlobal
    {
        get
        {
            return !TryGetComponent(out Collider c);
        }
    }

    /// <summary>
    /// compares the tags of the forces
    /// </summary>
    /// <param name="other">the tag of the receptor</param>
    /// <returns></returns>
    public bool CompareForceTag(string other)
    {
        return other == forceTag;
    }
    /// <summary>
    /// the force at a position. (falloff can affect force by positon)
    /// </summary>
    /// <param name="position"></param>
    /// <returns></returns>
    public Vector3 Force(Vector3 position)
    {
        if (TryGetComponent(out Collider c) && toCenter)
        {
            float dist = Vector3.Distance(position, transform.position);
            Vector3 dir = transform.position - position;
            return dir * force.magnitude * fallOff.Evaluate(dist / Radius(transform.position));
        }
        return force;
    }
    public Vector3 Center
    {
        get
        {
            if(TryGetComponent(out Collider c))
            {
                return c.bounds.center + transform.position;
            }
            return transform.position;
        }
    }
    public float Radius(Vector3 positon)
    {
        if (TryGetComponent(out Collider c))
        {
            return Vector3.Distance(c.bounds.ClosestPoint(transform.position - c.bounds.center), Vector3.zero);
        }
        return 0;
    }

    private void OnTriggerEnter(Collider other)
    {
        if(other.TryGetComponent(out ForceProbe probe))
        {
            probe.Fields.Add(this);
        }
    }
    private void OnTriggerExit(Collider other)
    {
        if (other.TryGetComponent(out ForceProbe probe))
        {
            probe.Fields.Remove(this);
        }
    }

}
