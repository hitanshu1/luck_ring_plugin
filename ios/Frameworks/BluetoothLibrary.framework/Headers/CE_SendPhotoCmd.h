//
//  CE_SendPhotoCmd.h
//  K6SDK
//
//  Created by LiJie on 2017/8/11.
//  Copyright © 2017年 LiJie. All rights reserved.
//

#import "CE_Cmd.h"

/// take photo command
@interface CE_SendPhotoCmd : CE_Cmd

/**  0：关闭拍照界面，1：打开拍照界面 */
@property (nonatomic,assign) uint8_t onoff;


/// initialize take photo command
/// @param onoff 0: close take photo; 1:open take photo function
- (instancetype)initWithOnoff:(NSInteger)onoff;

@end
