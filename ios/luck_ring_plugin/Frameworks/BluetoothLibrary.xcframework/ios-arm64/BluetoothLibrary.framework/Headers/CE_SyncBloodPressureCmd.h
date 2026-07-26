//
//  CE_SyncBloodPressureCmd.h
//  StarWristSport
//
//  Created by kwan on 2019/5/23.
//  Copyright © 2019 celink. All rights reserved.
//

#import "CE_Cmd.h"

NS_ASSUME_NONNULL_BEGIN

@interface CE_SyncBloodPressureCmd : CE_Cmd

// 0表示关闭检测，1表示打开检测
@property (nonatomic) uint8_t status;

@end

NS_ASSUME_NONNULL_END
