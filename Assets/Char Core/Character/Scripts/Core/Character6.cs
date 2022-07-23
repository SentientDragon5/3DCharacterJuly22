using System;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Events;
using System.Linq;
using UnityEngine.AI;

namespace Character
{
	[RequireComponent(typeof(Actor))]
	[RequireComponent(typeof(Animator))]
	[RequireComponent(typeof(Rigidbody))]
	[RequireComponent(typeof(CapsuleCollider))]
	[AddComponentMenu("Character/Movables/HumanoidBaseMovement")]
	public class Character6 : Moveable, ICharacter
	{
		#region components
		Animator animator; // The animator for the character
		CapsuleCollider capsuleCollider;
		Rigidbody rigidBody;
		NavMeshAgent agent;
		public Actor Actor
        {
            get
            {
				return GetComponent<Actor>();
			}
        }
		#endregion

		#region Animation Parameters
		// animator parameters:
		readonly int animatorForward = Animator.StringToHash("Forward");
		readonly int animatorRight = Animator.StringToHash("Right");
		readonly int animatorTurn = Animator.StringToHash("Turn");
		readonly int animatorCrouch = Animator.StringToHash("Crouch");
		readonly int animatorOnGround = Animator.StringToHash("OnGround");
		readonly int animatorJump = Animator.StringToHash("Jump");
		readonly int animatorJumpLeg = Animator.StringToHash("JumpLeg");
		readonly int animatorCapsuleY = Animator.StringToHash("CapsuleY");

		// animator animations:
		readonly int animatorGrounded = Animator.StringToHash("Base Layer.Grounded.Grounded");

		readonly int animatorAirborne = Animator.StringToHash("Base Layer.Flying.Airborne");


		readonly int animatorStrafe = Animator.StringToHash("Base Layer.Grounded.Strafe");

		//readonly int animatorGroundedMelee = Animator.StringToHash("Base Layer.Grounded.Grounded Melee");
		//readonly int animatorAirborneMelee = Animator.StringToHash("Base Layer.Flying.Airborne Melee");

		//readonly int animatorGroundedRanged = Animator.StringToHash("Base Layer.Grounded.Grounded Ranged");
		//readonly int animatorAirborneRanged = Animator.StringToHash("Base Layer.Flying.Airborne Ranged");

		//readonly int animatorGroundedAiming = Animator.StringToHash("Base Layer.Grounded.Grounded Ranged Aim");
		//readonly int animatorAirborneAiming = Animator.StringToHash("Base Layer.Flying.Airborne Aim");

		//readonly int animatorSliding = Animator.StringToHash("Base Layer.Grounded.Sliding");
		#endregion

		#region Inspector Declarations
		[SerializeField] private float JumpPower = 6;
		[SerializeField] private float airSpeed = 5f;//overide for gliding?
		[SerializeField] private float fallSpeed = 5f;//overide for gliding?
		[SerializeField] private float gravityMultiplier = 2f; // times Physics.gravity

		[SerializeField] private float airControl = 2;
		[SerializeField] private float stationaryTurnSpeed = 180f;
		[SerializeField] private float movingTurnSpeed = 360f;
		[SerializeField] private float runCycleOffset = 0.2f;

		[SerializeField] private LayerMask snapLayers = 1;// -1 = all
		[SerializeField] private float snapDistance = 1f;
		[SerializeField] private float minVelocityToMove = 0.1f; //prevent drift.

		[SerializeField] private float groundDotProduct = 0.5f;//0 to 0.5

		[SerializeField] private float skinWidth = 0.1f;//the distance for the checking collisions and snapping and such
		#endregion

		#region Declarations
		// to determine whether to be active
		bool enabled = true;

		// Variables passed from the controller to the character.
		Vector3 moveInput;
		bool crouch;
		bool jump;
		float extraTurnAmount;//for rotate.

		// amounts for movement
		float turnAmount;
		float forwardAmount;
		float rightAmount;

		// storing values for jumping or falling
		Vector3 airVelocity;
		bool jumpPressed = false;
		float jumpStartedTime = -1;

		// this is for determining wheter to write to the animator
		bool firstAnimatorFrame = true;

		// this is the curve that determines whether when up against a wall the
		// character can walk right into it
		// used in constraints
		private AnimationCurve wallSneakDotCurve = AnimationCurve.Linear(0, 0, 1, 1);

		// use this to find the direction to jump off a slope
		Vector3 contactNormal;

		// Contact data isnt actually ever used in this code yet, only the count
		// of the contacts. I store it if i need it in the future. Feel free to
		// remove it if you don't want it.

		// ground is anything with a dot product (cosTheta) of less than 0.5, or 45 degrees.
		// this value can be changed in the inspector as ground dot product
		List<ContactData> groundContacts = new List<ContactData>();
		// I havent decided to remove these because in essence this is whether it is touching ground
		/// <summary> Use Grounded to get whether the character is on the ground. This returns whether the character TOUCHING the ground.</summary>
		public bool TouchingGround => groundContacts.Count > 0;
		//A "Steep" is anything that isnt walkable but is under the player.
		List<ContactData> steepContacts = new List<ContactData>();
		public bool TouchingSteep => steepContacts.Count > 0;
		//Not implemented yet.
		List<ContactData> climbContacts = new List<ContactData>();
		public bool TouchingWall => climbContacts.Count > 0;
		#endregion


		public event System.Action OnGround;


		public override bool WantsActive
		{
			get
			{
				return true;
			}
		}
		public CapsuleCollider simpleCollider;
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
					simpleCollider.enabled = value;
				}
				colliderActivec = value;
			}
		}

		void Awake()
		{
			animator = GetComponent<Animator>();
			capsuleCollider = GetComponent<CapsuleCollider>();
			rigidBody = GetComponent<Rigidbody>();
			agent = GetComponent<NavMeshAgent>();
		}
		private void OnValidate()
		{
			Awake();
		}

		//Remove and make OnAnimatorMove be Lateupdate instead?
		private void LateUpdate()
		{
			//moveInput = Vector3.zero;
			//jump = false;
			//crouch = false;
			//extraTurnAmount = 0f;
		}

		#region IBz

		public void CharacterEnable(bool enable)
		{
			if (enabled == enable)
				return;
			enabled = enable;
			

			capsuleCollider.enabled = enable;
			//rigidBody.isKinematic = !enable;//doing in the Usercharacter script
			if (enable)
				firstAnimatorFrame = true;
		}
		public void Ragdoll()
        {
			if(TryGetComponent(out Ragdoll ragdoll))
            {
				ragdoll.EnterRagdoll();
            }
        }

		/// <summary>
        /// 
        /// </summary>
        /// <param name="move"></param>
        /// <param name="extra">0: jump, 1: crouch</param>
		public override void Move(Vector3 move, bool[] extra)
		{
			moveInput = move;
			if(extra.Length > 0)
				this.jump = extra[0];
			if (extra.Length > 1)
				this.crouch = extra[1];
			Debug.Log(gameObject.name + " " + moveInput + " " + IsActive);
		}
		//Degrees around y axis
		public void Rotate(float degrees)
		{
			extraTurnAmount = degrees;
		}
		#endregion

		void ApplyCapsuleHeight()
		{
			float capsuleY = animator.GetFloat(animatorCapsuleY);
			capsuleCollider.height = capsuleY;
			var c = capsuleCollider.center;
			c.y = capsuleY / 2f;
			capsuleCollider.center = c;
		}

		void UpdatePlayerPosition(Vector3 deltaPos)
		{
			Vector3 finalVelocity = deltaPos / Time.deltaTime;

			if (!jumpPressed)
			{
				finalVelocity.y = rigidBody.velocity.y;
			}
			airVelocity = finalVelocity;       // i need this to correctly detect player velocity in air mode
			//finalVelocity += NetForce() * Time.deltaTime;
			//CONNECTION RB STUFF
			float dTime = Time.deltaTime;
			rigidBody.velocity = finalVelocity;// + NetForceDeltaVelocity(dTime);
			//Debug.Log(NetForceDeltaVelocity(dTime));
			///this is the last thing that happens. the rigidbody is applying the motion.
		}

		public Vector3 CharacterVelocity
		{
			get
			{
				return Grounded ? rigidBody.velocity : airVelocity;
			}
		}

		private void HandleGroundedVelocities(int currentAnimation)
		{
			bool animationGrounded = currentAnimation == animatorGrounded || currentAnimation == animatorStrafe;

			// check whether conditions are right to allow a jump
			if (!(jump & !crouch & animationGrounded))
				return;

			// jump!
			airVelocity = CharacterVelocity + contactNormal * JumpPower;
			jump = false;
			jumpPressed = true;
			jumpStartedTime = Time.time;

			//Swap from grounded anim to air anim.
			animator.CrossFade(animatorAirborne, 0.1f, 0);//ADD

		}

		private void UpdateAnimator()
		{
			// Here we tell the animator what to do based on the current states and inputs.

			// update the animator parameters
			animator.SetFloat(animatorForward, forwardAmount, 0.1f, Time.deltaTime);
			animator.SetFloat(animatorRight, rightAmount, 0.1f, Time.deltaTime);
			animator.SetFloat(animatorTurn, turnAmount, 0.1f, Time.deltaTime);
			animator.SetBool(animatorOnGround, Grounded);
			if (!Grounded) // if flying
			{
				animator.SetFloat(animatorJump, CharacterVelocity.y);
			}
			else
			{
				// calculate which leg is behind, so as to leave that leg trailing in the jump animation
				// (This code is reliant on the specific run cycle offset in our animations,
				// and assumes one leg passes the other at the normalized clip times of 0.0 and 0.5)
				float runCycle = Mathf.Repeat(
						animator.GetCurrentAnimatorStateInfo(0).normalizedTime + runCycleOffset, 1);

				float jumpLeg = (runCycle < 0.5f ? 1 : -1) * forwardAmount;
				animator.SetFloat(animatorJumpLeg, jumpLeg);
			}
		}

		private void ConvertMoveInput()
		{
			Debug.Log(gameObject.name + " " + moveInput);
			// convert the world relative moveInput vector into a local-relative
			// turn amount and forward amount required to head in the desired
			// direction. 
			Vector3 localMove = transform.InverseTransformDirection(moveInput);
			if ((Math.Abs(localMove.x) > float.Epsilon) &
				(Math.Abs(localMove.z) > float.Epsilon))
				turnAmount = Mathf.Atan2(localMove.x, localMove.z) + Mathf.Deg2Rad * extraTurnAmount;
			else
				turnAmount = 0f;

			forwardAmount = localMove.z;
			forwardAmount = Constrain(forwardAmount, false);
			rightAmount = localMove.x;
			rightAmount = Constrain(rightAmount, true);
			//Debug.Log(forwardAmount + " " + rightAmount);
		}

		private void ApplyExtraTurnRotation(int currentAnimation)
		{
			if (currentAnimation != animatorGrounded)
				return;

			// help the character turn faster (this is in addition to root rotation in the animation)
			float turnSpeed = Mathf.Lerp(stationaryTurnSpeed, movingTurnSpeed, forwardAmount);
			transform.Rotate(0, (turnAmount + Mathf.Deg2Rad * extraTurnAmount) * turnSpeed * Time.deltaTime, 0);
		}

		private void HandleAirborneVelocities()
		{
			Vector3 airMove = new Vector3(moveInput.x * airSpeed, airVelocity.y, moveInput.z * airSpeed);
			airVelocity = Vector3.Lerp(airVelocity, airMove, Time.deltaTime * airControl);
			airVelocity = new Vector3(airVelocity.x, Mathf.Max(airVelocity.y, -1 * Mathf.Abs(fallSpeed)), airVelocity.z);
		}

		void FixedUpdate()
		{
			if (!IsActive)
				return;
			//if(!GetComponent<IController>().SimpleColliderActive)
			//	GetComponent<IController>().SimpleColliderActive = true;
			//if (GetComponent<IController>().RagdollCollidersActive)
			//	GetComponent<IController>().RagdollCollidersActive = false;

			GetCollisions(skinWidth);

			animator.SetBool(animatorCrouch, crouch);
			int currentAnimation = animator.GetCurrentAnimatorStateInfo(0).fullPathHash;

			ApplyCapsuleHeight();
			ConvertMoveInput();             // converts the relative move vector into local turn & fwd values
			ApplyExtraTurnRotation(currentAnimation);       // this is in addition to root rotation in the animations//moved from above convert

			// control and velocity handling is different when grounded and airborne:
			if (Grounded)
				HandleGroundedVelocities(currentAnimation);
			else
				HandleAirborneVelocities();

			UpdateAnimator(); // send input and other state parameters to the animator

		}

		void OnAnimatorMove()
		{
			if (!IsActive) return; //THIS MAY NEED TO BE REMOVED. I ADDED DURING SWIMMER

			if (Time.deltaTime < Mathf.Epsilon)
				return;

			Vector3 deltaPos;
			Vector3 deltaGravity = Physics.gravity * gravityMultiplier * Time.deltaTime;
			airVelocity += deltaGravity;

			if (Grounded)
			{
				deltaPos = animator.deltaPosition;
				deltaPos.y -= 5f * Time.deltaTime;
			}
			else
			{
				deltaPos = airVelocity * Time.deltaTime;
			}

			if (firstAnimatorFrame)
			{
				// if Animator just started, Animator move character
				// so you need to zeroing movement
				deltaPos = new Vector3(0f, deltaPos.y, 0f);
				firstAnimatorFrame = false;
			}


			Vector3 deltaPosFinal = deltaPos;
			//if (!jumpPressed && Grounded)
			//	deltaPosFinal += Snap(deltaPos);
			UpdatePlayerPosition(deltaPosFinal);

			// apply animator rotation
			transform.rotation *= animator.deltaRotation;
			jumpPressed = false;
		}


		#region Ground Check
		bool ground;
		public bool Grounded
		{
			get
			{
				bool output = (groundContacts.Count > 0 && ((jumpStartedTime + 0.5f < Time.time) || snapping)) || (agent != null && agent.isOnNavMesh);
				if (!ground && output)
                {
					if (OnGround != null)
						OnGround();
                }
				return output;
			}
		}


		void GetCollisions(float skinWidth)
		{
			float radius = capsuleCollider.radius;
			float height = capsuleCollider.height;
			Vector3 s1 = transform.position + Vector3.up * radius;
			Vector3 s2 = transform.position + Vector3.up * (height - radius);
			RaycastHit[] hits;

			hits = Physics.CapsuleCastAll(s1, s2, radius + skinWidth, Vector3.down, skinWidth, snapLayers, QueryTriggerInteraction.Ignore);//RAYCAST DISTANCWE OF SKIN WIDTH NOT ZERO! IT WORKED!


			// if collision comes from botton, that means
			// that character on the ground
			float charBottom =
				transform.position.y +
				capsuleCollider.center.y - capsuleCollider.height / 2 +
				capsuleCollider.radius * 0.8f;


			groundContacts.Clear();
			steepContacts.Clear();
			climbContacts.Clear();

			for (int i = 0; i < hits.Length; i++)
			{
				RaycastHit hit = hits[i];
				float dot = Vector3.Dot(Vector3.up, hit.normal);

				if (hit.point.y < charBottom && !hit.collider.transform.IsChildOf(transform))
				{
					if (dot > groundDotProduct)
						groundContacts.Add(ContactData.Convert(hit));
					else
						steepContacts.Add(ContactData.Convert(hit));
				}

				if (hit.point.y < charBottom && !hit.collider.transform.IsChildOf(transform))
				{
					Debug.DrawRay(hit.point, hit.normal, Color.blue);
				}
			}

			//find the ground normal
			RaycastHit normalFinder;
			if (Physics.Raycast(s1, Vector3.down, out normalFinder, skinWidth + radius, snapLayers, QueryTriggerInteraction.Ignore))
				contactNormal = normalFinder.normal;
			else
				contactNormal = Vector3.up;
		}


		private void OnDrawGizmos()
		{
			float radius = capsuleCollider.radius;
			float height = capsuleCollider.height;
			Vector3 s1 = transform.position + Vector3.up * radius;
			Vector3 s2 = transform.position + Vector3.up * (height - radius);
			Gizmos.DrawWireSphere(s1, radius);
			Gizmos.DrawWireSphere(s2, radius);
			Gizmos.color = new Color(1f, 0.75f, 0f);
			Gizmos.DrawWireSphere(s1, radius + skinWidth);
			Gizmos.DrawWireSphere(s2, radius + skinWidth);
		}

		//Constrain forward.
		float Constrain(float mag, bool right)
		{
			float constraintDistance = skinWidth;

			float radius = capsuleCollider.radius;
			float height = capsuleCollider.height;
			Vector3 s1 = transform.position + Vector3.up * radius;
			Vector3 s2 = transform.position + Vector3.up * (height - radius);

			float percentUp = 0.5f;// (The midpoint)
			Vector3 castPoint = Vector3.Lerp(s1, s2, percentUp);

			//cast from the chest bc if there is a slope then it would false trigger
			RaycastHit hit;
			if (Physics.Raycast(castPoint, right ? transform.right : transform.forward, out hit, constraintDistance + radius, snapLayers, QueryTriggerInteraction.Ignore))
			{
				float dist = hit.distance - (radius + constraintDistance);
				float dot = Vector3.Dot(Vector3.ProjectOnPlane(hit.normal, Vector3.up), transform.forward);
				mag = Mathf.Lerp(mag, 0, wallSneakDotCurve.Evaluate(-dot));

				Debug.DrawRay(castPoint, right ? transform.right : transform.forward, Color.magenta);
			}
			return mag;
		}

		#endregion

		#region Snap
		bool snapping = false;
		public Vector3 Snap(Vector3 deltaPos)
		{
			snapping = false;
			Vector3 snapDeltaPos = Vector3.zero;
			Vector3 castPoint = transform.position + deltaPos + Vector3.up * skinWidth;

			RaycastHit hit;
			if (Physics.Raycast(castPoint, Vector3.down, out hit, snapDistance, snapLayers, QueryTriggerInteraction.Ignore))
			{
				snapDeltaPos = hit.point - transform.position - deltaPos;
				snapping = true;
			}
			Debug.DrawRay(castPoint, Vector3.down * snapDistance, snapping ? Color.cyan : Color.red);

			Debug.Log(snapDeltaPos);
			return snapDeltaPos;
		}

		public float DistanceFromGround()
		{
			float maxDist = 20;
			float dist = maxDist;
			Vector3 castPoint = transform.position;

			RaycastHit hit;
			if (Physics.Raycast(castPoint, Vector3.down, out hit, maxDist, snapLayers, QueryTriggerInteraction.Ignore))
			{
				dist = hit.distance;
			}
			return dist;
		}
		#endregion


	}

	[System.Serializable]
	public class ContactData
	{
		public Vector3 point;
		public Vector3 normal;

		public ContactData(Vector3 _point, Vector3 _normal)
		{
			point = _point;
			normal = _normal;
		}

		public static ContactData Convert(ContactPoint contact)
		{
			return new ContactData(contact.point, contact.normal);
		}
		public static ContactData Convert(RaycastHit hit)
		{
			return new ContactData(hit.point, hit.normal);
		}
	}
}