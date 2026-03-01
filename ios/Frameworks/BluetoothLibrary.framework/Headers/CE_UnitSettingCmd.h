//
//  CE_UnitSettingCmd.h
//  StarWristSport
//
//  Created by kwan on 2018/7/24.
//  Copyright © 2018 celink. All rights reserved.
//

#import "CE_Cmd.h"

/// unit setting command
@interface CE_UnitSettingCmd : CE_Cmd 

@property (nonatomic, assign) NSInteger weight;//重量单位 0: 千克，1：磅，2：英石
@property (nonatomic, assign) NSInteger distance;//距离单位 0: 米，1：英里
@property (nonatomic, assign) NSInteger weather;//温度单位 0: 摄氏度，1：华氏度
@property (nonatomic, assign) NSInteger reserved;//对齐保留


/// initialize unit setting command
/// @param weight weight unit. 0: kilogram, 1: pound, 2: stone
/// @param distance distance unit. 0: meters, 1: miles
/// @param weather weather unit. 0: Celsius, 1: Fahrenheit
- (instancetype)initWithWeightUnit:(NSInteger)weight distanceUnit:(NSInteger)distance weatherUnit:(NSInteger)weather;

@end
