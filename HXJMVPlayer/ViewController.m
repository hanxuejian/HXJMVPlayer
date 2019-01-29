//
//  ViewController.m
//  HXJMVPlayer
//
//  Created by han on 2019/1/16.
//  Copyright © 2019年 han. All rights reserved.
//

#import "ViewController.h"
#import <HXJMediaPlayer/HXJPlayerView.h>

@interface ViewController () <HXJPlayerViewDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.blueColor;
    
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 100, 500, 400)];
    view.backgroundColor = UIColor.redColor;
    [self.view addSubview:view];
    
    NSURL *url = [NSURL URLWithString:@"https://file.mayiangel.com/videoProjectPath/015.mp4"];
    HXJPlayerView *playerView = [[HXJPlayerView alloc]initWithUrl:url];
    playerView.delegate = self ;
    playerView.frame = CGRectMake(0, 10, 375, 400);
    playerView.title = @"test";
    
    [view addSubview:playerView];
}

- (BOOL)isShouldAutoPlayWhenReadyToPlay {
    return YES;
}

@end
