using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BulletController : MonoBehaviour
{
    [SerializeField] private GameObject bulletDecal;
    [SerializeField] private float speed = 50;
    [SerializeField] private float maxLifetime = 3f;
    [SerializeField] private float trailTime = 3f;
    [SerializeField] private float damage = 1f;
    public float gunDamage = 1;

    public Vector3 target { get; set; }
    public bool hit { get; set; }
    

    UnityEngine.VFX.VisualEffect vfx;
    Rigidbody rigidbody;
    float startTime;

    private void OnEnable()
    {
        rigidbody = GetComponent<Rigidbody>();
        startTime = Time.time;
        Destroy(gameObject, maxLifetime + trailTime);
        //vfx = GetComponent<UnityEngine.VFX.VisualEffect>();

        //vfx.SetVector3("Target", transform.position);
    }

    void Update()//FixedUpdate instead?
    {
        transform.position = Vector3.MoveTowards(transform.position, target, speed * Time.deltaTime);
        if(!hit && Vector3.Distance(transform.position, target) < .01f)
        {
            StartCoroutine(WaitForTrail());
        }
        if(rigidbody.velocity.sqrMagnitude < 0.1f && Time.time - startTime > 0.25f)
        {
            StartCoroutine(WaitForTrail());
        }
    }

    private void OnCollisionEnter(Collision collision)
    {
        ContactPoint c = collision.GetContact(0);
        if(collision.gameObject.TryGetComponent(out Character.Health health))
        {
            health.HP = health.HP - Mathf.RoundToInt(damage * gunDamage);
        }
        Instantiate(bulletDecal, c.point + c.normal * 0.01f, Quaternion.LookRotation(c.normal));
        StartCoroutine(WaitForTrail());
    }

    IEnumerator WaitForTrail()
    {
        yield return new WaitForSeconds(trailTime);
        Destroy(gameObject);
    }

}
