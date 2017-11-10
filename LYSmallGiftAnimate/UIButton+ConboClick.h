//
//  UIButton+conboClick.h
//  LYSmallGiftAnimate
//
//  Created by 李洋 on 2017/11/10.
//  Copyright © 2017年 李洋. All rights reserved.
//

#import <UIKit/UIKit.h>

FOUNDATION_EXPORT CGFloat comboMaxTime;

@interface UIButton (ConboClick)

/**
 连击数
 */
@property (assign ,nonatomic) int combo;

/**
 连击的礼物comboId一样
 */
@property (assign ,nonatomic) int comboId;

/**
 点击显示连击时间倒计时
 */
- (void)comboClick;

@end
