//
//  CE_DeleteImageCmd.h
//  BluetoothLibrary
//
//  Created by coolwear on 2022/11/5.
//  Copyright © 2022 kwan. All rights reserved.
//

#import <BluetoothLibrary/BluetoothLibrary.h>

NS_ASSUME_NONNULL_BEGIN

@interface CE_DeleteImageCmd : CE_Cmd
@property (nonatomic, assign) uint8_t idx;
+ (void)deleteImageAtIndex:(NSInteger)index compelte:(CECmdErrorBlock)block;;
@end

NS_ASSUME_NONNULL_END
