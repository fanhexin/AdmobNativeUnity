using System.IO;
using UnityEditor;
using UnityEngine;

namespace AdmobNative.Editor
{
    [InitializeOnLoad]
    public class Setup
    {
        const string PACKAGE_PATH = "Packages/com.hpc.admobnative";
        const string DEPENDENCIES_PATH = "Assets/Editor/AdmobNativeDependencies.xml";
        const string RES_LIB_PATH = "Assets/Plugins/Android/AdmobNativeResLib";
        const string RESOURCES_PATH = "Assets/Resources";
        
        static Setup()
        {
            SetupDependencies();
            CopyResLib();
            CreateSettings();
        }

        static void SetupDependencies()
        {
            if (File.Exists(DEPENDENCIES_PATH))
            {
                return;
            }

            string pkgFilePath = Path.Combine(PACKAGE_PATH, "Editor", "Dependencies.xml");
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

        static void CopyResLib()
        {
            if (AssetDatabase.IsValidFolder(RES_LIB_PATH))
            {
                
                return;
            }

            string resLibPath = Path.Combine(PACKAGE_PATH, "Editor", "AdmobNativeResLib");
            if (!AssetDatabase.IsValidFolder(resLibPath))
            {
                return;
            }

            AssetDatabase.CopyAsset(resLibPath, RES_LIB_PATH);
        }

        static void CreateSettings()
        {
            string path = Path.Combine(RESOURCES_PATH, $"{Settings.FILE_NAME}.asset");
            if (File.Exists(path))
            {
                return;
            }

            Directory.CreateDirectory(RESOURCES_PATH);
            var settings = ScriptableObject.CreateInstance<Settings>();
            AssetDatabase.CreateAsset(settings, path);
            AssetDatabase.Refresh();
            SettingsWindow.Show(settings);
        }
    }
}