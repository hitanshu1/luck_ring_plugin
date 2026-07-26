//
//  CE_SystemPairCmd.h
//  K2SDKDemo
//
//  Created by cxq on 2016/12/28.
//  Copyright © 2016年 celink. All rights reserved.
//

#import "CE_Cmd.h"

/**
 用于通知设备侧，是否进行系统配对(配对后 设备才能收到 短信、QQ、微信等的消息)
 */
@interface CE_SystemPairCmd : CE_Cmd

/**
 0: 不打开配对 、1：打开配对
 */
@property (nonatomic,assign) uint8_t onoff;



@end
