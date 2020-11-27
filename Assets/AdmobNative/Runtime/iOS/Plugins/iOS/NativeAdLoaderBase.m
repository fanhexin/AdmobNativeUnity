//
// Created by mac on 2020/11/26.
//

#import "NativeAdLoaderBase.h"
#import "NativeAdBase.h"

@interface NativeAdLoaderBase()
@property (nonatomic, strong) NSTimer *timer;
@end

@implementation NativeAdLoaderBase
static int _timeout;

- (instancetype)initWithUnitId:(NSString *)unitId {
    self = [super init];
    if (self) {
        self.unitId = unitId;
    }

    return self;
}

- (void)load {
    self.timer = [NSTimer scheduledTimerWithTimeInterval:_timeout target:self selector:@selector(onTimeout:) userInfo:nil repeats:NO];
}

- (void)onAdLoadSuccess:(NativeAdLoaderBase *)adLoader nativeAd:(NativeAdBase *)ad {
    if (!self.timer.isValid) {
        [ad destroy];
        return;
    }

    [self.timer invalidate];
    [self.delegate onAdLoadSuccess:adLoader nativeAd:ad];
}

- (void)onAdLoadFail:(NativeAdLoaderBase *)adLoader errorMsg:(NSString *)error {
    if (!self.timer.isValid) {
        return;
    }

    [self.timer invalidate];
    [self.delegate onAdLoadFail:adLoader errorMsg:error];
}

- (void)onTimeout:(NSTimer *)timer{
    [self.delegate onAdLoadFail:self errorMsg:@"TimeoutTimer timeout!"];
}

+ (void)setTimeout:(int)timeout {
    _timeout = timeout;
}

+ (int)getTimeout {
    return _timeout;
}

@end