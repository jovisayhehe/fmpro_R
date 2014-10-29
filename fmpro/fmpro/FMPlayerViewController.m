//
//  FMPlayerViewController.m
//  fmpro
//
//  Created by jovi on 14-4-27.
//  Copyright (c) 2014年 jovi. All rights reserved.
//

#import "FMPlayerViewController.h"
#import "AFNetworking.h"
#import "SDImageCache.h"
#import "UIImageView+WebCache.h"

#import <AVFoundation/AVFoundation.h>

#import <MediaPlayer/MPNowPlayingInfoCenter.h>
#import <MediaPlayer/MPMediaItem.h>
#import "Track.h"
#import "DouBanApi.h"

static void *kStatusKVOKey = &kStatusKVOKey;
static void *kDurationKVOKey = &kDurationKVOKey;
static void *kBufferingRatioKVOKey = &kBufferingRatioKVOKey;
@interface FMPlayerViewController (){
    NSMutableArray *mlyrics;
}
@end

@implementation FMPlayerViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

    }
    return self;
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setNeedsStatusBarAppearanceUpdate];
    [self.LyricView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(lyricHandelSingleTap:)]];
    arraytks = [NSMutableArray array];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        [self getTestTracks];
    });
    
}

-(void)lyricHandelSingleTap:(UITapGestureRecognizer*)gestureRecognizer{
    
    self.blurView.hidden = YES;
    self.LyricView.hidden = YES;
}

- (IBAction)hideAction:(id)sender
{
    self.blurView.hidden = NO;
    self.LyricView.hidden = NO;
}

- (IBAction)likeAction:(id)sender{
    
    FMPlayerViewController *list = [[FMPlayerViewController alloc] init];
    [self presentViewController:list animated:NO completion:nil];
    
}

- (IBAction)nextAction:(id)sender{
    [self next];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.viewState = YES;
    [self resetStreamer];
    
    timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timerAction:) userInfo:nil repeats:YES];
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];

}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    self.viewState = NO;
}

- (void)resetStreamer
{
    [self cancelStreamer];
    
    if (0 == [arraytks count])
    {
        return;
    }
    else
    {
        Track *track = [arraytks objectAtIndex:_currentTrackIndex];
        
        self.artistLab.text = track.artist;
        self.titleLab.text = track.title;
        [self.cover sd_setImageWithURL:[NSURL URLWithString:track.picture]
                   placeholderImage:nil options:SDWebImageRefreshCached];
        
        __weak typeof(self) weakSelf = self;

        [self.cover sd_setImageWithURL:[NSURL URLWithString:track.picture] placeholderImage:nil options:SDWebImageRefreshCached completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            
            CGImageRef imgRef = image.CGImage;
            CGFloat width = CGImageGetWidth(imgRef);
            CGFloat height = CGImageGetHeight(imgRef);
            CGAffineTransform transform = CGAffineTransformIdentity;
            CGRect bounds = CGRectMake(0, 0, width, height);
            CGFloat scaleRatio = 1;
            transform = CGAffineTransformMakeTranslation(0.0, height);
            transform = CGAffineTransformScale(transform, 1.0, -1.0);
            UIGraphicsBeginImageContext(bounds.size);
            CGContextRef context = UIGraphicsGetCurrentContext();
            CGContextScaleCTM(context, scaleRatio, -scaleRatio);
            CGContextTranslateCTM(context, 0, -height);
            CGContextConcatCTM(context, transform);
            CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, width, height), imgRef);
            UIImage *imageCopy = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            weakSelf.bgcover.image = imageCopy;
            
        }];
        [self playTrack:track];
    }
}

- (void)playTrack:(Track *)track
{
    if (nil == mlyrics) {
        mlyrics = [NSMutableArray array];
    }
    NSArray *viewsToRemove = [self.LyricView subviews];
    for (UIView *v in viewsToRemove){
        [v removeFromSuperview];
    }
    [self.LyricView setContentOffset:CGPointMake(self.LyricView.contentOffset.x, 0)
                             animated:YES];
    
    [[DouBanApi sharedInstance] getLyric:track.sid ssid:track.ssid completionHandler:^(NSMutableArray *lyrics) {
        
        mlyrics = lyrics;
        [self.LyricView setContentSize:CGSizeMake(320, 30 * lyrics.count +160)];
        
        for (int i = 0; i < lyrics.count; i++) {
            UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake(0, 160+(30*i), 320, 30)];
            lab.textColor = [UIColor whiteColor];
            UIFont *font = [UIFont systemFontOfSize:13];
            lab.font = font;
            lab.backgroundColor = [UIColor clearColor];
            lab.text = [lyrics objectAtIndex:i][@"line"];
            lab.textAlignment = NSTextAlignmentCenter;
            [self.LyricView addSubview:lab];
        }
    } errorHandler:^(NSError *error) {
        
    }];
    
    self.kbsLab.text = [NSString stringWithFormat:@"%ldkbps",(long)track.kbps];
    streamer = [DOUAudioStreamer streamerWithAudioFile:track];
    [streamer addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:kStatusKVOKey];
    [streamer addObserver:self forKeyPath:@"duration" options:NSKeyValueObservingOptionNew context:kDurationKVOKey];
    [streamer addObserver:self forKeyPath:@"bufferingRatio" options:NSKeyValueObservingOptionNew context:kBufferingRatioKVOKey];
    [streamer play];
    
    NSUInteger nextIndex = _currentTrackIndex + 1;
    if (nextIndex >= [arraytks count]) {
        nextIndex = 0;
    }
    
    [DOUAudioStreamer setHintWithAudioFile:[arraytks objectAtIndex:nextIndex]];
}
- (void)cancelStreamer
{
    if (streamer != nil) {
        [streamer pause];
        [streamer removeObserver:self forKeyPath:@"status"];
        [streamer removeObserver:self forKeyPath:@"duration"];
        [streamer removeObserver:self forKeyPath:@"bufferingRatio"];
        streamer = nil;
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == kStatusKVOKey) {
        [self performSelector:@selector(updateStatus)
                     onThread:[NSThread mainThread]
                   withObject:nil
                waitUntilDone:NO];
    }
    else if (context == kDurationKVOKey) {
        [self performSelector:@selector(timerAction:)
                     onThread:[NSThread mainThread]
                   withObject:nil
                waitUntilDone:NO];
    }
    else if (context == kBufferingRatioKVOKey) {
        [self performSelector:@selector(updateBufferingStatus)
                     onThread:[NSThread mainThread]
                   withObject:nil
                waitUntilDone:NO];
    }
    else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)updateStatus
{
    [self updateLockscreen:-1];
    switch ([streamer status]) {
        case DOUAudioStreamerPlaying:

            break;
            
        case DOUAudioStreamerPaused:
            
            break;
            
        case DOUAudioStreamerIdle:
            
            break;
            
        case DOUAudioStreamerFinished:
            
            [self next];
            break;
            
        case DOUAudioStreamerBuffering:
            
            break;
            
        case DOUAudioStreamerError:
            
            break;
    }
}


- (void)timerAction:(id)timer
{
    if ([streamer duration] == 0.0) {
        return;
    }
    else {
        NSInteger index = -1;
        for (int i = 0; i < mlyrics.count; i++) {
            NSDictionary *dic = mlyrics[i];
            NSNumber *number = dic[@"time"];
            NSInteger time = [number integerValue];
            
            NSInteger ltime = 0;
            int ls = i +1;
            if (ls<mlyrics.count) {
                NSDictionary *ldic = mlyrics[i+1];
                if (ldic) {
                    NSNumber *number = ldic[@"time"];
                    ltime = [number integerValue];
                }
            }
            if (ltime!=0) {
                if ([streamer currentTime]>=time&&[streamer currentTime]<=ltime){
                    index = i;
                    break;
                }
            }else{
                if ([streamer currentTime]<time) {
                    index = 0;
                }else if (ltime==0){
                    index = mlyrics.count;
                }
                break;
            }
        }
        
        NSArray *viewsChange = [self.LyricView subviews];
        for (int n = 0; n<viewsChange.count; n++) {
            
            if (n==index) {
                UILabel *lab = viewsChange[n];
                lab.textColor = [UIColor redColor];
                if (n>0) {
                    UILabel *lab = viewsChange[n-1];
                    lab.textColor = [UIColor whiteColor];
                }
                break;
            }
        }
        CGRect animationRect = CGRectMake(0, 0, 320, (index*30)+350);

        [UIView animateWithDuration:1
                              delay:0
                            options:(UIViewAnimationOptionCurveLinear | UIViewAnimationOptionAllowUserInteraction)
                         animations:^{
                             [self.LyricView scrollRectToVisible:animationRect animated:NO];
                         }
                         completion:^(BOOL finished2) {
                             
                         }];
        
        self.timeLab.text = [self timeFormat:[streamer currentTime]];
        [self updateLockscreen:index];

    }
}

- (NSString *)timeFormat:(NSTimeInterval )time{
    NSString *string = @"";
    if (time >=3600) {
        string = [NSString stringWithFormat:@"%02li:%02li:%02li",
                  lround(floor(time / 3600.)) % 100,
                  lround(floor(time / 60.)) % 60,
                  lround(floor(time / 1.)) % 60];
    }else{
        string = [NSString stringWithFormat:@"%02li:%02li",
                  lround(floor(time / 60.)) % 60,
                  lround(floor(time / 1.)) % 60];
    }
    
    return string;
}


- (void)updateBufferingStatus
{
    //do
}

-(void)play
{
    if ([streamer status] == DOUAudioStreamerPaused ||
        [streamer status] == DOUAudioStreamerIdle) {
        [streamer play];
        [self updateLockscreen:-1];

    }
}

-(void)pause
{
    [streamer pause];

}

-(void)next
{
    if (++_currentTrackIndex >= [arraytks count]) {
        _currentTrackIndex = 0;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            [self getTestTracks];
            
        });
    }else{
        [self resetStreamer];

    }
    
}
-(void)previous
{
    
}

-(void)updateLockscreen:(NSInteger)index{
    
    Class playingInfoCenter = NSClassFromString(@"MPNowPlayingInfoCenter");

    if (playingInfoCenter) {
        NSDictionary* songInfo;
        if ([self timeFormat:[streamer duration]]) {
            songInfo = @{MPMediaItemPropertyTitle: self.titleLab.text,
                         MPMediaItemPropertyArtist:self.artistLab.text,
                         MPMediaItemPropertyPlaybackDuration:[NSNumber numberWithDouble:(double)[streamer duration]],
                         MPNowPlayingInfoPropertyElapsedPlaybackTime:[NSNumber numberWithDouble:(double)[streamer currentTime]],
                         MPNowPlayingInfoPropertyPlaybackRate:@1.0
                         };
        } else {
            songInfo = @{MPMediaItemPropertyTitle: self.titleLab.text,
                         MPMediaItemPropertyArtist:self.artistLab.text,
                         };
        }
        
        NSMutableDictionary *maybeWithImage = [NSMutableDictionary dictionaryWithDictionary:songInfo];
        if (self.cover.image) {

            if (mlyrics) {
                if (index!=-1) {
                    if (index<mlyrics.count) {

                        if (self.screenState == 1) {
                            NSString *str = [mlyrics objectAtIndex:index][@"line"];
                            UIImage *img = [self addText:self.cover.image text:str];
                            [maybeWithImage setValue:[[MPMediaItemArtwork alloc] initWithImage:img] forKey:MPMediaItemPropertyArtwork];
                        }

                    }

                }

            }else{
                 if (self.screenState == 1) {
                     [maybeWithImage setValue:[[MPMediaItemArtwork alloc] initWithImage:self.cover.image] forKey:MPMediaItemPropertyArtwork];
                 }

            }
        }
        
        [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:[NSDictionary dictionaryWithDictionary:maybeWithImage]];
    }
}

- (void)updateLockscreenTimeProgress
{
    Class playingInfoCenter = NSClassFromString(@"MPNowPlayingInfoCenter");
    
    if (playingInfoCenter) {
        NSDictionary* songInfo;
        if ([self timeFormat:[streamer duration]]) {
            songInfo = @{
                         MPMediaItemPropertyPlaybackDuration:[NSNumber numberWithDouble:(double)[streamer duration]],
                         MPNowPlayingInfoPropertyElapsedPlaybackTime:[NSNumber numberWithDouble:(double)[streamer currentTime]]
                         };
        }
        [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:[NSDictionary dictionaryWithDictionary:songInfo]];
    }
}


-(UIImage *)addText:(UIImage *)img text:(NSString *)text
{
    UIImage* returnImg = nil;
    int w = img.size.width;
    int h = img.size.height;
    
    CGFloat scale = [[UIScreen mainScreen] scale];
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(w*scale, h*scale), NO, 0.0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextScaleCTM(UIGraphicsGetCurrentContext(), scale, scale);
    
    CGContextClearRect(context,CGRectMake(0, 0, w, h));
    [img drawInRect:CGRectMake(0, 0, w,h)];
    
    
//    CGSize sizeTextCanDraw = [text sizeWithFont:[UIFont systemFontOfSize:18] forWidth:w lineBreakMode:NSLineBreakByWordWrapping];
    NSDictionary *attribute = @{NSFontAttributeName: [UIFont systemFontOfSize:18]};
    CGSize sizeTextCanDraw = [text boundingRectWithSize:CGSizeMake(w, CGFLOAT_MAX) options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading  attributes:attribute context:nil].size;
    
    CGContextSetFillColorWithColor(context, [UIColor redColor].CGColor);
    CGRect rcTextRect = CGRectMake(0, h - sizeTextCanDraw.height - 8, w, sizeTextCanDraw.height);
    
    NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    paragraphStyle.alignment = NSTextAlignmentCenter;
    NSDictionary *drawattribute = @{NSFontAttributeName: [UIFont systemFontOfSize:18],NSParagraphStyleAttributeName:paragraphStyle,
                                    NSForegroundColorAttributeName:[UIColor redColor]};
    [text drawInRect:rcTextRect withAttributes:drawattribute];
//    [text drawInRect:rcTextRect withFont:[UIFont systemFontOfSize:18] lineBreakMode:NSLineBreakByWordWrapping alignment:NSTextAlignmentCenter];
    

    returnImg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return [UIImage imageWithCGImage:returnImg.CGImage scale:scale orientation:UIImageOrientationUp];
}


-(void)getTestTracks{
    [arraytks removeAllObjects];
    NSString *url=@"http://douban.fm/j/app/radio/people";
    songParameters=[NSMutableDictionary dictionaryWithObjectsAndKeys:@"radio_desktop_win",@"app_name", @"100",@"version",@"n",@"type",@"1",@"channel",nil];
    AFHTTPRequestOperationManager *operationManager = [AFHTTPRequestOperationManager manager];
    [operationManager GET:url parameters:songParameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSArray *responseSongs = [responseObject objectForKey:@"song"];
        
        for (NSDictionary *song in responseSongs) {
            Track *track=[[Track alloc] init];
            
            track.artist=[song objectForKey:@"artist"];
            track.title=[song objectForKey:@"title"];
            track.sid=[song objectForKey:@"sid"];
            track.ssid = [song objectForKey:@"ssid"];
            track.url= [song objectForKey:@"url"];
            track.length = [[song objectForKey:@"length"] integerValue];
            track.picture=[ song objectForKey:@"picture"];
            track.kbps = [[song objectForKey:@"kbps"] integerValue];
            [arraytks addObject:track];
        }
        
        [self resetStreamer];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        
    }];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];

}

@end
