using System;
using System.Linq;
using AdmobNative.Common;
#if UNITY_ANDROID
using AdmobNative.Android;
#elif UNITY_IOS
using AdmobNative.iOS;
#endif

namespace AdmobNative
{
    public class AdmobNativeWrapper : IAdmobNativeWrapper
    {
        public event Action<string> OnAdLoadFailed
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

        readonly IAdmobNativeWrapper _wrapper;

        public AdmobNativeWrapper()
        {
            var settings = Settings.instance;
#if UNITY_ANDROID            
            _wrapper = new AndroidAdmobNativeWrapper(settings.unitIds, settings.numOfAdsToLoad, settings.timeout);
#elif UNITY_IOS
            _wrapper = new iOSAdmobNativeWrapper(settings.unitIds, settings.numOfAdsToLoad, settings.timeout);
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

        public void Hide()
        {
            _wrapper.Hide();
        }
    }
}