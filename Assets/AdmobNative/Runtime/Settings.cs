using System;
using UnityEngine;

namespace AdmobNative
{
    public class Settings : ScriptableObject
    {
        public const string FILE_NAME = "AdmobNativeSettings";
        private static Settings _instance;

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
        
        [Serializable]
        public class Item
        {
            [SerializeField] private string _appId;
            [SerializeField] private string _unitId;

            public string appId => _appId;
            public string unitId => _unitId;
        }

        [SerializeField] private Item _android;
        [SerializeField] private Item _iOS;

        public Item android => _android;
        public Item iOS => _iOS;
    }
}