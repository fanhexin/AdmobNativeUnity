//
// Created by mac on 2020/11/26.
//

#import "FbNativeAd.h"
#import "FbNativeAdView.h"
#import <FBAudienceNetwork/FBNativeAd.h>

@implementation FbNativeAd
- (instancetype)initWithAd:(id)ad xibName:(NSString *)xib {
    self = [super initWithAd:ad xibName:xib];
    if (self) {
        [FBMediaView class];
    }

    return self;
}

- (void)populateNativeAdView:(UIView *)adView {
    [super populateNativeAdView:adView];
    FBNativeAd *nativeAd = (FBNativeAd *) self.ad;
    if (!nativeAd.isAdValid) {
        return;
    }

    [nativeAd unregisterView];
    FbNativeAdView *nativeAdView = (FbNativeAdView *) adView;

    nativeAdView.adTitleLabel.text = nativeAd.advertiserName;
    nativeAdView.adBodyLabel.text = nativeAd.bodyText;
    nativeAdView.adOptionsView.nativeAd = nativeAd;
    [nativeAdView.adCallToActionButton setTitle:nativeAd.callToAction forState:UIControlStateNormal];

    nativeAdView.adTitleLabel.nativeAdViewTag = FBNativeAdViewTagTitle;
    nativeAdView.adBodyLabel.nativeAdViewTag = FBNativeAdViewTagBody;
    nativeAdView.adIconImageView.nativeAdViewTag = FBNativeAdViewTagIcon;

    [nativeAd registerViewForInteraction:nativeAdView
                               mediaView:nativeAdView.adCoverMediaView
                           iconImageView:nativeAdView.adIconImageView
                          viewController:UnityGetGLViewController()
                          clickableViews:@[nativeAdView.adCallToActionButton]];
}

@end
