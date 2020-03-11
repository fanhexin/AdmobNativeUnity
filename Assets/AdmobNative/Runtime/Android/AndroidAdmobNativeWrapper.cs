using System;
using AdmobNative.Common;
using UnityEngine;

namespace AdmobNative.Android
{
    public class AndroidAdmobNativeWrapper : IAdmobNativeWrapper
    {
        public event Action<int> OnAdLoadFailed;
        public event Action OnAdLoadSuccessful;
        
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
            Show(x, y, width, height, Color.white);
        }

        public void Show(int x, int y, int width, int height, Color color)
        {
            _adService.Call("show", x, y, width, height, $"#{ColorUtility.ToHtmlStringRGB(color)}");
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

        class AdLoadListener : AndroidJavaProxy 
        {
            private readonly Action _onSucceedCb;
            private readonly Action<int> _onErrorCb;

            public AdLoadListener(Action onSucceedCb, Action<int> onErrorCb) 
                : base("com.hpc.admobnative.AdLoadListener")
            {
                _onSucceedCb = onSucceedCb;
                _onErrorCb = onErrorCb;
            }

            void onError(int errorCode)
            {
                _onErrorCb?.Invoke(errorCode);    
            }

            void onSucceed()
            {
                _onSucceedCb?.Invoke();    
            }
        }
    }
}
