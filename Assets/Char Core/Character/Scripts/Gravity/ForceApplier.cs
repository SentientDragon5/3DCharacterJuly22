using System.Collections;
using System.Collections.Generic;
using UnityEngine;

/// <summary>
/// This script is used to apply gravity to rigidbodies instead of the normal Physics.gravity
/// </summary>
[RequireComponent(typeof(Rigidbody))]
public class ForceApplier : ForceProbe
{
    public string[] forceTags = new string[2] { "gravity", "wind" };
    public override string[] AutoApply => forceTags;
}