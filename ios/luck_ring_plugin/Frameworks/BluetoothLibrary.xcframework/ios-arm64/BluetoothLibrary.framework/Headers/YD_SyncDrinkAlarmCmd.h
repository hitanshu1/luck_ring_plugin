//
//  YD_SyncDrinkAlarmCmd.h
//  StarWristSport
//
//  Created by qiaoliwei on 2019/4/16.
//  Copyright © 2019年 celink. All rights reserved.
//

#import "CE_Cmd.h"

NS_ASSUME_NONNULL_BEGIN

/// drink water reminder command
@interface YD_SyncDrinkAlarmCmd : CE_Cmd

@property (nonatomic, assign) Byte onoff;
@property (nonatomic, assign) Byte start_hour;
@property (nonatomic, assign) Byte start_min;
@property (nonatomic, assign) Byte end_hour;
@property (nonatomic, assign) Byte end_min;

//drink water reminder interval. Four level support: 0: 30 minutes, 1: 1 hour, 2: 2 hours, 3: 3 hours
@property (nonatomic, assign) Byte interval;

- (instancetype)initWithDBString:(NSString *)waterRemind;
- (NSString *)combindDBString;


/// initialize drink water reminder command
/// @param onoff Switch status. 0: off, 1: on
/// @param startHour startHour. 0-24
/// @param startMintue startMintue. 0-59
/// @param endHour endHour
/// @param endMinute endMinute
/// @param intervalLevel drink water reminder interval. Four level support:
///                      0: 30 minutes, 1: 1 hour, 2: 2 hours, 3: 3 hours
- (instancetype)initWithOnoff:(NSInteger)onoff startHour:(NSInteger)startHour startMintue:(NSInteger)startMintue endHour:(NSInteger)endHour endMinute:(NSInteger)endMinute intervalLevel:(NSInteger)intervalLevel;

@end

NS_ASSUME_NONNULL_END
