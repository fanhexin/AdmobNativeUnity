//
// Created by mac on 2020/11/26.
//

#import <Foundation/Foundation.h>

@class NativeAdBase;
@class NativeAdLoaderBase;

@protocol NativeAdLoadResult <NSObject>
-(void)onAdLoadSuccess:(NativeAdLoaderBase *)adLoader nativeAd:(NativeAdBase *)ad;
-(void)onAdLoadFail:(NativeAdLoaderBase *)adLoader errorMsg:(NSString *)error;
@end