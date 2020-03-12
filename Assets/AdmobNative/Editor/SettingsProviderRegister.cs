using UnityEditor;

namespace AdmobNative.Editor
{
    public static class SettingsProviderRegister
    {
        [SettingsProvider]
        public static SettingsProvider CreateSettingsProvider()
        {
            var provider = new SettingsProvider("Project/AdmobNative", SettingsScope.Project)
            {
                label = "AdmobNative",
                guiHandler = context =>
                {
                    var editor = UnityEditor.Editor.CreateEditor(Settings.instance);
                    editor.OnInspectorGUI();
                }
            };

            return provider;
        }    
    }
}