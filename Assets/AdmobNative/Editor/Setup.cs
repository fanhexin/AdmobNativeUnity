using System.IO;
using UnityEditor;
using UnityEngine;

namespace AdmobNative.Editor
{
    [InitializeOnLoad]
    public class Setup
    {
        public const string PACKAGE_PATH = "Packages/com.github.fanhexin.admobnative";
        private const string DEPENDENCIES_PATH = "Assets/Editor/AdmobNativeDependencies.xml";
        private const string PROGUARD_PATH = "Assets/Plugins/Android/proguard-user.txt";
        private const string RESOURCES_PATH = "Assets/Resources";
        private const string IOS_PLUGIN_PATH = "Assets/Plugins/iOS";
        
        static Setup()
        {
            SetupDependencies();
            SetupProguard();
            CreateSettings();
            CopyiOSNibFile();
        }

        private static void CopyiOSNibFile()
        {
            string xib = "UnifiedNativeAdView.xib";
            string destPath = Path.Combine(IOS_PLUGIN_PATH, xib);
            if (File.Exists(destPath))
            {
                return;
            }
            
            Directory.CreateDirectory(IOS_PLUGIN_PATH);
            string path = Path.Combine(PACKAGE_PATH, "Editor", xib);
            File.Copy(path, destPath);
            AssetDatabase.Refresh();
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

        static void SetupProguard()
        {
            if (!File.Exists(PROGUARD_PATH))
            {
                return;
            }
            
            string pkgFilePath = Path.Combine(PACKAGE_PATH, "Editor", "proguard-user.txt");
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
        
        private static void CreateSettings()
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