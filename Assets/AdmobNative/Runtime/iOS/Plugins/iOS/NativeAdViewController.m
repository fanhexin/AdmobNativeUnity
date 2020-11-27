#import "NativeAdViewController.h"
#import <GoogleMobileAds/GoogleMobileAds.h>
#import <FBAudienceNetwork/FBAudienceNetworkAds.h>
#import "NativeAdLoaderBase.h"
#import "AdmobNativeAdLoader.h"
#import "FbNativeAdLoader.h"
#import "NativeAdBase.h"

static NSMutableArray<NativeAdLoaderBase *> *_nativeAdLoaders;
static bool _videoStartMute;
static int _numOfAdsToLoad;
static int _curUnitIdIndex = 0;
static int _loadStartIndex = 0;
static int _loadEndIndex = 0;
static int _maxPriceUnitIdIndex = 0;
static int _successNum = 0;
static int _failureNum = 0;
static bool _isLoading = false;
static NSMutableDictionary<NSString *, NativeAdBase *> *_index2NativeAd;
static NSMutableDictionary<NSString *, NSString *> *_unitId2ErrorMsg;

static NativeAdBase *_nativeAd;
static bool _isAdShowing;
static NSString *_goName;
static NSString *_loadSuccessfulTriggerName;
static NSString *_loadFailedTriggerName;

@interface NativeAdViewController () <GADVideoControllerDelegate, NativeAdLoadResult>

@property(nonatomic, strong) GADUnifiedNativeAdView *myView;
@property(nonatomic, strong) NSLayoutConstraint *heightConstraint;
@property (nonatomic) int x;
@property (nonatomic) int y;
@property (nonatomic) int width;
@property (nonatomic) int height;

@end

@implementation NativeAdViewController

static NativeAdViewController *myAdController;

#pragma mark Unity Methods

void init(char *unitIds, bool videoMuteAtBegin, int numOfAdsToLoad, int timeout) {
    if (!myAdController)
        myAdController = [NativeAdViewController new];
    NSString *unitIdsStr = [NSString stringWithUTF8String:unitIds];
    NSArray<NSString *> *unitIdArr = [unitIdsStr componentsSeparatedByString:@","];

    [myAdController initNative:unitIdArr
              isVideoStartMute:videoMuteAtBegin
                numOfAdsToLoad:numOfAdsToLoad
                timeout:timeout];
}

bool is_ready() {
    return [myAdController IsNativeReady];
}

bool show(float x, float y, float width, float height) {
    return [myAdController
            showNativeAd:width
                   sizeY:height
                    posX:x
                    posY:y];
}

bool hide() {
    return [myAdController hideNative];
}

void load() {
    if (_isLoading) {
        return;
    }
    _isLoading = true;

    [myAdController requestAd];
}

void add_event_listener(char *goName, char *loadSuccessfulTriggerName, char *loadFailedTriggerName) {
    _goName = [NSString stringWithUTF8String:goName];
    _loadSuccessfulTriggerName = [NSString stringWithUTF8String:loadSuccessfulTriggerName];
    _loadFailedTriggerName = [NSString stringWithUTF8String:loadFailedTriggerName];
}

#pragma mark Objective C Methods

- (void)initNative:(NSArray<NSString *> *)nativeAd
  isVideoStartMute:(bool)isVideoStartMute
    numOfAdsToLoad:(int)numOfAdsToLoad
           timeout:(int)timeout{
    [[GADMobileAds sharedInstance] startWithCompletionHandler:nil];  //初始化Admob广告
    [FBAudienceNetworkAds initializeWithSettings:nil completionHandler:nil];
    [NativeAdLoaderBase setTimeout:timeout];
    _nativeAdLoaders = [NSMutableArray<NativeAdLoaderBase *> new];
    for (int i = 0; i < nativeAd.count; ++i) {
        NSString *unitId = nativeAd[i];
        if ([unitId rangeOfString:@"ca-app-pub-"].location == NSNotFound) {
            [_nativeAdLoaders addObject:[FbNativeAdLoader.alloc initWithUnitId:unitId]];
        } else {
            [_nativeAdLoaders addObject:[AdmobNativeAdLoader.alloc initWithUnitId:unitId]];
        }
    }
    _videoStartMute = isVideoStartMute;
    _numOfAdsToLoad = numOfAdsToLoad;
    _isAdShowing = false;

    _maxPriceUnitIdIndex = nativeAd.count;
    _index2NativeAd = [NSMutableDictionary<NSString *, NativeAdBase *> new];
    _unitId2ErrorMsg = [NSMutableDictionary<NSString *, NSString *> new];
    _curUnitIdIndex = nativeAd.count - 1;
    [self resetLoadRange];
}

- (Boolean)IsNativeReady {
    return _nativeAd != nil;
}

- (Boolean)hideNative {
    if (!_isAdShowing || ![self IsNativeReady]) {
        return false;
    }

    _isAdShowing = false;
    [_nativeAd hide];
    return true;
}

- (void)requestAd {
    for (int i = _loadStartIndex; i <= _loadEndIndex; i++) {
        NativeAdLoaderBase *loader = _nativeAdLoaders[i];
        loader.index = i;
        loader.delegate = self;
        [loader load];
    }
}

- (Boolean)showNativeAd:(float)sizeX
                  sizeY:(float)sizeY
                   posX:(float)posX
                   posY:(float)posY {
    if (_isAdShowing || ![self IsNativeReady]) {
        return false;
    }

    self.x = posX;
    self.y = posY;
    self.width = sizeX;
    self.height = sizeY;
    [_nativeAd x:posX y:posY width:sizeX height:sizeY];
    _isAdShowing = true;
    return true;
}

#pragma mark GADAdLoaderDelegate

- (void)resetLoadRange {
    _loadStartIndex = 0;
    _loadEndIndex = MIN(_numOfAdsToLoad - 1, _curUnitIdIndex);
}

- (void)reset {
    _successNum = 0;
    _failureNum = 0;
    _isLoading = false;
    _maxPriceUnitIdIndex = _nativeAdLoaders.count;
}

- (void)checkForComplete {
    if ((_successNum + _failureNum) != (_loadEndIndex - _loadStartIndex + 1)) {
        return;
    }

    if (_successNum > 0) {
        _curUnitIdIndex = _maxPriceUnitIdIndex;
        [self reset];
        [self resetLoadRange];

        NSString *indexStr = [NSString stringWithFormat:@"%d", _curUnitIdIndex];
        _nativeAd = _index2NativeAd[indexStr];
        // 替换nativeAd时如果正处于显示状态，原来的nativeAd会被销毁，视图消失，需要重新show一下新的
        if (_isAdShowing) {
            [_nativeAd x:self.x y:self.y width:self.width height:self.height];
        }
        UnitySendMessage(_goName.UTF8String, _loadSuccessfulTriggerName.UTF8String, "");
        [_index2NativeAd removeAllObjects];
        return;
    }

    [self reset];

    _loadStartIndex = _loadEndIndex + 1;
    if (_loadStartIndex > _curUnitIdIndex) {
        [self resetLoadRange];
        UnitySendMessage(_goName.UTF8String, _loadFailedTriggerName.UTF8String, _unitId2ErrorMsg.description.UTF8String);
        [_unitId2ErrorMsg removeAllObjects];
        return;
    }

    _loadEndIndex = MIN(_loadStartIndex + _numOfAdsToLoad, _curUnitIdIndex);
    [self requestAd];
}

- (void)onAdLoadSuccess:(NativeAdLoaderBase *)adLoader nativeAd:(NativeAdBase *)ad {
    int index = adLoader.index;
    if (_maxPriceUnitIdIndex > index) {
        _maxPriceUnitIdIndex = index;
    }
    _index2NativeAd[[NSString stringWithFormat:@"%d", index]] = ad;
    ++_successNum;
    [self checkForComplete];
}

- (void)onAdLoadFail:(NativeAdLoaderBase *)adLoader errorMsg:(NSString *)error {
    ++_failureNum;
    _unitId2ErrorMsg[adLoader.unitId] = error.description;
    [self checkForComplete];
}

@end
