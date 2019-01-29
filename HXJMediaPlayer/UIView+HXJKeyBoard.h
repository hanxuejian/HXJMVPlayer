//
//  UIView+HXJKeyBoard.h
//  HXJMediaPlayer
//
//  Created by han on 2019/1/28.
//  Copyright © 2019年 han. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIView (HXJKeyBoard)

///返回视图是否被键盘遮盖，若是，offset 的值表示视图要避免遮盖的位移量
- (BOOL)isCoveredByBoard:(CGRect)keyboardRect offset:(CGFloat *)offset;

///计算的遮盖值 offset 要忽略 ignoreOffset 值，传 0 默认忽略 iPhone X 底部高度值
///这是因为在 iPhone X 设备中，底部视图高度包含了设备底部虚拟按钮，所以随键盘上移时，并不想其显示
- (BOOL)isCoveredByBoard:(CGRect)keyboardRect offset:(CGFloat *)offset ignoreOffset:(CGFloat)ignoreOffset;

///判断当前视图是否被其他视图遮盖
- (BOOL)isCoveredByView:(UIView *)view offset:(CGFloat *)offset;

///是否可见
- (BOOL)isViewVisiable;

///添加键盘收起事件
- (void)addGestureHideKeyboard:(UIView *)shouldendEditingView;

/**
 注册键盘变化事件，如果当前控件被遮盖，则作出相应的移动
 @param shouldMovedView 键盘变化时，应该移动的控件，如果为 nil ，则默认为当前控件移动
 */
- (void)registerKeyboardChangeNotification:(UIView *)shouldMovedView;

@end

NS_ASSUME_NONNULL_END
