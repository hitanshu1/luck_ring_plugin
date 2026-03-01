//
//  YD_SyncFaceIndexCmd.h
//  StarWristSport
//
//  Created by kwan on 2019/9/29.
//  Copyright © 2019 celink. All rights reserved.
//

#import "CE_Cmd.h"

NS_ASSUME_NONNULL_BEGIN

/// switch face index command
@interface YD_SyncFaceIndexCmd : CE_Cmd

@property (nonatomic, assign) uint8_t index;


/// initialize sync face index command
/// A device generally has several dials, depending on the device.
/// The watch face can be switched by sending the face index.
/// @param index Index of the watch face you choosed.
- (instancetype)initWithIndex:(NSInteger)index;

@end

NS_ASSUME_NONNULL_END
