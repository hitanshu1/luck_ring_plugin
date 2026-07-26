//
//  CE_SyncPairOKCmd.h
//  K2SDKDemo
//
//  Created by cxq on 2016/12/28.
//  Copyright © 2016年 celink. All rights reserved.
//

#import "CE_Cmd.h"


/**
 用于向设备侧确认是否配对完成
 当APP成功与设备连接绑定后(如扫描二维码或输入配对数字)，
 APP应主动告之设备侧，设备侧根据配对的状态信息来做相应的操作
 (如退出二维码界面，或保存相关的配对信息等)，
 该命令使用数据类型为DATA_TYPE_PAIR_FINISH
 */

/**  K3用到的 */
@interface CE_SyncPairOKCmd : CE_Cmd

@property (nonatomic, assign) Byte firstPairStatus;


/// initialize
/// @param status 0: normal, 1: first times pair
- (instancetype)initWith:(NSInteger)status;

@end
