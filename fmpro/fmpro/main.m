//
//  main.m
//  fmpro
//
//  Created by jovi on 14-4-22.
//  Copyright (c) 2014年 jovi. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AppDelegate.h"
#import "RemoteApplication.h"
int main(int argc, char * argv[])
{
    @autoreleasepool {
        return UIApplicationMain(argc, argv, NSStringFromClass([RemoteApplication class]),
                                 NSStringFromClass([AppDelegate class]));    }
}
