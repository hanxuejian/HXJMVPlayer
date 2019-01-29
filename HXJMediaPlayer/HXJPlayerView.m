//
//  HXJPlayerView.m
//  HXJMediaPlayer
//
//  Created by han on 2019/1/16.
//  Copyright © 2019年 han. All rights reserved.
//

#import "HXJPlayerView.h"
#import "HXJPlayerControlView.h"
#import "UIView+HXJKeyBoard.h"
#import "HXJMetaMacros.h"

@interface HXJPlayerView() <HXJPlayerControlViewDelegate>

//播放图层
@property (nonatomic, strong) AVPlayerLayer *playerLayer;

//播放对象
@property (nonatomic, strong) AVPlayer *player;

//播放监听对象
@property (nonatomic, strong) id playerPeriodicTimeObserver;

//播放模型
@property (nonatomic, strong) AVPlayerItem *playerItem;

//播放资源
@property (nonatomic, strong) AVURLAsset *asset;

//控制视图
@property (nonatomic, strong) HXJPlayerControlView *playerControlView;

//视频原始尺寸
@property (nonatomic, assign) CGSize videoNaturalSize;

//全屏背景视图
@property (nonatomic, strong) UIView *fullScreenBackView;

//全屏前的尺寸
@property (nonatomic, assign) CGRect rectBeforeFullScreen;

#pragma mark - 外部只读属性
@property (nonatomic, assign, readwrite) BOOL isPlaying;

@property (nonatomic, assign, readwrite) BOOL isFullScreen;

@property (nonatomic, assign, readwrite) HXJPlayerStatus status;

@end

@implementation HXJPlayerView

+ (Class)layerClass {
    return [AVPlayerLayer class];
}

#pragma mark - initial methods
- (instancetype)init {
    self = [super init];
    if (self) {
        self.clipsToBounds = YES;
    }
    return self;
}

- (instancetype)initWithUrl:(NSURL *)url {
    if ([self init]) {
        self.url = url;
        [self initView];
        [self initAsset];
        [self initPlayer];
        [self addObserverAndNotification];
    }
    return self;
}

- (void)initView {
    self.playerControlView = [[HXJPlayerControlView alloc]init];
    self.playerControlView.delegate = self;
    [self addSubview:self.playerControlView];
}

- (void)initAsset {
    NSDictionary *options = @{AVURLAssetPreferPreciseDurationAndTimingKey : @YES};
    self.asset = [[AVURLAsset alloc]initWithURL:self.url options:options];
    NSArray *keys = @[@keypath(self.asset,duration),@keypath(self.asset,tracks)];//@[@"duration",@"tracks"];
    
    [self.asset loadValuesAsynchronouslyForKeys:keys completionHandler:^{
        NSError *error = nil;
        AVKeyValueStatus tracksStatus = [self.asset statusOfValueForKey:@keypath(self.asset,duration) error:&error];
        switch (tracksStatus) {
            case AVKeyValueStatusLoaded:
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (!CMTIME_IS_INDEFINITE(self.asset.duration)) {
                        CGFloat second = 0;
                        if (self.asset.duration.timescale != 0) {
                            second = self.asset.duration.value / self.asset.duration.timescale;
                        }
                        self.playerControlView.totalTime = [self convertTimeToString:second];
                        self.playerControlView.minValue = 0;
                        self.playerControlView.maxValue = second;
                    }
                    [self resizeLayer];                    
                });
            }
                break;
            case AVKeyValueStatusFailed:
            {
                NSLog(@"播放失败");
            }
                break;
            case AVKeyValueStatusCancelled:
            {
                NSLog(@"播放取消");
            }
                break;
            case AVKeyValueStatusUnknown:
            {
                NSLog(@"未知错误");
            }
                break;
            case AVKeyValueStatusLoading:
            {
                NSLog(@"正在加载");
            }
                break;
        }
        
    }];
}

- (void)initPlayer {
    self.playerItem = [[AVPlayerItem alloc]initWithAsset:self.asset];
    self.player = [[AVPlayer alloc]initWithPlayerItem:self.playerItem];
    self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [self.playerLayer displayIfNeeded];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.playerControlView.frame = self.bounds;
}


- (void)resizeLayer {
    NSArray *array = self.asset.tracks;
    
    self.videoNaturalSize = CGSizeZero;
    
    for (AVAssetTrack *track in array) {
        
        if ([track.mediaType isEqualToString:AVMediaTypeVideo]) {
            self.videoNaturalSize = track.naturalSize;
        }
    }
    [self resizeFrame];
}

#pragma mark - 添加监听
- (void)addObserverAndNotification {
    
    //监听播放
    __weak typeof(self) weakSelf = self;
    
    self.playerPeriodicTimeObserver = [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1.f, 1.f)
                                                                                queue:NULL usingBlock:^(CMTime time)
    {
        weakSelf.playerControlView.value = weakSelf.playerItem.currentTime.value/weakSelf.playerItem.currentTime.timescale;
        if (!CMTIME_IS_INDEFINITE(self.asset.duration)) {
            weakSelf.playerControlView.currentTime = [weakSelf convertTimeToString:weakSelf.playerControlView.value];
        }
    }];
    
    //监听属性变化
    NSArray *keys = @[@keypath(self.playerItem,status),
                      @keypath(self.playerItem,loadedTimeRanges),
                      @keypath(self.playerItem,playbackBufferEmpty),
                      @keypath(self.playerItem,playbackLikelyToKeepUp),];
    for (NSString *key in keys) {
    [self.playerItem addObserver:self
                      forKeyPath:key
                         options:NSKeyValueObservingOptionNew
                         context:nil];
    }
    
    [self.player addObserver:self
                  forKeyPath:@keypath(self.player,rate)
                     options:NSKeyValueObservingOptionNew
                     context:nil];

    //监听通知
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(playerItemDidPlayToEndTimeNotification:) name:AVPlayerItemDidPlayToEndTimeNotification object:self.player.currentItem];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(willResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
}

#pragma mark - 调整视图大小
- (void)resizeFrame {
    CGFloat scaleLength = 0;
    CGFloat factor = self.videoNaturalSize.width*self.videoNaturalSize.height;
    
    if (!self.isFullScreen) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(isShouldRefreashViewAccordingVideoNaturalSize)]) {
            if ([self.delegate isShouldRefreashViewAccordingVideoNaturalSize] == NO) return;
        }
        
        CGFloat width = WindowFrameWidth;
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(widthWhenRefreashViewAccordingVideoNatureSize)]
            && [self.delegate respondsToSelector:@selector(heightWhenRefreashViewAccordingVideoNatureSize)]) {
            
            width = [self.delegate widthWhenRefreashViewAccordingVideoNatureSize];
            scaleLength = [self.delegate heightWhenRefreashViewAccordingVideoNatureSize];
            
        } else if (self.delegate && [self.delegate respondsToSelector:@selector(widthWhenRefreashViewAccordingVideoNatureSize)]) {
            width = [self.delegate widthWhenRefreashViewAccordingVideoNatureSize];
            scaleLength = width/self.videoNaturalSize.width*self.videoNaturalSize.height;
        }else if (self.delegate && [self.delegate respondsToSelector:@selector(heightWhenRefreashViewAccordingVideoNatureSize)]) {
            scaleLength = [self.delegate heightWhenRefreashViewAccordingVideoNatureSize];
            width = scaleLength/self.videoNaturalSize.height*self.videoNaturalSize.width;
            if (width == NAN) width = 282;
        } else {
            scaleLength = width/self.videoNaturalSize.width*self.videoNaturalSize.height;
        }
        
        if (scaleLength == NAN || factor == 0) scaleLength = 180;
        
        CGRect rect = self.frame;
        rect.size = CGSizeMake(width, scaleLength);
        self.frame = rect;
        if (self.superview && self.delegate &&
            [self.delegate respondsToSelector:@selector(isShouldRefreashSuperViewSize)] &&
            [self.delegate isShouldRefreashSuperViewSize]) {
            rect.origin = self.superview.frame.origin;
            self.superview.frame = rect;
        }
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(didRefreashedViewAccordingVideoNatureSize:)]) {
            [self.delegate didRefreashedViewAccordingVideoNatureSize:self.frame.size];
        }
    }else {
        self.rectBeforeFullScreen = self.frame;
        
        self.fullScreenBackView = [[UIView alloc]init];
        CGFloat height = WindowFrameHeight - SafeAreaStartY - SafeBottomAreaHeight;
        self.fullScreenBackView.frame = CGRectMake(0, SafeAreaStartY, WindowFrameWidth, height);
        self.fullScreenBackView.backgroundColor = [UIColor blackColor];
        self.transform = CGAffineTransformMakeRotation(M_PI_2);
        scaleLength = WindowFrameWidth/self.videoNaturalSize.height*self.videoNaturalSize.width;
        if (scaleLength == NAN || factor == 0) scaleLength = height;
        self.frame = CGRectMake(0, 0, WindowFrameWidth, scaleLength);
        self.center = CGPointMake(WindowFrameWidth/2, height/2);
        if (!self.superViewBeforeFullScreen) {
            self.superViewBeforeFullScreen = self.superview;
        }
        [self.fullScreenBackView addSubview:self];
    }
}

#pragma mark - getter and setter methods

- (NSString *)totalTime {
    return self.playerControlView.totalTime;
}

- (NSString *)currentTime {
    return self.playerControlView.currentTime;
}

- (CGFloat)rate {
    return self.player.rate;
}

- (HXJVideoLayerGravity)layerGravity {
    AVLayerVideoGravity gravity = self.playerLayer.videoGravity;
    if ([gravity isEqualToString:AVLayerVideoGravityResizeAspect]) return HXJVideoLayerGravityResizeAspect;
    if ([gravity isEqualToString:AVLayerVideoGravityResizeAspectFill]) return HXJVideoLayerGravityResizeAspectFill;
    if ([gravity isEqualToString:AVLayerVideoGravityResize]) return HXJVideoLayerGravityResize;
    return HXJVideoLayerGravityUnknown;
}

- (AVPlayer *)player {
    return self.playerLayer.player;
}

- (void)setPlayer:(AVPlayer *)player {
    self.playerLayer.player = player;
}

- (AVPlayerLayer *)playerLayer {
    return (AVPlayerLayer *)self.layer;
}

- (void)setTitle:(NSString *)title {
    self.playerControlView.title = title;
}

#pragma mark - 时间转换
- (NSString *)convertTimeToString:(CGFloat)second {
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:second];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    if (second/3600 >= 1) {
        [formatter setDateFormat:@"HH:mm:ss"];
    } else {
        [formatter setDateFormat:@"mm:ss"];
    }
    NSString *stringTime = [formatter stringFromDate:date];
    return stringTime;
}

#pragma mark - notification methods

- (void)playerItemDidPlayToEndTimeNotification:(NSNotification *)notification {
    [self.playerItem seekToTime:kCMTimeZero completionHandler:^(BOOL finished) {
        [self pause];
    }];
}

- (void)willResignActive:(NSNotification *)notification {
    if (self.isPlaying) {
        [self pause];
    }
}

#pragma mark - control methods

- (void)play {
    if (self.player) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(videoWillPlay:)]) {
            [self.delegate videoWillPlay:self];
        }
        [self.player play];
        self.isPlaying = YES;
        self.playerControlView.isPlaying = YES;
    }
}

- (void)pause {
    self.isPlaying = NO;
    if (self.player) {
        [self.player pause];
        self.playerControlView.isPlaying = NO;
    }
}

- (void)stop {
    NSArray *keys = @[@keypath(self.playerItem,status),
                      @keypath(self.playerItem,loadedTimeRanges),
                      @keypath(self.playerItem,playbackBufferEmpty),
                      @keypath(self.playerItem,playbackLikelyToKeepUp),];
    for (NSString *key in keys) {
        [self.playerItem removeObserver:self forKeyPath:key];
    }
    [self.player removeObserver:self forKeyPath:@keypath(self.player,rate)];
    [self.player removeTimeObserver:self.playerPeriodicTimeObserver];
    
    
    [[NSNotificationCenter defaultCenter]removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:[self.player currentItem]];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
    
    [self pause];
    if (self.player) {
        self.player = nil;
        self.asset = nil;
        self.playerItem = nil;
        [self removeFromSuperview];
    }
    self.playerControlView = nil;
}

#pragma mark - HXJPlayerControlViewDelegate

- (void)playerControlView:(HXJPlayerControlView *)controlView seekTimeWithValue:(CGFloat)value {
    CMTime pointTime = CMTimeMake(value * self.playerItem.currentTime.timescale, self.playerItem.currentTime.timescale);
    [self.playerItem seekToTime:pointTime toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:nil];
}

- (void)playerControlView:(HXJPlayerControlView *)controlView fullScreenBtnClicked:(UIButton *)button {
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(didFullScreenBtnClicked:)]) {
        [self.delegate didFullScreenBtnClicked:self.isFullScreen];
    }
    
    if (self.isFullScreen) {
        self.isFullScreen = NO;
        [self.fullScreenBackView removeFromSuperview];
        if (self.superViewBeforeFullScreen) {
            [UIView animateKeyframesWithDuration:kTransitionTime
                                           delay:0
                                         options:UIViewKeyframeAnimationOptionCalculationModeLinear
                                      animations:
             ^ {
                 self.transform = CGAffineTransformIdentity;
                 self.frame = self.rectBeforeFullScreen;
                 [self.superViewBeforeFullScreen addSubview:self];
                 [self layoutIfNeeded];
             } completion:nil];
            
        }
    }else {
        self.isFullScreen = YES;
        [UIView animateKeyframesWithDuration:kTransitionTime
                                       delay:0
                                     options:UIViewKeyframeAnimationOptionCalculationModeLinear
                                  animations:
         ^ {
             [self resizeFrame];
             [[[UIApplication sharedApplication]keyWindow]addSubview:self.fullScreenBackView];
             [self layoutIfNeeded];
         } completion:nil];
    }
    
    if (self.isFullScreen && self.delegate && [self.delegate respondsToSelector:@selector(didEnterFullScreen)]) {
        [self.delegate didEnterFullScreen];
    }
    
    if (!self.isFullScreen && self.delegate && [self.delegate respondsToSelector:@selector(didExitFullScreen)]) {
        [self.delegate didExitFullScreen];
    }
}

- (void)playerControlView:(HXJPlayerControlView *)controlView playOrPauseBtnClicked:(UIButton *)button {
    if (button.isSelected) {
        [self play];
    }else {
        [self pause];
    }
}

#pragma mark - 属性监听响应
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSKeyValueChangeKey,id> *)change
                       context:(void *)context
{
    if ([keyPath isEqualToString:@keypath(self.playerItem,status)]) {
        AVPlayerItemStatus itemStatus = [[change objectForKey:NSKeyValueChangeNewKey]integerValue];
        
        switch (itemStatus) {
            case AVPlayerItemStatusUnknown:
            {
                self.status = HXJPlayerStatusUnknown;
                NSLog(@"AVPlayerItemStatusUnknown");
            }
                break;
            case AVPlayerItemStatusReadyToPlay:
            {
                self.status = HXJPlayerStatusReadyToPlay;
                
                if (self.delegate && [self.delegate respondsToSelector:@selector(isShouldAutoPlayWhenReadyToPlay)]) {
                    self.isPlaying = [self.delegate isShouldAutoPlayWhenReadyToPlay];
                }
                
                if (self.isPlaying && [self isViewVisiable] && self.superview) {
                    [self play];
                }
                NSLog(@"AVPlayerItemStatusReadyToPlay");
            }
                break;
            case AVPlayerItemStatusFailed:
            {
                self.status = HXJPlayerStatusFailed;
                NSLog(@"AVPlayerItemStatusFailed");
            }
                break;
            default:
                break;
        }
    }else if ([keyPath isEqualToString:@keypath(self.playerItem,loadedTimeRanges)]) {
        NSArray *loadedTimeRanges = [self.playerItem loadedTimeRanges];
        CMTimeRange timeRange = [loadedTimeRanges.firstObject CMTimeRangeValue];
        float startSeconds = CMTimeGetSeconds(timeRange.start);
        float durationSeconds = CMTimeGetSeconds(timeRange.duration);
        NSTimeInterval timeInterval = startSeconds + durationSeconds;
        CMTime duration = self.playerItem.duration;
        CGFloat totalDuration = CMTimeGetSeconds(duration);
        //缓存变化
        if (totalDuration > 0) {
            self.playerControlView.bufferValue = timeInterval/totalDuration;
        }
    } else if ([keyPath isEqualToString:@keypath(self.playerItem,playbackBufferEmpty)]) {
        self.status = HXJPlayerStatusBuffering;
        [self.playerControlView showLoadingView];
    } else if ([keyPath isEqualToString:@keypath(self.playerItem,playbackLikelyToKeepUp)]) {
        
        [self.playerControlView hideLoadingView];
    } else if ([keyPath isEqualToString:@keypath(self.player,rate)]){
        if ([[change objectForKey:NSKeyValueChangeNewKey]integerValue] == 0) {
            self.isPlaying = NO;
            self.status = HXJPlayerStatusStopped;
        }else{
            self.isPlaying = YES;
            self.status = HXJPlayerStatusPlaying;
        }
    }
}

@end
