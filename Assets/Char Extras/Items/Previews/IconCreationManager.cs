using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
public class IconCreationManager : MonoBehaviour
{
    public GameObject[] objects;
    public string assetPath;
    private RenderTexture texture;
    private Camera camera;
    public Transform anchor;
    public float forward = 3.0f, up = 2.0f;
    public Vector2 size = new Vector2(512, 512);
    

    [ContextMenu("Multiple")]
    public void Create()
    {
        camera = Camera.main;
        texture = new RenderTexture((int)size.x, (int)size.y, 24);
        foreach (GameObject original in objects)
        {
            GameObject go = Instantiate(original, anchor.transform.position, Quaternion.identity);
            camera.transform.position = go.transform.position + go.transform.forward * forward;
            camera.transform.position += Vector3.up * up;
            //camera.transform.LookAt();
            camera.targetTexture = texture;
            camera.Render();
            Texture2D tex = new Texture2D(texture.width, texture.height, TextureFormat.ARGB32, false);
            Rect rectReadPicture = new Rect(0, 0, texture.width, texture.height);
            RenderTexture.active = texture;
            tex.ReadPixels(rectReadPicture, 0, 0);
            Color32[] colors = tex.GetPixels32();
            int i = 0;
            Color32 transparent = colors[i];
            for (; i < colors.Length; i++)
            {
                if (colors[i].Equals(transparent))
                {
                    colors[i] = new Color32();
                }
            }
            tex.SetPixels32(colors);
            RenderTexture.active = null;
            string cardPath = "Assets/" + assetPath + go.name + "_icon" + ".png";
            byte[] bytes = tex.EncodeToPNG();
            System.IO.File.WriteAllBytes(cardPath, bytes);
            AssetDatabase.ImportAsset(cardPath);
            TextureImporter ti = (TextureImporter)TextureImporter.GetAtPath(cardPath);
            ti.textureType = TextureImporterType.Sprite;
            ti.SaveAndReimport();
            DestroyImmediate(go.gameObject);
        }
    }
    public string _name;
    Camera cam;

    [Header("AUTO PLACE")]
    public bool AutoPlaceEnabled;
    public float distance = 1;
    public float orthoOffset = 1;
    public float upDown01 = 0.5f;
    public float leftRight = 0.5f;
    public Vector3 direction;
    
    [ContextMenu("Auto Place to Anchor")]
    public void AutoPlaceCam()
    {
        Bounds bounds = anchor.GetComponent<Renderer>().bounds;
        direction.Normalize();
        Vector3 center = bounds.center + anchor.position;
        //Vector3 offset = anchor.right * Mathf.Cos(leftRight * 2 * Mathf.PI) + anchor.forward * Mathf.Sin(leftRight * 2 * Mathf.PI) + anchor.up * upDown01;
        //Vector3 offsetBoundExtents = offset + new Vector3(offset.x * bounds.extents.x , offset.y * bounds.extents.y , offset.z * bounds.extents.z);
        Vector3 offset = bounds.ClosestPoint(bounds.center + direction * 1000f) * distance;
        transform.position = offset + anchor.position;
        //transform.position = bounds.ClosestPoint(anchor.position - offsetBoundExtents) - offsetBoundExtents;
        //transform.position = bounds.ClosestPoint(anchor.position - (anchor.forward * (bounds.extents.z + distance))) - anchor.forward * distance;
        transform.LookAt(center);
        Vector3 lookDir = transform.position - bounds.center;
        float orthoSize = bounds.extents.x * lookDir.x + bounds.extents.y * lookDir.y + bounds.extents.z * lookDir.z;
        orthoSize += orthoOffset;

        camera = GetComponent<Camera>();
        camera.orthographic = true;
        camera.orthographicSize = orthoSize;
    }
    private void OnDrawGizmosSelected()
    {
        if (anchor == null)
            return;
        Bounds bounds = anchor.GetComponent<Renderer>().bounds;
        Gizmos.DrawWireCube(anchor.position + bounds.center, bounds.extents * 2);
        if(AutoPlaceEnabled) AutoPlaceCam();
    }

    [ContextMenu("Single")]
        public void CreateSingle()
        {
            camera = GetComponent<Camera>();
            texture = new RenderTexture((int)size.x, (int)size.y, 24);

            //camera.transform.LookAt();
            camera.targetTexture = texture;
            camera.Render();
            Texture2D tex = new Texture2D(texture.width, texture.height, TextureFormat.ARGB32, false);
            Rect rectReadPicture = new Rect(0, 0, texture.width, texture.height);
            RenderTexture.active = texture;
            tex.ReadPixels(rectReadPicture, 0, 0);
            Color32[] colors = tex.GetPixels32();
            int i = 0;
            Color32 transparent = colors[i];
            for (; i < colors.Length; i++)
            {
                if (colors[i].Equals(transparent))
                {
                    colors[i] = new Color32();
                }
            }
            tex.SetPixels32(colors);
            RenderTexture.active = null;
            string cardPath = "Assets/" + assetPath + _name + "_icon" + ".png";
            byte[] bytes = tex.EncodeToPNG();
            System.IO.File.WriteAllBytes(cardPath, bytes);
            AssetDatabase.ImportAsset(cardPath);
            TextureImporter ti = (TextureImporter)TextureImporter.GetAtPath(cardPath);
            ti.textureType = TextureImporterType.Sprite;
            ti.SaveAndReimport();
        }
}