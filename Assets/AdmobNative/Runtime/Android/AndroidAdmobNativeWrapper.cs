using System;
using AdmobNative.Common;
using UnityEngine;

namespace AdmobNative.Android
{
    public class AndroidAdmobNativeWrapper : IAdmobNativeWrapper
    {
        public event Action<string> OnAdLoadFailed;
        public event Action OnAdLoadSuccessful;

        readonly AndroidJavaObject _adService;

        public bool isReady => _adService.Call<bool>("isReady");

        public AndroidAdmobNativeWrapper(string[] unitIds, int numOfAdsToLoad, int timeout)
        {
            AndroidJavaClass androidJavaClass = new AndroidJavaClass("com.unity3d.player.UnityPlayer");
            var curActivity = androidJavaClass.GetStatic<AndroidJavaObject>("currentActivity");
            _adService = new AndroidJavaObject("com.hpc.admobnative.AdService", curActivity, unitIds, numOfAdsToLoad, timeout);
        }

        public void Init(Action completeCb)
        {
            _adService.Call("init", new OnInitializationCompleteListener(completeCb));        
            _adService.Call("setAdLoadListener", new AdLoadListener(
                () => OnAdLoadSuccessful?.Invoke(), 
                err => OnAdLoadFailed?.Invoke(err)));     
        }

        public void Load()
        {
            _adService.Call("load");    
        }

        public void Show(int x, int y, int width, int height)
        {
            _adService.Call("show", x, y, width, height);
        }

        public void Hide()
        {
            _adService.Call("hide");    
        }

        class OnInitializationCompleteListener : AndroidJavaProxy 
        {
            readonly Action _callback;

            public OnInitializationCompleteListener(Action callback) 
                : base("com.google.android.gms.ads.initialization.OnInitializationCompleteListener")
            {
                _callback = callback;
            }

            void onInitializationComplete(AndroidJavaObject var1)
            {
                _callback?.Invoke();
            }
        }

        class AdLoadListener : AndroidJavaProxy 
        {
            readonly Action _onSucceedCb;
            readonly Action<string> _onErrorCb;

            public AdLoadListener(Action onSucceedCb, Action<string> onErrorCb) 
                : base("com.hpc.admobnative.AdLoadListener")
            {
                _onSucceedCb = onSucceedCb;
                _onErrorCb = onErrorCb;
            }

            void onError(string errorMsg)
            {
                _onErrorCb?.Invoke(errorMsg);    
            }

            void onSucceed()
            {
                _onSucceedCb?.Invoke();    
            }
        }
    }
}
