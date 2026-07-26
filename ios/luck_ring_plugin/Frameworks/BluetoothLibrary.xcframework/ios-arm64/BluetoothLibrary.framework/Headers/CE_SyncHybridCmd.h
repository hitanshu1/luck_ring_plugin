//
//  CE_SyncHybridCmd.h
//  CE_BleSDK
//
//  Created by LiJie on 2017/3/6.
//  Copyright © 2017年 celink. All rights reserved.
//

#import "CE_Cmd.h"


@interface CE_SyncHybridCmd : CE_Cmd

/**
 DATA_TYPE_USERINFO    102 用户信息
 DATA_TYPE_LANGUAGE_SETTING     103 语言设置信息
 DATA_TYPE_TIME        104 时间同步
 DATA_TYPE_WEATHER     105 天气信息
 DATA_TYPE_ALARM       106 闹钟信息
 DATA_TYPE_SET_TARGET  112 同步目标值*/
@property (nonatomic, strong) NSArray<CE_Cmd*> *infoItems;//条目信息


/// initialize
/// @param items the bluetooth cmd items
- (instancetype)initWithItems:(NSArray<CE_Cmd*>*)items;

@end
