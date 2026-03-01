//
//  CEProduct.h
//  K2SDKDemo
//
//  Created by cxq on 2016/12/21.
//  Copyright © 2016年 celink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CEConnector.h"
@class CBPeripheral;
@class CECharacteristicManager;
typedef NS_ENUM(NSInteger,ProductStatus) {
    
    ProductStatus_none,         //还没开始搜索
    ProductStatus_powerOff,     //蓝牙断开
    ProductStatus_searching,    //搜索中
    ProductStatus_connecting,   //正在连接中...
    ProductStatus_disconnected, //连接断开
    ProductStatus_connected,    //连接成功,开始配对
    ProductStatus_completed     //配对完成,可以正常通信
};

/**  搜索设备 的回调通知  value is an NSArray <SearchPeripheral *>*/
extern NSString * const ScanPeripheralsNoticeKey;
/**  设备状态改变的 回调通知  value is an NSNumber <ProductStatus>*/
extern NSString * const ProductStatusChangeNoticeKey;
/// 已被发现的外设通知
extern NSString * const CESDKPeripheralDidDiscoveredKey;

/**  管理一个设备 包括搜索 连接 数据传输 */
@interface CEProduct : NSObject

// 是否绑定
@property (nonatomic, assign, readonly, class) BOOL isBinding;

/**  用于管理CEProduct的搜索和连接 */
@property (nonatomic, strong, readonly) CEConnector *connect;

/**  设备当前状态 */
@property (nonatomic, assign, readonly) ProductStatus status;

/**  设备的服务ID */
@property (nonatomic, strong) NSString *sid;

/** 用于自动重连的设备的identifier*/
@property (nonatomic, strong) NSString *lastConnectUUId;

/** 读特征*/
//@property (nonatomic, strong, readonly) NSMutableArray *writeChars;

/** 写特征*/
//@property (nonatomic, strong, readonly) NSMutableArray *readChars;


@property (nonatomic, strong) CECharacteristicManager *characManager;

/**  是否正在 升级中(cmd 队列里面是否有 OTA的cmd) */
@property (nonatomic, assign) BOOL isUpdating;

// 判断是否是手表拒绝或者用户拒绝
@property (nonatomic, assign, readonly) BOOL refused;

/// 当前将要绑定或已经绑定的设备
@property (nonatomic, strong, readonly) CBPeripheral *peripheral;

/// 当前绑定设备的UUID, 用于自动重连
@property (nonatomic, strong) NSString *UUIDStr;

/** 修改设备的状态*/  
- (void)changeStatus:(ProductStatus)status;

/** 开始搜索*/
- (void)startScan;

/** 停止搜索*/
- (void)stopScan;

/** 开始自动重连*/
- (void)startAutoConnect;

/** 连接指定的设备*/
- (void)connect:(CBPeripheral *)peripheral;

/** 收到设备侧上传的数据,设备侧上传的数据*/
- (void)didReceivedData:(NSData *)receiveData;

/** 数据发送成功*/
- (void)didSendSuccess;

/** 解除绑定，并且会清除自动重连的设备信息。*/
- (void)releaseBind;

/** 保存已经连接的设备identifier*/
- (void)saveConnectedUUid;

@end
