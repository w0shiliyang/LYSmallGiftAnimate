//
//  UIButton+conboClick.m
//  LYSmallGiftAnimate
//
//  Created by 李洋 on 2017/11/10.
//  Copyright © 2017年 李洋. All rights reserved.
//

#import "UIButton+ConboClick.h"
#import <objc/runtime.h>

CGFloat comboMaxTime = 7;   //连击时间范围
CGFloat comboMaxTimeDistance = 0.01;

@interface UIButton ()

@property (strong ,nonatomic) NSTimer *comboTimer;
@property (strong ,nonatomic) UILabel *comboTimeLabel;
@property (assign ,nonatomic) CGFloat timerValue;

@end

@implementation UIButton (ConboClick)

- (void)comboClick {
    self.combo++;
    [self clear];
    self.comboTimer = [NSTimer scheduledTimerWithTimeInterval:comboMaxTimeDistance target:self selector:@selector(timerAction) userInfo:nil repeats:YES];
}

- (int)isCombo {
    if (self.timerValue != comboMaxTime && self.timerValue > 0) {
        return YES;
    }
    return NO;
}

- (void)clear {
    self.timerValue = comboMaxTime;
    [self.comboTimer invalidate];
    self.comboTimer = nil;
    self.comboTimeLabel.hidden = YES;
}

- (void)timerAction {
    self.timerValue -= comboMaxTimeDistance;
    if (self.timerValue < 0) {
        [self clear];
        self.combo = 1;
        //重新负值
        self.comboId = arc4random()%100000;
        return;
    }
    self.comboTimeLabel.hidden = NO;
    self.comboTimeLabel.text = [NSString stringWithFormat:@"%.f",self.timerValue];
}

- (UILabel *)comboTimeLabel {
    UILabel * label = objc_getAssociatedObject(self, _cmd);
    if (!label) {
        label = [[UILabel alloc]initWithFrame:self.bounds];
        label.textColor = [UIColor redColor];
        label.font = [UIFont systemFontOfSize:30];
        label.text = [NSString stringWithFormat:@"%.f",comboMaxTime];
        label.userInteractionEnabled = NO;
        label.textAlignment = NSTextAlignmentCenter;
        [self addSubview:label];
        self.comboTimeLabel = label;
    }
    return label;
}

#pragma mark - set get

- (CGFloat)timerValue {
    return [objc_getAssociatedObject(self, _cmd) floatValue];
}

- (void)setTimerValue:(CGFloat)timerValue {
    objc_setAssociatedObject(self, @selector(timerValue), @(timerValue), OBJC_ASSOCIATION_RETAIN);
}

- (void)setComboTimeLabel:(UILabel *)comboTimeLabel {
    objc_setAssociatedObject(self, @selector(comboTimeLabel), comboTimeLabel, OBJC_ASSOCIATION_RETAIN);
}

- (void)setComboTimer:(NSTimer *)comboTimer {
    objc_setAssociatedObject(self, @selector(comboTimer), comboTimer, OBJC_ASSOCIATION_RETAIN);
}

- (NSTimer *)comboTimer {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setCombo:(int)combo {
    objc_setAssociatedObject(self, @selector(combo), @(combo), OBJC_ASSOCIATION_RETAIN);
}

- (int)combo {
    int combo =  [objc_getAssociatedObject(self, _cmd) intValue];
    if (combo == 0) {
        combo = 1;
        self.combo = 1;
    }
    return combo;
}

- (int)comboId {
    int comboIdValue = [objc_getAssociatedObject(self, _cmd) intValue];
    if (!comboIdValue) {
        comboIdValue = arc4random()%100000;
        self.comboId = comboIdValue;
    }
    return comboIdValue;
}

- (void)setComboId:(int)comboId {
    objc_setAssociatedObject(self, @selector(comboId), @(comboId), OBJC_ASSOCIATION_RETAIN);
}

@end
