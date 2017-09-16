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

//检查是否可以连击显示
- (BOOL)checkIsComboGift:(GatewayGiftIncoming *)gift;

//检查是否空闲，空闲默认显示出来
- (BOOL)checkIsFirstShowGift:(GatewayGiftIncoming *)gift;

/**
 检查能否抢占
 
 @return 当前连击列表
 */
- (NSMutableArray *)checkTakeOver;

- (void)translateCombList:(NSMutableArray *)combList;

@property (nonatomic, weak) id <LittleGiftViewDelegate> delegate;

@end
