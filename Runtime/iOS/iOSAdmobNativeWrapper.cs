using System;
using System.Runtime.InteropServices;
using AdmobNative.Common;
using UnityEngine;

namespace AdmobNative.iOS
{
    public class iOSAdmobNativeWrapper : IAdmobNativeWrapper
    {
        private readonly string _adUnitId;
        public event Action<int> OnAdLoadFailed;
        public event Action OnAdLoadSuccessful;
        public bool isReady => is_ready();

        public iOSAdmobNativeWrapper(string adUnitId)
        {
            _adUnitId = adUnitId;
            var go = new GameObject("iOSAdmobNativeEventListener");
            var eventListener = go.AddComponent<EventListener>();
            eventListener.OnAdLoadFailed += errorCode => OnAdLoadFailed?.Invoke(errorCode);
            eventListener.OnAdLoadSuccessful += () => OnAdLoadSuccessful?.Invoke();
            add_event_listener(eventListener.name, 
                nameof(eventListener.TriggerOnAdLoadSuccessful),
                nameof(eventListener.TriggerOnAdLoadFailed));
        }
        
        public void Init(Action completeCb)
        {
            init(_adUnitId, false);
            completeCb?.Invoke(); 
        }

        public void Load()
        {
            load();
        }

        public void Show(int x, int y, int width, int height)
        {
            Show(x, y, width, height, Color.white);
        }

        public void Show(int x, int y, int width, int height, Color color)
        {
            set_background_color(color.r, color.g, color.b, color.a); 
            show(x, y, width, height);
        }

        public void Hide()
        {
            hide();
        }
        
        [DllImport("__Internal")]
        private static extern void init(string unitId, bool videoMuteAtBegin);

        [DllImport("__Internal")]
        private static extern bool is_ready();
        
        [DllImport("__Internal")]
        private static extern void load();

        [DllImport("__Internal")]
        private static extern bool show(float x, float y, float width, float height);

        [DllImport("__Internal")]
        private static extern bool hide();    
        
        [DllImport("__Internal")]
        private static extern void add_event_listener(string goName, string loadSuccessfulTriggerName, string loadFailedTriggerName);

        [DllImport("__Internal")]
        private static extern void set_background_color(float r, float g, float b, float a);
    }
}