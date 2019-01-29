//
//  HXJPlayerControlView.m
//  HXJMediaPlayer
//
//  Created by han on 2019/1/16.
//  Copyright © 2019年 han. All rights reserved.
//

#import "HXJPlayerControlView.h"
#import "HXJMetaMacros.h"

@interface HXJPlayerControlView ()

#pragma mark - 顶部控制视图容器
@property (nonatomic, strong) UIView *topControlView;

//添加标题
@property (nonatomic, strong) UILabel *titleLabel;

//控件显示、隐藏按钮
@property (nonatomic, strong) UIButton *showOrHideBtn;

#pragma mark - 中部控制视图容器
@property (nonatomic, strong) UIView *centerControlView;

//播放、暂停按钮
@property (nonatomic, strong) UIButton *playOrPauseBtn;

//加载动画
@property (nonatomic,strong) UIActivityIndicatorView *activityIndicatorView;

#pragma mark - 底部控制视图容器
@property (nonatomic, strong) UIView *bottomControlView;

//当前时间
@property (nonatomic,strong) UILabel *timeLabel;
//总时间
@property (nonatomic,strong) UILabel *totalTimeLabel;
//进度条
@property (nonatomic,strong) UISlider *slider;
//缓存进度条
@property (nonatomic,strong) UISlider *bufferSlider;
//全屏按钮
@property (nonatomic,strong) UIButton *fullScreenBtn;

//控制视图是否隐藏
@property (nonatomic, assign) BOOL isControlViewHide;

//定时隐藏控制视图
@property (nonatomic, strong) NSTimer *controlViewHideTimer;

@end

@implementation HXJPlayerControlView

#pragma mark - initial methods

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.clipsToBounds = YES;
        [self initView];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame delegate:(id<HXJPlayerControlViewDelegate>)delegate {
    if (self = [self initWithFrame:frame]) {
        self.delegate = delegate;
    }
    return self;
}

- (void)initView {
    [self addSubview:self.topControlView];
    
    [self addSubview:self.showOrHideBtn];
    
    [self addSubview:self.centerControlView];
    
    [self initBottomControlView];
    
    [self layoutIfNeeded];
}

- (void)initBottomControlView {
    [self.bottomControlView addSubview:self.timeLabel];
    [self.bottomControlView addSubview:self.totalTimeLabel];
    [self.bottomControlView addSubview:self.bufferSlider];
    [self.bottomControlView addSubview:self.slider];
    [self.bottomControlView addSubview:self.fullScreenBtn];
    [self addSubview:self.bottomControlView];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat width = self.frame.size.width;
    CGFloat height = self.frame.size.height;
    
    self.topControlView.frame = CGRectMake(0, 0, width, 30);
    self.titleLabel.frame = self.topControlView.bounds;
    
    CGFloat bottomControlViewHeight = 40;
    self.bottomControlView.frame = CGRectMake(0, height - bottomControlViewHeight, width, bottomControlViewHeight);
    [self layoutBottomControlView];
    
    self.showOrHideBtn.frame = CGRectMake(0, 0, width, height - self.bottomControlView.frame.size.height);
    self.centerControlView.center = CGPointMake(width/2, height/2);
    self.activityIndicatorView.center = CGPointMake(width/2, height/2);
}

- (void)layoutBottomControlView {
    CGFloat width = self.bottomControlView.frame.size.width;
    CGFloat height = self.bottomControlView.frame.size.height;
    CGFloat margin = 10;
    CGFloat startX = margin;
    CGFloat labelWidth = 50;
    CGFloat fullScreenBtnWidth = 30;
    CGFloat fullScreenBtnHeight = 23;
    
    CGRect rect = CGRectMake(startX, 0, labelWidth, height);
    
    self.timeLabel.frame = rect;
    
    startX += labelWidth + margin;
    rect.origin.x = startX;
    rect.origin.y = (height - self.slider.frame.size.height)/2;
    rect.size.width = width - startX - 3*margin - labelWidth - fullScreenBtnWidth;
    rect.size.height = self.slider.frame.size.height;
    
    self.slider.frame = rect;
    self.bufferSlider.frame = rect;
    
    startX += rect.size.width + margin;
    self.totalTimeLabel.frame = CGRectMake(startX, 0, labelWidth, height);
    
    startX += labelWidth + margin;
    rect.origin.x = startX;
    rect.origin.y = (height - fullScreenBtnHeight)/2;
    rect.size.width = fullScreenBtnWidth;
    rect.size.height = fullScreenBtnHeight;
    self.fullScreenBtn.frame = rect;
}

#pragma mark - setter and getter methods

- (UIView *)topControlView {
    if (!_topControlView) {
        _topControlView = [[UIView alloc]init];
        _topControlView.clipsToBounds = YES;
        
        UIView *backview = [[UIView alloc]init];
        backview.backgroundColor = UIColor.blackColor;
        backview.alpha = 0.4;
        backview.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        [_topControlView addSubview:backview];
        
        [_topControlView addSubview:self.titleLabel];
    }
    return _topControlView;
}

- (UIButton *)showOrHideBtn {
    if (!_showOrHideBtn) {
        _showOrHideBtn = [[UIButton alloc]init];
        [_showOrHideBtn addTarget:self action:@selector(showOrHideBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _showOrHideBtn;
}

- (UIView *)centerControlView {
    if (!_centerControlView) {
        CGRect rect = CGRectMake(0, 0, 64, 64);
        _centerControlView = [[UIView alloc]initWithFrame:rect];
        _centerControlView.clipsToBounds = YES;
        
        UIView *backview = [[UIView alloc]initWithFrame:rect];
        backview.backgroundColor = UIColor.blackColor;
        backview.alpha = 0.4;
        backview.layer.cornerRadius = 10;
        backview.clipsToBounds = YES;
        
        [_centerControlView addSubview:backview];
        [_centerControlView addSubview:self.playOrPauseBtn];
        [_centerControlView addSubview:self.activityIndicatorView];
    }
    return _centerControlView;
}

- (UIButton *)playOrPauseBtn {
    if (!_playOrPauseBtn) {
        _playOrPauseBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 64, 64)];
        
        [_playOrPauseBtn setImage:PlayerResourceImage(@"play") forState:UIControlStateNormal];
        [_playOrPauseBtn setShowsTouchWhenHighlighted:YES];
        [_playOrPauseBtn setImage:PlayerResourceImage(@"pause") forState:UIControlStateSelected];
        [_playOrPauseBtn addTarget:self action:@selector(playOrPauseBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _playOrPauseBtn;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc]init];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.font = [UIFont systemFontOfSize:15];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.numberOfLines = 1;
    }
    return _titleLabel;
}

- (UIActivityIndicatorView *)activityIndicatorView {
    if (!_activityIndicatorView) {
        _activityIndicatorView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        _activityIndicatorView.hidesWhenStopped = YES;
    }
    return _activityIndicatorView;
}

- (UIView *)bottomControlView {
    if (!_bottomControlView) {
        _bottomControlView = [[UIView alloc]init];
        _bottomControlView.clipsToBounds = YES;
        
        UIView *backview = [[UIView alloc]init];
        backview.backgroundColor = UIColor.blackColor;
        backview.alpha = 0.4;
        backview.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        [_bottomControlView addSubview:backview];
    }
    return _bottomControlView;
}

- (UILabel *)timeLabel {
    if (!_timeLabel) {
        _timeLabel = [[UILabel alloc]init];
        _timeLabel.textAlignment = NSTextAlignmentRight;
        _timeLabel.font = [UIFont systemFontOfSize:12];
        _timeLabel.textColor = [UIColor whiteColor];
        _timeLabel.text = @"00:00";
    }
    return _timeLabel;
}

- (UILabel *)totalTimeLabel {
    if (!_totalTimeLabel) {
        _totalTimeLabel = [[UILabel alloc]init];
        _totalTimeLabel.textAlignment = NSTextAlignmentLeft;
        _totalTimeLabel.font = [UIFont systemFontOfSize:12];
        _totalTimeLabel.textColor = [UIColor whiteColor];
        _totalTimeLabel.text = @"00:00";
    }
    return _totalTimeLabel;
}

-(UISlider *)slider{
    if (!_slider) {
        _slider = [[UISlider alloc]init];
        [_slider setThumbImage:PlayerResourceImage(@"current") forState:UIControlStateNormal];
        _slider.continuous = YES;
        _slider.maximumTrackTintColor = [UIColor clearColor];
        _slider.minimumTrackTintColor = [UIColor whiteColor];
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(sliderTapAction:)];
        [_slider addTarget:self action:@selector(sliderDragAction:) forControlEvents:UIControlEventValueChanged];
        [_slider addGestureRecognizer:tapGesture];
    }
    return _slider;
}

- (UIButton *)fullScreenBtn {
    if (!_fullScreenBtn) {
        _fullScreenBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _fullScreenBtn.contentMode = UIViewContentModeCenter;
        [_fullScreenBtn setImage:PlayerResourceImage(@"fullScreen") forState:UIControlStateNormal];
        [_fullScreenBtn addTarget:self action:@selector(fullScreenBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _fullScreenBtn;
}
- (UISlider *)bufferSlider{
    if (!_bufferSlider) {
        _bufferSlider = [[UISlider alloc]init];
        [_bufferSlider setThumbImage:[UIImage new] forState:UIControlStateNormal];
        _bufferSlider.continuous = YES;
        _bufferSlider.minimumTrackTintColor = [UIColor lightGrayColor];
        _bufferSlider.maximumTrackTintColor = [UIColor clearColor];
        _bufferSlider.minimumValue = 0.f;
        _bufferSlider.maximumValue = 1.f;
        _bufferSlider.userInteractionEnabled = NO;
    }
    return _bufferSlider;
}

- (void)setTitle:(NSString *)title {
    _title = title;
    self.titleLabel.text = title;
}

- (void)setValue:(CGFloat)value {
    self.slider.value = value;
}

- (CGFloat)value {
    return self.slider.value;
}

- (void)setBufferValue:(CGFloat)bufferValue {
    self.bufferSlider.value = bufferValue;
}

- (CGFloat)bufferValue {
    return self.bufferSlider.value;
}

- (void)setMinValue:(CGFloat)minValue {
    _minValue = minValue;
    self.slider.minimumValue = minValue;
}

- (void)setMaxValue:(CGFloat)maxValue {
    _maxValue = maxValue;
    self.slider.maximumValue = maxValue;
}

- (void)setCurrentTime:(NSString *)currentTime {
    _currentTime = currentTime;
    self.timeLabel.text = currentTime;
}

- (void)setTotalTime:(NSString *)totalTime {
    _totalTime = totalTime;
    self.totalTimeLabel.text = totalTime;
}

- (void)setIsPlaying:(BOOL)isPlaying {
    _isPlaying = isPlaying;
    self.playOrPauseBtn.selected = isPlaying;
    [self showOrHideControlView:!isPlaying];
}

- (void)setIsControlViewHide:(BOOL)isControlViewHide {
    _isControlViewHide = isControlViewHide;
    
    if (!isControlViewHide) {
        [self adjustControlViewHide];
    }
    
    self.topControlView.hidden = isControlViewHide;
    self.centerControlView.hidden = isControlViewHide;
    self.bottomControlView.hidden = isControlViewHide;
    
    if (isControlViewHide) {
        [self adjustControlViewHide];
    }
}

- (void)adjustControlViewHide {
    CGRect rect = self.topControlView.frame;
    rect.origin.x = 0;
    rect.origin.y = 0 - rect.size.height;
    self.topControlView.frame = rect;
    
    self.centerControlView.alpha = 0;
    
    rect = self.bottomControlView.frame;
    rect.origin.x = 0;
    rect.origin.y = self.bottomControlView.superview.frame.size.height;
    self.bottomControlView.frame = rect;
}

#pragma mark - slider actions methods
- (void)sliderTapAction:(UITapGestureRecognizer *)gesture {
    CGPoint point = [gesture locationInView:self.slider];
    CGFloat pointX = point.x;
    CGFloat sliderWidth = self.slider.frame.size.width;
    CGFloat currentValue = pointX/sliderWidth * self.slider.maximumValue;
    if ([self.delegate respondsToSelector:@selector(playerControlView:seekTimeWithValue:)]) {
        [self.delegate playerControlView:self seekTimeWithValue:currentValue];
    }
}

- (void)sliderDragAction:(UISlider *)slider {
    if ([self.delegate respondsToSelector:@selector(playerControlView:seekTimeWithValue:)]) {
        [self.delegate playerControlView:self seekTimeWithValue:slider.value];
    }
}

#pragma mark - full screen button clicked method
- (void)fullScreenBtnClicked:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(playerControlView:fullScreenBtnClicked:)]) {
        [self.delegate playerControlView:self fullScreenBtnClicked:sender];
    }
}

#pragma mark - show or hide control button clicked method
- (void)showOrHideBtnClicked:(UIButton *)sender {
    [self showOrHideControlView:self.isControlViewHide];
}

- (void)showOrHideControlView:(BOOL)shouldShow {
    @synchronized (@(self.isControlViewHide)) {
        
        self.centerControlView.userInteractionEnabled = NO;
        self.bottomControlView.userInteractionEnabled = NO;
        self.showOrHideBtn.enabled = NO;
        
        NSTimeInterval duration = 0.5;
        if (!shouldShow && !self.isControlViewHide) {
            [UIView animateWithDuration:duration animations:^{
                CGRect rect = self.bottomControlView.frame;
                rect.origin.y += rect.size.height;
                self.bottomControlView.frame = rect;
                
                rect = self.topControlView.frame;
                rect.origin.y -= rect.size.height;
                self.topControlView.frame = rect;
                
                self.centerControlView.alpha = 0;
            } completion:^(BOOL finished) {
                self.isControlViewHide = YES;
                [self.controlViewHideTimer invalidate];
            }];
        }else if (self.isControlViewHide) {
            self.isControlViewHide = NO;
            [UIView animateWithDuration:duration animations:^{
                CGRect rect = self.bottomControlView.frame;
                rect.origin.y -= rect.size.height;
                self.bottomControlView.frame = rect;
                
                rect = self.topControlView.frame;
                rect.origin.y += rect.size.height;
                self.topControlView.frame = rect;
                
                self.centerControlView.alpha = 1;
            } completion:^(BOOL finished) {
                
                [self resetControlViewHideTimer];
            }];
        }
        self.bottomControlView.userInteractionEnabled = YES;
        self.centerControlView.userInteractionEnabled = YES;
        self.showOrHideBtn.enabled = YES;
    }
}

- (void)resetControlViewHideTimer {
    [self.controlViewHideTimer invalidate];
    self.controlViewHideTimer = [NSTimer scheduledTimerWithTimeInterval:5
                                                                repeats:NO
                                                                  block:^(NSTimer * _Nonnull timer)
     {
         if (self.isPlaying) [self showOrHideControlView:NO];         
     }];
}

#pragma mark - 播放/暂停按钮点击事件
- (void)playOrPauseBtnClicked:(UIButton *)sender {
    sender.selected = !sender.isSelected;
    if (self.delegate && [self.delegate respondsToSelector:@selector(playerControlView:playOrPauseBtnClicked:)]) {
        [self.delegate playerControlView:self playOrPauseBtnClicked:sender];
    }
}

#pragma mark - 加载视图
- (void)showLoadingView {
    if (!self.activityIndicatorView.isAnimating) {
        self.playOrPauseBtn.hidden = YES;
        self.activityIndicatorView.hidden = NO;
        [self.activityIndicatorView startAnimating];
    }
}

- (void)hideLoadingView {
    [self.activityIndicatorView stopAnimating];
    self.activityIndicatorView.hidden = YES;
    self.playOrPauseBtn.hidden = NO;
}

#pragma mark - dealloc
- (void)dealloc {
    [self.controlViewHideTimer invalidate];
    self.controlViewHideTimer = nil;
}
@end
