//
//  ViewController.m
//  LYSmallGiftAnimate
//
//  Created by 李洋 on 2017/9/14.
//  Copyright © 2017年 李洋. All rights reserved.
//

#import "LivingRoomViewController.h"
#import "AllModel.h"
#import "LYConfig.h"
#import "LittleGiftView.h"

@interface LivingRoomViewController ()<LittleGiftViewDelegate>

@property (strong ,nonatomic) NSMutableArray *comboArray;
@property (strong ,nonatomic) NSMutableArray *randomPersonArray;
// 礼物
@property (nonatomic, strong) NSMutableArray *giftQueue; // 收到礼物的队列（按combid分类的二维数组）
@property (nonatomic, strong) NSArray *giftAnimatedViews; // 礼物动画显示区域

@end

@implementation LivingRoomViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initGiftView];
}

//初始化礼物UI
- (void)initGiftView
{
    _giftQueue = [NSMutableArray new];
    
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
    int combo = [self comboNumberWithButton:sender];//连击数
    giftModel.combo = combo;
    giftModel.giftId = (int)tag % 3;
    giftModel.comboId = (int)tag % 3+10;
    if (tag < 3) {
        //自己发的
        giftModel.nickname = @"我";
        giftModel.portrait = @"我";
        giftModel.uid = kLYUid;
        [self dealSelfSend:giftModel];
    }else{
        giftModel.comboId += 10;
        giftModel.uid = 250;
        giftModel.nickname = @"baby";
        giftModel.portrait = @"baby";
        [self dealOthersSend:giftModel];
    }
}

- (NSMutableArray *)randomPersonArray {
    if (!_randomPersonArray) {
        _randomPersonArray =
        @[
                                       @{@"uid":@1,@"name":@"邓超",@"combo":@[@0,@0,@0].mutableCopy}.mutableCopy,
                                       @{@"uid":@2,@"name":@"鹿晗",@"combo":@[@0,@0,@0].mutableCopy}.mutableCopy,
                                       ].mutableCopy;
    }
    return _randomPersonArray;
}

//随机人发送随机礼物
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    NSMutableArray * personArray = self.randomPersonArray;
    int randomValue = arc4random();
    
    int uid = randomValue % personArray.count;      //uid 0／陈赫 1／邓超 2/鹿晗
    int giftId = arc4random() % personArray.count;   //随机礼物id
    NSString * name = personArray[uid][@"name"];
    GatewayGiftIncoming * giftModel = [[GatewayGiftIncoming alloc] init];
    giftModel.uid = uid;
    giftModel.giftId = giftId;
    giftModel.nickname = name;
    giftModel.portrait = name;
    
    int combo = [self getRandomComboWithGiftModel:giftModel];
    giftModel.combo = combo;//连击数
    giftModel.comboId = uid + giftId + 100;//为了保证唯一性 
    
    giftModel.comboId += 10;
    [self dealOthersSend:giftModel];
}

- (int)getRandomComboWithGiftModel:(GatewayGiftIncoming *)model
{
    int uid = (int)model.uid;
    int giftId = model.giftId;
    NSMutableArray * array = self.randomPersonArray;
    NSMutableArray * comboArray = array[uid][@"combo"];
    NSNumber * combo = comboArray[giftId];
    combo = @([combo intValue] + 1);
    comboArray[giftId] = combo;
    array[uid][@"combo"] = comboArray;
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(setRandomArrayZero:) object:model];
    [self performSelector:@selector(setRandomArrayZero:) withObject:model afterDelay:kLYgiftStayDistance];
    return [combo intValue];
}

- (void)setRandomArrayZero:(GatewayGiftIncoming *)model
{
    NSMutableArray * array = self.randomPersonArray;
    NSNumber * combo = array[model.uid][@"combo"][model.giftId];
    combo = @(0);
}


#pragma mark - gift view delegate
- (void)needUpdateLittleGiftView:(LittleGiftView *)giftView
{
    NSMutableArray *firstCombArray = nil;
    while (!firstCombArray.firstObject) {
        firstCombArray = _giftQueue.firstObject;
        if (firstCombArray == nil) {
            return;
        }
        [_giftQueue removeObject:firstCombArray];
    };
    [giftView translateCombList:firstCombArray];
}

- (int)comboNumberWithButton:(UIButton *)sender {
    NSInteger tag = sender.tag;
    int value = [(NSNumber *)self.comboArray[tag] intValue];
    self.comboArray[tag] = @(value +1);
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(setComboZero:) object:sender];
    [self performSelector:@selector(setComboZero:) withObject:sender afterDelay:kLYgiftStayDistance];
    return [self.comboArray[tag] intValue];
}

- (void)setComboZero:(UIButton *)button
{
    self.comboArray[button.tag] = @(0);
}

- (NSMutableArray *)comboArray
{
    if (!_comboArray) {
        // 自己发的 + 老王发的
        _comboArray = @[@0,@0,@0,@0,@0,@0].mutableCopy;
    }
    return _comboArray;
}

// 收到服务器发送的礼物
- (void)showSmallGiftWithGiftDictionary:(GatewayGiftIncoming *)sendGiftInfo{
    // 自己发的礼物（优先显示）
    if (sendGiftInfo.uid == kLYUid) {
        // 处理本地的，服务器返回的过滤掉
        if (sendGiftInfo.localTime) {
            [self dealSelfSend:sendGiftInfo];
        }
    }
    // 别人发的礼物
    else {
        [self dealOthersSend:sendGiftInfo];
    }
}

// 处理自己发送的礼物
- (void)dealSelfSend:(GatewayGiftIncoming *)sendGiftInfo
{
    BOOL isCombo = [self checkCombo:sendGiftInfo];
    if (isCombo) {
        return;
    }
    
    BOOL accept = [self findAvailablePlayView:sendGiftInfo];
    if (!accept) {
        // 检查是否有显示位置可以被抢占
        NSMutableArray *tokeoverList = nil;
        for (LittleGiftView *giftView in self.giftAnimatedViews) {
            tokeoverList = [giftView checkTakeOver];
            if (tokeoverList) {
                break;
            }
        }
        if (!tokeoverList) {
            // 如果不能抢占显示位，插入队首
            NSMutableArray *combArray = [self findCombArrayOfGift:sendGiftInfo];
            if (!combArray) {
                combArray = [NSMutableArray new];
                [_giftQueue insertObject:combArray atIndex:0];
            }
            [combArray insertObject:sendGiftInfo atIndex:0];
        }
        else {
            // 如果能抢占
            [_giftQueue insertObject:tokeoverList atIndex:0];
            [self dealSelfSend:sendGiftInfo];
        }
    }
    
}

// 处理别人发送的礼物
- (void)dealOthersSend:(GatewayGiftIncoming *)sendGiftInfo
{
    BOOL accept = [self findAvailablePlayView:sendGiftInfo];
    // 如果不能在显示位插入，则插入队尾。
    if (!accept) {
        NSMutableArray *combArray = [self findCombArrayOfGift:sendGiftInfo];
        if (!combArray) {
            combArray = [NSMutableArray new];
            [_giftQueue addObject:combArray];
        }
        [combArray insertObject:sendGiftInfo atIndex:0];
    }
}

// 是否能找到显示区域
- (BOOL)findAvailablePlayView:(GatewayGiftIncoming *)gift
{
    BOOL accept = NO;
    for (LittleGiftView *giftView in self.giftAnimatedViews) {
        accept = [giftView checkGift:gift];
        if (accept) {
            return YES;
        }
    }
    return NO;
}

- (BOOL)checkCombo:(GatewayGiftIncoming *)gift
{
    BOOL iscombo = NO;
    for (LittleGiftView *giftView in self.giftAnimatedViews) {
        iscombo = [giftView checkIsComboGift:gift];
        if (iscombo) {
            return YES;
        }
    }
    return iscombo;
}

// 查找当前连击队列
- (NSMutableArray *)findCombArrayOfGift:(GatewayGiftIncoming *)sendGiftInfo
{
    __block NSMutableArray *combArray = nil;
    if (sendGiftInfo.comboId) {
        [_giftQueue enumerateObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSMutableArray *cur = obj;
            GatewayGiftIncoming *firstComb = cur.firstObject;
            if (firstComb && firstComb.comboId == sendGiftInfo.comboId) {
                combArray = cur;
                *stop = YES;
            }
        }];
    }
    return combArray;
}

// 自己发的礼物
- (void)sendFakeGift:(int)gid
{
    GatewayGiftIncoming *gift = [GatewayGiftIncoming new];
    static GatewayGiftIncoming *gLastGift = nil;
    BOOL expired = NO;
    if (!gLastGift) {
        gift.comboId = -1;
        expired = YES;
    }
    else {
        if (gid != gLastGift.giftId) {
            expired = YES;
        }
        else {
            if (gift.localTime - gLastGift.localTime >= 3.0) {
                expired = YES;
            }
        }
    }
    if (expired) {
        gift.combo = 1;
        gift.comboId = gLastGift.comboId-1;
    }
    else {
        gift.combo = gLastGift.combo + 1;
        gift.comboId = gLastGift.comboId;
    }
    
    [self showSmallGiftWithGiftDictionary:gift];
    gLastGift = gift;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

}


@end
