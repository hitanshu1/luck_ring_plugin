//
//  CE_SyncDisturbCmd.h
//  CE_BleSDK
//
//  Created by LiJie on 2017/3/13.
//  Copyright © 2017年 celink. All rights reserved.
//

#import "CE_Cmd.h"

@interface CE_DisturbItem : NSObject

/// start hour time. 0 to 24
@property (nonatomic, assign) uint8_t start_time_hour;
/// start minute time. 0 to 59
@property (nonatomic, assign) uint8_t start_time_min;

/// end hour time
@property (nonatomic, assign) uint8_t end_time_hour;
/// end minute time
@property (nonatomic, assign) uint8_t end_time_min;

@end


/// do not disturb command
@interface CE_SyncDisturbCmd : CE_Cmd


@property (nonatomic, assign)uint8_t switch_flag;	// 0: close , 1: open.
@property (nonatomic,strong) NSArray <CE_DisturbItem *>* _Nonnull disturbItems;

/// initialize do not disturb command
/// @param onoff Switch status. 0: close , 1: open.
/// @param items disturb setting items. Only support one item in many device.
- (instancetype _Nonnull )initWithOnoff:(NSInteger)onoff items:(nonnull NSArray<CE_DisturbItem *>*)items;

@end
