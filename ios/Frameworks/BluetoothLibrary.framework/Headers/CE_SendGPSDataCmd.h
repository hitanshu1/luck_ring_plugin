//
//  CE_SendGPSDataCmd.h
//  StarWristSport
//
//  Created by kwan on 2018/8/21.
//  Copyright © 2018 celink. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CE_Cmd.h"

typedef enum {
    GPS_ONLINE_TYPE = 0,        //GPS在线数据类型
    GPS_OFFLINE_TYPE,        //GPS离线数据类型
} GPS_ARGUMENT_TYPE;

@interface CE_SendGPSDataCmd : CE_Cmd

/**
 初始化 GPS 数据

 @param gpsData 从网络下载的 GPS 数据
 @param type GPS 数据类型
 @return id
 */
- (id)initWithGpsData:(NSData *)gpsData type:(GPS_ARGUMENT_TYPE)type;

/**
 数据同步到设备的进度
 */
@property (nonatomic,copy) void (^syncProgress)(CGFloat progress);

@end
