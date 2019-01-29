//
//  HXJMetaMacros.h
//  HXJMVPlayer
//
//  Created by han on 2019/1/28.
//  Copyright © 2019年 han. All rights reserved.
//

#ifndef HXJMetaMacros_h
#define HXJMetaMacros_h

#define WindowFrameWidth [[UIApplication sharedApplication] keyWindow].frame.size.width
#define WindowFrameHeight [[UIApplication sharedApplication] keyWindow].frame.size.height

#define iPhoneXBottomMargin 34

#define SafeAreaTopHeight (WindowFrameHeight == 812.0 ? 88 : 64)

#define SafeBottomAreaHeight (WindowFrameHeight == 812.0 ? 34 : 0)

#define SafeAreaStartY  (WindowFrameHeight == 812.0 ? 44 : 0)

#define keypath(OBJ, PATH) \
(((void)(NO && ((void)OBJ.PATH, NO)), # PATH))

///获取资源包中指定的图片资源
#define PlayerResourceImage(imageName) [UIImage imageWithContentsOfFile:PlayerResourcesImagePath(imageName)]

///获取资源包中指定的图片资源路径
#define PlayerResourcesImagePath(imageName) [PlayerResourcesBundle pathForResource:imageName ofType:@"png" inDirectory:@"pictures"]

///获取资源包
#define PlayerResourcesBundle [NSBundle bundleWithPath:[[NSBundle mainBundle]pathForResource:@"resources" ofType:@"bundle"]]


#endif /* HXJMetaMacros_h */
