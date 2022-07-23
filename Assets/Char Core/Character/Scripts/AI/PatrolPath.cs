using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System.Linq;

public class PatrolPath : MonoBehaviour
{
    private List<Transform> patrolPoints = new List<Transform>();
    private List<Vector3> subdivided = new List<Vector3>();

    [ContextMenu("Refresh")]
    private void OnValidate()
    {
        patrolPoints = new List<Transform>();
        for (int i = 0; i < transform.childCount; i++)
        {
            patrolPoints.Add(transform.GetChild(i));
        }
        subdivided = new List<Vector3>();
        for (int i = 0; i < patrolPoints.Count; i++)
        {
            Vector3 current = patrolPoints[i].position;
            int nextInt = i + 1;
            if (nextInt >= patrolPoints.Count) nextInt = 0;
            Vector3 next = patrolPoints[nextInt].position;

            float times = subdivisionsPerMeter * Vector3.Distance(current, next);
            for (int s=0; s<times; s++)
            {
                subdivided.Add(Vector3.Lerp(current, next, s / times));
            }
        }
    }


    private void OnDrawGizmos()
    {
        Gizmos.color = Color.cyan;
        for (int i = 0; i < patrolPoints.Count; i++)
        {
            Gizmos.DrawWireSphere(patrolPoints[i].position, 0.1f);
            int next = i + 1;
            if (next >= patrolPoints.Count) next = 0;
            Gizmos.DrawLine(patrolPoints[i].position, patrolPoints[next].position);
        }
        Gizmos.color = Color.yellow;
        for (int i = 0; i < subdivided.Count; i++)
        {
            Gizmos.DrawWireSphere(subdivided[i], 0.1f);
            int next = i + 1;
            if (next >= patrolPoints.Count) next = 0;
        }

        Gizmos.color = Color.red;
        List<Vector3> sorted = subdivided.OrderBy(i => Vector3.Distance(i, compare)).ToList();//using Linq

        Vector3 left = sorted[0];
        Vector3 right = sorted[1];
        Vector3 size = Vector3.one * 0.1f;
        Gizmos.DrawWireCube(left, size);
        Gizmos.DrawWireCube(right, size);
        Gizmos.DrawWireCube(compare, size);

        Gizmos.color = Color.magenta;
        Gizmos.DrawWireCube(NearestPoint(compare), size);

    }

    public List<Transform> points { get => patrolPoints; }
    public List<Vector3> PointLocs
    {
        get
        {
            List<Vector3> o = new List<Vector3>();
            for (int i = 0; i < patrolPoints.Count; i++)
            {
                o.Add(patrolPoints[i].position);
            }
            return o;
        }
    }
    public List<Vector3> Subdivided { get => subdivided; }

    [SerializeField, Range(0,10)] private float subdivisionsPerMeter = 2;
    public Vector3 compare;
    [SerializeField, Range(0,10)] private float nearestPointSubdivisions = 1;

    public Vector3 NearestPoint(Vector3 compare)
    {
        this.compare = compare;
        List<Vector3> sorted = subdivided.OrderBy(i => Vector3.Distance(i, compare)).ToList();//using Linq

        Vector3 left = sorted[0];
        Vector3 right = sorted[1];

        //Vector3 offset = right - left;
        //Vector3 compOff = compare - left;

        ////Now 'left' is at the orgin
        //Vector3 center3 = ((offset + compOff) / 3) + left;
        //Vector3 center2 = (offset / 2) + left;


        List<Vector3> nearPoints = new List<Vector3>();
        float iterations = nearestPointSubdivisions * Vector3.Distance(left, right);
        for (int i = 0; i < iterations; i++)
        {
            nearPoints.Add(Vector3.Lerp(left, right, i / iterations));
        }
        nearPoints = nearPoints.OrderBy(i => Vector3.Distance(i, compare)).ToList();//using Linq

        return nearPoints[0];
    }
}
