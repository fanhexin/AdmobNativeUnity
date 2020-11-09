using System;
using System.Runtime.InteropServices;
using AdmobNative.Common;
using UnityEngine;

namespace AdmobNative.iOS
{
    public class iOSAdmobNativeWrapper : IAdmobNativeWrapper
    {
        readonly string[] _unitIds;
        readonly int _numOfAdsToLoad;
        public event Action<string> OnAdLoadFailed;
        public event Action OnAdLoadSuccessful;
        public bool isReady => is_ready();

        public iOSAdmobNativeWrapper(string[] unitIds, int numOfAdsToLoad)
        {
            _unitIds = unitIds;
            _numOfAdsToLoad = numOfAdsToLoad;
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
            init(string.Join(",", _unitIds), true, _numOfAdsToLoad);
            completeCb?.Invoke(); 
        }

        public void Load()
        {
            load();
        }

        public void Show(int x, int y, int width, int height)
        {
            show(x, y, width, height);
        }

        public void Hide(bool consume = true)
        {
            hide(consume);
        }
        
        [DllImport("__Internal")]
        static extern void init(string unitIds, bool videoMuteAtBegin, int numOfAdsToLoad);

        [DllImport("__Internal")]
        static extern bool is_ready();
        
        [DllImport("__Internal")]
        static extern void load();

        [DllImport("__Internal")]
        static extern bool show(float x, float y, float width, float height);

        [DllImport("__Internal")]
        static extern bool hide(bool consume);    
        
        [DllImport("__Internal")]
        static extern void add_event_listener(string goName, string loadSuccessfulTriggerName, string loadFailedTriggerName);
    }
}