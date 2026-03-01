//
//  BluetoothLibrary.h
//  BluetoothLibrary
//
//  Created by kwan on 2020/3/10.
//  Copyright © 2020 kwan. All rights reserved.
//

#import "Foundation/Foundation.h"

//! Project version number for BluetoothLibrary.
FOUNDATION_EXPORT double BluetoothLibraryVersionNumber;

//! Project version string for BluetoothLibrary.
FOUNDATION_EXPORT const unsigned char BluetoothLibraryVersionString[];

#import "FuncType.h"
#import "SearchPeripheral.h"
#import "CEProduct.h"
#import "CEProductK6.h"

/** Command */

#import "CE_SyncPairOKCmd.h"
#import "CE_SystemPairCmd.h"
#import "CE_SensorCmd.h"
#import "CE_AppExitCmd.h"
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
#import "CE_RequestExerciseStatusCmd.h"
#import "CE_SyncUserInfoCmd.h"
#import "CE_SyncSettingK6Cmd.h"
#import "CE_SyncAlarmK6Cmd.h"
#import "CE_SyncTimeCmd.h"
#import "CE_UnitSettingCmd.h"
#import "CE_SyncWeatherCmd.h"
#import "CE_SyncHybridCmd.h"
#import "CE_SendPhotoCmd.h"
#import "CE_SyncGoalCmd.h"
#import "CE_SyncWatchMenuCmd.h"
#import "CE_SendOtaDataCmd.h"
#import "CE_SendMotionCmd.h"
#import "CE_SyncMusicInfoCmd.h"
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
#import "CE_SyncUserInfoCmd.h"
#import "CE_SyncGoalCmd.h"

#import "CE_SyncWeatherCmd518.h"
#import "CE_SyncSwimPoolLenCmd.h"
#import "CE_SyncWatchFaceCmd.h"
#import "CE_SendGPSDataCmd.h"
#import "YD_SyncSportCmd.h"
#import "CE_SyncResetCmd.h"
#import "CE_SyncExerciseCmd.h"
#import "CE_SyncMenstrualCycleCmd.h"

#import "CE_SyncWatchFaceStartCmd.h"
#import "CE_SyncSystemFaceDataCmd.h"
#import "CE_LocationInfoCdm.h"
#import "CE_ExternWeatherCmd.h"

#import "CE_SyncContactCmd.h"
#import "CE_SyncHeartRateCmd.h"
#import "CE_RequestEdrInfoCmd.h"
#import "CE_SyncQRCmd.h"
#import "CE_SyncPhotoDialCmd.h"
#import "CE_DeleteImageCmd.h"
#import "CE_SyncOnoffScreenCmd.h"
#import "CE_SyncAlipayData.h"
