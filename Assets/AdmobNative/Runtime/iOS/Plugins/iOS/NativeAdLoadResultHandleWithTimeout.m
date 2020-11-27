//
// Created by mac on 2020/11/27.
//

#import "NativeAdLoadResultHandleWithTimeout.h"
#import "NativeAdBase.h"

@interface NativeAdLoadResultHandleWithTimeout()
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) id<NativeAdLoadResult> delegate;
@end

@implementation NativeAdLoadResultHandleWithTimeout
- (instancetype)initWithTimeout:(int)timeout delegate:(id <NativeAdLoadResult>)delegate {
    self = [super init];
    if (self) {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:timeout target:self selector:@selector(onTimeout:) userInfo:nil repeats:NO];
        self.delegate = delegate;
    }

    return self;
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

@end