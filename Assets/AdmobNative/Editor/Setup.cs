using System.IO;
using UnityEditor;
using UnityEditor.Experimental;
using UnityEngine;

namespace AdmobNative.Editor
{
    [InitializeOnLoad]
    public class Setup
    {
        private const string DEPENDENCIES_PATH = "Assets/Editor/AdmobNativeDependencies.xml";
        private const string PROGUARD_PATH = "Assets/Plugins/Android/proguard-user.txt";
        private const string PACKAGE_PATH = "Packages/com.github.fanhexin.admobnative";
        
        static Setup()
        {
            SetupDependencies();
            SetupProguard();
        }

        static void SetupDependencies()
        {
            if (File.Exists(DEPENDENCIES_PATH))
            {
                return;
            }

            string pkgFilePath = Path.Combine(PACKAGE_PATH, "Dependencies.xml");
            TextAsset textAsset = AssetDatabase.LoadAssetAtPath<TextAsset>(pkgFilePath);
            if (textAsset == null)
            {
                return;
            }
            
            string dirName = Path.GetDirectoryName(DEPENDENCIES_PATH);
            Directory.CreateDirectory(dirName);
            File.WriteAllText(DEPENDENCIES_PATH, textAsset.text);
            AssetDatabase.Refresh();
        }

        static void SetupProguard()
        {
            if (!File.Exists(PROGUARD_PATH))
            {
                return;
            }
            
            string pkgFilePath = Path.Combine(PACKAGE_PATH, "proguard-user.txt");
            TextAsset textAsset = AssetDatabase.LoadAssetAtPath<TextAsset>(pkgFilePath);
            if (textAsset == null)
            {
                return;
            }

            string localContent = File.ReadAllText(PROGUARD_PATH);
            if (localContent.Contains(textAsset.text))
            {
                return;
            }
            
            File.WriteAllText(PROGUARD_PATH, $"{localContent}\n{textAsset.text}");
        }
    }
}