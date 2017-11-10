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
#import "UIButton+ConboClick.h"

static CGFloat giftShowDuration = 0.3f;
static CGFloat giftDismissDuration = 0.3f;

@interface LittleGiftView()
//UI
@property (weak, nonatomic) IBOutlet UIImageView *portraitImageView;
@property (weak, nonatomic) IBOutlet UIImageView *giftImageView;
@property (weak, nonatomic) IBOutlet UILabel *sendLabel;
@property (weak, nonatomic) IBOutlet UILabel *nicknameLabel;
@property (weak, nonatomic) IBOutlet GYLabel *combLabel;

@property (nonatomic, assign) int combo;    //连击数
@property (nonatomic, strong) NSTimer *timer;
@property (strong ,nonatomic) GatewayGiftIncoming *giftModel;
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
    if (_giftModel == nil) {
        //当前未显示，可以接受礼物
        accept = YES;
        _giftModel = gift;
        [self startComb:NO];
    }
    return accept;
}

- (BOOL)checkIsComboGift:(GatewayGiftIncoming *)gift
{
    BOOL isComb = NO;  // 是否连击
    if (_giftModel.comboId == gift.comboId) {
        //是相同的ID，可以接受礼物
        isComb = YES;
        if (gift.combo > self.giftModel.combo) {
            _giftModel.combo = gift.combo;
        }
        [self startComb:YES];
    }
    
    return isComb;
}

- (GatewayGiftIncoming *)checkTakeOver:(GatewayGiftIncoming *)gift
{
    if (self.giftModel) {
        if (_uid != kLYUid) {
            GatewayGiftIncoming * giftModel = self.giftModel;
            [self clear];
            [self checkIsFirstShowGift:gift];
            giftModel.needShowFirstCombo = YES;
            giftModel.firstCombo = giftModel.combo;
            return giftModel;
        }
    }
    return gift;
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
        _timer = [NSTimer eoc_scheduledTimerWithTimeInterval:comboMaxTime block:^{
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

- (void)clear
{
    _inComb = NO;
    _combo = 0;
    _uid = 0;
    _giftModel= nil;
}

- (void)combAnimated
{
    if (self.inComb) {
        return;
    }
    GatewayGiftIncoming *gift = self.giftModel;
    if (!gift) {
        return;
    }
    if (gift.needShowFirstCombo) {
        gift.needShowFirstCombo = NO;
        self.combo = gift.firstCombo-1;
    }
    else if (self.combo >= self.giftModel.combo) {
        return;
    }    
    self.combo++;
    [self setInComb:YES];
    [_combLabel.layer pop_removeAllAnimations];
    [self.combLabel setText:[NSString stringWithFormat:@"X %d", MAX(self.combo, 1)]];
    
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
    GatewayGiftIncoming *gift = self.giftModel;
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
    [UIView animateWithDuration:giftShowDuration animations:^{
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
    [UIView animateWithDuration:giftDismissDuration animations:^{
        @strongify(self);
        [self setTransform:CGAffineTransformMakeTranslation(0.0f, -self.bounds.size.height)];
        [self setAlpha:0.0f];
    } completion:^(BOOL finished) {
        [self clear];
        if (self.delegate && [self.delegate respondsToSelector:@selector(needUpdateLittleGiftView:)]) {
            [self.delegate needUpdateLittleGiftView:self];
        }
    }];
}

@end
