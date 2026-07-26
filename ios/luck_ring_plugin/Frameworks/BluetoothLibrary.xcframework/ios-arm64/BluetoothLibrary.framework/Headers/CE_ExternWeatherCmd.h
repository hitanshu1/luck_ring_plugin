//
//  CE_ExternWeatherCmd.h
//  CLBluetoothModule
//
//  Created by summer on 2024/3/20.
//

#import "CE_Cmd.h"

NS_ASSUME_NONNULL_BEGIN

@class CE_ExternWeatherItem;
@interface CE_ExternWeatherCmd : CE_Cmd

/// Current time's timestamps
@property (nonatomic, assign) int32_t time;

@property (nonatomic,assign) uint8_t weather;

 //日间天气
@property (nonatomic,assign) int8_t day_weather;

@property (nonatomic,assign) int8_t night_weather;

@property (nonatomic,assign) int8_t temperature;
@property (nonatomic,assign) int8_t feel_temperature;

@property (nonatomic,assign) int8_t wind_scale;
@property (nonatomic,assign) int8_t day_wind_scale;
@property (nonatomic,assign) int8_t night_wind_scale;
@property (nonatomic,assign) int8_t wind_direction;

@property (nonatomic,assign) int8_t humidity;
@property (nonatomic,assign) uint16_t rev;

@end

/**
 {
 unsigned char update_time[4]; //更新的时间

     unsigned char weather;        //type: 0. sunny, 1. cloudy, 2. partly_cloudy, 3. rain, 4. snow.
                             10.晴，11.多云，12.阴天，13.阵雨，14.雷阵雨，15.小雨，16.中雨，17.大雨，18. 雨夹雪，19.小雪，20.中雪，21.大雪，22.雾霾，23.风沙
  (0－4序号的天气为旧天气，按照旧协议转换，10－23序号为新协议的天气，另外APP在发送天气之前，应先获取设备侧的天气种类信息，然后再发送天气信息，因此APP在连接上蓝牙后应先发送混杂的同步命令到设备侧，设备侧也会返回混杂的同步命令到APP(其中包含了APP的控制命令)，然后APP再根据控制命令中的天气种类决定是发旧的0-4号天气还是新的10-23号天气)

 unsigned char day_weather;   //日间天气
 unsigned char night_weather;  //夜间天气

 signed char temperature;  //实时温度 单位为摄氏度
 signed char feel_temperature;  //体感温度 单位为摄氏度

 unsigned char wind_scale;        //风力等级
 unsigned char day_wind_scale;    //日间风力等级
 unsigned char night_wind_scale;   //夜间风力等级

 unsigned char wind_direction; //风向
 unsigned char humidity;  //相对湿度  百分比数值

 unsigned char rev[2];
 }weather_info_extern_struct;
 */

@interface CE_ExternWeatherItem : NSObject

@property (nonatomic,assign) uint8_t weather;

 //日间天气
@property (nonatomic,assign) int8_t day_weather;

@property (nonatomic,assign) int8_t night_weather;

@property (nonatomic,assign) int8_t temperature;
@property (nonatomic,assign) int8_t feel_temperature;
@property (nonatomic,assign) int8_t wind_scale;
@property (nonatomic,assign) int8_t day_wind_scale;
@property (nonatomic,assign) int8_t night_wind_scale;
@property (nonatomic,assign) int8_t wind_direction;

@property (nonatomic,assign) int8_t humidity;
@property (nonatomic,assign) uint16_t rev;

- (NSData *)itemData;
@end

NS_ASSUME_NONNULL_END
