//
//  SearchPeripheral.h
//  K2SDKDemo
//
//  Created by cxq on 2016/12/21.
//  Copyright © 2016年 celink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface SearchPeripheral : NSObject

@property (nullable, nonatomic, strong) CBPeripheral *peripheral;
@property (nullable, nonatomic, strong) NSNumber *rssi;
@property (nullable, nonatomic, strong) NSDictionary *advertisementData;

/** 是否被系统蓝牙连接上 */
@property (nonatomic,assign) BOOL isPairedSystem;

+ (instancetype _Nonnull)peripheral:(CBPeripheral * _Nonnull)peripheral
                  advertisementData:(NSDictionary * _Nonnull)advertisementData
                               rssi:(NSNumber * _Nonnull)rssi;

+ (instancetype _Nonnull)peripheral:(CBPeripheral * _Nonnull)peripheral
                     isSystemPaired:(BOOL)isPaired;

- (nullable NSString *)name;
// 展示在蓝牙搜索里面的ID
- (nullable NSString *)deviceID;
// 协议版本，根据此版本判断使用哪个版本的协议
- (NSInteger)version;

/// Return peripheral mac address if available
- (nullable NSString*)macAddress;

@end
