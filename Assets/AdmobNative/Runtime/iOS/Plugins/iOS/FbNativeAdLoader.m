//
// Created by mac on 2020/11/26.
//

#import "FbNativeAdLoader.h"
#import "FbNativeAd.h"
#import <FBAudienceNetwork/FBNativeAd.h>

@interface FbNativeAdLoader() <FBNativeAdDelegate>
@property (nonatomic, strong) FBNativeAd *fbNativeAd;
@end

@implementation FbNativeAdLoader

- (void)load {
    [super load];
    self.fbNativeAd = [FBNativeAd.alloc initWithPlacementID:self.unitId];
    self.fbNativeAd.delegate = self;
    [self.fbNativeAd loadAd];
}

- (void)nativeAdDidLoad:(FBNativeAd *)nativeAd {
    [nativeAd downloadMedia];
    [self onAdLoadSuccess:self nativeAd:[FbNativeAd.alloc initWithAd:nativeAd xibName:@"FbNativeAdView"]];
}

- (void)nativeAdDidDownloadMedia:(FBNativeAd *)nativeAd {
}

- (void)nativeAd:(FBNativeAd *)nativeAd didFailWithError:(NSError *)error {
    [self onAdLoadFail:self errorMsg:error.description];
}

@end
