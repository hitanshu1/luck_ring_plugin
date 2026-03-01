//
//  CEProductK6.h
//  CE_BleSDK
//
//  Created by cxq on 2017/1/3.
//  Copyright © 2017年 celink. All rights reserved.
//

#import "CEProduct.h"

/**  ========Start & End========== */
#import "CE_SyncPairOKCmd.h"
#import "CE_SystemPairCmd.h"
#import "CE_SensorCmd.h"
#import "CE_AppExitCmd.h"

/**  ========Request========== */
#import "CE_RequestSystemPairStatusCmd.h"
#import "CE_RequestOTAStatusCmd.h"

#import "CE_RequestUserInfo.h"
#import "CE_RequestDevInfoCmd.h"
#import "CE_RequestBatteryCmd.h"
#import "CE_RequestAlarmInfoCmd.h"
#import "CE_RequestAllInfoCmd.h"
#import "CE_RequestSettingButtonFunCmd.h"
#import "CE_RequestLongSitCmd.h"
#import "CE_RequestDisturbCmd.h"
#import "CE_RequestGoalCmd.h"
#import "CE_RequestBloodPresureCmd.h"
#import "YD_RequestWatchFaceSettingCmd.h"

/**  ======== Set & Send========== */
#import "CE_SyncUserInfoCmd.h"
#import "CE_SyncSettingK6Cmd.h"
#import "CE_SyncAlarmK6Cmd.h"
#import "CE_SyncTimeCmd.h"
#import "CE_UnitSettingCmd.h"
//电话 短信 通知---
#import "CE_SyncWeatherCmd.h"
#import "CE_SyncHybridCmd.h"
#import "CE_SendPhotoCmd.h"
//发现手机---
#import "CE_SyncGoalCmd.h"
#import "CE_SyncWatchMenuCmd.h"//消息推送选项 和 表盘菜单选择
#import "CE_SendOtaDataCmd.h"
#import "CE_SyncMusicInfoCmd.h"
//GPS
#import "CE_SyncGpsArgumentCmd.h"
#import "CE_SyncLongSitRemindCmd.h"
#import "CE_SyncPhoneControlCmd.h"
#import "CE_SyncDisturbCmd.h"

#import "YD_SyncSMSAlarmCmd.h"
#import "YD_SyncCallAlarmCmd.h"
#import "YD_SyncFinishGoalCmd.h"
#import "YD_SyncDrinkAlarmCmd.h"
#import "YD_SyncUpBrightCmd.h"
#import "YD_SyncAutoHeartCmd.h"
#import "YD_SyncFindDevCmd.h"
#import "YD_SyncLanguageCmd.h"

#import "CE_SyncHeartO2Cmd.h"
#import "CE_SyncECGCmd.h"
#import "CE_SyncBloodPressureCmd.h"

#import "YD_SyncFaceIndexCmd.h"
#import "CE_SyncSystemFaceDataCmd.h"
#import "CE_SyncCustomFaceCmd.h"
#import "CE_SendMotionCmd.h"


/**  蓝牙状态改变，非关闭。都会自动发送一次自动重连（有UUID 才能连上） */
/**
 第一次连接，自动发送 确认配对命令。设备需要 点击确认
 第二次（已保存UUID）连接，自动发送确认命令，设备不需要 再点击确认。
 
 --确认配对 后，自动发送： 1.打开数据开关命令 、 2.系统配对命令、 3.同步时间命令、 4.设备信息、5.OTA状态*/


/**  设备侧发过来的 数据通过通知 获取userInfo
 数据格式：@{  @"DataType":                NSNumber,    数据类型
 @"DataType_Description":    NSString,    对应数据类型的解释
 @"error_msg":               NSString,    错误信息，没有错误则为空
 @"Data":                    NSDictionary 具体的 数据。
 }
 */
extern NSString *const CEProductK6ReceiveDataNoticeKey;

typedef void(^CECmdErrorBlock)(NSError *);

@interface CEProductK6 : CEProduct

// 产品ID号，区分不同产品,读取 pid 需要在收到数据的通知之后
// 悦动设备 1-F618 ，2-F818
@property (nonatomic, assign) NSInteger pid;

@property (nonatomic, copy) void (^receiveOriginalDataHandler)(NSData *data); // the received original Bluetooth data
@property (nonatomic, copy) void (^sendOriginalDataHandler)(NSData *data); // the send original Bluetooth data
@property (nonatomic, copy) void (^connectStatusChanged)(ProductStatus status); // the connnection status

+ (instancetype)shareInstance;

//发送各种命令,并加入到队列(收到应答才发队列中的下个命令)
- (void)sendCmdToDevice:(CE_Cmd *)cmd complete:(CECmdErrorBlock)handler;

/// 清空cmd队列
- (void)cleanCmdQueue;

@end








