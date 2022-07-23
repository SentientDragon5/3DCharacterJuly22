using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.InputSystem;
using Character.Combat;
using Character.Interactions;
using Character.Riding;

namespace Character
{
    [AddComponentMenu("Character/BaseController")]
    public class Controller : MonoBehaviour
    {
        public virtual bool Aiming { get; }
        //public bool Grounded { get; }
        public virtual Vector3 target { get; }
        /// <summary>
        /// ordered by priority. ex: normal movment is at bottom (0).
        /// </summary>
        [Tooltip("ordered by priority. ex: normal movment is at bottom.")]
        public List<Moveable> moveTypes = new List<Moveable>();
        public int moveType = 0;

        public Actor actor;
        public Animator animator;
        public Combatant combatant;
        public Health health;
        public Interactor interactor;

        protected virtual void Awake()
        {

            DisableColliders();
            for (int j = moveTypes.Count - 1; j >= 0; j--)
            {
                moveTypes[j].IsActive = j == moveType;
            }
        }

        public void Shoot()
        {
            if(combatant != null)
                combatant.Attack();
        }
        public void Interact()
        {
            if (interactor != null)
                interactor.Interact();
        }

        public bool Grounded
        {
            get
            {
                return GetComponent<ICharacter>().Grounded;
            }
        }
        public void DisableColliders()
        {
            foreach (Moveable moveable in moveTypes)
            {
                moveable.ColliderActive = false;
                moveable.IsActive = false;
            }
        }
        public bool IsDead
        {
            get
            {
                if (health != null)
                    return health.IsDead;
                else
                    return false;
            }
        }
        /// <summary>
        /// Will shift between moveTypes and send input to resulting moveType. FOR PLAYER CHARACTERS
        /// </summary>
        /// <param name="input"></param>
        /// <param name="extraMove"></param>
        public void Move(Vector2 input, bool[] extraMove)
        {
            UpdateMoveType();
            moveTypes[moveType].Input(input, extraMove);
        }
        /// <summary>
        /// FOR AI
        /// </summary>
        /// <param name="move"></param>
        /// <param name="extraMove"></param>
        public void Move(Vector3 move, bool[] extraMove)
        {
            UpdateMoveType();
            // Debug.Log(gameObject.name + " " + move);
            moveTypes[moveType].Move(move, extraMove);
        }

        private void UpdateMoveType()
        {
            int newMoveType = 0;//Set it to default so if no other wants to be active then normal.
            for (int i = moveTypes.Count - 1; i >= 0; i--)
            {
                if (moveTypes[i].WantsActive)
                {
                    newMoveType = i;
                    break;
                }
            }

            if (newMoveType != moveType)
            {
                DisableColliders();
                for (int i = moveTypes.Count - 1; i >= 0; i--)
                {
                    moveTypes[i].IsActive = i == newMoveType;
                }
                moveTypes[moveType].OnExitState();
                moveType = newMoveType;
                moveTypes[moveType].OnEnterState();

            }
        }

        //public bool SimpleColliderActive { get; set; }
        //public bool RagdollCollidersActive { get; set; }
    }
}