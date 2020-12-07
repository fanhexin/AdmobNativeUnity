//
// Created by mac on 2020/11/26.
//

#import "NativeAdBase.h"
#import "NativeAdLoaderBase.h"

static NSMutableDictionary<NSString *, UIView *> *adViews;

@interface NativeAdBase()
@property(nonatomic, strong) NSString * xibName;
@end

@implementation NativeAdBase
- (instancetype)initWithAd:(id)ad xibName:(NSString *)xib{
    self = [super init];
    if (self) {
        if (adViews == nil) {
            adViews = NSMutableDictionary.new;
        }
        self.ad = ad;
        self.xibName = xib;

        UIView *adView = [adViews objectForKey:xib];
        if (adView == nil) {
            adView = [self createView:xib];
            adViews[xib] = adView;
            adView.hidden = YES;
            
            [UnityGetGLView() addSubview:adView];
        }
    }
    return self;
}

- (void)x:(int)x y:(int)y width:(int)width height:(int)height {
    CGFloat factor = UnityGetGLView().contentScaleFactor;
    CGFloat frameWidth = width / factor;
    CGFloat frameHeight = height / factor;
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    y = screenBounds.size.height - (y / factor) - frameHeight;
    x /= factor;

    UIView *adView = adViews[self.xibName];
    adView.frame = CGRectMake(x, y, frameWidth, frameHeight);

    [self populateNativeAdView:adView];
    adView.hidden = NO;
}

- (void)hide {
    adViews[self.xibName].hidden = YES;
}

- (void)destroy {
    self.ad = nil;
}

- (id)createView:(NSString *)xibName{
    NSBundle *bundle = [NSBundle mainBundle];
    if (![bundle pathForResource:xibName ofType:@"nib"])
    {
        bundle = [NSBundle bundleWithIdentifier:@"com.unity3d.framework"];
    }
    NSArray *nibObjects = [bundle loadNibNamed:xibName owner:nil options:nil];
    return nibObjects.firstObject;
}

- (void)populateNativeAdView:(UIView *)adView {

}

@end
