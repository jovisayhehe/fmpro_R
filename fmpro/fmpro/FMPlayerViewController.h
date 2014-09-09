//
//  FMPlayerViewController.h
//  fmpro
//
//  Created by jovi on 14-4-27.
//  Copyright (c) 2014年 jovi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DOUAudioStreamer.h"
#import "JCRBlurView.h"
@interface FMPlayerViewController : UIViewController{
    NSMutableDictionary *songParameters;
    NSMutableArray *arraytks;
    DOUAudioStreamer *streamer;
    NSTimer *timer;
    NSUInteger _currentTrackIndex;
}

@property(nonatomic,strong) IBOutlet UIScrollView *LyricView;
@property(nonatomic,strong) IBOutlet JCRBlurView *blurView;

@property(nonatomic,strong) IBOutlet UIImageView *cover;
@property(nonatomic,strong) IBOutlet UIImageView *bgcover;
@property(nonatomic,strong) IBOutlet UILabel *timeLab;
@property(nonatomic,strong) IBOutlet UILabel *artistLab;
@property(nonatomic,strong) IBOutlet UILabel *titleLab;
@property(nonatomic,strong) IBOutlet UILabel *kbsLab;
@property(nonatomic,strong) IBOutlet UIButton *nextButton;

@property(nonatomic,readwrite)  NSInteger screenState;
@property(nonatomic,readwrite)  BOOL viewState;

- (IBAction)nextAction:(id)sender;
- (IBAction)hideAction:(id)sender;
- (IBAction)likeAction:(id)sender;

-(void)play;
-(void)pause;
-(void)next;
-(void)previous;
-(void)updateLockscreen:(NSInteger)index;
@end
