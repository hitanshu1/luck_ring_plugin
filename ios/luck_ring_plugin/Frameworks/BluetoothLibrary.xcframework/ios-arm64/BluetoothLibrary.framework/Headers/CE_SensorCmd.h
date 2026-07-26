//
//  CE_SensorCmd.h
//  K2SDKDemo
//
//  Created by cxq on 2016/12/28.
//  Copyright © 2016年 celink. All rights reserved.
//

#import "CE_Cmd.h"

/**
 用于设置设备sensor开关.当APP进入前后台时都要主动发送data开关状态到设备侧，设备侧根据此开关状态来决定是否可能上传数据到APP,设备侧只有在开关打开时才可以上传sensor数据到APP，这样可起到省电的目的
 */

/** 数据开关*/
@interface CE_SensorCmd : CE_Cmd

+ (void)open;

+ (void)close;

/**
 设置数据开关的状态，0：关闭sensor，1：打开sensor。
 */
@property (nonatomic,assign) uint8_t onoff;


/// initialize
/// @param onoff
///        When app enter foreground send onoff = 1.
///        When app enter background or killed send onoff = 0.
- (instancetype)initWith:(NSInteger)onoff;

@end
