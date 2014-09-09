//
//  RemoteApplication.m
//  fmpro
//
//  Created by jovi on 14-4-22.
//  Copyright (c) 2014年 jovi. All rights reserved.
//

#import "RemoteApplication.h"
#import "AppDelegate.h"


@implementation RemoteApplication

- (void)remoteControlReceivedWithEvent:(UIEvent *)receivedEvent {
    if (receivedEvent.type == UIEventTypeRemoteControl) {
        AppDelegate* delegate = (AppDelegate*) [[UIApplication sharedApplication] delegate];
        
        switch (receivedEvent.subtype) {
            case UIEventSubtypeRemoteControlPause:
                [delegate.playerViewController pause];
                [delegate.playerViewController updateLockscreen:-1];
                

                break;
                
            case UIEventSubtypeRemoteControlPlay:
                [delegate.playerViewController play];
                [delegate.playerViewController updateLockscreen:-1];
                
                
                break;
                
            case UIEventSubtypeRemoteControlPreviousTrack:
                [delegate.playerViewController previous];
                [delegate.playerViewController updateLockscreen:-1];
                
                break;
                
            case UIEventSubtypeRemoteControlNextTrack:
                [delegate.playerViewController next];
                [delegate.playerViewController updateLockscreen:-1];
                
                break;
                
            default:
                break;
        }
    }
}

-(BOOL)canBecomeFirstResponder {
    return YES;
}

@end
