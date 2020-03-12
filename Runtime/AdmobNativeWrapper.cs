using System;
using AdmobNative.Common;
using UnityEngine;
#if UNITY_ANDROID
using AdmobNative.Android;
#elif UNITY_IOS
using AdmobNative.iOS;
#endif

namespace AdmobNative
{
    public class AdmobNativeWrapper : IAdmobNativeWrapper
    {
        public event Action<int> OnAdLoadFailed
        {
            add => _wrapper.OnAdLoadFailed += value;
            remove => _wrapper.OnAdLoadFailed -= value;
        }

        public event Action OnAdLoadSuccessful
        {
            add => _wrapper.OnAdLoadSuccessful += value;
            remove => _wrapper.OnAdLoadSuccessful -= value;
        }

        public bool isReady => _wrapper.isReady;

        private readonly IAdmobNativeWrapper _wrapper;

        public AdmobNativeWrapper()
        {
#if UNITY_ANDROID            
            _wrapper = new AndroidAdmobNativeWrapper(Settings.instance.android.unitId);
#elif UNITY_IOS
            _wrapper = new iOSAdmobNativeWrapper(Settings.instance.iOS.unitId);
#endif
        }
        
        public void Init(Action completeCb)
        {
            _wrapper.Init(completeCb);
        }

        public void Load()
        {
            _wrapper.Load();
        }

        public void Show(int x, int y, int width, int height)
        {
            _wrapper.Show(x, y, width, height);
        }

        public void Show(int x, int y, int width, int height, Color color)
        {
            _wrapper.Show(x, y, width, height, color);    
        }

        public void Hide()
        {
            _wrapper.Hide();
        }
    }
}