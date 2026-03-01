//
//  YD_SyncUpBrightCmd.h
//  StarWristSport
//
//  Created by qiaoliwei on 2019/4/16.
//  Copyright © 2019年 celink. All rights reserved.
//

#import "CE_Cmd.h"

NS_ASSUME_NONNULL_BEGIN

@interface YD_SyncUpBrightCmd : CE_Cmd
@property (nonatomic, assign) Byte onoff;
@property (nonatomic, assign) Byte start_hour;
@property (nonatomic, assign) Byte start_min;
@property (nonatomic, assign) Byte end_hour;
@property (nonatomic, assign) Byte end_min;


- (instancetype)initWithDBString:(NSString *)upBright;
- (NSString *)combindDBString;

/// initialize
/// @param onoff Switch status. 0: off, 1: on.
/// @param startHour start hour. 0 - 24
/// @param startMintue start minute. 0 - 59
/// @param endHour end hour. 0 - 24
/// @param endMinute end minute.  0 - 59
- (instancetype)initWithOnoff:(NSInteger)onoff startHour:(NSInteger)startHour startMintue:(NSInteger)startMintue endHour:(NSInteger)endHour endMinute:(NSInteger)endMinute;

@end

NS_ASSUME_NONNULL_END
