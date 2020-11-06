using UnityEngine;

namespace AdmobNative
{
    public class Settings : ScriptableObject
    {
        public const string FILE_NAME = "AdmobNativeSettings";
        static Settings _instance;

        public static Settings instance
        {
            get
            {
                if (_instance == null)
                {
                    _instance = Resources.Load<Settings>(FILE_NAME);
                }

                return _instance;
            }
        }

        [SerializeField] string _appId;
        [SerializeField] string[] _unitIds;
        [SerializeField] int _numOfAdsToLoad;

        public string appId => _appId;
        public string[] unitIds => _unitIds;
        public int numOfAdsToLoad => _numOfAdsToLoad;
    }
}