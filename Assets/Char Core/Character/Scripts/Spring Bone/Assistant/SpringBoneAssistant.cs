using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SpringBoneAssistant : MonoBehaviour
{
    public UnityChan.SpringManager mSpringManager;

    public Vector3 mTargetBoneAxis = new Vector3(0f, 1f, 0f);
    [ContextMenu("Mark Children")]
    public void MarkChildren()
    {
        //List<SpringBoneMarker> boneMarkers = new List<SpringBoneMarker>();

        // get spring bones set
        SpringBoneMarker[] boneMarkers = FindObjectsOfType<SpringBoneMarker>();

        // mark children
        for (int i = 0; i < boneMarkers.Length; i++)
        {
            boneMarkers[i].MarkChildren();
        }

        // get again, will include children
        boneMarkers = FindObjectsOfType<SpringBoneMarker>();
        List<SpringBoneMarker> markers = new List<SpringBoneMarker>(boneMarkers);
        List<UnityChan.SpringBone> springBones = new List<UnityChan.SpringBone> { };
        int maxIterations = 100;
        int c = 0;
        while(markers.Count > 0 && c<maxIterations)
        {
            // add spring bone
            UnityChan.SpringBone s = markers[0].AddSpringBone();//ADDED NULL CHECK AND handeling for 0 children
            if (s != null)
            {
                s.boneAxis = mTargetBoneAxis;
                springBones.Add(s);
            }
            
            // unmark object
            markers[0].UnmarkSelf();
            markers.RemoveAt(0);
            c++;
        }
        
        /*
        for (int i = boneMarkers.Length; i > 0; i--)
        {
            // add spring bone
            UnityChan.SpringBone s = boneMarkers[i].AddSpringBone();//ADDED NULL CHECK AND handeling for 0 children
            if(s!= null)
                springBones.Add(s);

            // set vector
            if (s != null)
                springBones[i].boneAxis = mTargetBoneAxis;

            // unmark object
            boneMarkers[i].UnmarkSelf();
        }
        */
        mSpringManager.springBones = springBones.ToArray();
    }

    [ContextMenu("CleanUp")]
    public void CleanUp()
    {
        SpringBoneMarker[] boneMarkers = FindObjectsOfType<SpringBoneMarker>();
        UnityChan.SpringBone[] springBones = FindObjectsOfType<UnityChan.SpringBone>();

        for (int i = 0; i < boneMarkers.Length; i++)
        {
            DestroyImmediate(boneMarkers[i]);

        }
        for (int i = 0; i < springBones.Length; i++)
        {
            DestroyImmediate(springBones[i]);
        }

    }
    //Add spring bone colliders to every human body bone? 2 or 3 per capsule, 8 per box, 1 per sphere?
    //how to make spring bones register all of them?
    //lag?
}