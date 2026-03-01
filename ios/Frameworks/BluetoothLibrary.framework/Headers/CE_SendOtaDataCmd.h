//
//  CE_SendOtaDataCmd.h
//  K2SDKDemo
//
//  Created by cxq on 2016/12/28.
//  Copyright © 2016年 celink. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CE_Cmd.h"

@interface CE_SendOtaDataCmd : CE_Cmd

/**  OTA数据， OTA状态数据， 设备版本信息， 进度回调 */
- (id)initWithData:(NSData *)otaData
     otaStatusInfo:(NSDictionary*)info
        deviceInfo:(NSDictionary*)deviceInfo
   complteProgress:(void (^)(CGFloat rate))handler;

@end
