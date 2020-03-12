using UnityEditor;
using UnityEngine;

namespace AdmobNative.Editor
{
    public class SettingsWindow : EditorWindow
    {
        private UnityEditor.Editor _settingsEditor;

        public static void Show(ScriptableObject settings)
        {
            var window = GetWindow<SettingsWindow>();
            window.Show();
            window._settingsEditor = UnityEditor.Editor.CreateEditor(settings);
        }

        private void OnGUI()
        {
            _settingsEditor.OnInspectorGUI();
        }
    }
}