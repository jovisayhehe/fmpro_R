//
//  Track.m
//  fmpro
//
//  Created by jovi on 14-4-26.
//  Copyright (c) 2014年 jovi. All rights reserved.
//

#import "Track.h"
@implementation Track

- (NSURL *)audioFileURL{
    return [NSURL URLWithString:[self url]];;
}

@end
