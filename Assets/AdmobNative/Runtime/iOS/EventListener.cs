using System;
using UnityEngine;

namespace AdmobNative.iOS
{
    public class EventListener : MonoBehaviour
    {
        public event Action<string> OnAdLoadFailed;
        public event Action OnAdLoadSuccessful;

        private void Awake()
        {
            DontDestroyOnLoad(this);
        }

        public void TriggerOnAdLoadFailed(string errorMsg)
        {
            OnAdLoadFailed?.Invoke(errorMsg);
        }

        public void TriggerOnAdLoadSuccessful()
        {
            OnAdLoadSuccessful?.Invoke();
        }
    }
}