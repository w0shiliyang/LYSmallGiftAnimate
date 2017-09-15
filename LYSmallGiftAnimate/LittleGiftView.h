//
//  LittleGiftView.h
//  LYSmallGiftAnimate
//
//  Created by 李洋 on 2017/9/14.
//  Copyright © 2017年 李洋. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "GYLabel.h"
#import "AllModel.h"

@class LittleGiftView;
@protocol LittleGiftViewDelegate

//获取新的数据
- (void)needUpdateLittleGiftView:(LittleGiftView *)giftView;

@end


@interface LittleGiftView : UIView

@property (weak, nonatomic) IBOutlet UIImageView *portraitImageView;
@property (weak, nonatomic) IBOutlet UIImageView *giftImageView;
@property (weak, nonatomic) IBOutlet UILabel *sendLabel;
@property (weak, nonatomic) IBOutlet UILabel *nicknameLabel;
@property (weak, nonatomic) IBOutlet GYLabel *combLabel;


@property (nonatomic, readonly) long long comboId;
@property (nonatomic, readonly) long long uid;
- (BOOL)checkGift:(GatewayGiftIncoming *)gift;
- (BOOL)checkIsComboGift:(GatewayGiftIncoming *)gift;
- (NSMutableArray *)checkTakeOver;   //
- (void)translateCombList:(NSMutableArray *)combList;

@property (nonatomic, weak) id <LittleGiftViewDelegate> delegate;

@end
