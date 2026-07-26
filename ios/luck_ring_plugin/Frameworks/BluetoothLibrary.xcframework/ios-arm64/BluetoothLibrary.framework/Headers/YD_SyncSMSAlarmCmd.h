//
//  YD_SyncSMSAlarmCmd.h
//  StarWristSport
//
//  Created by qiaoliwei on 2019/4/16.
//  Copyright © 2019年 celink. All rights reserved.
//

#import "CE_Cmd.h"

NS_ASSUME_NONNULL_BEGIN

/// SMS push switch command
@interface YD_SyncSMSAlarmCmd : CE_Cmd

@property (nonatomic, assign) Byte onoff; // 0: close, 1: open.


/// initialize SMS push switch command
/// @param onoff Switch status. 0: close, 1: open
- (instancetype)initWithOnoff:(NSInteger)onoff;

@end

NS_ASSUME_NONNULL_END
