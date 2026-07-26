//
//  CE_SyncCustomFaceCmd.h
//  StarWristSport
//
//  Created by kwan on 2019/9/29.
//  Copyright © 2019 celink. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CE_Cmd.h"

NS_ASSUME_NONNULL_BEGIN

@interface CE_SyncCustomFaceCmd : CE_Cmd

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

@property (nonatomic,copy) void (^syncProgress)(CGFloat progress);


/// initialize CE_SyncCustomFaceCmd
/// @param image Background image. The image size depend on the device. Before transferring the picture data, it needs to be processed into an appropriate size.
/// @param width The width of the background image required by the device.
///              Different equipment requires different parameters value.
/// @param height The height of the background image required by the device.
/// @param imageType 0: Don't change the background image. The image should be null.
///                  1: Use the default background image. The image should be null.
///                  2: Use the image you send. If the image data is null, it will not change the background image.
/// @param textColor The custom face text color.
/// @param timePosition 0: Time label in upper part, 1: Time label in the lower part.
/// @param timeAboveType Elements shown above time label. 0: Close, 1: Date, 2: Sleep time, 3: heart rate value, 4: step.
/// @param timeBelowType Elements shown below time label. The types same as the timeAboveType.
- (instancetype)initWithImage:(UIImage *)image width:(CGFloat)width height:(CGFloat)height imageType:(NSInteger)imageType textColor:(UIColor *)textColor timePosition:(NSInteger)timePosition timeAboveType:(NSInteger)timeAboveType timeBelowType:(NSInteger)timeBelowType;

/// initialize CE_SyncCustomFaceCmd
/// @param image Background image. The image size depend on the device. Before transferring the picture data, it needs to be processed into an appropriate size.
/// @param width The width of the background image required by the device.
///              Different equipment requires different parameters value.
/// @param height The height of the background image required by the device.
/// @param imageType 0: Don't change the background image. The image should be null.
///                  1: Use the default background image. The image should be null.
///                  2: Use the image you send. If the image data is null, it will not change the background image.
/// @param textColor The custom face text color.
/// @param timePosition 0: Time label in upper part, 1: Time label in the lower part.
/// @param timeAboveType Elements shown above time label. 0: Close, 1: Date, 2: Sleep time, 3: heart rate value, 4: step.
/// @param timeBelowType Elements shown below time label. The types same as the timeAboveType.
/// @param imageColorType Image's color type. 0: RGB565, 1: RGB888
- (instancetype)initWithImage:(UIImage *)image width:(CGFloat)width height:(CGFloat)height imageType:(NSInteger)imageType textColor:(UIColor *)textColor timePosition:(NSInteger)timePosition timeAboveType:(NSInteger)timeAboveType timeBelowType:(NSInteger)timeBelowType imageColorType:(NSInteger)imageColorType;

@end

NS_ASSUME_NONNULL_END
