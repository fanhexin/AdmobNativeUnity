#import "NativeAdViewController.h"
#import <GoogleMobileAds/GoogleMobileAds.h>
#import <UIKit/UIKit.h>

static NSArray<NSString *> *_nativeAdUnit;
static bool _videoStartMute;
static int _numOfAdsToLoad;
static int _unitIdIndex = 0;
static int _successNum = 0;
static int _failureNum = 0;
static bool _isLoading = false;

static NSMutableArray<GADUnifiedNativeAd*> *_cachedAdArr;
static bool _isAdShowing;
static NSString *_goName;
static NSString *_loadSuccessfulTriggerName;
static NSString *_loadFailedTriggerName;

@interface NativeAdViewController () <GADUnifiedNativeAdLoaderDelegate,
                              GADVideoControllerDelegate,
                              GADUnifiedNativeAdDelegate>

@property(nonatomic, strong) GADAdLoader *adLoader;
@property (nonatomic,strong) GADUnifiedNativeAdView *myView;
@property(nonatomic, strong) NSLayoutConstraint *heightConstraint;

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

bool hide(bool consume)
{
    return [myAdController hideNative:consume];
}

void load()
{
    if (_isLoading || is_ready()) {
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

void set_background_color(float r, float g, float b, float a)
{

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
    _cachedAdArr = [NSMutableArray new];
    
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
    return [_cachedAdArr count] > 0;
}

-(Boolean) hideNative:(Boolean)consume
{
    if(!_isAdShowing || ![self IsNativeReady])
    {
        return false;
    }
    
    _isAdShowing = false;
    if (consume) {
        [_cachedAdArr removeObjectAtIndex:0];
    }
    [self.myView setHidden:YES];
    return true;
}

- (void) requestAd
{
    GADVideoOptions *videoOptions = [[GADVideoOptions alloc] init];  //播放广告是否开启静音
    videoOptions.startMuted = _videoStartMute;
    
    GADMultipleAdsAdLoaderOptions *multipleAdsOptions = [[GADMultipleAdsAdLoaderOptions alloc] init];
    multipleAdsOptions.numberOfAds = _numOfAdsToLoad;
    
    GADNativeAdMediaAdLoaderOptions *mediaOptions = [[GADNativeAdMediaAdLoaderOptions alloc] init];
    mediaOptions.mediaAspectRatio = GADMediaAspectRatioLandscape;
        
    self.adLoader = [[GADAdLoader alloc] initWithAdUnitID:_nativeAdUnit[_unitIdIndex]
                                       rootViewController:self
                                                  adTypes:@[ kGADAdLoaderAdTypeUnifiedNative ]
                                                  options:@[ multipleAdsOptions, videoOptions, mediaOptions]];
    
    self.adLoader.delegate = self;
    [self.adLoader loadRequest:[GADRequest request]];
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
    
    GADUnifiedNativeAd* curNativeAdData = _cachedAdArr[0];
    if(curNativeAdData!= nil)
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
        nativeAdView.nativeAd = curNativeAdData;
        
        curNativeAdData.delegate = self;
        
        //body view >= 90 character
        // font size 10
        [((UILabel *)nativeAdView.bodyView) setFont:[UIFont systemFontOfSize:bodyFontSize * adaptationScale]];
        ((UILabel *)nativeAdView.bodyView).text = curNativeAdData.body;
        nativeAdView.bodyView.hidden = curNativeAdData.body ? NO : YES;
        
        //icon view
        ((UIImageView *)nativeAdView.iconView).image = curNativeAdData.icon.image;
        nativeAdView.iconView.hidden = curNativeAdData.icon ? NO : YES;
        
        
        //headlineView >=25 character
        //font size 13
        [((UILabel *)nativeAdView.headlineView) setFont:[UIFont systemFontOfSize: titleFontSize * adaptationScale]];
        ((UILabel *)nativeAdView.headlineView).text = curNativeAdData.headline;
        
        //callToActionView
//        [((UIButton *)nativeAdView.callToActionView).titleLabel setFont:[UIFont systemFontOfSize:callToActionFontSize * adaptationScale]];
//        [((UIButton *)nativeAdView.callToActionView) setTitle:curNativeAdData.callToAction
//                                                     forState:UIControlStateNormal];
//        nativeAdView.callToActionView.hidden = curNativeAdData.callToAction ? NO : YES;

        //NSLog(@"curNativeAd.videoController.aspectRatio %f", ratio);  //广告内容宽高比
        nativeAdView.mediaView.mediaContent = curNativeAdData.mediaContent;
               
        if(curNativeAdData.mediaContent.hasVideoContent)
        {
            // By acting as the delegate to the GADVideoController, this ViewController
            // receives messages about events in the video lifecycle.
            curNativeAdData.videoController.delegate = self;
        }
               

//        ((UIImageView *)nativeAdView.starRatingView).image = [self imageForStars:curNativeAdData.starRating];
//        nativeAdView.starRatingView.hidden = curNativeAdData.starRating ? NO : YES;
//
//        ((UILabel *)nativeAdView.storeView).text = curNativeAdData.store;
//        nativeAdView.storeView.hidden = curNativeAdData.store ? NO : YES;
//
//        ((UILabel *)nativeAdView.priceView).text = curNativeAdData.price;
//        nativeAdView.priceView.hidden = curNativeAdData.price ? NO : YES;

        ((UILabel *)nativeAdView.advertiserView).text = curNativeAdData.advertiser;
        nativeAdView.advertiserView.hidden = curNativeAdData.advertiser ? NO : YES;

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
    NSString* code = [NSString stringWithFormat:@"%ld", error.code];
    [self checkForComplete];
}

- (void)adLoader:(GADAdLoader *)adLoader didReceiveUnifiedNativeAd:(GADUnifiedNativeAd *)nativeAd
{
    ++_successNum;
    [_cachedAdArr addObject:nativeAd];
    [self checkForComplete];
}

- (void)reset
{
    _successNum = 0;
    _failureNum = 0;
    _isLoading = false;
}

- (void)checkForComplete
{
    if (_successNum + _failureNum != _numOfAdsToLoad) {
        return;
    }
    
    if (_successNum > 0) {
        [self reset];
        _unitIdIndex = 0;
        UnitySendMessage(_goName.UTF8String, _loadSuccessfulTriggerName.UTF8String, "");
        return;
    }
    
    [self reset];
    
    if (++_unitIdIndex > [_nativeAdUnit count] - 1) {
        _unitIdIndex = 0;
        UnitySendMessage(_goName.UTF8String, _loadFailedTriggerName.UTF8String, "");
        return;
    }
    
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
