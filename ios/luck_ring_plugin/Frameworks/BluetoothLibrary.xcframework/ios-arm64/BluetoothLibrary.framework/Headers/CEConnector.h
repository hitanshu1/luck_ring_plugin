//
//  CEBleConnect.h
//  K2SDKDemo
//
//  Created by cxq on 2016/12/19.
//  Copyright © 2016年 celink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
//搜索到的设备
#import "SearchPeripheral.h"
@class CEConnector;

@protocol CEConnectorDelegate <NSObject>

/**  蓝牙状态变更回调, 蓝牙状态 */
- (void)bluetoothStatusDidChanged:(CBManagerState)state;

/**  设备已连接成功的回调, 已经连接的设备 */
- (void)peripheralDidConnected:(CBPeripheral *)peripheral connect:(CEConnector *)connect;

/**  设备已断开连接的回调, 已经断开的设备 */
- (void)peripheralDidDisConnected:(CBPeripheral *)peripheral connect:(CEConnector *)connect;

/**  Connection state ERROR  */
- (void)peripheralConnectionError:(NSError*)error peripheral:(CBPeripheral *)peripheral;

@end

@interface CEConnector : NSObject

@property (nonatomic,weak) id <CEConnectorDelegate> delegate;

@property (nonatomic, strong, readonly) CBPeripheral *peripheral;

@property (nonatomic, assign, readonly) BOOL isScanning;

/// 自动扫描时间, 默认2s后自动停止扫描, 小于或等于0则需要手动停止
@property (nonatomic, assign) NSTimeInterval time;

- (instancetype)initWithDelegate:(id<CEConnectorDelegate>)delegate;

/// 开始搜索拥有指定服务ID的设备 ,YES:正在搜索， NO:没有打开蓝牙
- (BOOL)scanWithServiceId:(NSString *)sid;

- (void)stopScan;

- (void)connect:(CBPeripheral *)peripheral;

- (void)reconnectWithUUid:(NSString *)identifier;

- (void)cancel;


@end
