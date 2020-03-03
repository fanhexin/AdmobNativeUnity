using System.IO;
using UnityEditor;
using UnityEngine;

namespace AdmobNative.Editor
{
    [InitializeOnLoad]
    public class Setup
    {
        private const string FILE_PATH = "Assets/Editor/Dependencies.xml";
        private const string PROGUARD_PATH = "Assets/Plugins/Android/proguard-user.txt";
        
        static Setup()
        {
            SetupDependencies();
            SetupProguard();
        }

        static void SetupDependencies()
        {
            if (File.Exists(FILE_PATH))
            {
                return;
            }

            string fileName = Path.GetFileNameWithoutExtension(FILE_PATH);
            string content = Resources.Load<TextAsset>(fileName).text;
            string dirName = Path.GetDirectoryName(FILE_PATH);
            Directory.CreateDirectory(dirName);
            File.WriteAllText(Path.Combine(dirName, $"AdmobNative{fileName}.xml"), content);
            AssetDatabase.Refresh();
        }

        static void SetupProguard()
        {
            if (!File.Exists(PROGUARD_PATH))
            {
                return;
            }

            string fileName = Path.GetFileNameWithoutExtension(PROGUARD_PATH);
            string configContent = Resources.Load<TextAsset>(fileName).text;
            string localContent = File.ReadAllText(PROGUARD_PATH);
            if (localContent.Contains(configContent))
            {
                return;
            }
            
            File.WriteAllText(PROGUARD_PATH, $"{localContent}\n{configContent}");
        }
    }
}