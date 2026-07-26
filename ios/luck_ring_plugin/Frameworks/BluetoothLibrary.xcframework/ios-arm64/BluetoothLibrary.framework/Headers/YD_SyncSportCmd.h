//
//  YD_SyncSportCmd.h
//  StarWristSport
//
//  Created by kwan on 2019/3/18.
//  Copyright © 2019 celink. All rights reserved.
//

#import "CE_Cmd.h"

typedef enum {
    SPORT_STATUS_STOP = 0, // Stop workout
    SPORT_STATUS_START,    // Start workout
    SPORT_STATUS_PAUSE,    // Pause workout
    SPORT_STATUS_CONTINUE, // Resume from pause
    SPORT_STATUS_STOP_FORCE, // Force stop wokout
    SPORT_STATUS_SYNC, // Needed send app workout data to device. You can't send this type to device.
} SPORT_STATUS_TYPE;


NS_ASSUME_NONNULL_BEGIN

/// Application workout status set from device
@interface YD_SyncSportCmd : CE_Cmd

/// Workout type. Define your own.
@property (nonatomic, assign) uint8_t type;
/// Workout status. See enum SPORT_STATUS_SYNC.
@property (nonatomic, assign) uint8_t status;
/// Workout time with unit seconds.
@property (nonatomic, assign) int32_t time;
/// Workout distance.
@property (nonatomic, assign) int32_t distance;

@end

NS_ASSUME_NONNULL_END
