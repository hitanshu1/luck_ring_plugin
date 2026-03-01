//
//  CE_SyncMenstrualCycleCmd.h
//  BluetoothLibrary
//
//  Created by kwan on 2020/8/29.
//  Copyright © 2020 kwan. All rights reserved.
//

#import <BluetoothLibrary/BluetoothLibrary.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(uint8_t, MenstrualCycleType) {
    MenstrualCycleTypeNone = 0, // unknow type
    MenstrualCycleTypeNonPregnancy, // Menstrual cycle at non-pregnancy period
    MenstrualCycleTypePregnancy // Menstrual cycle at pregnancy period
};

@interface CE_SyncMenstrualCycleCmd : CE_Cmd

@property (nonatomic, assign) MenstrualCycleType menstrualCycleType;
@property (nonatomic, assign) uint32_t startTime; // Menstrual cycle start time
@property (nonatomic, assign) uint8_t duration; // Menstrual cycle duration
@property (nonatomic, assign) uint8_t period; // Menstrual cycle period
@property (nonatomic, assign) uint8_t onOff; // Reminder switch status. 0: off, 1: on.
@property (nonatomic, assign) uint8_t reminderMintue; // Reminder mintue. Values between 0 and 60.
@property (nonatomic, assign) uint8_t reminderHour; // Reminder hour. Values between 0 and 24.
@property (nonatomic, assign) uint8_t menstrualNoticeAdvance; // One day's advance notice menstrual. 0: off, 1: on.
@property (nonatomic, assign) uint8_t ovulationNoticeAdvance; // One day's advance notice ovulation. 0: off, 1: on.
@property (nonatomic, assign) uint8_t ovulationPeakNoticeAdvance; // One day's advance notice ovulation peak. 0: off, 1: on.
@property (nonatomic, assign) uint8_t ovulationEndNoticeAdvance; // One day's advance notice ovulation end. 0: off, 1: on.

@end

NS_ASSUME_NONNULL_END
