//
//  YD_SyncLanguageCmd.h
//  StarWristSport
//
//  Created by kwan on 2019/5/15.
//  Copyright © 2019 celink. All rights reserved.
//

#import "CE_Cmd.h"

NS_ASSUME_NONNULL_BEGIN

@interface YD_SyncLanguageCmd : CE_Cmd

@property (nonatomic) uint8_t language;


/// initalize
/// @param language 0: English(英语) 1: Simple-Chinese(简体中文), 2: Spanish(西班牙)
/// 3: Italian(意大利), 4: Portuguese(葡萄牙), 5: French(法语), 6: Japanese(日语), 7: Russian(俄语), 8: Korean(韩语), 9: German(德语), 10: Traditional-Chinese(繁体中文), 11: Arabic(阿拉伯语) 12: Indonesian(印度尼西亚语), 13: Turkish(土耳其语), 14: Ukrainian(乌克兰语), 15: Hebrew(希伯来语), 16 波兰语, 17 印地语， 18克罗地亚语
- (instancetype)initWithLanguage:(NSInteger)language;

@end

NS_ASSUME_NONNULL_END
