//
//  CE_SyncUserInfoCmd.h
//  K2SDKDemo
//
//  Created by cxq on 2016/12/26.
//  Copyright © 2016年 celink. All rights reserved.
//

#import "CE_Cmd.h"

/**
 用于设置设备侧的用户信息
 */
@interface CE_SyncUserInfoCmd : CE_Cmd

/**
  用户Id
 */
@property (nonatomic,assign) uint32_t userId;

/**
 用户性别 1女 0男
 */
@property (nonatomic,assign) uint8_t sex;

/**
 用户年龄
 */
@property (nonatomic,assign) uint8_t age;

/**
 用户身高
 */
@property (nonatomic,assign) uint8_t height;

/**
 用户体重 四舍五入
 */
@property (nonatomic,assign) uint8_t weight;

/**
 用户左右手习惯  0:左手 ，1：右手
 */
@property (nonatomic,assign) uint8_t lrHand;

@end
