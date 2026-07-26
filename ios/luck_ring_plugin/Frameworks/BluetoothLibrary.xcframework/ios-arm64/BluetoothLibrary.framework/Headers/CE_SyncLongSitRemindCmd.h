//
//  CE_SyncLongSitRemindCmd.h
//  CE_BleSDK
//
//  Created by LiJie on 2017/3/2.
//  Copyright © 2017年 celink. All rights reserved.
//

#import "CE_Cmd.h"


/// Sedentary reminder command
@interface CE_SyncLongSitRemindCmd : CE_Cmd

@property (nonatomic,assign) uint8_t onoff; // Switch staus. 0：close, 1：open
@property (nonatomic, assign) WeekRepeatDay repeatDay;

/** 时间段的： 开始时间，结束时间 */
@property (nonatomic, assign) uint8_t startTimeHour;
@property (nonatomic, assign) uint8_t startTimemin;
@property (nonatomic, assign) uint8_t endTimeHour;
@property (nonatomic, assign) uint8_t endTimeMin;
@property (nonatomic, assign) uint8_t noon_onoff;


/// initialize sedentary reminder command
/// @param onoff Switch staus. 0：close, 1：open
/// @param repeatDay WeekRepeatDay
/// @param startHour start hour. 0 to 24.
/// @param startMinute start minute. 0 to 59.
/// @param endHour end hour
/// @param endMinute end minute
- (instancetype)initWithOnoff:(NSInteger)onoff weekRepeatDay:(WeekRepeatDay)repeatDay startHour:(NSInteger)startHour startMinute:(NSInteger)startMinute endHour:(NSInteger)endHour endMinute:(NSInteger)endMinute;

@end
