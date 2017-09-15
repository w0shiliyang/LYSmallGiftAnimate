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
@property (strong ,nonatomic) NSMutableArray <GatewayGiftIncoming *>*randomModelArray;

// 礼物
@property (nonatomic, strong) NSMutableArray *giftQueue; // 收到礼物的队列（按combid分类的二维数组）
@property (nonatomic, strong) NSArray *giftAnimatedViews; // 礼物动画显示区域

@property (strong ,nonatomic) NSOperationQueue *operationQueue;     //队列
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
    _operationQueue = [[NSOperationQueue alloc]init];
    _operationQueue.maxConcurrentOperationCount = 1;
    
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
    NSBlockOperation * blockOperation = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"%@",[NSThread currentThread]);
        NSInteger tag = sender.tag;
        GatewayGiftIncoming * giftModel = [[GatewayGiftIncoming alloc] init];
        int combo = [self comboNumberWithButton:sender];//连击数
        giftModel.combo = combo;
        giftModel.giftId = (int)tag % kLYGiftCount;
        giftModel.comboId = (int)tag % kLYGiftCount+10;
        if (tag < kLYGiftCount) {
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
    }];
    [self.operationQueue addOperation:blockOperation];
}

- (NSMutableArray *)randomPersonArray {
    if (!_randomPersonArray) {
        _randomPersonArray =
        @[
                                       @{@"uid":@0,@"name":@"邓超",@"combo":@[@0,@0,@0].mutableCopy}.mutableCopy,
                                       @{@"uid":@1,@"name":@"鹿晗",@"combo":@[@0,@0,@0].mutableCopy}.mutableCopy,
                                       ].mutableCopy;
    }
    return _randomPersonArray;
}

- (NSMutableArray *)randomModelArray
{
    if (!_randomModelArray) {
        _randomModelArray = [[NSMutableArray alloc]init];
        NSMutableArray * personArray = self.randomPersonArray;
        
        for (int i = 0; i < personArray.count; i++) {
            int uid = i;  //uid
            for (int j = 0; j < kLYGiftCount; j++) {
                int giftId = arc4random() % kLYGiftCount;   //随机礼物id
                NSString * name = personArray[uid][@"name"];
                GatewayGiftIncoming * giftModel = [[GatewayGiftIncoming alloc] init];
                giftModel.uid = uid;
                giftModel.giftId = giftId;
                giftModel.nickname = name;
                giftModel.portrait = name;
                giftModel.comboId = uid + giftId + 100;//为了保证唯一性
                [_randomModelArray addObject:giftModel];
            }
        }
    }
    return _randomModelArray;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    NSBlockOperation * blockOperation = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"%@",[NSThread currentThread]);
        int index = arc4random() % self.randomModelArray.count;
        NSLog(@"%d",index);
        GatewayGiftIncoming * giftModel = self.randomModelArray[index];
        int combo = [self getRandomComboWithGiftModel:giftModel];
        giftModel.combo = combo;//连击数
    [self dealOthersSend:giftModel];
    }];
    [self.operationQueue addOperation:blockOperation];
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
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(setRandomArrayZero:) object:model];
        [self performSelector:@selector(setRandomArrayZero:) withObject:model afterDelay:kLYGiftStayDistance];
    });
    
    return [combo intValue];
}

- (void)setRandomArrayZero:(GatewayGiftIncoming *)model
{
    NSMutableArray * array = self.randomPersonArray;
    NSMutableArray * comboArray = array[model.uid][@"combo"];
    NSNumber * combo = comboArray[model.giftId];
    combo = @(0);
    comboArray[model.giftId] = combo;
    array[model.uid][@"combo"] = comboArray;
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
    dispatch_async(dispatch_get_main_queue(), ^{
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(setComboZero:) object:sender];
        [self performSelector:@selector(setComboZero:) withObject:sender afterDelay:kLYGiftStayDistance];
    });
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


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

}


@end
