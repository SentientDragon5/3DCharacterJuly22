using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ExitToOriginalController : StateMachineBehaviour
{
    public override void OnStateExit(Animator animator, AnimatorStateInfo stateInfo, int layerIndex)
    {
        if(animator.gameObject.TryGetComponent(out Character.Interactions.Interactor i))
        {
            i.SwitchToOriginal();
        }
    }
}
