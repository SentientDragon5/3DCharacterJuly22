using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Character;

/// <summary>
/// Use this as a parent class to anything that needs a reference to the player, notably UI.
/// PlayerRef.character should be the player referenced in the highest active parent transform of for instance UI.
/// 
/// </summary>
public class PlayerRef : MonoBehaviour
{
    /// <summary>
    /// this is the character referenced in the highest parent, if null it will try to return main user character.
    /// </summary>
    [SerializeField]
    private Controller targetCharacter;
    /// <summary>
    /// Whether this should be setting the static variable (this is for simple solutions)
    /// </summary>
    [SerializeField]
    private bool isStatic = false;

    private static Controller staticTargetCharacter;
    public static Controller StaticTargetCharacter
    {
        get => staticTargetCharacter;
    }

    public Controller TargetCharacter
    {
        get
        {

            if (targetCharacter != null)
            {
                //Debug.Log("PRE END");
                return targetCharacter;
            }

            Transform i = transform.parent;
            while(i.parent != null)
            {
                i = i.parent;
            }
            Controller c = i.GetComponent<PlayerRef>().targetCharacter;
            //Controller c = GetComponentInParent<PlayerRef>().targetCharacter;

            //Debug.Log("found a PlayerRef in parent " + (c != null));
            if (c != null)
            {
                //Debug.Log("PARENT END");
                targetCharacter = c;
                return targetCharacter;
            }
            if (targetCharacter == null && UserCharacter1.userCharacters.Count > 0)
            {
                targetCharacter = UserCharacter1.userCharacters[0];
                //Debug.Log("USER END");
                return targetCharacter;
            }
            //if (targetCharacter == null) Debug.Log("NULL END");
            //Debug.Log(targetCharacter.transform.name);
            return targetCharacter;
        }
    }


    private void Awake()
    {
        if (targetCharacter != null)
            return;
        if (isStatic)
            staticTargetCharacter = targetCharacter;

        Controller c = GetComponentInParent<PlayerRef>().targetCharacter;
        if (c != null)
            targetCharacter = c;
        if (targetCharacter == null && UserCharacter1.userCharacters.Count > 0)
            targetCharacter = UserCharacter1.userCharacters[0];


    }
}
