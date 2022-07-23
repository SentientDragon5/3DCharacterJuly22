using System.Collections;
using System.Collections.Generic;
using UnityEngine;
//using UnityEditor;
//using UnityEditor.Animations;
using Character.Interactions.InteractableExtras;

namespace Character.Interactions
{

    [AddComponentMenu("Interaction/Do Animation")]
    public class DoAnimationInteraction : Interactable
    {

        public override void Interact(Interactor interactor)
        {

        }

        //public override void Interact(Interactor interactor)
        //{
        //    if (onInteractor)
        //    {
        //        animator = interactor.GetComponent<Animator>();
        //    }
        //    else
        //    {
        //        animator = GetComponent<Animator>();
        //    }
        //    normal = animator.runtimeAnimatorController;
        //    normalC = (AnimatorController)normal;
        //    interactor.currentIKTasks.Clear();
        //    foreach(IKTask i in IKTasks)
        //    {
        //        interactor.currentIKTasks.Add(i);
        //    }

        //    PlayClip();
        //    animator.SetTrigger("TransitionNow");

        //    //if(tclip != null)
        //    //{
        //    //    tanimation = GetComponent<Animation>();
        //    //    tanimation.clip = tclip;
        //    //    tanimation.Play();
        //    //}
        //    //if(fclip != null)
        //    //{
        //    //    fanimation = interactor.GetComponent<Animation>();
        //    //    fanimation.enabled = true;
        //    //    fanimation.clip = fclip;
        //    //    fanimation.Play();
        //    //}
        //}
        //[Tooltip("Play the animation on the interactor rather than the interactable.")]
        //public bool onInteractor = false;
        //Animator animator;
        //RuntimeAnimatorController normal;
        //AnimatorController normalC;

        //AnimatorController created;
        //string path;

        ////public Animation animationa;
        //public AnimationClip clip;

        //[SerializeField] private List<IKTask> IKTasks = new List<IKTask>();
        ////[SerializeField] private List<IKTask> ikTasks = new List<IKTask>();

        //void Start()
        //{
        //    if(TryGetComponent(out Animator a))
        //    {
        //        //animator = a;
        //    }
        //}
        //public void CreateController()
        //{
        //    ///VERY IMPORTANT:                 float t = animator.GetCurrentAnimatorClipInfo(0)[0].clip
        //    ///clip to smooth from


        //    if (created != null)
        //    {
        //        AssetDatabase.DeleteAsset(path);
        //    }

        //    path = "Assets/Temp/TempStateMachineOf" + gameObject.name;
        //    created = AnimatorController.CreateAnimatorControllerAtPath(path);

        //    //Parameters
        //    created.AddParameter("TransitionNow", AnimatorControllerParameterType.Trigger);
        //    foreach (AnimatorControllerParameter parameter in normalC.parameters)
        //    {
        //        created.AddParameter(parameter);
        //    }

        //    //State Machines
        //    var rootStateMachine = created.layers[0].stateMachine;

        //    //IK pass
        //    AnimatorControllerLayer[] layers = created.layers;  // NOTE: this part didnt make a whole lot of sense
        //    layers[0].iKPass = true;                            // Make sure to reference the docs:
        //    created.layers = layers;                            // https://docs.unity3d.com/ScriptReference/Animations.AnimatorController-layers.html


        //    //Animation State
        //    var state = rootStateMachine.AddState("Animation");
        //    state.motion = clip;
        //    state.AddStateMachineBehaviour(typeof(ExitToOriginalController));
        //    state.AddStateMachineBehaviour(typeof(AddIKAnimation));


        //    //exit state
        //    var exitState = rootStateMachine.AddState("Exit State");

        //    //Transistions
        //    var exitTransition = state.AddTransition(exitState);
        //    exitTransition.AddCondition(AnimatorConditionMode.If, 0, "TransitionNow");
        //    exitTransition.hasExitTime = true;
        //    exitTransition.duration = 0;
        //}

        //[ContextMenu("P")]
        //public void PlayClip()
        //{
        //    if(created == null)
        //    {
        //        CreateController();
        //    }

        //    animator.runtimeAnimatorController = created;

        //}

        ///// <summary>
        ///// Called by ExitToOriginalController when the state is exited.
        ///// </summary>
        //public void SwitchToOriginal()
        //{
        //    animator.runtimeAnimatorController = normal;
        //}

        ///// <summary>
        ///// Delete the temporary Statemachine When the game ends.
        ///// </summary>
        //private void OnApplicationQuit()
        //{
        //    if(created != null)
        //    {
        //        UnityEditor.AssetDatabase.DeleteAsset(path);
        //    }
        //}


        /// <summary>
        /// This creates a statemachine that lerps from the current state to the state that the interaction
        /// is trying to have.
        /// </summary>
        /// <returns></returns>
        //public static RuntimeAnimatorController InteractionTemporaryStateMachine(List<AnimationClip> clips, GameObject target, out string path, float transitonTime)
        //{
        //    AnimatorController created;
        //    List<AnimatorState> states = new List<AnimatorState>();

        //    #region set Up
        //    path = "Assets/Temp/TempStateMachineOf" + target.name;
        //    created = AnimatorController.CreateAnimatorControllerAtPath(path);

        //    //Parameters
        //    created.AddParameter("TransitionNow", AnimatorControllerParameterType.Trigger);
        //    //State Machines
        //    var rootStateMachine = created.layers[0].stateMachine;
        //    #endregion

        //    //Animation State(s)
        //    states.Clear();
        //    AnimationClip startClip = target.GetComponent<Animator>().GetCurrentAnimatorStateInfo(0).
        //    states.Add(rootStateMachine.AddState("Starting Anim  "));


        //    for (int i = 0; i < clips.Count; i++)
        //    {
        //        states.Add(rootStateMachine.AddState("Animation " + i.ToString()));
        //        states[i + 1].motion = clips[i];

        //        var transition = states[(i + 1) - 1].AddTransition(states[i]);
        //        transition.AddCondition(UnityEditor.Animations.AnimatorConditionMode.If, 0, "TransitionNow");
        //        transition.duration = 0;
        //    }

        //    states[states.Count - 1].AddStateMachineBehaviour(typeof(ExitToOriginalController));

        //    //exit state
        //    var exitState = rootStateMachine.AddState("Exit State");

        //    //Transistions
        //    var exitTransition = state.AddTransition(exitState);
        //    exitTransition.AddCondition(AnimatorConditionMode.If, 0, "TransitionNow");
        //    exitTransition.hasExitTime = true;
        //    exitTransition.duration = 0;


        //    //Get the current state from the target
        //    //make that the first state.

        //    //cycle through each of the clips
        //    //create a state
        //    //create a transition from tthe previos to this

        //    //go back to the first position.

        //}
    }
}
namespace Character.Interactions.InteractableExtras
{
    [System.Serializable]
    public class IKTask
    {
        public AvatarIKGoal goal;
        public Vector3 offset;
        public Transform parent;
        public AnimationCurve weightCurve = AnimationCurve.Constant(0, 1, 0.8f);//Do the downward parabola

        public IKTask(AvatarIKGoal goal, Vector3 offset, Transform parent, AnimationCurve weightCurve)
        {
            this.goal = goal;
            this.offset = offset;
            this.parent = parent;
            this.weightCurve = weightCurve;
        }
    }
}