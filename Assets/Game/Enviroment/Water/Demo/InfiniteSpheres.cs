using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class InfiniteSpheres : MonoBehaviour
{
    public GameObject Sphere;
    GameObject mySphere;
    public Vector3 pos = new Vector3(110,8,50);
    public float killHeight = 1f;

    void Start()
    {
        mySphere = Instantiate(Sphere, pos, Quaternion.identity, transform);
    }

    void Update()
    {
        if(mySphere.transform.position.y < killHeight)
        {
            DestroyImmediate(mySphere);
            Start();
        }
    }
}
