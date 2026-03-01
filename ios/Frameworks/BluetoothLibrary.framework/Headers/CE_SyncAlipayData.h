//
//  CE_SyncAlipayData.h
//  BluetoothLibrary
//
//  Created by coolwear on 2023/3/2.
//  Copyright © 2023 kwan. All rights reserved.
//

#import <BluetoothLibrary/BluetoothLibrary.h>

NS_ASSUME_NONNULL_BEGIN

@interface CE_SyncAlipayData : CE_Cmd
@property (nonatomic, strong) NSData* alipayData;
@end

NS_ASSUME_NONNULL_END
