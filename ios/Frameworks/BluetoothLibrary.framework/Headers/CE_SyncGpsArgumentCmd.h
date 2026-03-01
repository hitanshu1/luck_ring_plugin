//
//  CE_SyncGpsArgumentCmd.h
//  CE_BleSDK
//
//  Created by cxq on 2017/2/9.
//  Copyright © 2017年 celink. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CE_Cmd.h"

@interface CE_SyncGpsArgumentCmd : CE_Cmd

@property (nonatomic,strong) NSData *gpArgumentData;
@property (nonatomic,assign) uint8_t gpsType;//0在线数据    1离线数据
@property (nonatomic,assign) uint32_t dataTime;//从网络上下载时的手机时间。

@property (nonatomic,copy) void (^syncProgress)(CGFloat progress);

@end
