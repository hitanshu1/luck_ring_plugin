//
//  CE_RequestAllInfoCmd.h
//  CE_BleSDK
//
//  Created by cxq on 2017/1/17.
//  Copyright © 2017年 celink. All rights reserved.
//

#import "CE_Cmd.h"


/**  (混杂数据)设备同步的意思
 DATA_TYPE_DEVINFO、      设备信息
 DATA_TYPE_BATTERY_INFO、 电池信息
 DATA_TYPE_SETTING、      设置信息
 DATA_TYPE_ALARM          闹钟信息*/
@interface CE_RequestAllInfoCmd : CE_Cmd

@end
