//
//  CE_SyncMusicInfoCmd.h
//  K2SDKDemo
//
//  Created by cxq on 2016/12/28.
//  Copyright © 2016年 celink. All rights reserved.
//

#import "CE_Cmd.h"

@interface MusicItemInfo : NSObject

@property (nonatomic,strong) NSData *infoData;//info data 的长度最多24字节

@end


@interface CE_SyncMusicInfoCmd : CE_Cmd

/**  app告知手机当前播放状态，可为1播放或2暂停 */
@property (nonatomic,assign) uint8_t music_status;

@property (nonatomic,strong,readonly) MusicItemInfo *music_name;//当前音乐的名字条目
@property (nonatomic,strong,readonly) MusicItemInfo *artist_name;//当前歌手名字条目
@property (nonatomic,strong,readonly) MusicItemInfo *album_name;//当前专辑的名字条目

@end
