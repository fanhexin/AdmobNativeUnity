using System;
using AdmobNative.Common;
using UnityEngine;

namespace AdmobNative.Android
{
    public class AndroidAdmobNativeWrapper : IAdmobNativeWrapper
    {
        public event Action<int> OnAdLoadFailed;
        
        private readonly AndroidJavaObject _adService;

        public bool isReady => _adService.Call<bool>("isReady");

        public AndroidAdmobNativeWrapper(string adUnitId)
        {
            AndroidJavaClass androidJavaClass = new AndroidJavaClass("com.unity3d.player.UnityPlayer");
            var curActivity = androidJavaClass.GetStatic<AndroidJavaObject>("currentActivity");
            _adService = new AndroidJavaObject("com.hpc.admobnative.AdService", curActivity, adUnitId);
        }

        public void Init(Action completeCb)
        {
            _adService.Call("init", new OnInitializationCompleteListener(completeCb));        
            _adService.Call("setAdFailedListener", new AdFailedListener(err => OnAdLoadFailed?.Invoke(err)));     
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
            private readonly Action _callback;

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

        class AdFailedListener : AndroidJavaProxy 
        {
            private readonly Action<int> _callback;

            public AdFailedListener(Action<int> callback) 
                : base("com.hpc.admobnative.AdFailedListener")
            {
                _callback = callback;
            }

            void onError(int errorCode)
            {
                _callback?.Invoke(errorCode);    
            }
        }
    }
}
