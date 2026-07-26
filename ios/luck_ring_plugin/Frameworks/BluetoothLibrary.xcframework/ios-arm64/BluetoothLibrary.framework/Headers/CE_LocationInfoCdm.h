//
//  CE_LocationInfoCdm.h
//  CLBluetoothModule
//
//  Created by summer on 2024/6/17.
//

#import "CE_Cmd.h"

NS_ASSUME_NONNULL_BEGIN

@interface CE_LocationInfoCdm : CE_Cmd

@property (nonatomic,assign) uint64_t lon;
@property (nonatomic,assign) uint64_t lan;
@property (nonatomic,copy) NSString *city_name;


@end

NS_ASSUME_NONNULL_END
