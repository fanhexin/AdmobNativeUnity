using System;
using AdmobNative.Android;
using AdmobNative.Common;

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

        public AdmobNativeWrapper(string adUnitId)
        {
#if UNITY_ANDROID            
            _wrapper = new AndroidAdmobNativeWrapper(adUnitId);
#elif UNITY_IOS
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