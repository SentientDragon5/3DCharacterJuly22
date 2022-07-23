using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System.Linq;

namespace Character
{
	public class Swimmer : Moveable
	{
		Animator animator; // The animator for the character
		CapsuleCollider capsuleCollider;
		Rigidbody rigidBody;


		readonly int animatorForward = Animator.StringToHash("Forward");
		readonly int animatorRight = Animator.StringToHash("Right");
		readonly int animatorTurn = Animator.StringToHash("Turn");
		readonly int animatorSwim = Animator.StringToHash("Swimming");


		readonly int animatorSwiming = Animator.StringToHash("Base Layer.Swimming.Swimming");
		readonly int animatorDashing = Animator.StringToHash("Base Layer.Swimming.Dash");

		[SerializeField] private float moveSpeed = 1f;
		[SerializeField] private float stationaryTurnSpeed = 180f;
		[SerializeField] private float movingTurnSpeed = 360f;

		[SerializeField] private float yOffset = -0.4f;

		public LayerMask waterLayer = 5;
		[SerializeField] private LayerMask enviromentLayer = 1;// -1 = all

		public bool Active
		{
			get
			{
				return IsUnderwater();
			}
		}

		Vector3 hitPoint = Vector3.zero;
		Vector3 normal = Vector3.up;
		Vector3 moveInput = Vector3.forward;
		bool dash;
		bool swimming;

		float extraTurnAmount;//for rotate.

		// amounts for movement
		float turnAmount;
		float forwardAmount;
		float rightdAmount;

		// this is for determining wheter to write to the animator
		bool firstAnimatorFrame = true;

		public float raycastHeight = 0.5f;


		public override bool WantsActive
		{
			get
			{
				return IsUnderwater();
			}
		}
		public CapsuleCollider swimmingCollider;
		bool colliderActivec = false;
		public override bool ColliderActive
		{
			get
			{
				return colliderActivec;
			}
			set
			{
				if (colliderActivec != value)
				{
					swimmingCollider.enabled = value;
				}
				colliderActivec= value;
			}
		}


		void Awake()
		{
			animator = GetComponent<Animator>();
			capsuleCollider = GetComponent<CapsuleCollider>();
			rigidBody = GetComponent<Rigidbody>();
		}
		private void OnValidate()
		{
			animator = GetComponent<Animator>();
			capsuleCollider = GetComponent<CapsuleCollider>();
			rigidBody = GetComponent<Rigidbody>();
		}

		public bool IsUnderwater()
		{
			//RaycastHit[] hitArr = Physics.RaycastAll(transform.position, Vector3.up, 100f, waterLayer, QueryTriggerInteraction.Collide);
			//List<RaycastHit> hits = hitArr.ToList();
			//bool hitWater = false;
			if (Physics.Raycast(transform.position + Vector3.up * raycastHeight, Vector3.up, out RaycastHit hit, 100, waterLayer, QueryTriggerInteraction.Collide))
			{
				hitPoint = hit.point;
				normal = hit.normal;
				Debug.DrawRay(transform.position + Vector3.up * raycastHeight, Vector3.up, Color.blue);
				if(Physics.Raycast(transform.position + Vector3.up * raycastHeight, Vector3.down, raycastHeight, enviromentLayer, QueryTriggerInteraction.Ignore))
				{
					Debug.DrawRay(transform.position + Vector3.up * (raycastHeight - yOffset), Vector3.down * (raycastHeight - yOffset), Color.red);
					return false;
				}
				return true;
			}
			Debug.DrawRay(transform.position + Vector3.up * raycastHeight, Vector3.up, Color.white);
			hitPoint = transform.position;
			return false;
		}


		public override void Move(Vector3 move, bool[] extra)
		{
			moveInput = move;
			if (extra.Length > 0)
				this.dash = extra[0];
		}


		private void LateUpdate()
		{
			//Debug.Log(rigidBody.velocity);
			moveInput = Vector3.zero;
			dash = false;
			extraTurnAmount = 0f;
		}

		#region IBz
		//Degrees around y axis
		public void Rotate(float degrees)
		{
			extraTurnAmount = degrees;
		}
		#endregion


		void UpdatePlayerPosition(Vector3 deltaPos)
		{
			Vector3 finalVelocity = deltaPos / Time.deltaTime;

			bool u = IsUnderwater();
			transform.position = new Vector3(transform.position.x, hitPoint.y + yOffset, transform.position.z);

			rigidBody.velocity = finalVelocity;
			///this is the last thing that happens. the rigidbody is applying the motion.
		}

		private void UpdateAnimator()
		{
			// Here we tell the animator what to do based on the current states and inputs.

			// update the animator parameters
			animator.SetFloat(animatorForward, forwardAmount, 0.1f, Time.deltaTime);
			animator.SetFloat(animatorRight, rightdAmount, 0.1f, Time.deltaTime);
			animator.SetFloat(animatorTurn, turnAmount, 0.1f, Time.deltaTime);
			int currentAnimation = animator.GetCurrentAnimatorStateInfo(0).fullPathHash;
			if (!(currentAnimation == animatorSwiming || currentAnimation == animatorDashing))
			{
				//Debug.Log(animator.GetCurrentAnimatorStateInfo(0).fullPathHash + " " + animatorSwiming);
				//Debug.Log(animator.GetNextAnimatorClipInfo(0)[0].clip.name);// animator.GetCurrentAnimatorStateInfo(0).fullPathHash)
				animator.CrossFade(animatorSwiming, 0, 0);//?? why was 0.1 too slow?
			}

		}

		private void ConvertMoveInput()
		{
			// convert the world relative moveInput vector into a local-relative
			// turn amount and forward amount required to head in the desired
			// direction. 
			Vector3 localMove = transform.InverseTransformDirection(moveInput);
			if ((Mathf.Abs(localMove.x) > float.Epsilon) &
				(Mathf.Abs(localMove.z) > float.Epsilon))
				turnAmount = Mathf.Atan2(localMove.x, localMove.z) + Mathf.Deg2Rad * extraTurnAmount;
			else
				turnAmount = 0f;

			forwardAmount = localMove.z;
			//forwardAmount = Constrain(forwardAmount, false);//RE ADD WHEN IT WORKS
			rightdAmount = localMove.x;
			//rightdAmount = Constrain(rightdAmount, true);
		}

		private void ApplyExtraTurnRotation(int currentAnimation)
		{
			if (currentAnimation != animatorSwiming)
				return;

			// help the character turn faster (this is in addition to root rotation in the animation)
			float turnSpeed = Mathf.Lerp(stationaryTurnSpeed, movingTurnSpeed, forwardAmount);
			transform.Rotate(0, (turnAmount + Mathf.Deg2Rad * extraTurnAmount) * turnSpeed * Time.deltaTime, 0);
		}

		void FixedUpdate()
		{
			swimming = IsUnderwater();
			animator.SetBool(animatorSwim, swimming);

			if (!Active)
				return;
			//Debug.Log("GOING");
			//if (GetComponent<IController>().SimpleColliderActive)
			//	GetComponent<IController>().SimpleColliderActive = false;
			//if (GetComponent<IController>().RagdollCollidersActive)
			//	GetComponent<IController>().RagdollCollidersActive = false;


			int currentAnimation = animator.GetCurrentAnimatorStateInfo(0).fullPathHash;

			ConvertMoveInput();             // converts the relative move vector into local turn & fwd values
			ApplyExtraTurnRotation(currentAnimation);       // this is in addition to root rotation in the animations

			UpdateAnimator(); // send input and other state parameters to the animator

		}

		void OnAnimatorMove()
		{
			if (!Active)
				return;

			if (Time.deltaTime < Mathf.Epsilon)
				return;

			Vector3 deltaPos = animator.deltaPosition;

			if (firstAnimatorFrame)
			{
				// if Animator just started, Animator move character
				// so you need to zeroing movement
				//deltaPos = new Vector3(0f, deltaPos.y, 0f);
				firstAnimatorFrame = false;
			}


			Vector3 deltaPosFinal = deltaPos;
			UpdatePlayerPosition(deltaPosFinal);

			// apply animator rotation
			transform.rotation *= animator.deltaRotation;

			//Debug.Log("rot , pos " + animator.deltaRotation + " " + deltaPosFinal);
		}

	}
}