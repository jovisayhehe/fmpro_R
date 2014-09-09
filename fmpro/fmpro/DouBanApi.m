//
//  DouBanApi.m
//  fmpro
//
//  Created by jovi on 14-4-29.
//  Copyright (c) 2014年 jovi. All rights reserved.
//

#import "DouBanApi.h"
#import "AFNetworking.h"

#define DOUBAN_API_LYRIC @"http://api.douban.com/v2/fm/lyric"
#define DOUBAN_API_CHANNELS @"http://api.douban.com/v2/fm/app_channels"
@implementation DouBanApi
{
    
}
static DouBanApi *instance = nil;

+ (DouBanApi *) sharedInstance
{
    static dispatch_once_t disLock = 0;
    
    if (instance == nil) {
        dispatch_once(&disLock, ^{
            if (instance == nil) {
                instance = [[DouBanApi alloc] init];
            }
        });
    }
    
    return instance;
}

- (void)getChannels:(DouBanChannelsBlock)channelsBlock errorHandler:(DouBanLyricErrorBlock)errorBlock
{
    NSDictionary *parameters = @{@"apikey":@"02f7751a55066bcb08e65f4eff134361"};
    
    AFHTTPRequestOperationManager *operationManager = [AFHTTPRequestOperationManager manager];
    [operationManager GET:DOUBAN_API_CHANNELS parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSArray *groups = responseObject[@"groups"];
        id rmod = groups[2];
        NSArray *chls = rmod[@"chls"];
        
        channelsBlock(chls);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        errorBlock(error);
        
    }];
}

- (void)getLyric:(NSString *)sid ssid:(NSString *)ssid completionHandler:(DouBanLyricBlock)lyricsBlock errorHandler:(DouBanLyricErrorBlock)errorBlock
{
    NSDictionary *parameters = @{@"sid": sid,@"ssid": ssid,@"apikey":@"02f7751a55066bcb08e65f4eff134361"};

    AFHTTPRequestOperationManager *operationManager = [AFHTTPRequestOperationManager manager];
    [operationManager GET:DOUBAN_API_LYRIC parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSString *lyrci = responseObject[@"lyric"];
        lyricsBlock([self LyricParser:lyrci]);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        errorBlock(error);
        
    }];
    
}


- (NSMutableArray *)LyricParser:(NSString *)str
{
    NSMutableArray *lyrics = [NSMutableArray array];
    
    NSArray *array = [str componentsSeparatedByString:@"\r\n"];
    for (NSString *str in array) {
        
        NSString *line = @"";
        NSRange range = [str rangeOfString:@"]" options:NSBackwardsSearch];
        if (range.length > 0) {
            NSString *renstr = [str substringFromIndex:NSMaxRange(range)];
            line = renstr;
        }
        
        NSError *error=[NSError new];
        NSRegularExpression *regex=[NSRegularExpression regularExpressionWithPattern:@"\\[(.*?)\\]" options:NSRegularExpressionCaseInsensitive error:&error];
        NSArray *matches=[regex matchesInString:str options:NSMatchingReportCompletion range:NSMakeRange(0,[str length])];
        for(NSTextCheckingResult*match in matches){
            NSRange r1 = [match rangeAtIndex:1];
            if (!NSEqualRanges(r1, NSMakeRange(NSNotFound, 0))) {
                long time = [self parseTime:[str substringWithRange:r1]];
                
                NSMutableDictionary *dic = [NSMutableDictionary dictionary];
                [dic setValue:[NSNumber numberWithInteger:time] forKey:@"time"];
                [dic setValue:line forKey:@"line"];
                
                [lyrics addObject:dic];
            }
        }
    }

    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"time" ascending:YES];
    [lyrics sortUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];

    
    return lyrics;
}

- (NSInteger)parseTime:(NSString *)time
{
    NSArray *array = [time componentsSeparatedByCharactersInSet:
                      [NSCharacterSet characterSetWithCharactersInString:@":."]];
    if (array.count<2) {
        return -1;
    }else if (array.count == 2){
        NSInteger min = [array[0] integerValue];
        NSInteger sec = [array[1] integerValue];
        if (min < 0 || sec < 0 || sec >= 60) {
            return -1;
        }
        return (min * 60 + sec);
    }else if (array.count == 3) {
            NSInteger min = [array[0] integerValue];
            NSInteger sec = [array[1] integerValue];
        
            if (min < 0 || sec < 0 || sec >= 60) {
                return -1;
            }
            return (min * 60 + sec);
    } else {
        return -1;
    }
    
    return -1;
}

@end
