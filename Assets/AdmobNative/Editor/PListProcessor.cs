#if UNITY_IOS
using System.IO;
using AdmobNative;
using UnityEditor;
using UnityEditor.Callbacks;
using UnityEditor.iOS.Xcode;


public static class PListProcessor
{
    [PostProcessBuild]
    public static void OnPostProcessBuild(BuildTarget buildTarget, string path)
    {
		var plistPath = Path.Combine(path, "Info.plist");
		var plist = new PlistDocument();
		plist.ReadFromFile(plistPath);

		PlistElementDict rootDict = plist.root;
		rootDict.SetString("GADApplicationIdentifier", Settings.instance.appId);
		
		plist.WriteToFile(plistPath);
    }
}
#endif
