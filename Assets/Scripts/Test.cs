using AdmobNative;
using UnityEngine;
using UnityEngine.UI;

public class Test : MonoBehaviour
{
    [SerializeField]
    private RectTransform _nativeAdPlaceholder;

    [SerializeField] private Button _showBtn;
    [SerializeField] private Button _hideBtn;
    [SerializeField] private RectTransform _canvas;

    private AdmobNativeWrapper _admobNative;

    void Start()
    {
        _showBtn.onClick.AddListener(OnShowBtnClick);
        _hideBtn.onClick.AddListener(OnHideBtnClick);
        
        _admobNative = new AdmobNativeWrapper();     
        _admobNative.OnAdLoadSuccessful += () => Debug.Log("UnityAdmobNative ad load successful!");
        _admobNative.OnAdLoadFailed += errCode => Debug.Log($"UnityAdmobNative ad load failed {errCode}!");
        
        _admobNative.Init(() =>
        {
            _admobNative.Load();
        });
        
        InvokeRepeating("UpdateShowBtnState", 0, 2);
    }

    private void OnHideBtnClick()
    {
        _admobNative.Hide();
        _admobNative.Load();
    }

    void UpdateShowBtnState()
    {
        _showBtn.interactable = _admobNative.isReady;
    }

    private void OnShowBtnClick()
    {
        _admobNative.Show(_canvas, _nativeAdPlaceholder, Color.green);
    }
}
