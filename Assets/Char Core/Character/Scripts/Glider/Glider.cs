using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.InputSystem;

namespace Character
{

    [AddComponentMenu("Character/Movables/Glider")]
    public class Glider : Moveable
	{
		#region components
		Animator animator; // The animator for the character
		Rigidbody rigidBody;
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
		readonly int animatorAirborne = Animator.StringToHash("Base Layer.Flying.Airborne");
		readonly int animatorGliding = Animator.StringToHash("Base Layer.Flying.Glider");
		#endregion

		#region Inspector Declarations
		[SerializeField] private float airSpeed = 10f;//overide for gliding?
		[SerializeField] private float fallSpeed = 1f;//overide for gliding?
		[SerializeField] private float gravityMultiplier = 0.1f; // times Physics.gravity

		[SerializeField] private float airControl = 5;
		[SerializeField] private float stationaryTurnSpeed = 90f;
		[SerializeField] private float movingTurnSpeed = 180f;

		[SerializeField] private LayerMask groundLayer = 1;// -1 = all

		[SerializeField] private float minDistFromGround = 1;
		[SerializeField] private InputActionReference glideToggle;
		#endregion

		#region Declarations

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

		#endregion


		public event System.Action OnGround;

		public bool toggleWant;

		public override bool WantsActive
		{
			get
			{
				if (GetComponent<Character6>().Grounded)
					return false;
				if (glideToggle.action.triggered)
					toggleWant = !toggleWant;
				// In the future, make it its own InputSystem.InputAction in the asset, then get ref to that.
				/*bool[] e = GetComponent<UserCharacter1>().ExtraInput;
				if(e.Length >= 7)
                {
					if(e[6])
						toggleWant = !toggleWant;
				}
				*/
				if (DistanceFromGround() < minDistFromGround)
					toggleWant = false;

				Debug.Log(toggleWant);
				return toggleWant;
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
			rigidBody = GetComponent<Rigidbody>();
		}
		private void OnValidate()
		{
			animator = GetComponent<Animator>();
			rigidBody = GetComponent<Rigidbody>();
		}

		private void LateUpdate()
		{
			moveInput = Vector3.zero;
			jump = false;
			crouch = false;
			extraTurnAmount = 0f;
		}

		#region IBz

		/// <summary>
		/// 
		/// </summary>
		/// <param name="move"></param>
		/// <param name="extra">0: jump, 1: crouch</param>
		public override void Move(Vector3 move, bool[] extra)
		{
			moveInput = move;
			if (extra.Length > 0)
				this.jump = extra[0];
			if (extra.Length > 1)
				this.crouch = extra[1];
		}
		//Degrees around y axis
		public void Rotate(float degrees)
		{
			extraTurnAmount = degrees;
		}
		#endregion

		void UpdatePlayerPosition(Vector3 deltaPos)
		{
			Vector3 finalVelocity = deltaPos / Time.deltaTime;

			if (!jumpPressed)
			{
				finalVelocity.y = rigidBody.velocity.y;
			}
			airVelocity = finalVelocity;       // i need this to correctly detect player velocity in air mode
			finalVelocity = new Vector3(finalVelocity.x, 0, finalVelocity.z);
			//CONNECTION RB STUFF
			rigidBody.velocity = finalVelocity;
			///this is the last thing that happens. the rigidbody is applying the motion.
		}

		public Vector3 CharacterVelocity
		{
			get
			{
				return airVelocity;
			}
		}


		private void UpdateAnimator()
		{
			// Here we tell the animator what to do based on the current states and inputs.
			if(animator.GetCurrentAnimatorStateInfo(0).fullPathHash != animatorGliding)
            {
				animator.CrossFade(animatorGliding, 0.1f);
            }
			// update the animator parameters
			animator.SetFloat(animatorForward, forwardAmount, 0.1f, Time.deltaTime);
			animator.SetFloat(animatorRight, rightAmount, 0.1f, Time.deltaTime);
			animator.SetFloat(animatorTurn, turnAmount, 0.1f, Time.deltaTime);
			animator.SetBool(animatorOnGround, false);
			animator.SetFloat(animatorJump, CharacterVelocity.y);
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
			rightAmount = localMove.x;
			//Debug.Log(forwardAmount + " " + rightAmount);
		}

		private void ApplyExtraTurnRotation(int currentAnimation)
		{
			//if (currentAnimation != animatorGrounded) return;

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

			animator.SetBool(animatorCrouch, crouch);
			int currentAnimation = animator.GetCurrentAnimatorStateInfo(0).fullPathHash;

			ConvertMoveInput();             // converts the relative move vector into local turn & fwd values
			ApplyExtraTurnRotation(currentAnimation);       // this is in addition to root rotation in the animations//moved from above convert

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

			deltaPos = airVelocity * Time.deltaTime;

			if (firstAnimatorFrame)
			{
				// if Animator just started, Animator move character
				// so you need to zeroing movement
				deltaPos = new Vector3(0f, deltaPos.y, 0f);
				firstAnimatorFrame = false;
			}


			Vector3 deltaPosFinal = deltaPos;
			UpdatePlayerPosition(deltaPosFinal);

			// apply animator rotation
			transform.rotation *= animator.deltaRotation;
			jumpPressed = false;
		}

		public float DistanceFromGround()
		{
			float maxDist = 10000;
			float dist = maxDist;
			Vector3 castPoint = transform.position;

			RaycastHit hit;
			if (Physics.Raycast(castPoint, Vector3.down, out hit, maxDist, groundLayer, QueryTriggerInteraction.Ignore))
			{
				dist = hit.distance;
			}
			return dist;
		}
	}
}