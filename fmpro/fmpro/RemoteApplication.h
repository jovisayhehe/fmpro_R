//
//  RemoteApplication.h
//  fmpro
//
//  Created by jovi on 14-4-22.
//  Copyright (c) 2014年 jovi. All rights reserved.
//



#import <UIKit/UIKit.h>

@interface RemoteApplication : UIApplication

-(void)remoteControlReceivedWithEvent:(UIEvent *)event;
-(BOOL)canBecomeFirstResponder;

@end
