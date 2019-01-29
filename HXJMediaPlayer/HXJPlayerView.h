//
//  HXJPlayerView.h
//  HXJMediaPlayer
//
//  Created by han on 2019/1/16.
//  Copyright © 2019年 han. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

//横竖屏过渡动画默认时间
#define kTransitionTime 0.2

//填充模式枚举值
typedef NS_ENUM(NSInteger,HXJVideoLayerGravity){
    HXJVideoLayerGravityResizeAspect,
    HXJVideoLayerGravityResizeAspectFill,
    HXJVideoLayerGravityResize,
    HXJVideoLayerGravityUnknown
};

//播放状态枚举值
typedef NS_ENUM(NSInteger,HXJPlayerStatus){
    HXJPlayerStatusFailed,
    HXJPlayerStatusReadyToPlay,
    HXJPlayerStatusUnknown,
    HXJPlayerStatusBuffering,
    HXJPlayerStatusPlaying,
    HXJPlayerStatusStopped,
};


@class HXJPlayerView;

@protocol HXJPlayerViewDelegate <NSObject>

@optional
///当视频已经可以播放时，是否自动播放，默认为YES
- (BOOL)isShouldAutoPlayWhenReadyToPlay;

///是否根据视频原大小刷新视频容器大小，如果不实现该代理，则默认为 YES
- (BOOL)isShouldRefreashViewAccordingVideoNaturalSize;

///当根据视频大小调整显示视图大小时的宽度，默认是屏幕的宽度
- (CGFloat)widthWhenRefreashViewAccordingVideoNatureSize;

///当根据视频大小调整显示视图大小时的高度
- (CGFloat)heightWhenRefreashViewAccordingVideoNatureSize;

///视频视图调整结束，size 是视频调整后的大小
- (void)didRefreashedViewAccordingVideoNatureSize:(CGSize)size;

///视频视图调整结束后，是否自动调整其父视图大小与视频视图一致
- (BOOL)isShouldRefreashSuperViewSize;

/**
 全屏按钮点击
 
 @param isFullScreen 当前屏幕是否是全屏状态
 */
- (void)didFullScreenBtnClicked:(BOOL)isFullScreen;

///进入全屏
- (void)didEnterFullScreen;

///退出全屏
- (void)didExitFullScreen;

///即将播放
- (void)videoWillPlay:(HXJPlayerView *)playerView;

@end

@interface HXJPlayerView : UIView

//总时长
@property (nonatomic,strong,readonly) NSString *totalTime;
//当前时间
@property (nonatomic,strong,readonly) NSString *currentTime;
//播放速率
@property (nonatomic,assign,readonly) CGFloat rate;
//播放状态
@property (nonatomic,assign,readonly) HXJPlayerStatus status;
//屏幕填充模式
@property (nonatomic,assign,readonly) HXJVideoLayerGravity layerGravity;
//是否正在播放
@property (nonatomic,assign,readonly) BOOL isPlaying;
//是否全屏
@property (nonatomic,assign,readonly) BOOL isFullScreen;

//播放器标题
@property (nonatomic,copy) NSString *title;

//当前播放资源地址
@property (nonatomic,copy) NSURL *url;

#pragma mark - initial methods

///用播放地址初始化播放器
- (instancetype)initWithUrl:(NSURL *)url;

#pragma mark - control methods

///播放
- (void)play;

///暂停
- (void)pause;

///停止
- (void)stop;

///全屏前的父视图，默认是该视图的父视图
@property (nonatomic, weak) UIView *superViewBeforeFullScreen;

///代理
@property (nonatomic, weak) id <HXJPlayerViewDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
