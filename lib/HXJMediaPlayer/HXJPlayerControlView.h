//
//  HXJPlayerControlView.h
//  HXJMediaPlayer
//
//  Created by han on 2019/1/16.
//  Copyright © 2019年 han. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class HXJPlayerControlView;

@protocol HXJPlayerControlViewDelegate <NSObject>

@required
/**
 播放器进度变化
 
 @param controlView 播放器控制视图
 @param value 播放器应跳转到的时间值
 */
- (void)playerControlView:(HXJPlayerControlView *)controlView seekTimeWithValue:(CGFloat)value;

/**
 全屏按钮点击事件代理方法
 
 @param controlView 控制视图
 @param button 全屏按钮
 */
- (void)playerControlView:(HXJPlayerControlView *)controlView fullScreenBtnClicked:(UIButton *)button;

/**
 播放或暂停按钮点击
 
 @param controlView 控制视图
 @param button 播放/暂停按钮，按钮选中状态表示视频正在播放
 */
- (void)playerControlView:(HXJPlayerControlView *)controlView playOrPauseBtnClicked:(UIButton *)button;


@end

@interface HXJPlayerControlView : UIView

//标题
@property (nonatomic, strong) NSString *title;

//播放进度条当前值
@property (nonatomic,assign) CGFloat value;

//缓存进度条当前值
@property (nonatomic,assign) CGFloat bufferValue;

//最小值
@property (nonatomic,assign) CGFloat minValue;

//最大值
@property (nonatomic,assign) CGFloat maxValue;

//当前播放时间
@property (nonatomic,copy) NSString *currentTime;

//总时间
@property (nonatomic,copy) NSString *totalTime;

//控制代理
@property (nonatomic, weak) id <HXJPlayerControlViewDelegate> delegate;

//视频是否播放
@property (nonatomic, assign) BOOL isPlaying;

- (instancetype)initWithFrame:(CGRect)frame delegate:(id <HXJPlayerControlViewDelegate>)delegate;

/**
 显示/隐藏控制视图
 
 @param shouldShow 该参数为 YES 表示显示，为 NO 表示隐藏
 */
- (void)showOrHideControlView:(BOOL)shouldShow;

///显示加载视图
- (void)showLoadingView;

///隐藏加载视图
- (void)hideLoadingView;

@end

NS_ASSUME_NONNULL_END
