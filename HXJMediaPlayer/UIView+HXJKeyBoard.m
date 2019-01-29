//
//  UIView+HXJKeyBoard.m
//  HXJMediaPlayer
//
//  Created by han on 2019/1/28.
//  Copyright © 2019年 han. All rights reserved.
//

#import "UIView+HXJKeyBoard.h"
#import <objc/runtime.h>
#import "HXJMetaMacros.h"

@implementation UIView (HXJKeyBoard)

#pragma mark 判断当前视图是否被键盘遮盖
- (BOOL)isCoveredByBoard:(CGRect)keyboardRect offset:(CGFloat *)offset {
    if (!self) {
        return NO;
    }
    if (![self superview]) {
        return NO;
    }
    if (self.hidden) {
        return NO;
    }
    UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
    NSArray *windows = [[UIApplication sharedApplication] windows];
    UIWindow *keyboardWindow;
    for (id window in windows) {
        
        NSString *keyboardWindowString = NSStringFromClass([window class]);
        if ([keyboardWindowString isEqualToString:@"UITextEffectsWindow"]) {
            keyboardWindow = window;
            break;
        }
    }
    if (keyboardWindow == nil) return NO;
    
    keyboardRect = [keyboardWindow convertRect:keyboardRect toWindow:keyWindow];
    CGRect rect = [self.superview convertRect:self.frame toView:keyWindow];
    if (CGRectIsEmpty(rect) || CGRectIsNull(rect) || CGSizeEqualToSize(rect.size, CGSizeZero)) {
        return NO;
    }
    CGFloat heightOfCovered = keyboardRect.origin.y - rect.origin.y - rect.size.height;
    heightOfCovered = heightOfCovered > -keyboardRect.size.height ? heightOfCovered : -keyboardRect.size.height;
    
    *offset = heightOfCovered;
    return CGRectIntersectsRect(rect, keyboardRect);
}

- (BOOL)isCoveredByBoard:(CGRect)keyboardRect offset:(CGFloat *)offset ignoreOffset:(CGFloat)ignoreOffset {
    BOOL isCover = [self isCoveredByBoard:keyboardRect offset:offset];
    if (ignoreOffset == 0) ignoreOffset = SafeBottomAreaHeight;
    *offset = *offset + ignoreOffset;
    return isCover;
}

#pragma mark 判断当前视图是否被其他视图遮盖
- (BOOL)isCoveredByView:(UIView *)view offset:(CGFloat *)offset {
    if (!self || !view) {
        return NO;
    }
    if (![self superview]) {
        return NO;
    }
    if (self.hidden || view.hidden) {
        return NO;
    }
    UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
    
    CGRect viewRect;
    if([view isKindOfClass:[UIWindow class]]){
        viewRect = [(UIWindow*)view convertRect:view.frame toWindow:keyWindow];
    }else {
        viewRect = [view.superview convertRect:view.frame toView:keyWindow];
    }
    
    CGRect rect = [self.superview convertRect:self.frame toView:keyWindow];
    rect.origin.y -= SafeAreaTopHeight;
    if (CGRectIsEmpty(rect) || CGRectIsNull(rect) || CGSizeEqualToSize(rect.size, CGSizeZero)) {
        return NO;
    }
    CGFloat heightOfCovered = viewRect.origin.y - rect.origin.y - rect.size.height;
    heightOfCovered = heightOfCovered > -viewRect.size.height ? heightOfCovered : -viewRect.size.height;
    
    *offset = heightOfCovered;
    return CGRectIntersectsRect(rect, viewRect);
    
}

- (BOOL)isViewVisiable {
    UIWindow *keyWindow = [[UIApplication sharedApplication]keyWindow];
    CGFloat offset;
    return [self isCoveredByView:keyWindow offset:&offset];
}

const void *shouldendEditingViewKey = &shouldendEditingViewKey;
- (void)addGestureHideKeyboard:(UIView *)shouldendEditingView {
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(resignKeyBoard:)];
    self.userInteractionEnabled = YES;
    [self addGestureRecognizer:tap];
    objc_setAssociatedObject(self, shouldendEditingViewKey, shouldendEditingView, OBJC_ASSOCIATION_ASSIGN);
}

- (void)resignKeyBoard:(UITapGestureRecognizer *)tap {
    UIView *view = objc_getAssociatedObject(self, shouldendEditingViewKey);
    if (view == nil) view = self;
    [view endEditing:YES];
}

#pragma mark - 注册键盘显示及隐藏事件
const void *shouldMovedViewKey = &shouldMovedViewKey;
const void *shouldMovedViewOriginFrameKey = &shouldMovedViewOriginFrameKey;
const void *shouldMovedViewContentOffsetKey = &shouldMovedViewContentOffsetKey;

- (void)registerKeyboardChangeNotification:(UIView *)shouldMovedView {
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardWillChange:) name:UIKeyboardWillChangeFrameNotification object:nil];
    
    objc_setAssociatedObject(self, shouldMovedViewKey, shouldMovedView, OBJC_ASSOCIATION_ASSIGN);
    
}

#pragma mark - 键盘显示
- (void)keyboardWillChange:(NSNotification *)notification {
    if (!self.isFirstResponder) return;
    CGRect keyboardBeginFrame = [[notification.userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    CGRect keyboardEndFrame = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    UIView *view = objc_getAssociatedObject(self, shouldMovedViewKey);
    if (view == nil) view = self;
    
    CGFloat viewBottom = [UIScreen mainScreen].bounds.size.height;
    
    BOOL isShow = keyboardBeginFrame.origin.y >= viewBottom;
    
    if (isShow) {
        if ([view isKindOfClass:[UIScrollView class]]) {
            UIScrollView *scrollView = (UIScrollView *)view;
            objc_setAssociatedObject(self, shouldMovedViewContentOffsetKey, @(scrollView.contentOffset), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }else {
            objc_setAssociatedObject(self, shouldMovedViewOriginFrameKey, @(view.frame), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }
    }
    
    BOOL isHide = keyboardEndFrame.origin.y >= viewBottom;
    
    //键盘隐藏
    if (isHide) {
        if ([view isKindOfClass:[UIScrollView class]]) {
            UIScrollView *scrollView = (UIScrollView *)view;
            CGPoint point = [objc_getAssociatedObject(self, shouldMovedViewContentOffsetKey) CGPointValue];
            [scrollView setContentOffset:point animated:YES];
        }else {
            CGRect rect = [objc_getAssociatedObject(self, shouldMovedViewOriginFrameKey) CGRectValue];
            view.frame = rect;
        }
        return;
    }
    
    //键盘变化
    CGFloat offset;
    if ([self isCoveredByBoard:keyboardEndFrame offset:&offset]) {
        if ([view isKindOfClass:[UIScrollView class]]) {
            UIScrollView *scrollView = (UIScrollView *)view;
            offset = scrollView.contentOffset.y - offset + 10;
            [scrollView setContentOffset:CGPointMake(0, offset) animated:YES];
        }else {
            CGRect rect = view.frame;
            rect.origin.y += offset - 10;
            view.frame = rect;
        }
    }
}

@end
