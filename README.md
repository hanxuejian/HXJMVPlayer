# 播放器

使用苹果官方的 **AVFoundation** 框架，可以很容易的封装一个视频的播放器。

在获取视频资源后，只需要将视频在播放图层中渲染即可，并且可以在图层中添加控件，以便对视频的播放和暂停进行控制。

下面封装的库，主要包含两个类 **HXJPlayerView** 和 **HXJPlayerControlView** 。但是，在具体使用时，只需要使用 HXJPlayerView 类，创建一个播放视图即可。

## HXJPlayerView
使用该类时，需要先获取视频资源的地址，进而用该地址作为参数初始化一个播放器实例对象。

```
- (instancetype)initWithUrl:(NSURL *)url;
```

该类中提供了视频播放、暂停、终止的控制方法，可以根据需要进行调用。

该类中还提供了一些只读属性，用来获取视频的当前状态，如是否播放中、播放速率、是否全屏播放等。

另外，其还提供了一个 **title** 属性，用来设置播放器的标题。

重要的是其定义了一个遵循 **HXJPlayerViewDelegate** 协议的代理，实现协议中的方法，可以进行一些操作。

### HXJPlayerViewDelegate
该协议中定义了一些方法，提供了一些响应视频操作的机会。

1. 视频加载到可以播放时，默认并不会自动播放，但是使用下面的方法，可以将视频设置为自动播放的。

	```
	- (BOOL)isShouldAutoPlayWhenReadyToPlay;
	```

2. 在获取到视频资源信息后，默认会根据视频的大小尺寸，等比例调整播放器的大小尺寸，并且默认是以屏幕的宽度为基准的。但是下面的方法可以禁止调整播放器的尺寸，或者自定义调整的宽度和高度。

	```
	- (BOOL)isShouldRefreashViewAccordingVideoNaturalSize;
	```
	
	上面的方法返回 YES，下面的两个方法才有意义。
	
	```
	- (CGFloat)widthWhenRefreashViewAccordingVideoNatureSize;
	- (CGFloat)heightWhenRefreashViewAccordingVideoNatureSize;
	```
	这两个方法只实现一个时，视频的调整都是和原尺寸等比例的，但是如果都进行了自定义，那么尺寸未必会保持等比。

3. 视频的大小如果进行了调整，即 **isShouldRefreashViewAccordingVideoNaturalSize** 协议方法返回了 YES ，那么便会返回调整后的视频播放尺寸。

	```
	- (void)didRefreashedViewAccordingVideoNatureSize:(CGSize)size;
	```
	当然，如果需要用这个尺寸调整播放器父视图与播放器大小尺寸一致，那么可以直接令下面的方法返回 YES 。
	
	```
	- (BOOL)isShouldRefreashSuperViewSize;
	```

4. 其他诸如视频将要播放、进入全屏、退出全屏等方法如下。

	```
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
	```

## HXJPlayerControlView
该类是控制视图，其封装了播放按钮、进度条、播放时间等控件，类似的，其也拥有一个代理，该代理需要遵循 **HXJPlayerControlViewDelegate** 协议，该协议中的方法会在播放器控制操作发生时执行。

这个代理对象实际就是 HXJPlayerView 实例对象，其负责处理视频的播放、暂停、全屏等操作。

[具体的实现可以参见源码](https://github.com/hanxuejian/HXJMVPlayer)。
