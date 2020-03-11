using System;
using UnityEngine;

namespace AdmobNative.iOS
{
    public class EventListener : MonoBehaviour
    {
        public event Action<int> OnAdLoadFailed;
        public event Action OnAdLoadSuccessful;

        private void Awake()
        {
            DontDestroyOnLoad(this);
        }

        public void TriggerOnAdLoadFailed(int errorCode)
        {
            OnAdLoadFailed?.Invoke(errorCode);
        }

        public void TriggerOnAdLoadSuccessful()
        {
            OnAdLoadSuccessful?.Invoke();
        }
    }
}