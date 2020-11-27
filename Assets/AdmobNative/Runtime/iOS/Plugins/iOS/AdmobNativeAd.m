//
// Created by mac on 2020/11/26.
//

#import "AdmobNativeAd.h"
#import <GoogleMobileAds/GoogleMobileAds.h>

@interface AdmobNativeAd() <GADUnifiedNativeAdDelegate>
@end

@implementation AdmobNativeAd
- (void)populateNativeAdView:(UIView *)adView {
    [super populateNativeAdView:adView];

    GADUnifiedNativeAdView *nativeAdView = (GADUnifiedNativeAdView *) adView;
    GADUnifiedNativeAd *nativeAd = (GADUnifiedNativeAd *)self.ad;

    if (nativeAd == nil)
        return;
    // Deactivate the height constraint that was set when the previous video ad loaded.
    nativeAdView.nativeAd = nativeAd;
    nativeAd.delegate = self;

    ((UILabel *)nativeAdView.bodyView).text = nativeAd.body;
    nativeAdView.bodyView.hidden = nativeAd.body ? NO : YES;

    //icon view
    ((UIImageView *)nativeAdView.iconView).image = nativeAd.icon.image;
    nativeAdView.iconView.hidden = nativeAd.icon ? NO : YES;

    ((UILabel *)nativeAdView.headlineView).text = nativeAd.headline;

    //callToActionView
    [((UIButton *)nativeAdView.callToActionView) setTitle:nativeAd.callToAction
                                                 forState:UIControlStateNormal];
    nativeAdView.callToActionView.hidden = nativeAd.callToAction ? NO : YES;

    nativeAdView.mediaView.mediaContent = nativeAd.mediaContent;

    ((UILabel *)nativeAdView.advertiserView).text = nativeAd.advertiser;
    nativeAdView.advertiserView.hidden = nativeAd.advertiser ? NO : YES;

    // In order for the SDK to process touch events properly, user interaction
    // should be disabled.
    nativeAdView.callToActionView.userInteractionEnabled = NO;
}

@end