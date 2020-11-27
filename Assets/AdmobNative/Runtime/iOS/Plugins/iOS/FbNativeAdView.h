//
// Created by mac on 2020/11/26.
//

#import <Foundation/Foundation.h>
#import <FBAudienceNetwork/FBMediaView.h>
#import <FBAudienceNetwork/FBAdOptionsView.h>


@interface FbNativeAdView : UIView
@property (weak, nonatomic) IBOutlet UIImageView *adIconImageView;
@property (weak, nonatomic) IBOutlet FBMediaView *adCoverMediaView;
@property (weak, nonatomic) IBOutlet UILabel *adTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *adBodyLabel;
@property (weak, nonatomic) IBOutlet FBAdOptionsView *adOptionsView;
@property (weak, nonatomic) IBOutlet UIButton *adCallToActionButton;
@end
