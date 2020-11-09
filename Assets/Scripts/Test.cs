using AdmobNative;
using UnityEngine;
using UnityEngine.UI;

public class Test : MonoBehaviour
{
    [SerializeField] RectTransform _nativeAdPlaceholder;

    [SerializeField] Button _showBtn;
    [SerializeField] Button _hideBtn;
    [SerializeField] Button _hideAndConsumeBtn;
    [SerializeField] RectTransform _canvas;

    AdmobNativeWrapper _admobNative;

    void Start()
    {
        _showBtn.onClick.AddListener(OnShowBtnClick);
        _hideBtn.onClick.AddListener(() => _admobNative.Hide(false));
        _hideAndConsumeBtn.onClick.AddListener(OnHideBtnClick);
        
        _admobNative = new AdmobNativeWrapper();     
        _admobNative.OnAdLoadSuccessful += () => Debug.Log("UnityAdmobNative ad load successful!");
        _admobNative.OnAdLoadFailed += errCode => Debug.Log($"UnityAdmobNative ad load failed {errCode}!");
        
        _admobNative.Init(() =>
        {
            _admobNative.Load();
        });
        
        InvokeRepeating(nameof(UpdateShowBtnState), 0, 2);
    }

    void OnHideBtnClick()
    {
        _admobNative.Hide();
        _admobNative.Load();
    }

    void UpdateShowBtnState()
    {
        _showBtn.interactable = _admobNative.isReady;
    }

    void OnShowBtnClick()
    {
        _admobNative.Show(_canvas, _nativeAdPlaceholder);
    }
}
