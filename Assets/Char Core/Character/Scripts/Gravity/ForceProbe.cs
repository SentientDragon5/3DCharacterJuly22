using System.Collections;
using System.Collections.Generic;
using UnityEngine;

/// <summary>
/// use the ForceApplier script to add forces to any object. otherwise Movables should use this to get forces.
/// </summary>
public class ForceProbe : MonoBehaviour
{
    private List<ForceField> fields = new List<ForceField>();
    public List<ForceField> Fields => fields;

    Rigidbody forceProbe_rb;
    private void Start()
    {
        /*ForceField[] wwFields = Object.FindObjectsOfType<ForceField>();
        foreach(ForceField f in wwFields)
        {
            if (f.IsGlobal)
                fields.Add(f);
        }*/
        fields.AddRange(ForceField.globalFields);
        forceProbe_rb = GetComponent<Rigidbody>();
    }

    // for debug
    //[HideInInspector]
    public Vector3 LASTNETFORCE;
    /// <summary>
    /// this is the net force from all fields
    /// </summary>
    public Vector3 NetForce()
    {
        Vector3 o = Vector3.zero;
        foreach (ForceField field in fields)
        {
            o += field.Force(transform.position);
        }
        LASTNETFORCE = o;
        return o;
    }
    /// <summary>
    /// this will get all the forces of a certain tag.
    /// </summary>
    /// <param name="forceTag"></param>
    /// <returns></returns>
    public Vector3 NetForce(string forceTag)
    {
        Vector3 o = Vector3.zero;
        foreach (ForceField field in fields)
        {
            if(field.CompareForceTag(forceTag))
                o += field.Force(transform.position);
        }
        LASTNETFORCE = o;
        return o;
    }
    /// <summary>
    /// use "public virtual string[] AutoApply { get { return new string[0]; } }" in child classes to disable auto applied gravity.
    /// </summary>
    public virtual string[] AutoApply { get { return new string[1] { "gravity" }; } }


    private void LateUpdate()
    {
        if(forceProbe_rb == null)
            forceProbe_rb = GetComponent<Rigidbody>();
        if (AutoApply.Length > 0)
            ApplyForces(AutoApply);
        //Debug.Log(gameObject.name);
    }
    /// <summary>
    /// Applies the force of all forces with that tag in range.
    /// </summary>
    /// <param name="tags"></param>
    public void ApplyForces(string[] tags)
    {
        for (int j = 0; j < tags.Length; j++)
        {
            forceProbe_rb.velocity += NetForce(tags[j]) * Time.deltaTime;
        }
    }
    /// <summary>
    /// Applies the force of all forces with AutoApply tags in range.
    /// </summary>
    public void ApplyForces()
    {
        if (AutoApply.Length > 0)
            ApplyForces(AutoApply);
    }
    public Vector3 NetForceDeltaVelocity(float deltaTime)
    {
        Vector3 o = Vector3.zero;
        if (AutoApply.Length > 0)
        {
            string[] tags = AutoApply;
            for (int j = 0; j < tags.Length; j++)
            {
                o += NetForce(tags[j]) * deltaTime;
            }
        }
        return o;
    }
}
