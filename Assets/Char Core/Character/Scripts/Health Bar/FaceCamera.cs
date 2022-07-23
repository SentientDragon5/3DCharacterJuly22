using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class FaceCamera : MonoBehaviour
{
    public Transform face;

    private void Start()
    {
        face = Camera.main.transform;
    }

    private void FixedUpdate()
    {
        transform.LookAt(face);
    }
}
