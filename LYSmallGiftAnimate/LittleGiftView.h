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

@protocol LittleGiftViewDelegate <NSObject>

//获取新的数据
- (void)needUpdateLittleGiftView:(LittleGiftView *)giftView;

@end

@interface LittleGiftView : UIView

/**
 连击ID
 */
@property (nonatomic, readonly) long long comboId;

/**
 用户ID 用于区分是否是自己送的
 */
@property (nonatomic, readonly) long long uid;

@property (nonatomic, weak) id <LittleGiftViewDelegate> delegate;


//检查是否可以连击显示 可以则处理
- (BOOL)checkIsComboGift:(GatewayGiftIncoming *)gift;

//检查是否空闲，空闲显示出来
- (BOOL)checkIsFirstShowGift:(GatewayGiftIncoming *)gift;

/**
 检查能否抢占
 
 @return 抢占成功，返回顶替的数据，未能抢占成功（都是自己发的）返回gift
 */
- (GatewayGiftIncoming *)checkTakeOver:(GatewayGiftIncoming *)gift;

@end
