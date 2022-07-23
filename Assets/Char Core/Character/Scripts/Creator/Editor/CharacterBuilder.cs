// Unity C# reference source
// Copyright (c) Unity Technologies. For terms of use, see
// https://unity3d.com/legal/licenses/Unity_Reference_Only_License

using UnityEngine;
using UnityEditor;
using System.Collections;
using System;
using Character;
using System.IO;

using Character.Combat;
using Character.Interactions;
using Character.Riding;
using Character.Save;
using Character.Inventory;
using UnityEngine.InputSystem;
using UnityEngine.AI;
using Character.Interactions.Dialouge;
//https://github.com/Unity-Technologies/UnityCsReference/blob/9710f1610086285933b86e42d62d2348ec51ce44/Editor/Mono/RagdollBuilder.cs

#pragma warning disable 649

namespace UnityEditor
{
    class CharacterBuilder : ScriptableWizard
    {
        public enum ControlType { Manual, User, AI, Both };
        public enum InteractionType { None, Talk };

        //Configure these in the script asset
        [Header("Character")]
        public Animator animator;
        [Header("Movement")]
        public RuntimeAnimatorController animatorController;
        public ControlType controlledType = ControlType.User;
        public InputActionAsset actionAsset;
        [Space]
        public bool canSwim = true;
        public bool canRide = true;
        public bool canClimb = false;

        [Header("Dialouge")]
        public string characterName = "Name";
        public Affiliation affiliation = Affiliation.Good;
        public InteractionType interaction = InteractionType.None;
        public bool createDialougeAsset = false;
        [TextArea(5, 100)] public string dialougeText = "Hello!;";
        //use ; to inicate line end, use /option text/option pointer pos Dont include name as first line, this will auto do that.
        public string savePath = "Assets/Game/Characters";

        [Header("Spring Bone")]
        public bool createSpringBones = true;
        float springStiffness = 0.6f;
        AnimationCurve springStiffnessCurve
        {
            get
            {
                AnimationCurve o = new AnimationCurve();
                o.AddKey(new Keyframe(0, 0, Mathf.PI / 4, Mathf.PI / 4));
                o.AddKey(new Keyframe(1, 1, 0, 0));
                return o;
            }
        }
        float springDrag = 0.8f;


        //This will add components needed for character.
        void AddComponents()
        {
            GameObject g = animator.gameObject;
            CapsuleCollider capsuleCollider = g.AddComponent<CapsuleCollider>();
            capsuleCollider.radius = 0.25f;
            capsuleCollider.direction = 1;
            capsuleCollider.center = Vector3.up * 0.95f;
            capsuleCollider.height = 1.9f;
            Rigidbody rb = g.AddComponent<Rigidbody>();
            rb.constraints = RigidbodyConstraints.FreezeRotation;


            Controller controller = null;
            if ((controlledType == ControlType.User || controlledType == ControlType.Both) && actionAsset != null)
            {
                UserCharacter1 tempController = g.AddComponent<UserCharacter1>();
                tempController.playerInput = g.AddComponent<PlayerInput>();
                tempController.playerInput.actions = actionAsset;
                controller = tempController;

                CharacterInventory inv = g.AddComponent<CharacterInventory>();
                inv.Input = tempController.playerInput;
                CharacterLoader loader = g.AddComponent<CharacterLoader>();
                loader.path = "/" + characterName + ".chr";
                
            }
            else if (controlledType == ControlType.AI || controlledType == ControlType.Both || actionAsset == null)
            {
                AICharacter tempController = g.AddComponent<AICharacter>();
                //tempController.playerInput = g.AddComponent<PlayerInput>();//navmesh

                controller = tempController;
            }

            //It should never reach this state
            if (controller == null)
            {
                Debug.LogError("Something is wrong with Character builder and setting the control type.");
                controller = g.AddComponent<Controller>();
            }

            controller.animator = animator;
            controller.health = g.AddComponent<Health>();
            controller.actor = g.AddComponent<Actor>();
            controller.actor.team = affiliation;

            //Combatant
            controller.combatant = g.AddComponent<Combatant>();

            GameObject rhandGO = new GameObject("Hand");
            ResetLocalTransform(rhandGO.transform);
            rhandGO.transform.parent = animator.GetBoneTransform(HumanBodyBones.RightHand);
            controller.combatant.hand = rhandGO.transform;
            AimIK aim = g.AddComponent<AimIK>();
            aim.bone = animator.GetBoneTransform(HumanBodyBones.Spine);
            g.AddComponent<LookAtTarget>();
            //loader
            //inventory


            Character6 baseMovement = g.AddComponent<Character6>();
            baseMovement.simpleCollider = capsuleCollider;
            controller.moveTypes.Add(baseMovement);
            controller.interactor = g.AddComponent<Interactor>();
            controller.interactor.hand = rhandGO.transform;

            GameObject colliderChildren = new GameObject("Collider Children");
            colliderChildren.transform.parent = g.transform;

            if (canClimb)
            {
                GameObject climbChild = new GameObject("Climb Collider");
                ResetLocalTransform(climbChild.transform);
                climbChild.transform.parent = colliderChildren.transform;
                CapsuleCollider climbCollider = climbChild.AddComponent<CapsuleCollider>();
                climbCollider.radius = 0.5f;
                climbCollider.direction = 2;
                climbCollider.center = Vector3.up * 0.5f;
                climbCollider.height = 1.5f;

                //Swimmer swimmer = g.AddComponent<Swimmer>();
                //controller.moveTypes.Add(swimmer);
                //swimmer.swimmingCollider = climbCollider;
            }

            if (canRide)
            {
                GameObject rideChild = new GameObject("Ride Collider");
                ResetLocalTransform(rideChild.transform);
                rideChild.transform.parent = colliderChildren.transform;
                CapsuleCollider riderCollider = rideChild.AddComponent<CapsuleCollider>();
                riderCollider.radius = 0.5f;
                riderCollider.direction = 2;
                riderCollider.center = Vector3.up * 0.5f;
                riderCollider.height = 1.5f;

                Rider rider = g.AddComponent<Rider>();
                controller.moveTypes.Add(rider);
                //rider.collider = riderCollider;
            }

            if (canSwim)
            {
                GameObject swimChild = new GameObject("Swim Collider");
                ResetLocalTransform(swimChild.transform);
                swimChild.transform.parent = colliderChildren.transform;
                CapsuleCollider swimCollider = swimChild.AddComponent<CapsuleCollider>();
                swimCollider.radius = 0.5f;
                swimCollider.direction = 2;
                swimCollider.center = Vector3.up * 0.5f;
                swimCollider.height = 1.5f;

                Swimmer swimmer = g.AddComponent<Swimmer>();
                controller.moveTypes.Add(swimmer);
                swimmer.swimmingCollider = swimCollider;
            }

            Ragdoll ragdoll = g.AddComponent<Ragdoll>();
            controller.moveTypes.Add(ragdoll);
            //ragdoll.simpleCollider = capsuleCollider;

            if(createDialougeAsset && dialougeText != "")
            {
                DialougeSO example = ScriptableObject.CreateInstance<DialougeSO>();
                example.StringToDialouge(characterName + ";" + dialougeText);
                string path = savePath + "/" + characterName + ".asset";
                AssetDatabase.CreateAsset(example, path);
                AssetDatabase.SaveAssets();
                AssetDatabase.Refresh();
                EditorUtility.FocusProjectWindow();
                Selection.activeObject = example;
            }


            if(createSpringBones)
                CreateSpringBones();
        }
        void ResetLocalTransform(Transform t)
        {
            t.localPosition = Vector3.zero;
            t.localRotation = Quaternion.identity;
            t.localScale = Vector3.one;
        }
        void CreateSpringBones()
        {
            //put markers on all nonhuman bones
            //convert to springs.
            Transform root = animator.GetBoneTransform(HumanBodyBones.Hips).parent;//springRoot;//animator.transform.GetChild(0).GetChild(0);//THIS MAY NEED CHANGING
            UnityChan.SpringManager m = root.gameObject.AddComponent<UnityChan.SpringManager>();
            SpringBoneAssistant assist = root.gameObject.AddComponent<SpringBoneAssistant>();
            assist.mSpringManager = m;
            m.stiffnessForce = springStiffness;
            m.stiffnessCurve = springStiffnessCurve;
            m.dragForce = springDrag;
            m.dragCurve = springStiffnessCurve;


            RecurseThruBones(root);

            assist.MarkChildren();
            
        }
        void RecurseThruBones(Transform bone)
        {
            for(int i=0; i< bone.childCount; i++)
            {
                Transform child = bone.GetChild(i);
                bool isHumanBone = false;
                //for each human bone check flag if human
                
                for(int b=0; b<55; b++)
                {
                    if (child == animator.GetBoneTransform((HumanBodyBones)b))
                    {
                        isHumanBone = true;
                        continue;
                    }
                }

                if(!isHumanBone)
                {
                    child.gameObject.AddComponent<SpringBoneMarker>();
                }
                else
                {
                    RecurseThruBones(child);
                }
            }
        }

        Transform pelvis;

        Transform leftHips = null;
        Transform leftKnee = null;
        Transform leftFoot = null;

        Transform rightHips = null;
        Transform rightKnee = null;
        Transform rightFoot = null;

        Transform leftArm = null;
        Transform leftElbow = null;

        Transform rightArm = null;
        Transform rightElbow = null;

        Transform middleSpine = null;
        Transform head = null;

        [Header("Ragdoll Settings")]
        public float headSizeMultiplier = 0.0125f;
        public float capsuleRadiusCoeficient = 0.3f;
        public float totalMass = 20;
        public float strength = 0.5f;//default 0;

        Vector3 right = Vector3.right;
        Vector3 up = Vector3.up;
        Vector3 forward = Vector3.forward;

        Vector3 worldRight = Vector3.right;
        Vector3 worldUp = Vector3.up;
        Vector3 worldForward = Vector3.forward;
        public bool flipForward = false;

        // this sets instance variables of transforms to humanbody bones.
        void SetTransformsFromAvatar()
        {
            if (animator == null || !animator.isHuman)
                return;

            pelvis = animator.GetBoneTransform(HumanBodyBones.Hips);

            leftHips = animator.GetBoneTransform(HumanBodyBones.LeftUpperLeg);
            leftKnee = animator.GetBoneTransform(HumanBodyBones.LeftLowerLeg);
            leftFoot = animator.GetBoneTransform(HumanBodyBones.LeftFoot);

            rightHips = animator.GetBoneTransform(HumanBodyBones.RightUpperLeg);
            rightKnee = animator.GetBoneTransform(HumanBodyBones.RightLowerLeg);
            rightFoot = animator.GetBoneTransform(HumanBodyBones.RightFoot);

            leftArm = animator.GetBoneTransform(HumanBodyBones.LeftUpperArm);
            leftElbow = animator.GetBoneTransform(HumanBodyBones.LeftLowerArm);

            rightArm = animator.GetBoneTransform(HumanBodyBones.RightUpperArm);
            rightElbow = animator.GetBoneTransform(HumanBodyBones.RightLowerArm);

            middleSpine = animator.GetBoneTransform(HumanBodyBones.Chest);
            head = animator.GetBoneTransform(HumanBodyBones.Head);
        }

        class BoneInfo
        {
            public string name;

            public Transform anchor;
            public CharacterJoint joint;
            public BoneInfo parent;

            public float minLimit;
            public float maxLimit;
            public float swingLimit;

            public Vector3 axis;
            public Vector3 normalAxis;

            public float radiusScale;
            public Type colliderType;

            public ArrayList children = new ArrayList();
            public float density;
            public float summedMass;// The mass of this and all children bodies
        }

        ArrayList bones;
        BoneInfo rootBone;

        string CheckConsistency()
        {
            SetTransformsFromAvatar();
            PrepareBones();
            Hashtable map = new Hashtable();
            foreach (BoneInfo bone in bones)
            {
                if (bone.anchor)
                {
                    if (map[bone.anchor] != null)
                    {
                        BoneInfo oldBone = (BoneInfo)map[bone.anchor];
                        return String.Format("{0} and {1} may not be assigned to the same bone.", bone.name, oldBone.name);
                    }
                    map[bone.anchor] = bone;
                }
            }

            foreach (BoneInfo bone in bones)
            {
                if (bone.anchor == null)
                    return String.Format("{0} has not been assigned yet.\n", bone.name);
            }

            return "";
        }

        void OnDrawGizmos()
        {
            if (pelvis)
            {
                Gizmos.color = Color.red; Gizmos.DrawRay(pelvis.position, pelvis.TransformDirection(right));
                Gizmos.color = Color.green; Gizmos.DrawRay(pelvis.position, pelvis.TransformDirection(up));
                Gizmos.color = Color.blue; Gizmos.DrawRay(pelvis.position, pelvis.TransformDirection(forward));
            }
        }

        //Change class name to this class
        [MenuItem("GameObject/3D Object/Character/Humanoid Character", false, 2000)]
        static void CreateWizard()
        {
            ScriptableWizard.DisplayWizard<CharacterBuilder>("Create Character");
        }

        #region ragdollMethods

        void DecomposeVector(out Vector3 normalCompo, out Vector3 tangentCompo, Vector3 outwardDir, Vector3 outwardNormal)
        {
            outwardNormal = outwardNormal.normalized;
            normalCompo = outwardNormal * Vector3.Dot(outwardDir, outwardNormal);
            tangentCompo = outwardDir - normalCompo;
        }

        void CalculateAxes()
        {
            if (head != null && pelvis != null)
                up = CalculateDirectionAxis(pelvis.InverseTransformPoint(head.position));
            if (rightElbow != null && pelvis != null)
            {
                Vector3 removed, temp;
                DecomposeVector(out temp, out removed, pelvis.InverseTransformPoint(rightElbow.position), up);
                right = CalculateDirectionAxis(removed);
            }

            forward = Vector3.Cross(right, up);
            if (flipForward)
                forward = -forward;
        }

        void OnWizardUpdate()
        {
            errorString = CheckConsistency();
            CalculateAxes();

            if (errorString.Length != 0)
            {
                helpString = "Drag all bones from the hierarchy into their slots.\nMake sure your character is in T-Stand.\n";
            }
            else
            {
                helpString = "Make sure your character is in T-Stand.\nMake sure the blue axis faces in the same direction the chracter is looking.\nUse flipForward to flip the direction";
            }

            isValid = errorString.Length == 0;
        }

        void PrepareBones()
        {
            if (pelvis)
            {
                worldRight = pelvis.TransformDirection(right);
                worldUp = pelvis.TransformDirection(up);
                worldForward = pelvis.TransformDirection(forward);
            }

            bones = new ArrayList();

            rootBone = new BoneInfo();
            rootBone.name = "Pelvis";
            rootBone.anchor = pelvis;
            rootBone.parent = null;
            rootBone.density = 2.5F;
            bones.Add(rootBone);

            AddMirroredJoint("Hips", leftHips, rightHips, "Pelvis", worldRight, worldForward, -20, 70, 30, typeof(CapsuleCollider), 0.3F, 1.5F);
            AddMirroredJoint("Knee", leftKnee, rightKnee, "Hips", worldRight, worldForward, -80, 0, 0, typeof(CapsuleCollider), 0.25F, 1.5F);

            AddJoint("Middle Spine", middleSpine, "Pelvis", worldRight, worldForward, -20, 20, 10, null, 1, 2.5F);

            AddMirroredJoint("Arm", leftArm, rightArm, "Middle Spine", worldUp, worldForward, -70, 10, 50, typeof(CapsuleCollider), 0.25F, 1.0F);
            AddMirroredJoint("Elbow", leftElbow, rightElbow, "Arm", worldForward, worldUp, -90, 0, 0, typeof(CapsuleCollider), 0.20F, 1.0F);

            AddJoint("Head", head, "Middle Spine", worldRight, worldForward, -40, 25, 25, null, 1, 1.0F);
        }

        //This is order of things occuring
        void OnWizardCreate()
        {
            AddComponents();
            SetTransformsFromAvatar();
            Cleanup();
            BuildCapsules();
            AddBreastColliders();
            AddHeadCollider();

            BuildBodies();
            BuildJoints();
            CalculateMass();
        }

        BoneInfo FindBone(string name)
        {
            foreach (BoneInfo bone in bones)
            {
                if (bone.name == name)
                    return bone;
            }
            return null;
        }

        void AddMirroredJoint(string name, Transform leftAnchor, Transform rightAnchor, string parent, Vector3 worldTwistAxis, Vector3 worldSwingAxis, float minLimit, float maxLimit, float swingLimit, Type colliderType, float radiusScale, float density)
        {
            AddJoint("Left " + name, leftAnchor, parent, worldTwistAxis, worldSwingAxis, minLimit, maxLimit, swingLimit, colliderType, radiusScale, density);
            AddJoint("Right " + name, rightAnchor, parent, worldTwistAxis, worldSwingAxis, minLimit, maxLimit, swingLimit, colliderType, radiusScale, density);
        }

        void AddJoint(string name, Transform anchor, string parent, Vector3 worldTwistAxis, Vector3 worldSwingAxis, float minLimit, float maxLimit, float swingLimit, Type colliderType, float radiusScale, float density)
        {
            BoneInfo bone = new BoneInfo();
            bone.name = name;
            bone.anchor = anchor;
            bone.axis = worldTwistAxis;
            bone.normalAxis = worldSwingAxis;
            bone.minLimit = minLimit;
            bone.maxLimit = maxLimit;
            bone.swingLimit = swingLimit;
            bone.density = density;
            bone.colliderType = colliderType;
            bone.radiusScale = radiusScale;

            if (FindBone(parent) != null)
                bone.parent = FindBone(parent);
            else if (name.StartsWith("Left"))
                bone.parent = FindBone("Left " + parent);
            else if (name.StartsWith("Right"))
                bone.parent = FindBone("Right " + parent);


            bone.parent.children.Add(bone);
            bones.Add(bone);
        }

        void BuildCapsules()
        {
            foreach (BoneInfo bone in bones)
            {
                if (bone.colliderType != typeof(CapsuleCollider))
                    continue;

                int direction;
                float distance;
                if (bone.children.Count == 1)
                {
                    BoneInfo childBone = (BoneInfo)bone.children[0];
                    Vector3 endPoint = childBone.anchor.position;
                    CalculateDirection(bone.anchor.InverseTransformPoint(endPoint), out direction, out distance);
                }
                else
                {
                    Vector3 endPoint = (bone.anchor.position - bone.parent.anchor.position) + bone.anchor.position;
                    CalculateDirection(bone.anchor.InverseTransformPoint(endPoint), out direction, out distance);

                    if (bone.anchor.GetComponentsInChildren(typeof(Transform)).Length > 1)
                    {
                        Bounds bounds = new Bounds();
                        foreach (Transform child in bone.anchor.GetComponentsInChildren(typeof(Transform)))
                        {
                            bounds.Encapsulate(bone.anchor.InverseTransformPoint(child.position));
                        }

                        if (distance > 0)
                            distance = bounds.max[direction];
                        else
                            distance = bounds.min[direction];
                    }
                }

                CapsuleCollider collider = Undo.AddComponent<CapsuleCollider>(bone.anchor.gameObject);
                collider.direction = direction;

                Vector3 center = Vector3.zero;
                center[direction] = distance * 0.5F;
                collider.center = center;
                collider.height = Mathf.Abs(distance);
                collider.radius = Mathf.Abs(distance * bone.radiusScale) * capsuleRadiusCoeficient;
            }
        }

        void Cleanup()
        {
            foreach (BoneInfo bone in bones)
            {
                if (!bone.anchor)
                    continue;

                Component[] joints = bone.anchor.GetComponentsInChildren(typeof(Joint));
                foreach (Joint joint in joints)
                    Undo.DestroyObjectImmediate(joint);

                Component[] bodies = bone.anchor.GetComponentsInChildren(typeof(Rigidbody));
                foreach (Rigidbody body in bodies)
                    Undo.DestroyObjectImmediate(body);

                Component[] colliders = bone.anchor.GetComponentsInChildren(typeof(Collider));
                foreach (Collider collider in colliders)
                    Undo.DestroyObjectImmediate(collider);
            }
        }

        void BuildBodies()
        {
            foreach (BoneInfo bone in bones)
            {
                Undo.AddComponent<Rigidbody>(bone.anchor.gameObject);
                bone.anchor.GetComponent<Rigidbody>().mass = bone.density;
            }
        }

        void BuildJoints()
        {
            foreach (BoneInfo bone in bones)
            {
                if (bone.parent == null)
                    continue;

                CharacterJoint joint = Undo.AddComponent<CharacterJoint>(bone.anchor.gameObject);
                bone.joint = joint;

                // Setup connection and axis
                joint.axis = CalculateDirectionAxis(bone.anchor.InverseTransformDirection(bone.axis));
                joint.swingAxis = CalculateDirectionAxis(bone.anchor.InverseTransformDirection(bone.normalAxis));
                joint.anchor = Vector3.zero;
                joint.connectedBody = bone.parent.anchor.GetComponent<Rigidbody>();
                joint.enablePreprocessing = false; // turn off to handle degenerated scenarios, like spawning inside geometry.

                // Setup limits
                SoftJointLimit limit = new SoftJointLimit();
                limit.contactDistance = 0; // default to zero, which automatically sets contact distance.

                limit.limit = bone.minLimit;
                joint.lowTwistLimit = limit;

                limit.limit = bone.maxLimit;
                joint.highTwistLimit = limit;

                limit.limit = bone.swingLimit;
                joint.swing1Limit = limit;

                limit.limit = 0;
                joint.swing2Limit = limit;
            }
        }

        void CalculateMassRecurse(BoneInfo bone)
        {
            float mass = bone.anchor.GetComponent<Rigidbody>().mass;
            foreach (BoneInfo child in bone.children)
            {
                CalculateMassRecurse(child);
                mass += child.summedMass;
            }
            bone.summedMass = mass;
        }

        void CalculateMass()
        {
            // Calculate allChildMass by summing all bodies
            CalculateMassRecurse(rootBone);

            // Rescale the mass so that the whole character weights totalMass
            float massScale = totalMass / rootBone.summedMass;
            foreach (BoneInfo bone in bones)
                bone.anchor.GetComponent<Rigidbody>().mass *= massScale;

            // Recalculate allChildMass by summing all bodies
            CalculateMassRecurse(rootBone);
        }

        static void CalculateDirection(Vector3 point, out int direction, out float distance)
        {
            // Calculate longest axis
            direction = 0;
            if (Mathf.Abs(point[1]) > Mathf.Abs(point[0]))
                direction = 1;
            if (Mathf.Abs(point[2]) > Mathf.Abs(point[direction]))
                direction = 2;

            distance = point[direction];
        }

        static Vector3 CalculateDirectionAxis(Vector3 point)
        {
            int direction = 0;
            float distance;
            CalculateDirection(point, out direction, out distance);
            Vector3 axis = Vector3.zero;
            if (distance > 0)
                axis[direction] = 1.0F;
            else
                axis[direction] = -1.0F;
            return axis;
        }

        static int SmallestComponent(Vector3 point)
        {
            int direction = 0;
            if (Mathf.Abs(point[1]) < Mathf.Abs(point[0]))
                direction = 1;
            if (Mathf.Abs(point[2]) < Mathf.Abs(point[direction]))
                direction = 2;
            return direction;
        }

        static int LargestComponent(Vector3 point)
        {
            int direction = 0;
            if (Mathf.Abs(point[1]) > Mathf.Abs(point[0]))
                direction = 1;
            if (Mathf.Abs(point[2]) > Mathf.Abs(point[direction]))
                direction = 2;
            return direction;
        }

        static int SecondLargestComponent(Vector3 point)
        {
            int smallest = SmallestComponent(point);
            int largest = LargestComponent(point);
            if (smallest < largest)
            {
                int temp = largest;
                largest = smallest;
                smallest = temp;
            }

            if (smallest == 0 && largest == 1)
                return 2;
            else if (smallest == 0 && largest == 2)
                return 1;
            else
                return 0;
        }

        Bounds Clip(Bounds bounds, Transform relativeTo, Transform clipTransform, bool below)
        {
            int axis = LargestComponent(bounds.size);

            if (Vector3.Dot(worldUp, relativeTo.TransformPoint(bounds.max)) > Vector3.Dot(worldUp, relativeTo.TransformPoint(bounds.min)) == below)
            {
                Vector3 min = bounds.min;
                min[axis] = relativeTo.InverseTransformPoint(clipTransform.position)[axis];
                bounds.min = min;
            }
            else
            {
                Vector3 max = bounds.max;
                max[axis] = relativeTo.InverseTransformPoint(clipTransform.position)[axis];
                bounds.max = max;
            }
            return bounds;
        }

        Bounds GetBreastBounds(Transform relativeTo)
        {
            // Pelvis bounds
            Bounds bounds = new Bounds();
            bounds.Encapsulate(relativeTo.InverseTransformPoint(leftHips.position));
            bounds.Encapsulate(relativeTo.InverseTransformPoint(rightHips.position));
            bounds.Encapsulate(relativeTo.InverseTransformPoint(leftArm.position));
            bounds.Encapsulate(relativeTo.InverseTransformPoint(rightArm.position));
            Vector3 size = bounds.size;
            size[SmallestComponent(bounds.size)] = size[LargestComponent(bounds.size)] / 2.0F;
            bounds.size = size;
            return bounds;
        }

        void AddBreastColliders()
        {
            // Middle spine and pelvis
            if (middleSpine != null && pelvis != null)
            {
                Bounds bounds;
                BoxCollider box;

                // Middle spine bounds
                bounds = Clip(GetBreastBounds(pelvis), pelvis, middleSpine, false);
                box = Undo.AddComponent<BoxCollider>(pelvis.gameObject);
                box.center = bounds.center;
                box.size = bounds.size;

                bounds = Clip(GetBreastBounds(middleSpine), middleSpine, middleSpine, true);
                box = Undo.AddComponent<BoxCollider>(middleSpine.gameObject);
                box.center = bounds.center;
                box.size = bounds.size;
            }
            // Only pelvis
            else
            {
                Bounds bounds = new Bounds();
                bounds.Encapsulate(pelvis.InverseTransformPoint(leftHips.position));
                bounds.Encapsulate(pelvis.InverseTransformPoint(rightHips.position));
                bounds.Encapsulate(pelvis.InverseTransformPoint(leftArm.position));
                bounds.Encapsulate(pelvis.InverseTransformPoint(rightArm.position));

                Vector3 size = bounds.size;
                size[SmallestComponent(bounds.size)] = size[LargestComponent(bounds.size)] / 2.0F;

                BoxCollider box = Undo.AddComponent<BoxCollider>(pelvis.gameObject);
                box.center = bounds.center;
                box.size = size;
            }
        }

        void AddHeadCollider()
        {
            if (head.GetComponent<Collider>())
                Destroy(head.GetComponent<Collider>());

            float radius = Vector3.Distance(leftArm.transform.position, rightArm.transform.position);
            radius /= 4;
            radius *= headSizeMultiplier;

            SphereCollider sphere = Undo.AddComponent<SphereCollider>(head.gameObject);
            sphere.radius = radius;
            Vector3 center = Vector3.zero;

            int direction;
            float distance;
            CalculateDirection(head.InverseTransformPoint(pelvis.position), out direction, out distance);
            if (distance > 0)
                center[direction] = -radius;
            else
                center[direction] = radius;
            sphere.center = center;
        }
        #endregion
    }
}