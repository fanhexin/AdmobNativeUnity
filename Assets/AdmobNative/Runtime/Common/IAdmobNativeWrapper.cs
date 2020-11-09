using System;

namespace AdmobNative.Common
{
    public interface IAdmobNativeWrapper
    {
        event Action<string> OnAdLoadFailed;
        event Action OnAdLoadSuccessful;
        
        bool isReady { get; }
        void Init(Action completeCb);
        void Load();
        void Show(int x, int y, int width, int height);
        void Hide(bool consume = true);
    }
}