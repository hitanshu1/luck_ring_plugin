//
//  CE_SyncAlarmK6Cmd.h
//  CE_BleSDK
//
//  Created by LiJie on 2017/3/13.
//  Copyright © 2017年 celink. All rights reserved.
//

#import "CE_Cmd.h"


/**
 1个闹钟信息
 */
@interface CE_AlarmItem : NSObject

/**  闹钟名称 20字节 6个汉字*/
@property (nonatomic, copy) NSString * _Nullable name;

/** 在一星期中重复的天数
 repeatDay的最高位表示是否重复，1表示每个星期都重复，0表示永不重复，
 若是永不重复则repeatDay的低7位要全部填1(即0x7F = 127)，以表示每天都有效，这样设备侧会仅闹一次后再将闹钟值删除*/
@property (nonatomic,assign) WeekRepeatDay repeatDay;


/**是否每周重复  设备返回时候直接判断repeatDay 的值即可*/
@property (nonatomic,assign) BOOL isRepeatWeek;


/**闹钟提醒的小时*/
@property (nonatomic,assign) uint8_t hour;


/**闹钟提醒的分钟*/
@property (nonatomic,assign) uint8_t min;


/**闹钟提醒状态 0:关闭 1:打开*/
@property (nonatomic,assign) uint8_t status;


/// initliaize
/// @param status alarm swith status. 0: off, 1: on
/// @param isRepeatWeek Repeat alarm every week.
/// @param repeatDay Alarm repeat day on every day.
/// @param hour The alarm hour.
/// @param minute The alarm minute.
- (nonnull instancetype)initWithStatus:(NSInteger)status weekRepeat:(BOOL)isRepeatWeek weekRepeatDay:(WeekRepeatDay)repeatDay hour:(NSInteger)hour minute:(NSInteger)minute;

@end

@interface CE_AlarmItem518 : CE_AlarmItem

@end

@interface CE_SyncAlarmK6Cmd : CE_Cmd

@property (nonatomic,strong) NSArray <CE_AlarmItem *> * _Nullable alarmItems;


/// initlaize alarm command
/// @param alarmItems alarmItems
- (nonnull instancetype)initWithItems:(nonnull NSArray<CE_AlarmItem *>*)alarmItems;

@end
