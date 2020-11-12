#import "NativeAdViewController.h"
#import <GoogleMobileAds/GoogleMobileAds.h>
#import <UIKit/UIKit.h>

static NSArray<NSString *> *_nativeAdUnit;
static bool _videoStartMute;
static int _numOfAdsToLoad;
static int _curUnitIdIndex = 0;
static int _loadStartIndex = 0;
static int _loadEndIndex = 0;
static int _maxPriceUnitIdIndex = 0;
static int _successNum = 0;
static int _failureNum = 0;
static bool _isLoading = false;
static NSMutableDictionary<NSString*, GADUnifiedNativeAd*> *_index2NativeAd;
static NSMutableDictionary<NSString*, NSString*> *_unitId2ErrorMsg;

static GADUnifiedNativeAd *_nativeAd;
static bool _isAdShowing;
static NSString *_goName;
static NSString *_loadSuccessfulTriggerName;
static NSString *_loadFailedTriggerName;

@interface NativeAdViewController () <GADUnifiedNativeAdLoaderDelegate,
                              GADVideoControllerDelegate,
                              GADUnifiedNativeAdDelegate>

@property (nonatomic,strong) GADUnifiedNativeAdView *myView;
@property(nonatomic, strong) NSLayoutConstraint *heightConstraint;
@property(nonatomic, strong) NSMutableArray<GADAdLoader *> *adLoaders;

@end

@implementation NativeAdViewController

static NativeAdViewController *myAdController;

#pragma mark Unity Methods

void init(char *unitIds, bool videoMuteAtBegin, int numOfAdsToLoad)
{
    if(!myAdController)
        myAdController = [NativeAdViewController new];
    
    NSString *unitIdsStr = [NSString stringWithUTF8String:unitIds];
    NSArray<NSString *> *unitIdArr = [unitIdsStr componentsSeparatedByString:@","];
       
    [myAdController initNative:unitIdArr
              isVideoStartMute:videoMuteAtBegin
            numOfAdsToLoad:numOfAdsToLoad];
}

bool is_ready()
{
    return [myAdController IsNativeReady];
}

bool show(float x, float y, float width, float height)
{
    return [myAdController
            showNativeAd:width
            sizeY:height
            posX:x
            posY:y];
}

bool hide()
{
    return [myAdController hideNative];
}

void load()
{
    if (_isLoading) {
        return;
    }
    _isLoading = true;
    
    [myAdController requestAd];
}

void add_event_listener(char* goName, char* loadSuccessfulTriggerName, char* loadFailedTriggerName)
{
    _goName = [NSString stringWithUTF8String:goName];
    _loadSuccessfulTriggerName = [NSString stringWithUTF8String:loadSuccessfulTriggerName];
    _loadFailedTriggerName = [NSString stringWithUTF8String:loadFailedTriggerName];
}

#pragma mark Objective C Methods

-(void)initNative:(NSArray<NSString *> *)nativeAd
 isVideoStartMute:(bool)isVideoStartMute
numOfAdsToLoad:(int)numOfAdsToLoad
{
    [[GADMobileAds sharedInstance] startWithCompletionHandler:nil];  //初始化Admob广告
    
    _nativeAdUnit = nativeAd;
    _videoStartMute = isVideoStartMute;
    _numOfAdsToLoad = numOfAdsToLoad;
    _isAdShowing = false;
    
    _maxPriceUnitIdIndex = _nativeAdUnit.count;
    _index2NativeAd = [NSMutableDictionary<NSString*, GADUnifiedNativeAd*> new];
    _unitId2ErrorMsg = [NSMutableDictionary<NSString*, NSString*> new];
    _curUnitIdIndex = _nativeAdUnit.count - 1;
    [self resetLoadRange];
    
    self.adLoaders = [NSMutableArray new];
    NSBundle *bundle = [NSBundle mainBundle];
    if (![bundle pathForResource:@"UnifiedNativeAdView" ofType:@"nib"])
    {
        bundle = [NSBundle bundleWithIdentifier:@"com.unity3d.framework"];
    }
        
    NSArray *nibObjects = [bundle loadNibNamed:@"UnifiedNativeAdView" owner:nil options:nil];
    
    self.myView = (GADUnifiedNativeAdView *)nibObjects.firstObject;
    [UnityGetGLView() addSubview:self.myView];
    [self.myView setHidden:YES];
}

-(Boolean) IsNativeReady
{
    return _nativeAd != nil;
}

-(Boolean) hideNative
{
    if(!_isAdShowing || ![self IsNativeReady])
    {
        return false;
    }
    
    _isAdShowing = false;
    [self.myView setHidden:YES];
    return true;
}

- (void) requestAd
{
    GADVideoOptions *videoOptions = [[GADVideoOptions alloc] init];  //播放广告是否开启静音
    videoOptions.startMuted = _videoStartMute;
    
    GADMultipleAdsAdLoaderOptions *multipleAdsOptions = [[GADMultipleAdsAdLoaderOptions alloc] init];
    multipleAdsOptions.numberOfAds = 1;
    
    GADNativeAdMediaAdLoaderOptions *mediaOptions = [[GADNativeAdMediaAdLoaderOptions alloc] init];
    mediaOptions.mediaAspectRatio = GADMediaAspectRatioLandscape;
        
    for (int i = _loadStartIndex; i <= _loadEndIndex; i++) {
        GADAdLoader *adLoader = [[GADAdLoader alloc] initWithAdUnitID:_nativeAdUnit[i]
                                           rootViewController:self
                                                      adTypes:@[ kGADAdLoaderAdTypeUnifiedNative ]
                                                      options:@[ videoOptions, mediaOptions, multipleAdsOptions]];
        
        adLoader.delegate = self;
        [adLoader loadRequest:[GADRequest request]];
        [self.adLoaders addObject:adLoader];
    }
}

-(Boolean)showNativeAd:(float) sizeX
                 sizeY:(float)sizeY
                  posX:(float)posX
                  posY:(float)posY
{
    if(_isAdShowing || ![self IsNativeReady])
    {
        return false;
    }
    
    //各元素大小
    
    CGFloat titleFontSize = 13;
    CGFloat bodyFontSize = 10;
    
    //目标分辨率，当前设备需要根据分辨率调整字体等大小
    CGFloat adaptationScale = 1;
    
    if(_nativeAd != nil)
    {
        _isAdShowing = true;
        [self.myView setHidden:NO];
            
        GADUnifiedNativeAdView *nativeAdView = self.myView;
        
        CGFloat factor = UnityGetGLView().contentScaleFactor;
        CGFloat frameWidth = sizeX / factor;
        CGFloat frameHeight = sizeY / factor;
        
        CGRect screenBounds = [[UIScreen mainScreen] bounds];
        posY = screenBounds.size.height - (posY / factor) - frameHeight;
        posX /= factor;
        nativeAdView.frame = CGRectMake(posX, posY, frameWidth, frameHeight);
                
        // Deactivate the height constraint that was set when the previous video ad loaded.
        self.heightConstraint.active = NO;
        nativeAdView.nativeAd = _nativeAd;
        
        _nativeAd.delegate = self;
        
        //body view >= 90 character
        // font size 10
        [((UILabel *)nativeAdView.bodyView) setFont:[UIFont systemFontOfSize:bodyFontSize * adaptationScale]];
        ((UILabel *)nativeAdView.bodyView).text = _nativeAd.body;
        nativeAdView.bodyView.hidden = _nativeAd.body ? NO : YES;
        
        //icon view
        ((UIImageView *)nativeAdView.iconView).image = _nativeAd.icon.image;
        nativeAdView.iconView.hidden = _nativeAd.icon ? NO : YES;
        
        
        //headlineView >=25 character
        //font size 13
        [((UILabel *)nativeAdView.headlineView) setFont:[UIFont systemFontOfSize: titleFontSize * adaptationScale]];
        ((UILabel *)nativeAdView.headlineView).text = _nativeAd.headline;
        
        //callToActionView
//        [((UIButton *)nativeAdView.callToActionView).titleLabel setFont:[UIFont systemFontOfSize:callToActionFontSize * adaptationScale]];
//        [((UIButton *)nativeAdView.callToActionView) setTitle:curNativeAdData.callToAction
//                                                     forState:UIControlStateNormal];
//        nativeAdView.callToActionView.hidden = curNativeAdData.callToAction ? NO : YES;

        //NSLog(@"curNativeAd.videoController.aspectRatio %f", ratio);  //广告内容宽高比
        nativeAdView.mediaView.mediaContent = _nativeAd.mediaContent;
               
        if(_nativeAd.mediaContent.hasVideoContent)
        {
            // By acting as the delegate to the GADVideoController, this ViewController
            // receives messages about events in the video lifecycle.
            _nativeAd.videoController.delegate = self;
        }
               

//        ((UIImageView *)nativeAdView.starRatingView).image = [self imageForStars:curNativeAdData.starRating];
//        nativeAdView.starRatingView.hidden = curNativeAdData.starRating ? NO : YES;
//
//        ((UILabel *)nativeAdView.storeView).text = curNativeAdData.store;
//        nativeAdView.storeView.hidden = curNativeAdData.store ? NO : YES;
//
//        ((UILabel *)nativeAdView.priceView).text = curNativeAdData.price;
//        nativeAdView.priceView.hidden = curNativeAdData.price ? NO : YES;

        ((UILabel *)nativeAdView.advertiserView).text = _nativeAd.advertiser;
        nativeAdView.advertiserView.hidden = _nativeAd.advertiser ? NO : YES;

        // In order for the SDK to process touch events properly, user interaction
        // should be disabled.
        nativeAdView.callToActionView.userInteractionEnabled = NO;
    }
    
    return true;
}

#pragma mark GADAdLoaderDelegate

- (void)adLoader:(GADAdLoader *)adLoader didFailToReceiveAdWithError:(GADRequestError *)error
{
    ++_failureNum;
    _unitId2ErrorMsg[adLoader.adUnitID] = error.description;
    [self checkForComplete];
}

- (void)adLoader:(GADAdLoader *)adLoader didReceiveUnifiedNativeAd:(GADUnifiedNativeAd *)nativeAd
{
    int index = [_nativeAdUnit indexOfObject:adLoader.adUnitID];
    if (_maxPriceUnitIdIndex > index) {
        _maxPriceUnitIdIndex = index;
    }
    _index2NativeAd[[NSString stringWithFormat:@"%d", index]] = nativeAd;
    ++_successNum;
    [self checkForComplete];
}

- (void)resetLoadRange
{
    _loadStartIndex = 0;
    _loadEndIndex = MIN(_numOfAdsToLoad - 1, _curUnitIdIndex);
}

- (void)reset
{
    _successNum = 0;
    _failureNum = 0;
    _isLoading = false;
    _maxPriceUnitIdIndex = _nativeAdUnit.count;
    [self.adLoaders removeAllObjects];
}

- (void)checkForComplete
{
    if ((_successNum + _failureNum) != (_loadEndIndex - _loadStartIndex + 1)) {
        return;
    }
    
    if (_successNum > 0) {
        _curUnitIdIndex = _maxPriceUnitIdIndex;
        [self reset];
        [self resetLoadRange];
        
        NSString *indexStr = [NSString stringWithFormat:@"%d", _curUnitIdIndex];
        _nativeAd = _index2NativeAd[indexStr];
        UnitySendMessage(_goName.UTF8String, _loadSuccessfulTriggerName.UTF8String, "");
        [_index2NativeAd removeAllObjects];
        return;
    }
    
    [self reset];
    
    _loadStartIndex = _loadEndIndex + 1;
    if (_loadStartIndex > _curUnitIdIndex)
    {
        [self resetLoadRange];
        UnitySendMessage(_goName.UTF8String, _loadFailedTriggerName.UTF8String, _unitId2ErrorMsg.description.UTF8String);
        [_unitId2ErrorMsg removeAllObjects];
        return;
    }
    
    _loadEndIndex = MIN(_loadStartIndex + _numOfAdsToLoad, _curUnitIdIndex);
    [self requestAd];
}

- (void)adLoaderDidFinishLoading:(GADAdLoader *) adLoader {
  // The adLoader has finished loading ads, and a new request can be sent.
    //NSLog(@"adLoader FinishLoading");
}

/// Gets an image representing the number of stars. Returns nil if rating is less than 3.5 stars.
- (UIImage *)imageForStars:(NSDecimalNumber *)numberOfStars {
    double starRating = numberOfStars.doubleValue;
    if (starRating >= 5) {
        return [UIImage imageNamed:@"stars_5"];
    } else if (starRating >= 4.5) {
        return [UIImage imageNamed:@"stars_4_5"];
    } else if (starRating >= 4) {
        return [UIImage imageNamed:@"stars_4"];
    } else if (starRating >= 3.5) {
        return [UIImage imageNamed:@"stars_3_5"];
    } else {
        return nil;
    }
}

@end
