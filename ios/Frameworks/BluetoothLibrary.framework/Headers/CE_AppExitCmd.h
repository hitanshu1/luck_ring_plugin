//
//  CE_AppExitCmd.h
//  K2SDKDemo
//
//  Created by cxq on 2016/12/28.
//  Copyright © 2016年 celink. All rights reserved.
//

#import "CE_Cmd.h"


/**
 杀死APP时，需要向设备侧发送的数据
 */
@interface CE_AppExitCmd : CE_Cmd

+ (void)send;

@end
