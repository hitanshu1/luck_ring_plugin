//
//  CE_SyncGoalCmd.h
//  K2SDKDemo
//
//  Created by cxq on 2016/12/28.
//  Copyright © 2016年 celink. All rights reserved.
//

#import "CE_Cmd.h"


/**
 The goal of a day command
 用于设置设备的目标值
 */
@interface CE_SyncGoalCmd : CE_Cmd

/**
 步数目标
 */
@property (nonatomic,assign) uint32_t step;

/**
 距离目标
 */
@property (nonatomic,assign) uint32_t distance;

/**
 卡路里目标
 */
@property (nonatomic,assign) uint32_t calories;

/**
 睡眠目标 单位：分钟
 */
@property (nonatomic,assign) uint16_t sleep;

@property (nonatomic,assign) uint16_t sportTime;


/// initialize goal command of a day
/// @param step Step value
/// @param distance distance (meter)
/// @param calories calories (cal)
/// @param sleepTime sleepTime (minute)
/// @param sportTime sportTime (minute)
- (instancetype)initWithStep:(NSInteger)step distance:(NSInteger)distance calories:(NSInteger)calories sleeptime:(NSInteger)sleepTime sportTime:(NSInteger)sportTime;

@end
