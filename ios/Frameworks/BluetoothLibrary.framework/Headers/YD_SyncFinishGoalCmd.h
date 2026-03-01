//
//  YD_SyncFinishGoalCmd.h
//  StarWristSport
//
//  Created by qiaoliwei on 2019/4/16.
//  Copyright © 2019年 celink. All rights reserved.
//

#import "CE_Cmd.h"

NS_ASSUME_NONNULL_BEGIN

@interface YD_SyncFinishGoalCmd : CE_Cmd

@property (nonatomic, assign) Byte onoff; // 0: close, 1: open.

@end

NS_ASSUME_NONNULL_END
