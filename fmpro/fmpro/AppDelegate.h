//
//  AppDelegate.h
//  fmpro
//
//  Created by jovi on 14-4-22.
//  Copyright (c) 2014年 jovi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
#import "FMPlayerViewController.h"
@interface AppDelegate : UIResponder <UIApplicationDelegate,AVAudioPlayerDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) FMPlayerViewController *playerViewController;

@end
