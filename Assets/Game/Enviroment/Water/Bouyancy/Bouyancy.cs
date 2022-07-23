using System.Collections;
using System.Collections.Generic;
using UnityEngine;


public enum WaterState { Underwater, Floating, NotInWater};
public class Bouyancy : MonoBehaviour
{
	public WaterState state = WaterState.NotInWater;
	[SerializeField]
	float submergenceOffset = 0f;

	[SerializeField][Tooltip("Negitive Values Sink, Positive Values Float")]
	float buoyancy = 0.1f;

	[SerializeField]
	Vector3 buoyancyCenter = Vector3.zero;

	[SerializeField, Range(0f, 10f)]
	float waterDrag = 1f;

	[SerializeField]
	LayerMask waterMask = 0;

	Rigidbody body;
	float depth;

	[SerializeField]
	float currentAffect = 1000;
	Vector3 waterCurrent;

	void Awake()
	{
		body = GetComponent<Rigidbody>();
		body.useGravity = false;
	}

	void FixedUpdate()
	{
		CheckDepth();
		if(state == WaterState.Underwater)
        {
			body.AddForce(waterCurrent, ForceMode.Acceleration);

			float drag = Mathf.Max(0f, 1f - waterDrag * Time.deltaTime);
			body.velocity *= drag;
			body.angularVelocity *= drag;
			body.AddForceAtPosition(Physics.gravity * -(buoyancy * (depth + 1)), transform.TransformPoint(buoyancyCenter), ForceMode.Acceleration);

			body.AddForce(Physics.gravity, ForceMode.Acceleration);
		}
        else if(state == WaterState.Floating)
        {
			body.AddForce(waterCurrent, ForceMode.Acceleration);

			float drag = Mathf.Max(0f, 1f - waterDrag * Time.deltaTime);
			body.velocity *= drag;
			body.angularVelocity *= drag;
		}
        else
        {
			body.AddForce(Physics.gravity, ForceMode.Acceleration);
		}
	}

	void CheckDepth()
    {
		Debug.DrawRay(body.position + Vector3.down * submergenceOffset, Vector3.up * 50);
		if (Physics.Raycast(body.position + Vector3.down * submergenceOffset, Vector3.up, out RaycastHit hit, 50, waterMask, QueryTriggerInteraction.Collide))
		{
			depth = hit.distance - submergenceOffset;

			waterCurrent = new Vector3(hit.normal.x * -currentAffect, 0, hit.normal.z * -currentAffect);
			if(depth > 0.1)
            {
				state = WaterState.Underwater;
            }
            else
            {
				state = WaterState.Floating;
            }
		}
		else
		{
			state = WaterState.NotInWater;
		}
	}
}
