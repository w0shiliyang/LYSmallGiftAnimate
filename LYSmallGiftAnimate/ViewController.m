//
//  ViewController.m
//  LYSmallGiftAnimate
//
//  Created by 李洋 on 2017/9/14.
//  Copyright © 2017年 李洋. All rights reserved.
//

#import "ViewController.h"
#import "AllModel.h"
#import "LYConfig.h"
#import "LittleGiftView.h"
#import "UIButton+ConboClick.h"

@interface ViewController ()<LittleGiftViewDelegate>

@property (nonatomic, strong) NSMutableArray *giftQueue;  // 礼物队列
@property (nonatomic, strong) NSArray *giftAnimatedViews; // 礼物动画数组

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //初始化礼物UI
    NSMutableArray *giftViews = [NSMutableArray new];
    CGFloat y = self.view.bounds.size.height - 410;
    
    for (int i = 0;i<2;i++) {
        LittleGiftView *littleGift = [[NSBundle mainBundle]loadNibNamed:@"LittleGiftView" owner:nil options:nil].lastObject;
        littleGift.delegate = self;
        [littleGift setAlpha:0.0f];
        CGRect frame = littleGift.frame;
        frame.origin.y = y;
        [littleGift setFrame:frame];
        [self.view addSubview:littleGift];
        [giftViews addObject:littleGift];
        y += 84;
    }
    _giftAnimatedViews = giftViews.copy;
}

//送礼物
- (IBAction)sendGiftAction:(UIButton *)sender {
    NSInteger tag = sender.tag;
    GatewayGiftIncoming * giftModel = [[GatewayGiftIncoming alloc] init];
    giftModel.combo = sender.combo;//连击数
    giftModel.comboId = sender.comboId;
    NSLog(@"comboId = %d, combo = %d",sender.comboId,sender.combo);
    giftModel.giftId = (int)tag % kLYGiftCount;
    if (tag < kLYGiftCount) {
        //自己发的
        giftModel.nickname = @"我";
        giftModel.portrait = @"我";
        giftModel.uid = kLYUid;
    }else{
        giftModel.comboId += 10;
        giftModel.uid = 250;
        giftModel.nickname = @"baby";
        giftModel.portrait = @"baby";
    }
    [self controlModel:giftModel];
    [sender comboClick];
}

- (void)controlModel:(GatewayGiftIncoming *)model {
    if (model.uid == kLYUid) {
        [self dealSelfSend:model];
    }else{
        [self dealOthersSend:model];
    }
}

#pragma mark - gift view delegate
- (void)needUpdateLittleGiftView:(LittleGiftView *)giftView
{
    GatewayGiftIncoming * model = self.giftQueue.firstObject;
    if (!model) {
        return;
    }else{
        [self.giftQueue removeObject:model];
        [self controlModel:model];
    }
}

// 处理自己发送的礼物
- (void)dealSelfSend:(GatewayGiftIncoming *)sendGiftInfo
{
    //连击优先显示
    BOOL isCombo = NO;
    for (LittleGiftView *giftView in self.giftAnimatedViews) {
        isCombo = [giftView checkIsComboGift:sendGiftInfo];
        if (isCombo) {
            return;
        }
    }
    
    //有空闲的优先显示
    BOOL isShow = NO;
    for (LittleGiftView *giftView in self.giftAnimatedViews) {
        isShow = [giftView checkIsFirstShowGift:sendGiftInfo];
        if (isShow) {
            return;
        }
    }
    
    //看看可不可以抢占 (自己送的礼物超过2个就无法抢占)
    GatewayGiftIncoming * insertShowingModel;
    for (LittleGiftView *giftView in self.giftAnimatedViews) {
        insertShowingModel = [giftView checkTakeOver:sendGiftInfo];
        if (insertShowingModel != sendGiftInfo) {
            break;
        }
    }
    if (insertShowingModel) {
        [self insertGift:insertShowingModel];
    }

}

// 处理别人发送的礼物
- (void)dealOthersSend:(GatewayGiftIncoming *)sendGiftInfo
{
    BOOL isCombo = NO;
    for (LittleGiftView *giftView in self.giftAnimatedViews) {
        isCombo = [giftView checkIsComboGift:sendGiftInfo];
        if (isCombo) {
            return;
        }
    }
    BOOL isShow = NO;
    for (LittleGiftView *giftView in self.giftAnimatedViews) {
        isShow = [giftView checkIsFirstShowGift:sendGiftInfo];
        if (isShow) {
            return;
        }
    }
    [self insertGift:sendGiftInfo];
}

// 查找并存储
- (void)insertGift:(GatewayGiftIncoming *)sendGiftInfo {
    __block BOOL isJoin = NO;
    [self.giftQueue enumerateObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        GatewayGiftIncoming *cur = obj;
        if (cur && cur.comboId == sendGiftInfo.comboId && cur.combo < sendGiftInfo.comboId) {
            cur.combo = sendGiftInfo.combo;
            isJoin = YES;
            *stop = YES;
        }
    }];
    if (!isJoin) {
        if (sendGiftInfo.uid == kLYUid){
            [self.giftQueue insertObject:sendGiftInfo atIndex:0];
        }else{
            [self.giftQueue addObject:sendGiftInfo];
        }
    }
}

#pragma mark - get

- (NSMutableArray *)giftQueue {
    if (!_giftQueue) {
        _giftQueue = [NSMutableArray new];
    }
    return _giftQueue;
}

@end
