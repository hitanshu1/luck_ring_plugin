//
//  CE_SyncSystemFaceDataCmd.h
//  StarWristSport
//
//  Created by kwan on 2019/9/29.
//  Copyright © 2019 celink. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CE_Cmd.h"

NS_ASSUME_NONNULL_BEGIN

@interface CE_SyncSystemFaceDataCmd : CE_Cmd

/**
 If acceleration is supported, the data will be sent at a very high rate.
 The default value is NO. Use command `CE_SyncWatchFaceStartCmd` to check whether the device support accelerate.
 */
@property (nonatomic, assign) BOOL isSupportAccelerate;

@property (nonatomic, strong) NSData *data;

@property (nonatomic, copy) void (^syncProgress)(CGFloat progress);

@end

NS_ASSUME_NONNULL_END
