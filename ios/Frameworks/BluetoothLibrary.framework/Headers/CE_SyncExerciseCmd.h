//
//  CE_SyncExerciseCmd.h
//  StarWristSport
//
//  Created by ledong on 2018/3/30.
//  Copyright © 2018年 celink. All rights reserved.
//

#import "CE_Cmd.h"

@interface CE_SyncExerciseCmd : CE_Cmd

@property (nonatomic, assign) uint8_t exerType;
@property (nonatomic, assign) uint8_t exerStatus;

@end
