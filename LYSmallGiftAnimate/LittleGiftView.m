//
//  LittleGiftView.m
//  LYSmallGiftAnimate
//
//  Created by 李洋 on 2017/9/14.
//  Copyright © 2017年 李洋. All rights reserved.
//

#import "LittleGiftView.h"
#import "NSTimer+EOCBlocksSupport.h"
#import <POP.h>
#import <EXTScope.h>
#import "LYConfig.h"

#define kLYGiftShowDuration 0.3f
#define kLYGiftDismissDuration 0.3f

@interface LittleGiftView()

@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) NSMutableArray *comboList;
@property (nonatomic, assign) BOOL inComb;
@property (nonatomic, strong) POPSpringAnimation *giftComboAnimation;

@end

@implementation LittleGiftView

- (void)dealloc
{
    [_timer invalidate];
}

- (BOOL)checkIsFirstShowGift:(GatewayGiftIncoming *)gift
{
    BOOL accept = NO;   // 是否接受
    
    if (_comboList == nil) {
        //列表为空，可以接受礼物
        _comboList = [NSMutableArray new];
        accept = YES;
        [_comboList addObject:gift];
        [self startComb:NO];
    }
    
    return accept;
}

- (BOOL)checkIsComboGift:(GatewayGiftIncoming *)gift
{
    BOOL isComb = NO;  // 是否连击
    
    // 判断ID是否相同
    if (gift.comboId && gift.comboId == self.comboId) {
        [_comboList addObject:gift];
        isComb = YES;
    }
    
    // 如果连击
    if (isComb) {
        [self startComb:isComb];
    }
    
    return isComb;
}


- (NSMutableArray *)checkTakeOver
{
    if (self.comboList) {
        if (_uid != kLYUid) {
            NSMutableArray *comboList = self.comboList;
            [self clearQueue];
            return comboList;
        }
    }
    return nil;
}

- (void)translateCombList:(NSMutableArray *)combList
{
    _comboList = combList;
    GatewayGiftIncoming * giftModel = _comboList.firstObject;
    _uid = giftModel.uid;
    [self startComb:NO];
}

- (POPSpringAnimation *)giftComboAnimation
{
    if (!_giftComboAnimation) {
        POPSpringAnimation *anim = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerScaleXY];
        anim.fromValue = [NSValue valueWithCGPoint:CGPointMake(2.0f, 2.0)];
        anim.toValue = [NSValue valueWithCGPoint:CGPointMake(1.0, 1.0)];
        anim.springBounciness = 15.0;   //反弹力
        anim.springSpeed = 25.0;        //加速度
        _giftComboAnimation = anim;
    }
    return _giftComboAnimation;
}

- (void)startComb:(BOOL)isComb
{
    dispatch_async(dispatch_get_main_queue(), ^{
        // 取消之前定时器
        if (_timer) {
            [_timer invalidate];
            _timer = nil;
        }
        
        // 创建新的定时器，显示3秒消失
        @weakify(self);
        _timer = [NSTimer eoc_scheduledTimerWithTimeInterval:kLYGiftStayDistance block:^{
            @strongify(self);
            [self expired];
        } repeats:NO];
        
        if (isComb) {
            // 开始连击动画
            [self combAnimated];
        }
        else {
            // 开始显示动画
            [self showAnimated];
        }
    });
}

- (void)expired
{
    [_combLabel.layer pop_removeAllAnimations];
    [self.layer removeAllAnimations];
    
    [self dismissAnimated];
}

- (void)clearQueue
{
    
    _comboList = nil;    // 失效清空连击队列
    _inComb = NO;
    _comboId = 0;
    _uid = 0;
}

- (void)combAnimated
{

    if (self.inComb) {
        return;
    }

    GatewayGiftIncoming *gift = self.comboList.firstObject;
    
    if (!gift) {
        return;
    }

    [self setInComb:YES];
    [_combLabel.layer pop_removeAllAnimations];
    [self.comboList removeObjectAtIndex:0];
    [self.combLabel setText:[NSString stringWithFormat:@"X %d", MAX(gift.combo, 1)]];
    
    POPSpringAnimation *anim = self.giftComboAnimation;
    @weakify(self);
    anim.completionBlock = ^(POPAnimation *anim, BOOL finished) {
        @strongify(self);
        if (finished) {
            [self setInComb:NO];
            [self startComb:YES];
        }};
    [_combLabel.layer pop_addAnimation:anim forKey:@"LYComb"];
}

- (void)showAnimated
{
    GatewayGiftIncoming *gift = self.comboList.firstObject;
    if (!gift) {
        return;
    }
    
    _comboId = gift.comboId;
    _uid = gift.uid;
    [self.portraitImageView setImage:[UIImage imageNamed:gift.portrait]];
    [self.nicknameLabel setText:gift.nickname];
    
    LiveGiftModel *giftInfo = [LiveGiftModel giftImageOfId:gift.giftId];
    [self.giftImageView setImage:[UIImage imageNamed:giftInfo.icon]];
    [self.sendLabel setText:[NSString stringWithFormat:@"送出了, %@", giftInfo.name]];

    [_combLabel.layer pop_removeAllAnimations];

    [self setTransform:CGAffineTransformMakeTranslation(-self.bounds.size.width, 0.0f)];
    [self setAlpha:0.0f];
    @weakify(self);
    [UIView animateWithDuration:kLYGiftShowDuration animations:^{
        @strongify(self);
        [self setTransform:CGAffineTransformIdentity];
        [self setAlpha:1.0f];
    } completion:^(BOOL finished) {
        @strongify(self);
        [self startComb:YES];
    }];
}

- (void)dismissAnimated
{
    @weakify(self);
    [UIView animateWithDuration:kLYGiftDismissDuration animations:^{
        @strongify(self);
        [self setTransform:CGAffineTransformMakeTranslation(0.0f, -self.bounds.size.height)];
        [self setAlpha:0.0f];
    } completion:^(BOOL finished) {
        [self clearQueue];
        if (self.delegate) {
            [self.delegate needUpdateLittleGiftView:self];
        }
    }];
}

@end
