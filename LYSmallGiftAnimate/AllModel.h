//
//  AllModel.h
//  LYSmallGiftAnimate
//
//  Created by 李洋 on 2017/9/14.
//  Copyright © 2017年 李洋. All rights reserved.
//

#import <Foundation/Foundation.h>

//收礼物
@interface GatewayGiftIncoming :NSObject

@property (nonatomic, copy) NSString *nickname;
@property (nonatomic, copy) NSString *portrait;
@property (nonatomic, assign) int combo;        //连击数
@property (nonatomic, assign) int firstCombo;   //第一次显示的连击数
@property (assign ,nonatomic) BOOL needShowFirstCombo;
@property (nonatomic, assign) long long comboId;//每个人送的每个礼物的comboId不同
@property (nonatomic, assign) int giftId;       //礼物id
@property (nonatomic, assign) int level;
@property (nonatomic, assign) long long roomId;
@property (nonatomic, assign) long long toUid;
@property (nonatomic, assign) int verified;
@property (nonatomic, assign) long long uid;
@property (nonatomic, assign) int utime;
@property (nonatomic, assign) double localTime;

+ (instancetype)giftWithCombo:(int)comb giftId:(int)giftId comboId:(int)comboId nickname:(NSString *)nickname portrait:(NSString *)portrait uid:(long long)uid;

@end

@interface LiveGiftModel : NSObject

@property (nonatomic, assign) int idd;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *icon;
@property (nonatomic, copy) NSString *desc;
@property (nonatomic, copy) NSString *isDefault;
@property (nonatomic, assign) int status;
@property (nonatomic, assign) int exp;
@property (nonatomic, assign) int lucky;
@property (nonatomic, assign) int percentage;
@property (nonatomic, assign) int diamond;
@property (nonatomic, assign) int type;//1小礼物 2大礼物  3红包 小礼物可连击
@property (nonatomic, copy) NSString *luckSetting;

+ (LiveGiftModel *)giftImageOfId:(int)idd;

@end
