//
// Created by 高橋啓治郎 on 11/1/1.
// Copyright 2011 iOS 4 プログラミングブック. All rights reserved.
//

#import <UIKit/UIKit.h>

@class XfadingViewController;

@interface XfadingAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    XfadingViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet XfadingViewController *viewController;

@end

