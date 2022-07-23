using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class RenTexToSprite : MonoBehaviour
{
    public RenderTexture inRenTex;
    public Texture2D inTex;
    public Sprite outSprite;

    private Image i;
    private void Awake()
    {
        i = GetComponent<Image>();
        i.enabled = true;
    }

    public void Update()
    {

        RenderTexture.active = inRenTex;
        inTex = new Texture2D(inRenTex.width, inRenTex.height);
        inTex.ReadPixels(new Rect(0, 0, inRenTex.width, inRenTex.height), 0, 0);
        inTex.Apply();
        inRenTex.Release();

        outSprite = SpriteFromTex(inTex);
        if (i == null) i = GetComponent<Image>();
        i.sprite = outSprite;
    }


    public static Sprite SpriteFromTex(Texture2D tex)
    {
        Sprite s;
        s = Sprite.Create(tex, new Rect(0.0f, 0.0f, tex.width, tex.height), new Vector2(0.5f, 0.5f), 100.0f);
        return s;
    }
}
