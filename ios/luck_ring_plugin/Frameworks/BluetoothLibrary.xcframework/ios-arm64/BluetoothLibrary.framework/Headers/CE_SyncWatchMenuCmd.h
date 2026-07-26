//
//  CE_SyncWatchMenuCmd.h
//  K2SDKDemo
//
//  Created by cxq on 2016/12/28.
//  Copyright © 2016年 celink. All rights reserved.
//

#import "CE_Cmd.h"

/// device message alert switches command
@interface CE_SyncWatchMenuCmd : CE_Cmd

/// Master switch.
/// If master switch disabled, all of the message alert will be closed.
@property (nonatomic,assign) BOOL allSwitch;

@property (nonatomic,assign) BOOL qq;
@property (nonatomic,assign) BOOL wechat;
@property (nonatomic,assign) BOOL email;
@property (nonatomic,assign) BOOL facebook;
@property (nonatomic,assign) BOOL twitter;
@property (nonatomic,assign) BOOL whatsapp;
@property (nonatomic,assign) BOOL instagram;
@property (nonatomic,assign) BOOL skype;
@property (nonatomic,assign) BOOL linkedIn;
@property (nonatomic,assign) BOOL line;
@property (nonatomic,assign) BOOL other;
@property (nonatomic,assign) BOOL kakaoTalk;
@property (nonatomic,assign) BOOL telegram;
@end
