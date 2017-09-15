//
//  AllModel.m
//  LYSmallGiftAnimate
//
//  Created by 李洋 on 2017/9/14.
//  Copyright © 2017年 李洋. All rights reserved.
//

#import "AllModel.h"

@implementation GatewayGiftIncoming

+ (instancetype)giftWithCombo:(int)comb giftId:(int)giftId comboId:(int)comboId nickname:(NSString *)nickname portrait:(NSString *)portrait uid:(long long)uid {
    GatewayGiftIncoming * giftModel = [[GatewayGiftIncoming alloc] init];
    giftModel.combo = comb;
    giftModel.giftId = giftId;
    giftModel.comboId = comboId;
    giftModel.nickname = nickname;
    giftModel.portrait = portrait;
    giftModel.uid = uid;
    return giftModel;
}

@end

@implementation LiveGiftModel

+ (LiveGiftModel *)giftImageOfId:(int)idd
{
    NSMutableArray * giftIconArr = (NSMutableArray *)@[@"红酒",@"啤酒",@"星巴克咖啡"];
    LiveGiftModel * model = [[LiveGiftModel alloc]init];
    model.idd = idd;
    model.name = giftIconArr[idd];
    model.icon = giftIconArr[idd];
    return model;
}


@end
