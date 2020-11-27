//
// Created by mac on 2020/11/26.
//

#import <Foundation/Foundation.h>


@interface NativeAdBase : NSObject
@property(nonatomic, strong) id ad;

- (instancetype)initWithAd:(id)ad xibName:(NSString *)xib;
-(void)x:(int)x y:(int)y width:(int)width height:(int)height;
-(void)hide;
-(void)destroy;
-(void)populateNativeAdView:(UIView *)adView;
@end