//
//  CE_SyncTimeCmd.h
//  K2SDKDemo
//
//  Created by cxq on 2016/12/23.
//  Copyright © 2016年 celink. All rights reserved.
//

#import "CE_Cmd.h"

/**
 设置设备的时间
 */
@interface CE_SyncTimeCmd : CE_Cmd

/**
 时间戳，是相对于1970-1-1的时间 单位 秒
 */
@property (nonatomic,assign) uint32_t absTime;

/**
 是相对于伦敦0时区的偏移时区值 单位 秒
 */
@property (nonatomic,assign) int32_t offsetTime;

@property (nonatomic,assign) Byte format; //0: 12h, 1:24h.
@property (nonatomic,assign) Byte mdFormat; // Month day format. 0: month-day, 1: day-month

/// initialize
/// @param absTime timestamp since 1970
/// @param offsetTime time zone offset
/// @param format  0:12-hour, 1:24-hour
/// @param mdFormat 0: month-day, 1: day-month
- (instancetype)initWithAbsTime:(double)absTime offset:(NSInteger)offsetTime format:(NSInteger)format mdFormat:(NSInteger)mdFormat;

@end
