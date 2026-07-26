//
//  CE_Cmd.h
//  K2SDKDemo
//
//  Created by cxq on 2016/12/23.
//  Copyright © 2016年 celink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FuncType.h"

typedef NS_ENUM(NSInteger, SendStatus) {
    
    SendStatus_notSend = 0,
    SendStatus_sending,
    SendStatus_sendEnd
};

typedef enum
{
    WeekRepeatDay_sun		= 1<<0,  //every Sunday repeat
    WeekRepeatDay_mon       = 1<<1,  //every Monday repeat
    WeekRepeatDay_tues		= 1<<2,  //every Tuesday repeat
    WeekRepeatDay_wed		= 1<<3,  //every Wednesday repeat
    WeekRepeatDay_thu		= 1<<4,  //every Thursday repeat
    WeekRepeatDay_fri		= 1<<5,  //every Friday repeat
    WeekRepeatDay_sat		= 1<<6,  //every Saturday repeat
}WeekRepeatDay;


/**封装了向设备侧发送的数据细节*/
@interface CE_Cmd : NSObject


/**因设备侧原因导致需要重发的次数*/
@property (nonatomic,assign) int repeatSendTimes;//重发次数


/**发送的超时时间 单位s*/
@property (nonatomic,assign) int overtime;//超时时间


/**发送状态*/
@property (nonatomic,assign) SendStatus sendStatus;


/**发送回调block*/
@property (nonatomic,copy) void (^sendCallback)(NSError *error);

@property (nonatomic, copy) void(^qrEndCallback)(NSError *error);

/**  如果命令 是没有应答的，则设置 该值为 YES，默认都是有应答的。 */
@property (nonatomic,assign) BOOL noCallback;

/**判断数据是否发送完整 YES:发送完成 NO:发送未完成，需要发送更多数据*/
- (BOOL)isSendEnd;

/**获取要发送的数据  type 0从头发 1从上次发送的位置发 2从接下来的位置发*/
- (NSData *)cmdData:(int)type;

/**  数据类型*/
- (K6_DataFuncType)funcType;

/**  命令类型 ,默认都为发送类型*/
- (K6_CMD_TYPE)cmdRequestType;


@end

