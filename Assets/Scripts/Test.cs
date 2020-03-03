using AdmobNative;
using UnityEngine;
using UnityEngine.UI;

public class Test : MonoBehaviour
{
    [SerializeField]
    private string _adUnitId;
    
    [SerializeField]
    private RectTransform _nativeAdPlaceholder;

    [SerializeField] private Button _showBtn;
    [SerializeField] private Button _hideBtn;
    [SerializeField] private RectTransform _canvas;

    private AdServiceWrapper _adService;

    void Start()
    {
        _showBtn.onClick.AddListener(OnShowBtnClick);
        _hideBtn.onClick.AddListener(OnHideBtnClick);
        
        _adService = new AdServiceWrapper(_adUnitId);     
        _adService.Init(() =>
        {
            _adService.Load();
        });
        
        InvokeRepeating("UpdateShowBtnState", 0, 2);
    }

    private void OnHideBtnClick()
    {
        _adService.Hide();
        _adService.Load();
    }

    void UpdateShowBtnState()
    {
        _showBtn.interactable = _adService.isReady;
    }

    private void OnShowBtnClick()
    {
        _adService.Show(_canvas, _nativeAdPlaceholder);
    }
}
