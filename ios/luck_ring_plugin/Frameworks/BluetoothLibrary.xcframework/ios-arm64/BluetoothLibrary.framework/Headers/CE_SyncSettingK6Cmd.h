//
//  CE_SyncSettingK6Cmd.h
//  CE_BleSDK
//
//  Created by LiJie on 2017/3/13.
//  Copyright © 2017年 celink. All rights reserved.
//

#import "CE_Cmd.h"
/**  K6 使用 */
@interface CE_SyncSettingK6Cmd : CE_Cmd

/**  0:12进制,1:24进制 , 0xFF:not set */
@property (nonatomic,assign) uint8_t clock_disp_type;

/**  抬手、翻腕 功能，0：close；1:抬手、翻腕 亮屏；0xFF: not set */
@property (nonatomic,assign) uint8_t hand_rise;

/**  语言   1: 中文，0：英语 */
@property (nonatomic,assign) uint8_t language;

@property (nonatomic, assign) uint8_t lock;

@end
