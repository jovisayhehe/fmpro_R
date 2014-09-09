//
//  Track.h
//  fmpro
//
//  Created by jovi on 14-4-26.
//  Copyright (c) 2014年 jovi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DOUAudioStreamer.h"

@interface Track : NSObject<DOUAudioFile>

@property (nonatomic,strong) NSString *album;
@property (nonatomic,strong) NSString *picture;
@property (nonatomic,strong) NSString *ssid;
@property (nonatomic,strong) NSString *artist;
@property (nonatomic,strong) NSString *url;
@property (nonatomic,strong) NSString *company;
@property (nonatomic,strong) NSString *title;
@property (nonatomic,assign) float rating_avg;
@property (nonatomic,assign) NSInteger length;
@property (nonatomic,strong) NSString *subtype;
@property (nonatomic,strong) NSString *public_time;
@property (nonatomic,strong) NSString *sid;
@property (nonatomic,strong) NSString *aid;
@property (nonatomic,strong) NSString *sha256;
@property (nonatomic,assign) NSUInteger kbps;
@property (nonatomic,strong) NSString *albumtitle;
@property (nonatomic,assign) NSUInteger like;

@property (nonatomic,strong) NSString *hlink;
@property (nonatomic,strong) NSString *dlink;

@end
