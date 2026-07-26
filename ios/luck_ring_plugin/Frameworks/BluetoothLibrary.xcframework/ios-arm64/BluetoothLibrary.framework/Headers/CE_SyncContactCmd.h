//
//  ContactCmd.h
//  BluetoothLibrary
//
//  Created by coolwear on 2021/9/17.
//  Copyright © 2021 kwan. All rights reserved.
//

// 手表中index从1开始， app端同步从0开始
#import <BluetoothLibrary/BluetoothLibrary.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, ContactCmdType) {
    ContactCmdTypeAdd, //添加
    ContactCmdTypeDelete, //删除
    ContactCmdTypeClear, //清空
    ContactCmdTypeSync  //同步
};


@interface CE_SyncContactCmd : CE_Cmd

@property (nonatomic, copy) NSString * name;

@property (nonatomic, copy) NSString * phone;

@property (nonatomic, assign) ContactCmdType type;

@property (nonatomic, copy) NSString *removeIndex; //删除索引

@property (nonatomic, copy) NSString *syncIndex; //同步索引

@property (nonatomic, assign) NSInteger syncIdx;

@property (nonatomic, assign) NSInteger nameSize;//名字大小(默认20)

// 同步
+ (void)syncAtIndex:(uint8_t)index handler:(_Nullable CECmdErrorBlock)handler;

// 插入
+ (void)insertWithName:(NSString *)name phone:(NSString *)phone handler:(_Nullable CECmdErrorBlock)handler;

+ (void)insert:(NSString *)tel name:(NSString *)name nameSize:(NSInteger)nameSize;

// 删除
+ (void)deleteAtIndex:(uint8_t)index handler:(_Nullable CECmdErrorBlock)handler;

@end

NS_ASSUME_NONNULL_END
