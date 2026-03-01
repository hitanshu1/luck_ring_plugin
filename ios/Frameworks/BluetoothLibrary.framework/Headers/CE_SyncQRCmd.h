//
//  CE_SyncQRCmd.h
//  BluetoothLibrary
//
//  Created by coolwear on 2022/8/9.
//  Copyright © 2022 kwan. All rights reserved.
//

#import <BluetoothLibrary/BluetoothLibrary.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, QR_TYPE) {
    QR_TYPE_NULL = 0,
    QR_TYPE_WECHAT,
    QR_TYPE_QQ,
    QR_TYPE_ALIPAY,
    QR_TYPE_WHATSAPP,
    QR_TYPE_TWITTER,
    QR_TYPE_LINKEDIN,
    QR_TYPE_INSTAGRAM,
    QR_TYPE_FACEBOOK,
    QR_TYPE_WEIBO,
    QR_TYPE_LINE,
    QR_TYPE_TIM,
    QR_TYPE_SNAPCHAT,
    QR_TYPE_VIBER,
    QR_TYPE_PAYPAL,
    QR_TYPE_OTHER,
};

@interface CE_SyncQRCmd : CE_Cmd

@property (nonatomic, assign) NSInteger idx;    //列表序号
@property (nonatomic, assign) QR_TYPE type;   //类型
@property (nonatomic, assign) NSInteger len;    //二维码长度
@property (nonatomic, copy) NSString *name;     //名字最大20个字节
@property (nonatomic, copy) NSString *content;  //二维码内容

@property (nonatomic, assign) K6_DataFuncType dataType;

//+ (void)sendQr:(NSString *)name content:(NSString *)content idx:(NSInteger)idx type:(QR_TYPE)type complete:(CECmdErrorBlock)complete;

+ (void)sendQrWithName:(NSString *)name
               content:(NSString *)content
                 qrIdx:(NSInteger)qrIdx
                qrType:(QR_TYPE)qrType
              complete:(CECmdErrorBlock)complete;

+ (void)removeQrWithIdx:(NSInteger)idx;

+ (void)clearQr;

@end

NS_ASSUME_NONNULL_END
