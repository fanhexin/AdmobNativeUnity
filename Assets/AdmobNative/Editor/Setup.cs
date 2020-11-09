using System.IO;
using UnityEditor;
using UnityEngine;

namespace AdmobNative.Editor
{
    [InitializeOnLoad]
    public class Setup
    {
        const string PACKAGE_PATH = "Packages/com.hpcfun.admobnative";
        const string DEPENDENCIES_PATH = "Assets/Editor/AdmobNativeDependencies.xml";
        const string RESOURCES_PATH = "Assets/Resources";
        
        static Setup()
        {
            SetupDependencies();
            CreateSettings();

            if (!Directory.Exists("Assets/Plugins/Android/AdmobNativeResLib"))
            {
                ImportPkg();
            }
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

        static void ImportPkg()
        {
            string pkgPath = Path.Combine(PACKAGE_PATH, "Editor", "NativeAdViewResource.unitypackage");
            AssetDatabase.ImportPackage(pkgPath, true);
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