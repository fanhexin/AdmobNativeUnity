//
// Created by mac on 2020/11/26.
//

#import <GoogleMobileAds/GoogleMobileAds.h>
#import "AdmobNativeAdLoader.h"
#import "AdmobNativeAd.h"

@interface AdmobNativeAdLoader()<GADUnifiedNativeAdLoaderDelegate>
@property (nonatomic, strong) GADAdLoader *adLoader;
@end

@implementation AdmobNativeAdLoader
- (void)load {
    [super load];
    GADVideoOptions *videoOptions = [[GADVideoOptions alloc] init];  //播放广告是否开启静音
    videoOptions.startMuted = TRUE;

    GADMultipleAdsAdLoaderOptions *multipleAdsOptions = [[GADMultipleAdsAdLoaderOptions alloc] init];
    multipleAdsOptions.numberOfAds = 1;

    GADNativeAdMediaAdLoaderOptions *mediaOptions = [[GADNativeAdMediaAdLoaderOptions alloc] init];
    mediaOptions.mediaAspectRatio = GADMediaAspectRatioLandscape;

    self.adLoader = [[GADAdLoader alloc] initWithAdUnitID:self.unitId
                                               rootViewController:UnityGetGLViewController()
                                                          adTypes:@[ kGADAdLoaderAdTypeUnifiedNative ]
                                                          options:@[ videoOptions, mediaOptions, multipleAdsOptions]];

    self.adLoader.delegate = self;
    [self.adLoader loadRequest:[GADRequest request]];
}

- (void)adLoader:(GADAdLoader *)adLoader didFailToReceiveAdWithError:(GADRequestError *)error {
    [self onAdLoadFail:self errorMsg:error.description];
}

- (void)adLoader:(GADAdLoader *)adLoader didReceiveUnifiedNativeAd:(GADUnifiedNativeAd *)nativeAd
{
    [self onAdLoadSuccess:self nativeAd:[AdmobNativeAd.alloc initWithAd:nativeAd xibName:@"AdmobNativeAdView"]];
}

- (void)adLoaderDidFinishLoading:(GADAdLoader *)adLoader {
    self.adLoader = nil;
}

@end