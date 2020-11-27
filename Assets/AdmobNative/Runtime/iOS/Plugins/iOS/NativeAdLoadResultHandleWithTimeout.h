//
// Created by mac on 2020/11/27.
//

#import <Foundation/Foundation.h>
#import "NativeAdLoadResult.h"


@interface NativeAdLoadResultHandleWithTimeout : NSObject<NativeAdLoadResult>
- (instancetype)initWithTimeout:(int)timeout delegate:(id <NativeAdLoadResult>)delegate;
@end