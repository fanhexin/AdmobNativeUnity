using System;
using UnityEngine;

namespace AdmobNative
{
    public class AdServiceWrapper
    {
        public event Action<int> OnAdLoadFailed;
        
        private readonly AndroidJavaObject _adService;
        readonly Vector3[] _corners = new Vector3[4];

        public bool isReady => _adService.Call<bool>("isReady");

        public AdServiceWrapper(string adUnitId)
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

        public void Show(RectTransform canvas, RectTransform adPlaceholder)
        {
            adPlaceholder.GetWorldCorners(_corners);
            Vector2 bottomLeft = canvas.InverseTransformPoint(_corners[0]);
            
            float canvasWidth = canvas.rect.width;
            float canvasHeight = canvas.rect.height;
            
            int x = (int) ((canvasWidth / 2 - Mathf.Abs(bottomLeft.x)) / canvasWidth * Screen.width);
            int y = (int) ((canvasHeight / 2 - Mathf.Abs(bottomLeft.y)) / canvasHeight * Screen.height);
            int width = (int) (adPlaceholder.rect.width / canvasWidth * Screen.width);
            int height = (int) (adPlaceholder.rect.height / canvasHeight * Screen.height);
            
            Show(x, y, width, height);
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
