using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ExplosiveTrigger : MonoBehaviour
{
    public GameObject ExplosionPrefab;

    public string characterTag = "Character";
    public bool onTrigger = true;
    private void OnTriggerEnter(Collider other)
    {
        if (other.transform.CompareTag(characterTag))
            Instantiate(ExplosionPrefab, transform);
    }
    public bool onCollision = true;
    private void OnCollisonEnter(Collision other)
    {
        if(other.transform.CompareTag(characterTag))
            Instantiate(ExplosionPrefab, transform);
    }

    public float periodic = 1;
    float last = 0;
    private void FixedUpdate()
    {
        if(periodic > 0.09f && Time.time - last > periodic)
        {
            Instantiate(ExplosionPrefab, transform);
            last = Time.time;
        }
    }
    
}
