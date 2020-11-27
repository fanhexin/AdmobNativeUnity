//
// Created by mac on 2020/11/26.
//

#import <Foundation/Foundation.h>
#import "NativeAdLoadResult.h"

@interface NativeAdLoaderBase : NSObject<NativeAdLoadResult>
@property(nonatomic, strong) NSString *unitId;
@property(nonatomic, weak, nullable) id<NativeAdLoadResult> delegate;
@property(nonatomic) int index;

+(void)setTimeout:(int)timeout;
+(int)getTimeout;

- (instancetype)initWithUnitId:(NSString *)unitId;
-(void)load;
-(void)internalLoad:(id<NativeAdLoadResult>)delegate;
@end