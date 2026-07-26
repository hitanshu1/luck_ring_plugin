//
//  CE_SyncHeartRateCmd.h
//  BluetoothLibrary
//
//  Created by coolwear on 2022/2/21.
//  Copyright © 2022 kwan. All rights reserved.
//

#import <BluetoothLibrary/BluetoothLibrary.h>

NS_ASSUME_NONNULL_BEGIN

@interface CE_SyncHeartRateCmd : CE_Cmd
// 0表示关闭检测，1表示打开检测
@property (nonatomic) uint8_t status;
@end

NS_ASSUME_NONNULL_END
