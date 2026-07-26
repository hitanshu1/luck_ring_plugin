//
//  YD_SyncFindDevCmd.h
//  StarWristSport
//
//  Created by qiaoliwei on 2019/4/16.
//  Copyright © 2019年 celink. All rights reserved.
//

#import "CE_Cmd.h"

NS_ASSUME_NONNULL_BEGIN

/// find device command
@interface YD_SyncFindDevCmd : CE_Cmd

@property (nonatomic, assign) Byte onoff; // 0: close, 1: open.


/// initialize find device command
/// @param onoff Status. 0: close, 1: open.
- (instancetype)initWithOnoff:(NSInteger)onoff;

@end

NS_ASSUME_NONNULL_END
