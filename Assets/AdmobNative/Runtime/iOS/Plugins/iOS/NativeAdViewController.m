#import "NativeAdViewController.h"
#import <GoogleMobileAds/GoogleMobileAds.h>
#import <UIKit/UIKit.h>

static NSString *_nativeAdUnit;
static bool _videoStartMute;
static int _numberOfCachedAds;
static GADUnifiedNativeAd* _cachedAdDataArray[5] = {nil, nil, nil, nil, nil};
static int _showAdIndex;
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
@property(nonatomic, strong) UIColor* backgroundColor;

@end

@implementation NativeAdViewController

static NativeAdViewController *myAdController;

#pragma mark Unity Methods

void init(char *unitId, bool videoMuteAtBegin)
{
    if(!myAdController)
        myAdController = [NativeAdViewController new];
    
    NSString *ocnativeAd = [NSString stringWithUTF8String:unitId];
       
    [myAdController initNative:ocnativeAd
              isVideoStartMute:videoMuteAtBegin
            nativeCachedNumber:1];
    
    myAdController.backgroundColor = UIColor.whiteColor;
}

bool is_ready()
{
    return [myAdController IsNativeReady] && ![myAdController isNativeLoading];
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
    if (!myAdController)
    {
        return;
    }
    
    myAdController.backgroundColor = [UIColor colorWithRed:r green:g blue:b alpha:a];
}

#pragma mark Objective C Methods

-(void)initNative:(NSString *)nativeAd
 isVideoStartMute:(bool)isVideoStartMute
nativeCachedNumber:(int)nativeCachedNumber
{

    if (nativeCachedNumber > 5)
    {
        nativeCachedNumber = 5;
    }
    else if (nativeCachedNumber < 1)
    {
        nativeCachedNumber = 1;
    }
        
    [[GADMobileAds sharedInstance] startWithCompletionHandler:nil];  //初始化Admob广告
    
    _nativeAdUnit = nativeAd;
    _videoStartMute = isVideoStartMute;
    _numberOfCachedAds = nativeCachedNumber;
    _showAdIndex = -1;
    _isAdShowing = false;
    
    NSBundle *bundle = [NSBundle mainBundle];
    if (![bundle pathForResource:@"UnifiedNativeAdView" ofType:@"xib"])
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
    for (int i = 0; i < _numberOfCachedAds; ++i)
    {
        if (_cachedAdDataArray[i] != nil)
        {
            return true;
        }
    }

    return false;
}

-(Boolean) isNativeLoading
{
    if(_adLoader != nil)
    {
        return _adLoader.isLoading;
    }
    return false;
}

-(Boolean) hideNative
{
    if(!_isAdShowing)
    {
        return false;
    }
    _isAdShowing = false;
    if(_showAdIndex > -1)
    {
      _cachedAdDataArray[_showAdIndex] = nil;
    }
    _showAdIndex = -1;
    
    [self.myView setHidden:YES];
    
    return true;
}

- (void) requestAd
{
    int needLoadCount = 0;
    for (int i = 0; i < _numberOfCachedAds; ++i)
    {
        if (_cachedAdDataArray[i] == nil)
        {
           ++needLoadCount;
        }
    }
    if (needLoadCount == 0)
    {
        return;
    }
    
    GADVideoOptions *videoOptions = [[GADVideoOptions alloc] init];  //播放广告是否开启静音
    videoOptions.startMuted = _videoStartMute;
    
    GADMultipleAdsAdLoaderOptions *multipleAdsOptions = [[GADMultipleAdsAdLoaderOptions alloc] init];
    multipleAdsOptions.numberOfAds = needLoadCount;
        
    self.adLoader = [[GADAdLoader alloc] initWithAdUnitID:_nativeAdUnit
                                       rootViewController:self
                                                  adTypes:@[ kGADAdLoaderAdTypeUnifiedNative ]
                                                  options:@[ multipleAdsOptions, videoOptions]];
    
    self.adLoader.delegate = self;
    [self.adLoader loadRequest:[GADRequest request]];
}

-(Boolean)showNativeAd:(float) sizeX
                 sizeY:(float)sizeY
                  posX:(float)posX
                  posY:(float)posY
{
    if(_isAdShowing)
    {
        return false;
    }
    
    if(![myAdController IsNativeReady])
    {
        return false;
    }
    
    for (int i = 0; i < _numberOfCachedAds; ++i)
     {
         if(_cachedAdDataArray[i] != nil)
         {
             _showAdIndex = i;
             break;
         }
     }
    
    //各元素大小
    CGFloat iconWidth = 35;
    CGFloat iconHeight = 35;
    
    CGFloat callToActionBtnWidth = 72;
    CGFloat callToActionBtnHeight = 56;
    
    CGFloat titleFontSize = 13;
    CGFloat bodyFontSize = 10;
    CGFloat callToActionFontSize = 15;
    
    CGFloat bodyHeadLinePercentSize = 0.7;
    
    
    //目标分辨率，当前设备需要根据分辨率调整字体等大小
    CGFloat kscreenW = [UIScreen mainScreen].bounds.size.width;
    CGFloat kscreenH = [UIScreen mainScreen].bounds.size.height;
    CGFloat adaptationScale = 1;
    
    GADUnifiedNativeAd* curNativeAdData = _cachedAdDataArray[_showAdIndex];
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
        nativeAdView.backgroundColor = self.backgroundColor;
        
        curNativeAdData.delegate = self;

        CGFloat marginX = 10.0;
        CGFloat marginY = 5.0;
        
        //body view >= 90 character
        // font size 10
        [((UILabel *)nativeAdView.bodyView) setFont:[UIFont systemFontOfSize:bodyFontSize * adaptationScale]];
        ((UILabel *)nativeAdView.bodyView).text = curNativeAdData.body;
        nativeAdView.bodyView.hidden = curNativeAdData.body ? NO : YES;
        CGRect bodyViewRect = nativeAdView.bodyView.frame;
        bodyViewRect.origin.y = frameHeight - bodyViewRect.size.height;
        bodyViewRect.origin.x = marginX;
        bodyViewRect.size.width = frameWidth * bodyHeadLinePercentSize;
        nativeAdView.bodyView.frame = bodyViewRect;
        //[NativeAdViewController PrintUIView:@"bodyView" uiview:nativeAdView.bodyView];
        
        //icon view
        ((UIImageView *)nativeAdView.iconView).image = curNativeAdData.icon.image;
        nativeAdView.iconView.hidden = curNativeAdData.icon ? NO : YES;
        CGRect iconViewRect = nativeAdView.iconView.frame;
        
        [((UIButton *)nativeAdView.callToActionView).titleLabel setLineBreakMode:UILineBreakModeTailTruncation];
        [((UIButton *)nativeAdView.callToActionView).titleLabel setNumberOfLines:2];

        if(!nativeAdView.iconView.hidden)
        {
            iconViewRect.origin.x = marginX;
            iconViewRect.size.width = iconWidth * adaptationScale;
            iconViewRect.size.height = iconHeight * adaptationScale;
            iconViewRect.origin.y = bodyViewRect.origin.y - iconViewRect.size.height;
            nativeAdView.iconView.frame = iconViewRect;
        }
        
        //headlineView >=25 character
        //font size 13
        [((UILabel *)nativeAdView.headlineView) setFont:[UIFont systemFontOfSize: titleFontSize * adaptationScale]];
        ((UILabel *)nativeAdView.headlineView).text = curNativeAdData.headline;
        CGRect headlineViewRect = nativeAdView.headlineView.frame;
        headlineViewRect.origin.y = bodyViewRect.origin.y - headlineViewRect.size.height;
        headlineViewRect.origin.x = marginX;
        headlineViewRect.size.width = (nativeAdView.iconView.hidden ? bodyHeadLinePercentSize : 0.5) * frameWidth;
        nativeAdView.headlineView.frame = headlineViewRect;
        
        //如果icon显示 headline右移
        if(!nativeAdView.iconView.hidden)
        {
          headlineViewRect.origin.x = iconViewRect.origin.x + iconViewRect.size.width + marginX;
          headlineViewRect.origin.y = iconViewRect.origin.y + iconViewRect.size.height * 0.5 - headlineViewRect.size.height * 0.5;
          nativeAdView.headlineView.frame = headlineViewRect;
        }
        
        //callToActionView
        [((UIButton *)nativeAdView.callToActionView).titleLabel setFont:[UIFont systemFontOfSize:callToActionFontSize * adaptationScale]];
        [((UIButton *)nativeAdView.callToActionView) setTitle:curNativeAdData.callToAction
                                                     forState:UIControlStateNormal];
//        nativeAdView.callToActionView.hidden = curNativeAdData.callToAction ? NO : YES;
        CGRect callToActionViewRect = nativeAdView.callToActionView.frame;
        if(!nativeAdView.callToActionView.hidden)
        {
            callToActionViewRect.size.width = callToActionBtnWidth * adaptationScale;
            callToActionViewRect.size.height = callToActionBtnHeight * adaptationScale;
            callToActionViewRect.origin.x = frameWidth - callToActionViewRect.size.width - 10;
            CGFloat callToActionViewSizeY = 0;
            if(!nativeAdView.iconView.hidden)
            {
                callToActionViewSizeY = iconViewRect.origin.y + (frameHeight -  iconViewRect.origin.y) * 0.5
                - callToActionViewRect.size.height * 0.5;
            }
            else
            {
                callToActionViewSizeY = headlineViewRect.origin.y + (frameHeight - headlineViewRect.origin.y) * 0.5
                - callToActionViewRect.size.height * 0.5;
            }
            
            callToActionViewRect.origin.y = callToActionViewSizeY - 5;
            nativeAdView.callToActionView.frame = callToActionViewRect;
        }
        
        
        CGFloat ratio = curNativeAdData.mediaContent.aspectRatio;

        //NSLog(@"curNativeAd.videoController.aspectRatio %f", ratio);  //广告内容宽高比
        nativeAdView.mediaView.mediaContent = curNativeAdData.mediaContent;
        if (ratio > 0)
        {
        
            CGFloat boundX = marginX;
            CGFloat boundY = marginY;
            //CGFloat maxWidth = frameWidth - boundX * 2;
            CGFloat maxHeight = frameHeight - boundY * 2;
            if(!nativeAdView.iconView.hidden)
            {
                maxHeight = maxHeight - (frameHeight -  iconViewRect.origin.y);
            }
            else
            {
                maxHeight = maxHeight - (frameHeight - headlineViewRect.origin.y);
            }
            
            if(ratio > 1.0)   //landspace ad
            {
                CGFloat nativeViewFrameWidth = frameWidth - 2 * boundX;
                CGFloat nativeViewFrameHeight = nativeViewFrameWidth / ratio;
                if(nativeViewFrameHeight > maxHeight)
                {
                    nativeViewFrameHeight = maxHeight;
                    nativeViewFrameWidth = nativeViewFrameHeight * ratio;
                }
                
                CGFloat nativeViewPosX = (frameWidth - nativeViewFrameWidth) * 0.5;
                CGFloat nativeViewPosY = boundY;//boundY + (maxHeight - nativeViewFrameHeight) * 0.5;  //center
                
                nativeAdView.mediaView.frame = CGRectMake(nativeViewPosX, nativeViewPosY, nativeViewFrameWidth, nativeViewFrameHeight);
            } // portrait ad
            else
            {
                CGFloat nativeViewFrameHeight = maxHeight;
                CGFloat nativeViewFrameWidth = nativeViewFrameHeight * ratio;
                CGFloat nativeViewPosX = (frameWidth - nativeViewFrameWidth) * 0.5f;

                CGFloat nativeViewPosY = boundY;//boundY + (frameHeight - nativeViewFrameHeight) * 0.5;
//                CGFloat nativeViewPosY = boundY + (maxHeight - nativeViewFrameHeight) * 0.5;  //center
                nativeAdView.mediaView.frame = CGRectMake(nativeViewPosX, nativeViewPosY, nativeViewFrameWidth, nativeViewFrameHeight);
            }
        }
               
        if(curNativeAdData.videoController.hasVideoContent)
        {
            // By acting as the delegate to the GADVideoController, this ViewController
            // receives messages about events in the video lifecycle.
            curNativeAdData.videoController.delegate = self;
        }
               

        ((UIImageView *)nativeAdView.starRatingView).image = [self imageForStars:curNativeAdData.starRating];
        nativeAdView.starRatingView.hidden = curNativeAdData.starRating ? NO : YES;

        ((UILabel *)nativeAdView.storeView).text = curNativeAdData.store;
        nativeAdView.storeView.hidden = curNativeAdData.store ? NO : YES;

        ((UILabel *)nativeAdView.priceView).text = curNativeAdData.price;
        nativeAdView.priceView.hidden = curNativeAdData.price ? NO : YES;

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
    NSString* code = [NSString stringWithFormat:@"%ld", error.code];
    UnitySendMessage(_goName.UTF8String, _loadFailedTriggerName.UTF8String, code.UTF8String);
}

- (void)adLoader:(GADAdLoader *)adLoader didReceiveUnifiedNativeAd:(GADUnifiedNativeAd *)nativeAd
{
    for (int i = 0; i < _numberOfCachedAds; ++i)
    {
        if(_cachedAdDataArray[i] == nil)
        {
            _cachedAdDataArray[i] = nativeAd;
            NSLog(@"adLoader load ad index %d",i);
            break;
        }
    }
     
    UnitySendMessage(_goName.UTF8String, _loadSuccessfulTriggerName.UTF8String, "");
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

#pragma mark GADVideoControllerDelegate implementation

- (void)videoControllerDidEndVideoPlayback:(GADVideoController *)videoController {
    //  self.videoStatusLabel.text = @"Video playback has ended.";
}

#pragma mark GADUnifiedNativeAdDelegate

- (void)nativeAdDidRecordImpression:(GADUnifiedNativeAd *)nativeAd {
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (void)nativeAdDidRecordClick:(GADUnifiedNativeAd *)nativeAd {
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (void)nativeAdWillPresentScreen:(GADUnifiedNativeAd *)nativeAd {
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (void)nativeAdWillDismissScreen:(GADUnifiedNativeAd *)nativeAd {
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (void)nativeAdDidDismissScreen:(GADUnifiedNativeAd *)nativeAd {
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (void)nativeAdWillLeaveApplication:(GADUnifiedNativeAd *)nativeAd {
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

#pragma mark Utility

+ (void) PrintUIView: (NSString *)tag uiview: (UIView*)uiview
{
    CGRect rect = uiview.frame;
    CGPoint point = uiview.center;
    
    NSLog(@"center.x %f center.y %f", point.x, point.y);
    NSLog(@"%@ origin.x %f origin.y %f size.width %f size.height %f", tag, rect.origin.x, rect.origin.y,
          rect.size.width, rect.size.height);
}

+ (void) PrintUIViewFrameRect: (NSString *)tag rect: (CGRect)rect
{
    NSLog(@"%@ posX %f posY %f width %f height %f", tag, rect.origin.x, rect.origin.y,
          rect.size.width, rect.size.height);
}


@end
