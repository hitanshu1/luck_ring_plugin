//
//  CE_SyncPhotoDialCmd.h
//  BluetoothLibrary
//
//  Created by coolwear on 2022/10/28.
//  Copyright © 2022 kwan. All rights reserved.
//

#import <BluetoothLibrary/BluetoothLibrary.h>

NS_ASSUME_NONNULL_BEGIN

@interface CE_SyncPhotoDialCmd : CE_Cmd
/**
 If acceleration is supported, the data will be sent at a very high rate.
 The default value is NO. Use command `CE_SyncWatchFaceStartCmd` to check whether the device support accelerate.
 */
@property (nonatomic, assign) BOOL isSupportAccelerate;

@property (nonatomic) unsigned char *imageBytes;
@property (nonatomic) size_t height;
@property (nonatomic) size_t width;
@property (nonatomic) size_t data_len;

// 背景图片类型 0.之前的背景图片(即不改变图片) 1：默认的系统背景图片 2：自定义背景图片（如果图片为空则展示上一次的）
@property (nonatomic, assign) NSInteger backgroundImageType;

@property (nonatomic, assign) NSInteger timePosition;
@property (nonatomic, assign) NSInteger timeAboveType;
@property (nonatomic, assign) NSInteger timeBelowType;

@property (nonatomic, strong) UIColor *color;

@property (nonatomic, assign) CGFloat timeX;
@property (nonatomic, assign) CGFloat timeY;
@property (nonatomic, assign) uint8_t model;//0=点击屏幕切换 1=自动切换
@property (nonatomic, assign) uint8_t timeInterval;
@property (nonatomic, assign) uint8_t timeUp;
@property (nonatomic, assign) uint8_t timeDown;
@property (nonatomic, assign) uint8_t imgNum;//图片数量 255=不改变图片
@property (nonatomic, strong) NSArray<UIImage *> *imgs;

- (void)prepare;

@property (nonatomic,copy) void (^syncProgress)(CGFloat progress);


@end

NS_ASSUME_NONNULL_END
