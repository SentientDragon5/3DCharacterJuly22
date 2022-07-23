using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace Character
{
    public interface ICharacter
    {
        public Actor Actor { get; }
        public void Move(Vector3 move, bool[] extra);
        public void Rotate(float degrees);
        public Vector3 CharacterVelocity { get; }
        public bool Grounded { get; }
        public void Ragdoll();
        public void CharacterEnable(bool enable);

    }
}