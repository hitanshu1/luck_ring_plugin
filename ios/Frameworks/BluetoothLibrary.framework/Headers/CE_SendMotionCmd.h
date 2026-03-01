//
//  CE_SendMotionCmd.h
//  BluetoothLibrary
//
//  Created by coolwear on 2023/8/19.
//  Copyright © 2023 kwan. All rights reserved.
//

#import <BluetoothLibrary/BluetoothLibrary.h>

NS_ASSUME_NONNULL_BEGIN

@interface CE_SendMotionCmd : CE_Cmd

@property (nonatomic,assign) uint8_t onoff;

- (instancetype)initWithOnoff:(NSInteger)onoff;

+ (void)open;
+ (void)close;

@end

NS_ASSUME_NONNULL_END

