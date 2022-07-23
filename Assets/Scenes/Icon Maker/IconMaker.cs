using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using System.IO;
//https://answers.unity.com/questions/787589/creating-an-texture-asset.html

namespace Util
{

    public class IconMaker : MonoBehaviour
    {
        public Texture2D preview;
        /*
            public RenderTexture rt;
            [ContextMenu("Create")]
            public void Create()
            {

                // the 24 can be 0,16,24, formats like
                // RenderTextureFormat.Default, ARGB32 etc.

                GetComponent<Camera>().targetTexture = rt;
                GetComponent<Camera>().Render();

                RenderTexture.active = rt;
                Texture2D virtualPhoto = new Texture2D(rt.width, rt.height, TextureFormat.RGBA32, false);
                // false, meaning no need for mipmaps
                virtualPhoto.ReadPixels(new Rect(0, 0, rt.width, rt.height), 0, 0);

                RenderTexture.active = null; //can help avoid errors 
                GetComponent<Camera>().targetTexture = null;
                // consider ... Destroy(tempRT);

                byte[] bytes;
                bytes = virtualPhoto.EncodeToPNG();
                DestroyImmediate(virtualPhoto);
                System.IO.File.WriteAllBytes(Application.dataPath + "/", bytes);
            }
        */


        private const string previewPath = "Char Extras/Items/Previews";
        [MenuItem("DeepSpace/Create Preview...")]
        static void CreatePreview()
        {
            var transforms = Selection.GetTransforms(SelectionMode.TopLevel);

            if (transforms.Length > 0)
            {
                for (int i = 0; i < transforms.Length; i++)
                {
                    var t = transforms[i];
                    if (t.GetComponent<IconMaker>() == null &&
                        EditorUtility.DisplayDialog("Create Preview?", string.Format("Do you want to create and add a preview component to {0}", t), "Create", "Cancel"))
                    {
                        var prev = AssetPreview.GetAssetPreview(t.gameObject);
                        if (prev != null)
                        {
                            string path = Path.Combine(Application.dataPath, string.Format("{0}/{1}.png", previewPath, t.gameObject.name));
                            Debug.Log(string.Format("Creating asset at {0}", path));
                            File.WriteAllBytes(path, prev.EncodeToPNG());

                            var provider = t.gameObject.AddComponent<IconMaker>();
                            provider.preview = (Texture2D)AssetDatabase.LoadAssetAtPath("Assets/" + path, typeof(Texture2D));
                        }
                    }
                }


            }
        }
    }
}