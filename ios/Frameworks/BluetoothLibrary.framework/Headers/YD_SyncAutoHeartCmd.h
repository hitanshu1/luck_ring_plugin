//
//  YD_SyncAutoHeartCmd.h
//  StarWristSport
//
//  Created by qiaoliwei on 2019/4/16.
//  Copyright © 2019年 celink. All rights reserved.
//

#import "CE_Cmd.h"

NS_ASSUME_NONNULL_BEGIN

/// auto heart rate detection setting command
@interface YD_SyncAutoHeartCmd : CE_Cmd
/// Automatic heart rate detection. Once every 10 minutes.
/// 0: close, 1: open.
@property (nonatomic, assign) Byte onoff;

/// Heart rate measurement for 24 hours
/// Valid when DATA_TYPE_FUNCTION_CONTROL hasHR24h is true
@property (nonatomic, assign) Byte hr24hOnoff;

@end

NS_ASSUME_NONNULL_END
