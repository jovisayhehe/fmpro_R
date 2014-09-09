//
//  DouBanApi.h
//  fmpro
//
//  Created by jovi on 14-4-29.
//  Copyright (c) 2014年 jovi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DouBanApi : NSObject
typedef void (^DouBanLyricBlock)(NSMutableArray* lyrics);
typedef void (^DouBanLyricErrorBlock)(NSError* error);
typedef void (^DouBanChannelsBlock)(NSArray* channels);


- (void)getLyric:(NSString *)sid ssid:(NSString *)ssid completionHandler:(DouBanLyricBlock) lyricsBlock errorHandler:(DouBanLyricErrorBlock) errorBlock;
- (void)login;

- (void)getChannels:(DouBanChannelsBlock) channelsBlock errorHandler:(DouBanLyricErrorBlock)errorBlock;
+ (DouBanApi *) sharedInstance;

@end
