//
//  CE_SyncWeatherCmd.h
//  K2SDKDemo
//
//  Created by cxq on 2016/12/28.
//  Copyright © 2016年 celink. All rights reserved.
//

#import "CE_Cmd.h"

@interface CE_WeatherItem : NSObject

///  weather code
///
/// New weather type code
/// code       mean
/// 10         sunny 晴
/// 11         partly cloudy  多云
/// 12         cloudy day 阴天
/// 13         shower 阵雨
/// 14         Thundershower 雷阵雨
/// 15         Light rain 小雨
/// 16         Moderate rain 中雨
/// 17         heavy rain大雨
/// 18         Sleet雨夹雪
/// 19         Light snow小雪
/// 20         Moderate snow中雪
/// 21         The heavy snow大雪
/// 22         haze雾霾
/// 23         The wind风
///
/// deprecated below:
/// Old version of weather code
/// code       mean
/// 0          sunny
/// 1          cloudy
/// 2          partly_cloudy
/// 3          rain
/// 4          snow
@property (nonatomic,assign) uint8_t weather;
/// lowest temperature value of the day. Unit of value is Celsius.
@property (nonatomic,assign) int8_t low_temperature;
/// highest temperature value of the day. Unit of value is Celsius.
@property (nonatomic,assign) int8_t high_temperature;
/// air quality value. Could ignore this value.
@property (nonatomic,assign) uint16_t PM;

- (NSData *)itemData;

@end


/// weather command
@interface CE_SyncWeatherCmd : CE_Cmd

/// Current time's timestamps
@property (nonatomic, assign) int32_t time;
/// today's weather
@property (nonatomic, strong) CE_WeatherItem *todyWeather;
/// tomorrow's weather
@property (nonatomic, strong) CE_WeatherItem *tomorrowWeather;
/// the day after tomorrow's wether
@property (nonatomic, strong) CE_WeatherItem *dayAfterTomorrowWeather;

@end

// 实时天气
@interface CE_WeatherCurrCmd : CE_Cmd
@property (nonatomic, assign) uint8_t cond_code;    //天气图标
@property (nonatomic, assign) int8_t tmp;           //温度
@property (nonatomic, assign) uint8_t wind_sc;      //风力
@property (nonatomic, assign) uint8_t hum;          //湿度
@end
