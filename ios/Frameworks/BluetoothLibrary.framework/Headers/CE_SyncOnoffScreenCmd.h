//
//  CE_SyncOnoffScreenCmd.h
//  BluetoothLibrary
//
//  Created by coolwear on 2022/11/23.
//  Copyright © 2022 kwan. All rights reserved.
//

#import <BluetoothLibrary/BluetoothLibrary.h>

NS_ASSUME_NONNULL_BEGIN

@interface CE_SyncOnoffScreenCmd : CE_Cmd
@property (nonatomic, assign) BOOL isSupportAccelerate;
@property (nonatomic) unsigned char *imageBytes;
@property (nonatomic) size_t height;
@property (nonatomic) size_t width;
@property (nonatomic) size_t data_len;
@property (nonatomic,copy) void (^progress)(CGFloat value);

@property (assign) uint8_t power_flag;

@property (nonatomic, strong) UIImage* image;

@property (nonatomic, assign) NSInteger type; //类型 1=删除

- (void)prepare;

- (void)prepareForDelete;
@end

NS_ASSUME_NONNULL_END
